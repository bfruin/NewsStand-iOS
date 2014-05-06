//
//  ViewController.m
//  NewsStand
//
//  Created by Brendan on 12/29/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"
#import "ViewControllerRequestOperation.h"
#import "SettingsViewController.h"
#import "SourcesViewController.h"
#import "NewsAnnotationView.h"
#import "TopStoriesViewController.h"
#import "UIImageResizing.h"
#import "ImageViewer.h"
#import "DetailViewController.h"
#import "JMImageCache.h"
#import "TopStoriesRequestOperation.h"
#import "RequestQueue.h"
#import "SimulatorLocationRequestOperation.h"
#import "GetFeaturedFeeds.h"
#import "SourcesNumDocs.h"
#import "PrefetchRequestOperation.h"


#import "UIDevice-ORMMA.h"
#import "MKMapView+ZoomLevel.h"

//For Simulator Location
#import <ifaddrs.h>
#import <arpa/inet.h>


#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

static BOOL first = TRUE;
static BOOL markerCheck = TRUE;

static BOOL viewDidUnload = FALSE;

@implementation ViewController

@synthesize mapView;
@synthesize annotations;
@synthesize isPad, hasInet;
@synthesize topTabBar, botTabBar;
@synthesize refreshButton, plusButton, minusButton;
@synthesize activityIndicator;
@synthesize modeLabel, searchLabel, sourceButton, searchCancelButton, sourceCancelButton;
@synthesize generalImage, businessImage, healthImage, sciTechImage, entertainmentImage, sportsImage;
@synthesize locationFont;
@synthesize layerSelected, topics, topicsSelected, imageFilterSelected, videoFilterSelected, handMode, searchKeyword;
@synthesize allSources, feedSources, countrySources, boundSources, sourcesSelected, languageSources;
@synthesize languagesSelected, sourceDisplayed, numSourcesSelected;
@synthesize standMode;
@synthesize botFirstItem, botSecondItem, botThirdItem, botFourthItem, botFifthItem, botSixthItem;
@synthesize motionManager, automaticHandMode;
@synthesize portraitFirst, topStoriesAnnotations;
@synthesize geocoder;
@synthesize locateAlertView, searchAlertView;
@synthesize URLrequest, queue, currentRequestID;
@synthesize padDetailViewController;
@synthesize blackButton;
@synthesize simulatorLat, simulatorLon, simulatorQueue;

static NSString * const GMAP_ANNOTATION_SELECTED = @"gMapAnnotationSelected";
static float MOTION_SCALE = 5.0;

- (void)didReceiveMemoryWarning
{
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - Settings
- (void) initializeSettings
{
    topicsSelected = [[NSMutableArray alloc] init];
    [topicsSelected addObject:[NSNumber numberWithBool:YES]];
    for (int i = 0; i < 6; i++)
        [topicsSelected addObject:[NSNumber numberWithBool:NO]];
    
    imageFilterSelected = 0;
    videoFilterSelected = 0;
    
    standMode = 0;
    [modeLabel setText:@"NewsStand"];
    
    topics = [[NSMutableArray alloc] init];
    [topics addObject:@"All"];
    [topics addObject:@"General"];
    [topics addObject:@"Business"];
    [topics addObject:@"SciTech"];
    [topics addObject:@"Entertainment"];
    [topics addObject:@"Health"];
    [topics addObject:@"Sports"];
    
    lastSliderValue = mapSlider.value;
}



- (void)initImagesAndFonts 
{
    generalImage = [[UIImage imageNamed:@"General.gif"] scaleToSize:CGSizeMake(25.0, 25.0)];
    businessImage = [[UIImage imageNamed:@"Business.gif"] scaleToSize:CGSizeMake(25.0, 25.0)];
    healthImage = [[UIImage imageNamed:@"Health.png"] scaleToSize:CGSizeMake(25.0, 25.0)];
    sciTechImage = [[UIImage imageNamed:@"SciTech.gif"] scaleToSize:CGSizeMake(25.0, 25.0)];
    entertainmentImage = [[UIImage imageNamed:@"Entertainment.gif"] scaleToSize:CGSizeMake(25.0, 25.0)];
    sportsImage = [[UIImage imageNamed:@"Sports.png"] scaleToSize:CGSizeMake(25.0, 25.0)];
    
    locationFont = [UIFont boldSystemFontOfSize:20.0];
    
    [activityIndicator setColor:[UIColor blackColor]];
    [activityIndicator setHidesWhenStopped:YES];
    activityIndicator.hidden = YES;
}

- (void) initializeViewDidUnload
{
    [activityIndicator setColor:[UIColor blackColor]];
    [activityIndicator setHidesWhenStopped:YES];
    activityIndicator.hidden = YES;
    
    isPad = ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad);
}


- (NSString *)getTopicString 
{
    if ([[topicsSelected objectAtIndex:0] boolValue])
        return @"";

    NSString *topicsParam = @"&cat=";
    bool first = TRUE;

    for (int i = 1; i < [topicsSelected count]; i++) {
        if ([[topicsSelected objectAtIndex:i] boolValue]) {
            if (first)
                topicsParam = [topicsParam stringByAppendingString:[NSString stringWithFormat:@"%@", [topics objectAtIndex:i]]];
            else {
                topicsParam = [topicsParam stringByAppendingString:[NSString stringWithFormat:@",%@", [topics objectAtIndex:i]]];
            }
            first = false;
        }
    }
    
    return topicsParam;
}

- (NSString *)settingsParamString
{
    NSString *paramString = @"";
    
    //Layer
    if (layerSelected != iconLayer || layerSelected != locationLayer) {
        if (layerSelected == keywordLayer)
            paramString = @"&layer=0";
        else if (layerSelected == peopleLayer)
            paramString = @"&layer=1";
        else if (layerSelected == diseaseLayer)
            paramString = @"&layer=2";
    }
    
    //Topics
    paramString = [paramString stringByAppendingString:[self getTopicString]];
    
    //Image & Video Filters
    if (imageFilterSelected != 0) 
        if (imageFilterSelected == 1)
            paramString = [paramString stringByAppendingString:@"&num_images=1"];
        else if (imageFilterSelected == 2)
            paramString = [paramString stringByAppendingString:@"&num_images=10"];
        else
            paramString = [paramString stringByAppendingString:@"&num_images=50"];
    if (videoFilterSelected != 0)
        if (videoFilterSelected == 1)
            paramString = [paramString stringByAppendingString:@"&num_videos=1"];
        else if (videoFilterSelected == 2)
            paramString = [paramString stringByAppendingString:@"&num_videos=5"];
        else 
            paramString = [paramString stringByAppendingString:@"&num_videos=10"];
    
    if (searchKeyword != nil && ![searchKeyword isEqualToString:@""]) {
        paramString = [paramString stringByAppendingString:[NSString stringWithFormat:@"&search=%@", searchKeyword]];
    }
    
    return paramString;
}

-(IBAction)searchCancelButtonPushed:(id)sender
{
    searchKeyword = @"";
    [[searchAlertView textFieldAtIndex:0] setText:@""];
    [self refreshMap];
    [searchLabel setHidden:YES];
    [searchCancelButton setHidden:YES];
}

- (void) disableItemsForStandMode
{
    if (standMode == 0) {
        [botFirstItem setEnabled:TRUE];
        [botThirdItem setEnabled:TRUE];
        [botFourthItem setEnabled:TRUE];
        [botSixthItem setEnabled:TRUE];
    } else if (standMode == 1) {
        if (handMode != 3) {
            [botThirdItem setEnabled:TRUE];
            [botFourthItem setEnabled:FALSE];
        } else {
            [botThirdItem setEnabled:FALSE];
            [botFourthItem setEnabled:TRUE];
        }
    } else if (standMode >= 2) {
        if (standMode == 2) {
            if (handMode != 3) {
                [botFourthItem setEnabled:TRUE];
            } else {
                [botThirdItem setEnabled:TRUE];
            }
        } else {
            if (handMode != 3) {
                [botThirdItem setEnabled:TRUE];
                [botFourthItem setEnabled:FALSE];
            } else {
                [botThirdItem setEnabled:FALSE];
                [botFourthItem setEnabled:TRUE];
            }
        }
        
        if (handMode != 3) {
            [botFirstItem setEnabled:TRUE];
            [botSixthItem setEnabled:FALSE];
        } else {
            [botFirstItem setEnabled:FALSE];
            [botSixthItem setEnabled:TRUE];
        }
    } 
    
}

#pragma mark - Tab Bar Delegate Functions

// Automatically called when a tab bar item is selected on either the top or bottom tab bar.
- (void) tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    if (tabBar == topTabBar) {
        if (item.tag == 0) {  // Home button selected
            [self homeItemPushed];
        } else if (item.tag == 1) {
            [self localItemPushed];
        } else if (item.tag == 2) {
            [self worldItemPushed];
        } else { 
            [self locateItemPushed];
        }
    } else {
        if (item.tag == 0) {
            if (handMode != 3)
                [self infoItemPushed];
            else
                [self topStoriesItemPushed];
        } else if (item.tag == 1) {
            if (handMode != 3) 
                [self searchItemPushed];
            else
                [self modeItemPushed];
        } else if (item.tag == 2) {
            if (handMode != 3) 
                [self settingsItemPushed];
            else
                [self sourcesItemPushed];
        } else if (item.tag == 3) {
            if (handMode != 3) 
                [self sourcesItemPushed];
            else 
                [self settingsItemPushed];
        } else if (item.tag == 4) {
            if (handMode != 3) 
                [self modeItemPushed];
            else
                [self searchItemPushed];
        } else if (item.tag == 5) {
            if (handMode != 3)
                [self topStoriesItemPushed];
            else
                [self infoItemPushed];
        }
    }
}

#pragma mark - Top Tab Bar

- (void) homeItemPushed 
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    
    region.center.latitude = [prefs floatForKey:@"homeCenterLat"];
    region.center.longitude = [prefs floatForKey:@"homeCenterLon"];
    span.latitudeDelta = [prefs floatForKey:@"homeLatDelta"];
    span.longitudeDelta = [prefs floatForKey:@"homeLonDelta"];
    
    region.span = span;
    
    if (span.latitudeDelta != 0.0)
        [mapView setRegion:region animated:!first];
    else
        [self worldItemPushed];
    
}

- (void)localItemPushed
{
    #if TARGET_IPHONE_SIMULATOR
        CLLocation *location = [[CLLocation alloc] initWithLatitude:simulatorLat longitude:simulatorLon];
        CLLocationCoordinate2D coord = location.coordinate;
    
        currentSpan = .03;
        MKCoordinateSpan span = MKCoordinateSpanMake(currentSpan, currentSpan);
        MKCoordinateRegion region;
        region.span = span;
    
        CLLocationCoordinate2D center;
        center.latitude = coord.latitude;
        center.longitude = coord.longitude;
    
        region.center = center;
    
        checkForMarker = TRUE;
        [mapView setRegion:region animated:YES];
        return;
    #endif


    //Location Services Not Enabled
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
        UIAlertView *enabledAlertView = [[UIAlertView alloc] initWithTitle:@"" message:@"Location services not currently enabled. Please enable Location Services for NewsStand in System Settings." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [enabledAlertView show];
    } else {
        NSLog(@"Location services enabled");
        mapView.showsUserLocation = YES;
    
        MKUserLocation *userLocation = mapView.userLocation;
        CLLocation *location = userLocation.location;
        CLLocationCoordinate2D coord = location.coordinate;
    
        if (coord.latitude < .0001 && coord.latitude > -.0001 &&
            coord.longitude < .001 && coord.longitude > -.001) {
            NSLog(@"User location detected at (0,0) going to try to get location from IP");
            location = [[CLLocation alloc] initWithLatitude:simulatorLat longitude:simulatorLon];
            coord = location.coordinate;
            if (coord.latitude < .0001 && coord.latitude > -.0001 &&
                coord.longitude < .001 && coord.longitude > -.001) {
                return; //Do nothing
            }
        }
        
        currentSpan = .03;
        MKCoordinateSpan span = MKCoordinateSpanMake(currentSpan, currentSpan);
        MKCoordinateRegion region;
        region.span = span;
    
        CLLocationCoordinate2D center;
        center.latitude = coord.latitude;
        center.longitude = coord.longitude;
    
        region.center = center;
    
        checkForMarker = TRUE;
        [mapView setRegion:region animated:YES];
    }
}

-(IBAction)mapSliderChangedValue:(id)sender
{
    int i = 0;
    int max = (int)(mapSlider.value * annotations.count + 1);
    int lastMax = (int)(lastSliderValue * annotations.count + 1);
    
    lastSliderValue = mapSlider.value;
    
    while (i < annotations.count) {
        if (i <= lastMax) {
            [mapView addAnnotation:[annotations objectAtIndex:i]];
            [[annotations objectAtIndex:i] setDisplayed:YES];
        } else if (i > max) {
            [mapView removeAnnotation:[annotations objectAtIndex:i]];
            [[annotations objectAtIndex:i] setDisplayed:NO];
        }
        
        i+=1;
    }
}

- (void) worldItemPushed 
{
    NSLog(@"Display world");
    
    if (!isPad) {
        if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
            MKCoordinateSpan span = MKCoordinateSpanMake(115.00, 115.000);
            MKCoordinateRegion region;
            region.span = span;
            
            CLLocationCoordinate2D center;
            center.latitude = 20.000;
            center.longitude = -20.000;
            region.center = center;
            [mapView setRegion:region animated:!first];                                        
        } else {
			MKCoordinateSpan span = MKCoordinateSpanMake(111.696806, 337.50);
			MKCoordinateRegion region;
			region.span = span;
			
			CLLocationCoordinate2D center;
			center.latitude = 21.289374;
			center.longitude = 11.25;
			region.center = center;
			[mapView setRegion:region animated:!first];
		}
    } else {
        if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
            MKCoordinateSpan span = MKCoordinateSpanMake(164.8634, 270.0000);
            MKCoordinateRegion region;
            region.span = span;
            
            CLLocationCoordinate2D center;
            center.latitude = 20.3;
            center.longitude = 12.3;
            region.center = center;
            [mapView setRegion:region animated:!first]; 
        } else {
            MKCoordinateSpan span = MKCoordinateSpanMake(145.836988, 360.0000);
			MKCoordinateRegion region;
			region.span = span;
			
			CLLocationCoordinate2D center;
			center.latitude = 25.48;
			center.longitude = 0.00;
			region.center = center;
			[mapView setRegion:region animated:!first];
        }
    }
}

- (void) locateItemPushed
{
    if (locateAlertView == nil) {
        locateAlertView = [[UIAlertView alloc] initWithTitle:@"Enter location to find" message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Locate", nil];
        locateAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;
        [[locateAlertView textFieldAtIndex:0] setClearButtonMode:UITextFieldViewModeWhileEditing];
    }
    
    [locateAlertView setTitle:@"Enter location to find"];
    [locateAlertView show];
}


#pragma mark - Bottom Tab Bar

- (void) infoItemPushed
{
    CustomWebView *customWebView = [[CustomWebView alloc] initWithString:@"http://www.cs.umd.edu/~hjs/newsstand-first-page.html" andTitle:@"Info"];
    [self.navigationController pushViewController:customWebView animated:YES];
}

-(void) searchItemPushed
{
    if (searchAlertView == nil) {
        searchAlertView = [[UIAlertView alloc] initWithTitle:@"Enter a search keyword" message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Search", nil];
        searchAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;
        [[searchAlertView textFieldAtIndex:0] setClearButtonMode:UITextFieldViewModeWhileEditing];
    }
    [searchAlertView show];
}

- (void) settingsItemPushed
{
    SettingsViewController *settingsViewController = [[SettingsViewController alloc] init];
    [self.navigationController pushViewController:settingsViewController animated:YES];
}

- (void) sourcesItemPushed
{
    SourcesViewController *sourcesViewController = [[SourcesViewController alloc] init];
    [self.navigationController pushViewController:sourcesViewController animated:YES];
}

-(void) modeItemPushed
{
    static BOOL sourceCancelBefore = TRUE;
    UITabBarItem *modeItem;
    
    if (handMode != 3) {
        modeItem = botFifthItem;
    } else {
        modeItem = botSecondItem;
    }
    
    if (standMode == 0) { // In NewsStand switching to TwitterStand
        [modeItem setTitle:@"PhotoStand"];
        [modeItem setImage:[UIImage imageNamed:@"camera.png"]];
        [modeLabel setText:@"TwitterStand"];
        [sourceButton setHidden:YES]; //Disabled for TwitterStand
        sourceCancelBefore = sourceCancelButton.hidden;
        [sourceCancelButton setHidden:YES];
        standMode++;
    } else if (standMode == 1) { // In TwitterStand switching to PhotoStand
        [modeItem setTitle:@"TweetPhoto"];
        [modeItem setImage:[UIImage imageNamed:@"tweetPhoto.png"]];
        [modeLabel setText:@"PhotoStand"];
        [sourceButton setHidden:NO];
        [sourceCancelButton setHidden:sourceCancelBefore];
        standMode++;
    } else if (standMode == 2) { // In PhotoStand switching to TweetPhoto
        [modeItem setTitle:@"NewsStand"];
        [modeItem setImage:[UIImage imageNamed:@"news_icon.png"]];
        [modeLabel setText:@"TweetPhoto"];
        [sourceButton setHidden:YES];
        sourceCancelBefore = sourceCancelButton.hidden;
        [sourceCancelButton setHidden:YES];
        standMode++;
    } else { // In TweetPhoto switching to NewsStand
        [modeItem setTitle:@"TwitterStand"];
        [modeItem setImage:[UIImage imageNamed:@"bird.png"]];
        [modeLabel setText:@"NewsStand"];
        [sourceButton setHidden:NO];
        standMode = 0;
    }
    
    [self disableItemsForStandMode];
         
    [self refreshMap];
    [botTabBar setSelectedItem:nil];
}

-(void) topStoriesItemPushed
{
    if (!isPad) {
        if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
            portraitFirst = TRUE;
            TopStoriesViewController *topStoriesViewController = [[TopStoriesViewController alloc] initWithNibName:@"TopStoriesViewController_iPhone" andAnnotations:topStoriesAnnotations withHoverIndex:0 lastSelectedRow:-1 withMarkers:nil];     
            [self.navigationController pushViewController:topStoriesViewController animated:YES];
        } else {
            portraitFirst = FALSE;
            TopStoriesViewController *topStoriesViewController = [[TopStoriesViewController alloc] initWithNibName:@"TopStoriesViewController_iPhone_Land" andAnnotations:topStoriesAnnotations withHoverIndex:0 lastSelectedRow:-1 withMarkers:nil];
            [self.navigationController pushViewController:topStoriesViewController animated:YES];
        }
    } else {
        if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
            portraitFirst = TRUE;
            TopStoriesViewController *topStoriesViewController = [[TopStoriesViewController alloc] initWithNibName:@"TopStoriesViewController_iPad" andAnnotations:topStoriesAnnotations withHoverIndex:0 lastSelectedRow:-1 withMarkers:nil];     
            [self.navigationController pushViewController:topStoriesViewController animated:YES];
        } else {
            portraitFirst = FALSE;
            TopStoriesViewController *topStoriesViewController = [[TopStoriesViewController alloc] initWithNibName:@"TopStoriesViewController_iPad_Land" andAnnotations:topStoriesAnnotations withHoverIndex:0 lastSelectedRow:-1 withMarkers:nil];
            [self.navigationController pushViewController:topStoriesViewController animated:YES];
        }
    }
}

- (void) unselectBotTabBar
{
    [botTabBar setSelectedItem:nil];
}

- (void) setBotTabBarForHandMode
{
    if (handMode == 3) {
        [botFirstItem setImage:[UIImage imageNamed:@"rss.png"]];
        [botFirstItem setTitle:@"Top Stories"];
        
        switch (standMode) {
            case 0:
                [botSecondItem setImage:[UIImage imageNamed:@"bird.png"]];
                [botSecondItem setTitle:@"TwitterStand"];
                break;
            case 1:
                [botSecondItem setImage:[UIImage imageNamed:@"camera.png"]];
                [botSecondItem setTitle:@"PhotoStand"];
                break;
            case 2:
                [botSecondItem setImage:[UIImage imageNamed:@"tweetPhoto.png"]];
                [botSecondItem setTitle:@"TweetPhoto"];
                break;
            case 3:
                [botSecondItem setImage:[UIImage imageNamed:@"news_icon.png"]];
                [botSecondItem setTitle:@"NewsStand"];
                break;
        }
        
        [botThirdItem setImage:[UIImage imageNamed:@"newspaper.png"]];
        [botThirdItem setTitle:@"Sources"];
        [botFourthItem setImage:[UIImage imageNamed:@"settings.png"]];
        [botFourthItem setTitle:@"Settings"];
        [botFifthItem setImage:[UIImage imageNamed:@"search.png"]];
        [botFifthItem setTitle:@"Search"];
        [botSixthItem setImage:[UIImage imageNamed:@"info.png"]];
        [botSixthItem setTitle:@"Info"];

    } else {
        [botFirstItem setImage:[UIImage imageNamed:@"info.png"]];
        [botFirstItem setTitle:@"Info"];
        [botSecondItem setImage:[UIImage imageNamed:@"search.png"]];
        [botSecondItem setTitle:@"Search"];
        [botThirdItem setImage:[UIImage imageNamed:@"settings.png"]];
        [botThirdItem setTitle:@"Settings"];
        [botFourthItem setImage:[UIImage imageNamed:@"newspaper.png"]];
        [botFourthItem setTitle:@"Sources"];
        
        switch (standMode) {
            case 0:
                [botFifthItem setImage:[UIImage imageNamed:@"bird.png"]];
                [botFifthItem setTitle:@"TwitterStand"];
                break;
            case 1:
                [botFifthItem setImage:[UIImage imageNamed:@"camera.png"]];
                [botFifthItem setTitle:@"PhotoStand"];
                break;
            case 2:
                [botFifthItem setImage:[UIImage imageNamed:@"tweetPhoto.png"]];
                [botFifthItem setTitle:@"TweetPhoto"];
                break;
            case 3:
                [botFifthItem setImage:[UIImage imageNamed:@"news_icon.png"]];
                [botFifthItem setTitle:@"NewsStand"];
                break;
        }
        
        [botSixthItem setImage:[UIImage imageNamed:@"rss.png"]];
        [botSixthItem setTitle:@"Top Stories"];
    }
}

#pragma mark - Alert View Delegate
- (void) didNotFindLocation
{
    [locateAlertView setTitle:@"Location not found. Please enter a new location."];
    NSLog(@"CALLED");
    [locateAlertView show];
}

-(void) alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView == locateAlertView) {
        if (buttonIndex == 0) { //Cancel and Exit Button
            [[alertView textFieldAtIndex:0] setText:@""];
        } else if (buttonIndex == 1){
            if (geocoder.geocoding)
                [geocoder cancelGeocode];
            
            [geocoder geocodeAddressString:[[alertView textFieldAtIndex:0] text] completionHandler:^(NSArray *placemarks, NSError *error) {
                NSLog(@"IN BLOCK");
                if (!error) {
                    NSLog(@"Found a location");

                } else {
                    NSLog(@"Error in geocoding");
                    [NSTimer scheduledTimerWithTimeInterval:.25 target:self selector:@selector(didNotFindLocation) userInfo:nil repeats:NO];
                    return;
                }
                
                NSLog(@"Num found: %d", [placemarks count]);
                
                CLPlacemark *placemark = [placemarks objectAtIndex:0];
                MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(placemark.region.center, placemark.region.radius, placemark.region.radius);
                
                checkForMarker = TRUE;
                [mapView setRegion:region animated:YES];
            }];
            NSLog(@"After");
        }
        topTabBar.selectedItem = nil;
    } else if (alertView == searchAlertView) {
        if (buttonIndex == 0) {
            [[alertView textFieldAtIndex:0] setText:@""];
            searchKeyword = @"";
            [searchLabel setText:searchKeyword];
            [searchLabel setHidden:YES];
            [searchCancelButton setHidden:YES];
        } else {
            searchKeyword = [[alertView textFieldAtIndex:0] text];
            [searchLabel setText:[NSString stringWithFormat:@"Search Keyword: %@", searchKeyword]];
            [searchLabel setHidden:NO];
            [searchCancelButton setHidden:NO];
        }
        
        [self refreshMap];
        botTabBar.selectedItem = nil;
    } else {
        topTabBar.selectedItem = nil;
    }
}

#pragma mark - Map

- (void)mapView:(MKMapView*)localMapView regionDidChangeAnimated:(BOOL)animated
{
    // Ignore initial map update due to the map being repositioned to home (or world) at startupr
    static BOOL firstMapUpdate = TRUE;

    markerCheck = TRUE;
    topTabBar.selectedItem = nil;
    
    // Commented out as double called due to gesture recognizes (pan, swipe)
    if (!firstMapUpdate)
        [self refreshMap];
    
    firstMapUpdate = FALSE;
}


- (void) toggleDisplayingMapButtons:(BOOL)displayButtons
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:.2];
    if (displayButtons) {
        [refreshButton setAlpha:0.0];
        [plusButton setAlpha:0.0];
        [minusButton setAlpha:0.0];
    } else {
        [refreshButton setAlpha:0.5];
        [plusButton setAlpha:0.5];
        [minusButton setAlpha:0.5];
    }
    [UIView commitAnimations];
}
   
- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)localContext {
    char *actionCharStr = (char*)localContext;
    NSString *action = [NSString stringWithCString:actionCharStr encoding:NSStringEncodingConversionAllowLossy];
    
	if ([action isEqualToString:GMAP_ANNOTATION_SELECTED]) {
		BOOL annotationAppeared = [[change valueForKey:@"new"] boolValue];
		[self toggleDisplayingMapButtons:annotationAppeared];
		
		if (standMode >= 2) {
			[UIView beginAnimations:nil context:NULL];
			[UIView setAnimationDuration:.2];
			NewsAnnotationView *currentAnnotationView;
            currentAnnotationView = (NewsAnnotationView*)object;
                        
            int max_dim = 42;
            if (isPad)
                max_dim = 60; //Fixes floating point issues
            
            int annotation_width = (int)ceil(currentAnnotationView.frame.size.width);
            int annotation_height = (int)ceil(currentAnnotationView.frame.size.height);
            
            if (annotationAppeared && (annotation_width == max_dim || annotation_height == max_dim)) {
                currentAnnotationView.frame = CGRectMake(currentAnnotationView.frame.origin.x, currentAnnotationView.frame.origin.y, 
                                                        currentAnnotationView.frame.size.width*3, currentAnnotationView.frame.size.height*3);
				
            } else if (annotation_width > max_dim || annotation_height > max_dim)  {
                currentAnnotationView.frame = CGRectMake(currentAnnotationView.frame.origin.x, currentAnnotationView.frame.origin.y, 
                                                         currentAnnotationView.frame.size.width/3, currentAnnotationView.frame.size.height/3);
            }
            
			[UIView commitAnimations];
		}
        
	}

}


-(MKAnnotationView *)mapView:(MKMapView *)localMapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if ([annotation class] == MKUserLocation.class) {
        MKPinAnnotationView *pin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"userLocationID"];
        #if TARGET_IPHONE_SIMULATOR
            mapView.showsUserLocation = NO;
        #endif
        
        return pin;
    }
    
    NewsAnnotationView *annotationView = nil;
    NewsStandLayer currentLayer = layerSelected;
    
    if (standMode < 2) { // NewsStand && TwitterStand
        if (currentLayer == locationLayer) {
            annotationView = (NewsAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"newsview2"];
            annotationView = [[NewsAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"newsview2"];  
            
            [annotationView setNewsAnnotation:annotation];
            [annotationView setFont:locationFont];
            
            CGSize textSize = [annotation.title sizeWithFont:locationFont];
            annotationView.frame = CGRectMake(annotationView.frame.origin.x, annotationView.frame.origin.y, (CGFloat)textSize.width, (CGFloat)textSize.height);

            annotationView.canShowCallout = YES;
            annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        } else if (currentLayer == iconLayer) {
            annotationView = (NewsAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"newsview"];
            if (annotationView == nil)
                annotationView = [[NewsAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"newsview"];
            
            NewsAnnotation *newsAnnotation = (NewsAnnotation *)annotation;
            annotationView.canShowCallout = YES;
            
            if ([newsAnnotation.topic isEqualToString:@"General"])
                annotationView.image = generalImage;
            else if ([newsAnnotation.topic isEqualToString:@"Business"])
                annotationView.image = businessImage;
            else if ([newsAnnotation.topic isEqualToString:@"Health"])
                annotationView.image = healthImage;
            else if ([newsAnnotation.topic isEqualToString:@"SciTech"])
                annotationView.image = sciTechImage;
            else if ([newsAnnotation.topic isEqualToString:@"Entertainment"])
                annotationView.image = entertainmentImage;
            else if ([newsAnnotation.topic isEqualToString:@"Sports"])
                annotationView.image = sportsImage;
            
            annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        } else {  // Keyword, People, Disease Layer
            annotationView = (NewsAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"newsview2"];
            if (annotationView == nil)
                annotationView = [[NewsAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"newsview2"];
                
            
            [annotationView setNewsAnnotation:annotation];
            [annotationView setFont:locationFont];
            
            CGSize textSize = [annotationView.newsAnnotation.keyword sizeWithFont:locationFont];
            [annotationView setFrame:CGRectMake(annotationView.frame.origin.x, annotationView.frame.origin.y, (CGFloat)textSize.width, (CGFloat)textSize.height)];
            
            [annotationView setCanShowCallout:TRUE];
            [annotationView setRightCalloutAccessoryView:[UIButton buttonWithType:UIButtonTypeDetailDisclosure]];
        }
    } else {
        NewsAnnotation *newsAnnotation = (NewsAnnotation*)annotation;
        [newsAnnotation setSubtitle:[newsAnnotation caption]];
        annotationView = (NewsAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"newsview2"];
        annotationView = [[NewsAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"newsview2"];
        
        [annotationView setNewsAnnotation:newsAnnotation];
        [annotationView setImage_url:[newsAnnotation img_url]];
        if (![newsAnnotation imageFailed]) {
            [annotationView setImage:[[JMImageCache sharedCache] imageForURLOrThrowException:[newsAnnotation img_url] delegate:annotationView]];
        }
        
        float width = newsAnnotation.width, height = newsAnnotation.height, factor;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            if (width == 0 || height == 0) { // this looks wrong (first case)
                width = 60;
                height = 60;
            } else if (width >= height) {
                factor = 60 / width;
                width = factor * width;
                height = factor * height;
            } else {
                factor = 60 / height;
                width = factor * width;
                height = factor * height;
            }
        else {
            if (width == 0 || height == 0) { // this looks wrong (first case)
                width = 42;
                height = 42;
            } else if (width >= height) {
                factor = 42 / width;
                width = factor * width;
                height = factor * height;
            } else {
                factor = 42 / height;
                width = factor * width;
                height = factor * height;
            }
        }
        [annotationView setFrame:CGRectMake(annotationView.frame.origin.x, annotationView.frame.origin.y, width, height)];
        
        [annotationView setCanShowCallout:TRUE];
        [annotationView setRightCalloutAccessoryView:[UIButton buttonWithType:UIButtonTypeDetailDisclosure]];
    }

    [annotationView addObserver:self forKeyPath:@"selected" options:NSKeyValueObservingOptionNew context:(void*)("gMapAnnotationSelected")];
    [annotationView setObserving:YES];
    
    return annotationView;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    NewsAnnotation *annotation = [view annotation];
    
    NSString *urlString;
    NSString *modeParam = @"newsstand";
    if (standMode == 1 || standMode == 3)
        modeParam = @"twitterstand";
    
    if (standMode < 2) {
        urlString = [NSString stringWithFormat:@"http://%@.umiacs.umd.edu/news/xml_top_locations?gaz_id=%d%@%@", modeParam, [annotation gaz_id], [self sourceParamString] ,
                     [self settingsParamString]];
    } else {
        urlString = [NSString stringWithFormat:@"http://%@.umiacs.umd.edu/news/xml_gaz_images?gaz_id=%d%@", modeParam, [annotation gaz_id], [self sourceParamString]];
    }
    
    NSOperationQueue *ignoreQueue = [[NSOperationQueue alloc] init];
    
    PrefetchRequestOperation *prefetchOperation = [[PrefetchRequestOperation alloc] initWithRequestString:urlString];
    [ignoreQueue addOperation:prefetchOperation];
}

- (void)mapView:(MKMapView *)_mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{	
    NewsAnnotation *annotation = [view annotation];
    
    if (UIDeviceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
        portraitFirst = false;
    } else {
        portraitFirst = true;
    }
    
    if (!isPad) {
        NSString *nibName = @"DetailViewController";
        if (!portraitFirst) {
            nibName = @"DetailViewController_Landscape";
        }
        
        if (standMode < 2) {
            if (layerSelected == iconLayer || layerSelected == locationLayer) {
                DetailViewController *detailViewController = [[DetailViewController alloc] initWithNibName:nibName andGazId:[annotation gaz_id] andSourceString:[self sourceParamString] andSettingsString:[self settingsParamString] withTitle:[annotation name] andStandMode:standMode];
                [self.navigationController pushViewController:detailViewController animated:YES];
            } else if (layerSelected == keywordLayer) {
                DetailViewController *detailViewController = [[DetailViewController alloc] initWithGazId:[annotation gaz_id] andSourceString:[self sourceParamString] andSettingsString:[self settingsParamString] withTitle:[NSString stringWithFormat:@"Keywords in %@", [annotation name]]  andStandMode:standMode];
                [self.navigationController pushViewController:detailViewController animated:YES];
            } else if (layerSelected == peopleLayer) {
                DetailViewController *detailViewController = [[DetailViewController alloc] initWithGazId:[annotation gaz_id] andSourceString:[self sourceParamString] andSettingsString:[self settingsParamString] withTitle:[NSString stringWithFormat:@"People in %@", [annotation name]]  andStandMode:standMode];
                [self.navigationController pushViewController:detailViewController animated:YES];
            } else {
                DetailViewController *detailViewController = [[DetailViewController alloc] initWithGazId:[annotation gaz_id] andSourceString:[self sourceParamString] andSettingsString:[self settingsParamString] withTitle:[NSString stringWithFormat:@"Diseases in %@", [annotation name]]  andStandMode:standMode];
                [self.navigationController pushViewController:detailViewController animated:YES];
            }
        } else { //PhotoStand
            NSString *gaz_name;
            if ([[annotation name] length] >= 20) 
                gaz_name = [annotation.name substringToIndex:20];
            else
                gaz_name = [annotation name];
        
            ImageViewer *imageViewer = [[ImageViewer alloc] initWithImageTopic:gaz_name withImageId:[annotation gaz_id] andStandMode:standMode andConstraints:[self sourceParamString]];
            [self.navigationController pushViewController:imageViewer animated:YES];
        }
    } else { //iPad
        CGSize screenDimensions;
        if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation]))
            screenDimensions = [[UIDevice currentDevice] screenSizeForOrientation:UIDeviceOrientationPortrait];
        else
            screenDimensions = [[UIDevice currentDevice] screenSizeForOrientation:UIDeviceOrientationLandscapeLeft];
        
        float screenWidth = screenDimensions.width;
        float screenHeight = screenDimensions.height;
        
        if (standMode < 2) {
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:.35];
            [blackButton setAlpha:.3];
            [UIView commitAnimations];
            
            if (layerSelected == iconLayer || layerSelected == locationLayer) {
                padDetailViewController = [[DetailViewController alloc] initWithNibName:@"DetailViewController_iPad" andGazId:[annotation gaz_id] andSourceString:[self sourceParamString] andSettingsString:[self settingsParamString] withTitle:[annotation name] andStandMode:standMode];
            } else if (layerSelected == keywordLayer) {
                padDetailViewController = [[DetailViewController alloc] initWithGazId:[annotation gaz_id] andSourceString:[self sourceParamString] andSettingsString:[self settingsParamString] withTitle:[NSString stringWithFormat:@"Keywords in %@", [annotation name]]  andStandMode:standMode];
            } else if (layerSelected == peopleLayer) {
                padDetailViewController = [[DetailViewController alloc] initWithGazId:[annotation gaz_id] andSourceString:[self sourceParamString] andSettingsString:[self settingsParamString] withTitle:[NSString stringWithFormat:@"People in %@", [annotation name]]  andStandMode:standMode];
            } else {
                padDetailViewController = [[DetailViewController alloc] initWithGazId:[annotation gaz_id] andSourceString:[self sourceParamString] andSettingsString:[self settingsParamString] withTitle:[NSString stringWithFormat:@"Diseases in %@", [annotation name]]  andStandMode:standMode];
            }
            
            [padDetailViewController.view.layer setCornerRadius:30.0f];
            [padDetailViewController.view.layer setBorderColor:[UIColor lightGrayColor].CGColor];
            [padDetailViewController.view.layer setBorderWidth:1.5f];
            [padDetailViewController.view.layer setShadowColor:[UIColor blackColor].CGColor];
            [padDetailViewController.view.layer setShadowOpacity:.8];
            [padDetailViewController.view.layer setShadowRadius:3.0];
            [padDetailViewController.view.layer setShadowOffset:CGSizeMake(2.0, 2.0)];

            
            if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
                padDetailViewController.view.frame = CGRectMake(screenWidth / 5, screenHeight / 5, screenWidth * .6, screenHeight * .6);
            } else {
                padDetailViewController.view.frame = CGRectMake(screenWidth / 5, screenHeight / 5, screenWidth * .6, screenHeight * .6);
            }
            
            padDetailViewController.view.clipsToBounds = YES;
            padDetailViewController.view.layer.shadowOpacity = 1.0;
            padDetailViewController.view.layer.cornerRadius = 5;
            [self.view addSubview:padDetailViewController.view];
            
        } else { //PhotoStand
            NSString *gaz_name;
            if ([[annotation name] length] >= 20) 
                gaz_name = [annotation.name substringToIndex:20];
            else
                gaz_name = [annotation name];
            
            ImageViewer *imageViewer = [[ImageViewer alloc] initWithImageTopic:gaz_name withImageId:[annotation gaz_id] andStandMode:standMode andConstraints:[self sourceParamString]];
            [self.navigationController pushViewController:imageViewer animated:YES];
        }
        
    }
}

-(void) setHomeLocation
{
    CLLocationCoordinate2D center = mapView.centerCoordinate;
    CLLocationDegrees lat = center.latitude;
    CLLocationDegrees lon = center.longitude;
    
    MKCoordinateRegion region = mapView.region;
    MKCoordinateSpan span = region.span;
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setFloat:lat forKey:@"homeCenterLat"];
    [prefs setFloat:lon forKey:@"homeCenterLon"];
    
    [prefs setFloat:span.latitudeDelta forKey:@"homeLatDelta"];
    [prefs setFloat:span.longitudeDelta forKey:@"homeLonDelta"];
}

-(NSString *) URLEncodeString:(NSString *) str
{
    
    NSMutableString *tempStr = [NSMutableString stringWithString:str];
    [tempStr replaceOccurrencesOfString:@" " withString:@"+" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [tempStr length])];
    
    
    return [[NSString stringWithFormat:@"%@",tempStr] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

-(void) refreshMap
{
    if (!hasInet)
        return;
    
    NSString *mode = @"newsstand";
    NSString *stand = @"";
    NSString *zoom = @"";
    
    if (standMode == 1 || standMode == 3) //TwitterStand & TweetPhoto
        mode = @"twitterstand";
    
    if (standMode >= 2) {
        stand = [NSString stringWithFormat:@"&stand=%d", standMode];
        
        int zoomLevel = [mapView zoomLevel];
        NSLog(@"Zoom Level %d", zoomLevel);
        zoom = [NSString stringWithFormat:@"&zoom=%d", zoomLevel];
    }
    CLLocationCoordinate2D center = mapView.centerCoordinate;
    CLLocationDegrees lat = center.latitude;
    CLLocationDegrees lon = center.longitude;
    
    MKCoordinateRegion region = mapView.region;
    MKCoordinateSpan span = region.span;
    
    double lat_low = lat - span.latitudeDelta / 2.0;
    double lat_high = lat + span.latitudeDelta / 2.0;
    double lon_low = lon - span.longitudeDelta / 2.0;
    double lon_high = lon + span.longitudeDelta / 2.0;
    
    NSString *settingsParamString = [self settingsParamString];
    NSString *sourceParamString = [self sourceParamString];

    
    NSString *urlString;
    if (standMode == 0 || standMode == 2) {
        urlString = [NSString stringWithFormat:@"http://%@.umiacs.umd.edu/news/xml_map?lat_low=%f&lat_high=%f&lon_low=%f&lon_high=%f%@%@%@%@", mode, lat_low, lat_high, lon_low, lon_high, stand, zoom, settingsParamString, sourceParamString];
    } else { //TwitterStand
        urlString = [NSString stringWithFormat:@"http://%@.umiacs.umd.edu/news/xml_map?lat_low=%f&lat_high=%f&lon_low=%f&lon_high=%f%@",mode, lat_low, lat_high, lon_low, lon_high, settingsParamString];
    }
    
    urlString = [self URLEncodeString:urlString];
    
    NSLog(@"View Controller downloading %@", urlString);
    double ratio = (lon_high - lon_low) / (lat_high - lat_low);
    NSLog(@"Ratio: %f", ratio);
    currentRequestID++;
    
    
   // [[RequestQueue mainQueue] cancelAllRequests];
   [queue cancelAllOperations];
    
    NSURL *url = [NSURL URLWithString:urlString];
    URLrequest = [NSURLRequest requestWithURL:url];
    [[RequestQueue mainQueue] addRequest:URLrequest completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        if (data && error == nil)
        {
            ViewControllerRequestOperation *viewControllerRequestOperation = [[ViewControllerRequestOperation alloc] initWithRequestData:data andRequestId:currentRequestID];
            [queue addOperation:viewControllerRequestOperation];
        } else if (error)
        {
            NSLog(@"View Controller parse error: %@", error);
        }
    }];
    
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [activityIndicator startAnimating];
}

// The following function fixes an issue where the map stops responding to pinches and pans
- (void)addMapGestureRecognizers
{
    /*
    if (NSFoundationVersionNumber >= 678.58){
        
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureCaptured:)];
        pan.delegate = self;
        [mapView addGestureRecognizer:pan];
        
        UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchGestureCaptured:)];
        
        pinch.delegate = self;          
        [mapView addGestureRecognizer:pinch];
        
        UITapGestureRecognizer *swipe = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(swipeGestureCaptured:)];
        swipe.delegate = self;
        [mapView addGestureRecognizer:swipe];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureCaptured:)];
        tap.delegate = self;
        [mapView addGestureRecognizer:tap];
        
        
    }
     */
}

- (void) loadUnloadMap
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    
    region.center.latitude = [prefs floatForKey:@"unloadCenterLat"];
    region.center.longitude = [prefs floatForKey:@"unloadCenterLon"];
    span.latitudeDelta = [prefs floatForKey:@"unloadLatDelta"];
    span.longitudeDelta = [prefs floatForKey:@"unloadLonDelta"];
    
    region.span = span;
    
    [mapView setRegion:region animated:NO];
}
 #pragma mark -
 #pragma mark Gesture Recognizers
 
 - (void)pinchGestureCaptured:(UIPinchGestureRecognizer*)gesture{
     if (UIGestureRecognizerStateEnded == gesture.state){
         [topTabBar setSelectedItem:nil];
         [self refreshMap]; 
     }
 }
 
 - (void)panGestureCaptured:(UIPanGestureRecognizer*)gesture{
 
     if(UIGestureRecognizerStateEnded == gesture.state){
        [topTabBar setSelectedItem:nil];
        [self refreshMap];
     }
 }

- (void)swipeGestureCaptured:(UISwipeGestureRecognizer*)gesture{
    if(UIGestureRecognizerStateEnded == gesture.state){
        [topTabBar setSelectedItem:nil];
        [self refreshMap];
    }
}

- (void)tapGestureCaptured:(UITapGestureRecognizer*) gesture {
    if (UIGestureRecognizerStateEnded == gesture.state) {
        [topTabBar setSelectedItem:nil];
        [self refreshMap];
    }
}
 
 -(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
     return YES;
 }
 
 -(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
     return YES;
 }
 
 - (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
     return YES;
 }

#pragma mark - Buttons on Map
-(IBAction)refreshButtonPressed:(id)sender {
    MKCoordinateRegion region = mapView.region;
    MKCoordinateSpan span = mapView.region.span;
    
    NSLog(@"Center x: %f y: %f   spanLat %f   spanLon %f", region.center.latitude, region.center.longitude, span.latitudeDelta, span.longitudeDelta);
    
    [self refreshMap];
}
-(IBAction)plusButtonPressed:(id)sender 
{
    MKCoordinateRegion newRegion = [mapView region];
    MKCoordinateSpan newSpan = MKCoordinateSpanMake(newRegion.span.latitudeDelta / 2.0, newRegion.span.longitudeDelta / 2.0);
    newRegion.span = newSpan;
  
    [mapView setRegion:newRegion animated:YES];
}
-(IBAction)minusButtonPressed:(id)sender 
{
    MKCoordinateRegion newRegion = [mapView region];
    
    if (newRegion.span.latitudeDelta > 90.0 || newRegion.span.longitudeDelta > 90.0)
        return;
    
    MKCoordinateSpan newSpan = MKCoordinateSpanMake(newRegion.span.latitudeDelta * 1.75, newRegion.span.longitudeDelta * 1.75);
    newRegion.span = newSpan;
    
    [mapView setRegion:newRegion animated:YES];
}

- (void)updateMapButtonsOnHandMode
{
    UIInterfaceOrientation currentOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    //If not a pad handle handmode
    if (!isPad) {
        if (UIInterfaceOrientationIsLandscape(currentOrientation)) {
            if (handMode == 1) { // Neutral (Default)
                refreshButton.frame = CGRectMake(13.0, 72.0, 50.0, 50.0);
                plusButton.frame = CGRectMake(422.0, 72.0, 50.0, 50.0);
                minusButton.frame = CGRectMake(422.0, 136.0, 50.0, 50.0);
                [refreshButton setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin];
                [plusButton setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
                [minusButton setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
            } else if (handMode == 2) { // Left hand mode
                refreshButton.frame = CGRectMake(13.0, 72.0, 50.0, 50.0);
                plusButton.frame = CGRectMake(385.0, 60.0, 50.0, 50.0);
                minusButton.frame = CGRectMake(427.0, 136.0, 50.0, 50.0);
                [refreshButton setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin];
                [plusButton setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
                [minusButton setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
            } else if (handMode == 3) {
                refreshButton.frame = CGRectMake(416.0, 58.0, 50.0, 50.0);
                plusButton.frame = CGRectMake(55.0, 60.0, 50.0, 50.0);
                minusButton.frame = CGRectMake(13.0, 136.0, 50.0, 50.0);
                [refreshButton setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
                [plusButton setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin];
                [minusButton setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin];
            }
        } else {
            if (handMode == 1) { // Neutral (Default)
                refreshButton.frame = CGRectMake(13.0, 72.0, 50.0, 50.0);
                plusButton.frame = CGRectMake(262.0, 72.0, 50.0, 50.0);
                minusButton.frame = CGRectMake(262.0, 136.0, 50.0, 50.0);
                [refreshButton setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin];
                [plusButton setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
                [minusButton setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
            } else if (handMode == 2) { // Left hand mode
                refreshButton.frame = CGRectMake(13.0, 72.0, 50.0, 50.0);
                plusButton.frame = CGRectMake(225.0, 60.0, 50.0, 50.0);
                minusButton.frame = CGRectMake(267.0, 136.0, 50.0, 50.0);
                [refreshButton setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin];
                [plusButton setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
                [minusButton setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
            } else if (handMode == 3) {
                refreshButton.frame = CGRectMake(256.0, 58.0, 50.0, 50.0);
                plusButton.frame = CGRectMake(55.0, 60.0, 50.0, 50.0);
                minusButton.frame = CGRectMake(13.0, 136.0, 50.0, 50.0);
                [refreshButton setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
                [plusButton setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin];
                [minusButton setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin];
            }
        }
    }
    [self setBotTabBarForHandMode];
    [self disableItemsForStandMode];
}

#pragma mark - Top Stories

- (void) populateTopStories
{
    NSString *mode = @"newsstand";
    if (standMode == 1)
        mode = @"twitterstand";
    
    NSString *topStoriesQueryString = [[NSString alloc] initWithString:[NSString stringWithFormat:@"http://%@.umiacs.umd.edu/news/iphone_results?a=5%@%@", mode, [self sourceParamString], [self settingsParamString]]];
    
    TopStoriesRequestOperation *topStoriesRequestOperation = [[TopStoriesRequestOperation alloc] initWithRequestString:topStoriesQueryString andTopStoriesViewController:nil];
    [queue addOperation:topStoriesRequestOperation];
    
}

#pragma mark - IP Address (For Simulator)
//Private IP
- (NSString *)getIPAddress {    
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en1"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];               
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    NSLog(@"IP Address is: %@", address);
    
    return address;
    
} 

//Public IP

- (void) getPublicIP
{
    SimulatorLocationRequestOperation *simulatorRequestOperation = [[SimulatorLocationRequestOperation alloc] init];
    [simulatorQueue addOperation:simulatorRequestOperation];
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    if (viewDidUnload) {
        NSLog(@"VIEW DID UNLOAD DO NOT REDO");
        [self  initializeViewDidUnload];
        [self addMapGestureRecognizers];
        viewDidUnload = NO;
        [self loadUnloadMap];
        if (standMode == 0) {
            [modeLabel setText:@"NewsStand"];
        } else if (standMode == 1) {
            [modeLabel setText:@"TwitterStand"];
        } else if (standMode == 2) {
            [modeLabel setText:@"PhotoStand"];
        } else {
            [modeLabel setText:@"TweetPhoto"];
        }

        automaticHandMode = [prefs boolForKey:@"automaticHandMode"];
        [self setSourceAndCancelButton];
    } else {
        
        simulatorQueue = [[NSOperationQueue alloc] init];
        
        [self initializeSettings];
        [self initializeSources];
        [self initImagesAndFonts];
        [self addMapGestureRecognizers];
        
        //Find location even if not simulator - in case of location at 0,0 
        
        [self getPublicIP];    
    
        isPad = ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad);
        geocoder = [[CLGeocoder alloc] init];
    
        queue = [[NSOperationQueue alloc] init];
        
        if (!isPad) {
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
            
            automaticHandMode = TRUE;
            
        } else {
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
        }
            
        self.title = @"  Map  "; // Leading and trailing whitespace to extend button size in navigation controller
        [self populateTopStories];
        
        //Trigger Location
        mapView.showsUserLocation = YES;
    
        #if TARGET_IPHONE_SIMULATOR
            mapView.showsUserLocation = NO;
        #endif
    }


    for (UITabBarItem *tabBarItem in topTabBar.items) {
            [tabBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                [UIColor whiteColor], UITextAttributeTextColor,
                                                [UIFont fontWithName:@"Helvetica" size:12.0], UITextAttributeFont, nil]
                                      forState:UIControlStateNormal];
    }
    
    for (UITabBarItem *tabBarItem in botTabBar.items) {
        [tabBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                            [UIColor whiteColor], UITextAttributeTextColor,
                                            [UIFont fontWithName:@"Helvetica" size:12.0], UITextAttributeFont, nil]
                                  forState:UIControlStateNormal];
    }
    
    
    if (isPad) {
        blackButton =[UIButton buttonWithType:UIButtonTypeRoundedRect];
        [blackButton setImage:[UIImage imageNamed:@"black.jpg"] forState:UIControlStateNormal];
        [blackButton  setImage:[UIImage imageNamed:@"black.jpg"] forState:UIControlStateHighlighted];
        [blackButton  setImage:[UIImage imageNamed:@"black.jpg"] forState:UIControlStateSelected];
        [blackButton addTarget:self action:@selector(dismissDetailViewController) forControlEvents:UIControlEventTouchUpInside];
        [blackButton setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
        
        isPad = ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad);
        
        CGSize screenDimensions;
        if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation]))
            screenDimensions = [[UIDevice currentDevice] screenSizeForOrientation:UIDeviceOrientationPortrait];
        else
            screenDimensions = [[UIDevice currentDevice] screenSizeForOrientation:UIDeviceOrientationLandscapeLeft];
        
        float width = screenDimensions.width;
        float height = screenDimensions.height;
        if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
            [blackButton setFrame:CGRectMake(0.0, 0.0, width, height)];
        } else {
            [blackButton setFrame:CGRectMake(0.0, 0.0, height, width)];
        }
        [blackButton setAlpha:0.0];
        [self.view addSubview:blackButton];
    }
   
   // [self setNeedsStatusBarAppearanceUpdate];
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)stateOnViewUnload
{
    //Save current position of map
    CLLocationCoordinate2D center = mapView.centerCoordinate;
    CLLocationDegrees lat = center.latitude;
    CLLocationDegrees lon = center.longitude;
    
    MKCoordinateRegion region = mapView.region;
    MKCoordinateSpan span = region.span;
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setFloat:lat forKey:@"unloadCenterLat"];
    [prefs setFloat:lon forKey:@"unloadCenterLon"];
    
    [prefs setFloat:span.latitudeDelta forKey:@"unloadLatDelta"];
    [prefs setFloat:span.longitudeDelta forKey:@"unloadLonDelta"];
    
    [prefs setBool:automaticHandMode forKey:@"automaticHandMode"];
    
    for (UIGestureRecognizer *gestureRecognizer in mapView.gestureRecognizers) {
        [mapView removeGestureRecognizer:gestureRecognizer];
    }
}

- (void)viewDidUnload
{
    NSLog(@"\n\nView did unload\n\n\n");
    viewDidUnload = TRUE;
    [self stateOnViewUnload];
    
    [super viewDidUnload];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self.navigationController setToolbarHidden:YES animated:YES];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:YES];

    [self updateMapButtonsOnHandMode];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    motionManager = nil;
    motionManager = [[CMMotionManager alloc] init];
    [motionManager startAccelerometerUpdatesToQueue:[[NSOperationQueue alloc] init]
                                             withHandler:^(CMAccelerometerData *data, NSError *error) {
                                                 dispatch_async(dispatch_get_main_queue(), ^{
                                                     double x = data.acceleration.x * MOTION_SCALE;
                                                     if (automaticHandMode) {
                                                         if (x >= 1.0 && handMode != 3) {
                                                             NSLog(@"View will appear 1 sec - 3");
                                                             handMode = 3;
                                                             [self updateMapButtonsOnHandMode];
                                                         } else if (x <= -1.0 && handMode != 2) {
                                                             handMode = 2;
                                                             [self updateMapButtonsOnHandMode];
                                                         }
                                                     }
                                                 });
                                             }
     ];
    [motionManager setAccelerometerUpdateInterval:.5];
    
    NSTimer *deselectBotTabBar = [NSTimer timerWithTimeInterval:.2 target:self selector:@selector(unselectBotTabBar) userInfo:nil repeats:NO];
    [deselectBotTabBar fire];
    if (first) {
        [self homeItemPushed];
        first = FALSE;
    } else if (viewDidUnload) {
        [self loadUnloadMap];
    }
    
    
     }

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
    [motionManager stopAccelerometerUpdates];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else if ([blackButton alpha] < 0.1){
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return NO;
    }
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    
}



- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    
}

#pragma mark - Sources
- (NSString *)sourceParamString
{
    if (standMode == 1) //TwitterStand - no source constraints
        return @"";
    
    NSString *paramString = @"";
    
    if (sourcesSelected == allSourcesSelected) {
        NSString *languagesSelectedString = @"";
        BOOL first = TRUE;
        
        for (int i = 0; i < [languageSources count]; i++) {
            if ([[languageSources objectAtIndex:i] selected]) {
                if (first) {
                    languagesSelectedString = [[languageSources objectAtIndex:i] lang_code];
                    first = FALSE;
                } else {
                    languagesSelectedString = [NSString stringWithFormat:@"%@,%@", languagesSelectedString, [[languageSources objectAtIndex:i] lang_code]];
                }
            } 
        }
        
        if ([languagesSelectedString isEqualToString:@"en"]) {
            if ([[allSources objectAtIndex:0] selected])
                paramString = [paramString stringByAppendingString:@"&rank=time"];
            else if ([[allSources objectAtIndex:2] selected])
                paramString = [paramString stringByAppendingString:@"&rank=newest"];
        } else {
            paramString = [paramString stringByAppendingString:[NSString stringWithFormat:@"&lang=%@", languagesSelectedString]];
        }
    } else if (sourcesSelected == feedSourcesSelected) {
        for (Source *currSource in feedSources) {
            if ([currSource selected]) {
                if ([paramString isEqualToString:@""])
                    paramString = [paramString stringByAppendingString:@"&feedlinks="];
                else
                    paramString = [paramString stringByAppendingString:@","];
                
                paramString = [paramString stringByAppendingFormat:@"%d", [currSource feed_link]];
            }
        }
    } else if (sourcesSelected == countrySourcesSelected) {
        for (Source *currSource in countrySources) {
            if ([currSource selected]) {
                if ([paramString isEqualToString:@""])
                    paramString = [paramString stringByAppendingString:@"&cname="];
                else
                    paramString = [paramString stringByAppendingString:@","];
                
                paramString = [paramString stringByAppendingString:[currSource name]];
            }
        }
    } else { //Bound Sources
        for (Source *currSource in boundSources) {
            if ([currSource selected]) {
                float lat = [currSource centerLat];
                float lon = [currSource centerLon];
                float latD = [currSource latDelta];
                float lonD = [currSource lonDelta];
                
                double lat_low = lat - latD / 2;
                double lat_high = lat + latD / 2;
                double lon_low = lon - lonD / 2;
                double lon_high = lon + lonD / 2;
                
                paramString = [paramString stringByAppendingString:[NSString stringWithFormat:@"&src_lat_low=%f&src_lat_high=%f&src_lon_low=%f&src_lon_high=%f", lat_low, lat_high, lon_low, lon_high]];
                break; //Only one bound source can be selected at a time
            }
        }
    }
             
    return paramString;
}

- (BOOL) itemSelectedInArray:(NSMutableArray *)array
{
    for (int i = 0; i < [array count]; i++)
        if ([[array objectAtIndex:i] selected])
            return YES;
    
    return NO;
}

-(IBAction)sourceCancelButtonPressed:(id)sender
{
    numSourcesSelected--;
    
    if (sourcesSelected == allSourcesSelected) {
        
        if ([languagesSelected count] == 1 && [languagesSelected containsObject:@"en"]) {
            [[allSources objectAtIndex:0] setSelected:YES];
            [[allSources objectAtIndex:sourceDisplayed] setSelected:NO];
        
            sourceDisplayed = 0;
            numSourcesSelected = 1;
        } else {
            for (int i = 0; i < [languageSources count]; i++) {
                if ([[[languageSources objectAtIndex:i] lang_code] isEqualToString:[languagesSelected objectAtIndex:sourceDisplayed]]) {
                    [[languageSources objectAtIndex:i] setSelected:NO];
                    break;
                }
            }
            
            [languagesSelected removeObjectAtIndex:sourceDisplayed];
            
            if (languagesSelected == nil || [languagesSelected count] == 0) {
                [[allSources objectAtIndex:0] setSelected:YES];
                
                [languagesSelected removeAllObjects];
                [languagesSelected addObject:@"en"];
                
                for (int i = 0; i < [languageSources count]; i++) {
                    if ([[[languageSources objectAtIndex:i] lang_code] isEqualToString:@"en"]) {
                        [[languageSources objectAtIndex:i] setSelected:YES];
                        break;
                    }
                }
                
                sourceDisplayed = 0;
                numSourcesSelected = 1;
            } else {
                if (sourceDisplayed >= [languagesSelected count]) 
                    sourceDisplayed = 0;
            }
        }
    } else if (sourcesSelected == feedSourcesSelected) {
        [[feedSources objectAtIndex:sourceDisplayed] setSelected:NO];
        
        if (numSourcesSelected == 0) {
            [[allSources objectAtIndex:0] setSelected:YES];
            sourcesSelected = allSourcesSelected;
            numSourcesSelected = 1;
        } else {
            BOOL foundSource = FALSE;
            
            int numFeeds = [feedSources count];
            for (int i = sourceDisplayed + 1; i < numFeeds; i++) 
                if ([[feedSources objectAtIndex:i] selected]) {
                    sourceDisplayed = i;
                    foundSource = TRUE;
                    break;
                }

            if (!foundSource) 
                for (int i = 0; i < sourceDisplayed; i++) 
                    if ([[feedSources objectAtIndex:i] selected]) {
                        sourceDisplayed = i;
                        break;
                }
        }
    } else if (sourcesSelected == countrySourcesSelected) {
        [[countrySources objectAtIndex:sourceDisplayed] setSelected:NO];
        
        if (numSourcesSelected == 0) {
            [[allSources objectAtIndex:0] setSelected:YES];
            sourcesSelected = allSourcesSelected;
            numSourcesSelected = 1;
        } else {
            BOOL foundSource = FALSE;
            
            int numCountries = [countrySources count];
            for (int i = sourceDisplayed + 1; i < numCountries; i++) 
                if ([[countrySources objectAtIndex:i] selected]) {
                    sourceDisplayed = i;
                    foundSource = TRUE;
                    break;
                }
            
            if (!foundSource) 
                for (int i = 0; i < sourceDisplayed; i++) 
                    if ([[countrySources objectAtIndex:i] selected]) {
                        sourceDisplayed = i;
                        //foundSource = TRUE;
                        break;
                    }
        }
    } else { // Bound Source
        [[boundSources objectAtIndex:sourceDisplayed] setSelected:NO];
        [[allSources objectAtIndex:0] setSelected:YES];
        sourcesSelected = allSourcesSelected;
        numSourcesSelected = 1;
    }
    [self refreshMap];
    [self setSourceAndCancelButton];
}

- (void) setSourceAndCancelButton
{
    NSString *sourceButtonText = @"";
    
    if (sourcesSelected == allSourcesSelected) {
        if ([languagesSelected count] == 0 || ([languagesSelected count] == 1 && [languagesSelected containsObject:@"en"])) {
            if ([[allSources objectAtIndex:0] selected]) {
                sourceButtonText = @"Rep. Source: Most Recent";
                sourceDisplayed = 0;
            } else if ([[allSources objectAtIndex:1] selected]) {
                sourceButtonText = @"Rep. Source: Most Reputable";
                sourceDisplayed = 1;
            } else if ([[allSources objectAtIndex:2] selected]) {
                sourceButtonText = @"Rep. Source: Real Time";
                sourceDisplayed = 2;
            } else {
                sourceButtonText = @"Rep. Source: Twitter";
                sourceDisplayed = 3;
            }
            
            numSourcesSelected = 1;
        } else {
            numSourcesSelected = [languageSources count];
            NSString *languageName = @"";

            if (sourceDisplayed >= [languagesSelected count])
                sourceDisplayed = 0;
            
            for (Source *currentLanguage in languageSources) 
                if ([[currentLanguage lang_code] isEqualToString:[languagesSelected objectAtIndex:sourceDisplayed]])
                    languageName = [currentLanguage name];
            
            if (numSourcesSelected > 1) {
                sourceButtonText = [NSString stringWithFormat:@"Languages: %@...", languageName];
            } else {
                sourceButtonText = [NSString stringWithFormat:@"Language: %@", languageName];
            }
        }

    } else if (sourcesSelected == feedSourcesSelected) {
        int firstSelected = -1, feedsSelected = 0;
        int feedCount = [feedSources count];
        for (int i = 0; i < feedCount; i++) 
            if ([[feedSources objectAtIndex:i] selected]) {
                feedsSelected++;
                if (firstSelected == -1)
                    firstSelected = i;
            }
        if (feedsSelected > 1) {
            sourceButtonText = [NSString stringWithFormat:@"Sources: %@...", [[feedSources objectAtIndex:firstSelected] name]];
        } else {
            sourceButtonText = [NSString stringWithFormat:@"Source: %@", [[feedSources objectAtIndex:firstSelected] name]];
        }
        numSourcesSelected = feedsSelected;
        sourceDisplayed = firstSelected;
    } else if (sourcesSelected == countrySourcesSelected) {
        int firstSelected = -1, countriesSelected = 0;
        int countryCount = [countrySources count];
        for (int i = 0; i < countryCount; i++) 
            if ([[countrySources objectAtIndex:i] selected])  {
                countriesSelected++;
                if (firstSelected == -1)
                    firstSelected = i;
            }
        
        if (countriesSelected > 1)
            sourceButtonText = [NSString stringWithFormat:@"Sources from: %@...", [[countrySources objectAtIndex:firstSelected] name]];
        else
            sourceButtonText = [NSString stringWithFormat:@"Sources from: %@", [[countrySources objectAtIndex:firstSelected] name]];
        numSourcesSelected = countriesSelected;
        sourceDisplayed = firstSelected;
    } else {
        int firstSelected = -1;
        int i = 0;
        for (Source *currentSource in boundSources) {
            if ([currentSource selected]) {
                firstSelected = i;
                break;
            }
            i++;
        }
        numSourcesSelected = 1;
        sourceDisplayed = firstSelected;
        
        sourceButtonText = [NSString stringWithFormat:@"Sources from Region: %@", [[boundSources objectAtIndex:firstSelected] name]];
    }
    
    if (sourcesSelected != allSourcesSelected || sourceDisplayed != 0) {
        sourceCancelButton.hidden = NO;
    } else {
        if ([languagesSelected count] == 0 || ([languagesSelected count] == 1 && [languagesSelected containsObject:@"en"]))
            sourceCancelButton.hidden = YES;
        else
            sourceCancelButton.hidden = NO;
    }
    
    if (numSourcesSelected == 1) {
        [sourceButton setEnabled:NO];
    } else {
        [sourceButton setEnabled:YES];
    }
    [sourceButton setTitle:sourceButtonText forState:UIControlStateNormal];
}

- (void) initializeSources
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    NSData *allSourcesData = [prefs objectForKey:@"allSourcesData"];
    if (allSourcesData != nil)
        allSources = [[NSMutableArray alloc] initWithArray:[NSKeyedUnarchiver unarchiveObjectWithData:allSourcesData]];
    
    NSData *feedSourcesData = [prefs objectForKey:@"feedSourcesData"];
    if (feedSourcesData != nil)
        feedSources = [[NSMutableArray alloc] initWithArray:[NSKeyedUnarchiver unarchiveObjectWithData:feedSourcesData]];
    
    NSData *countrySourcesData = [prefs objectForKey:@"countrySourcesData"];
    if (countrySourcesData != nil) 
        countrySources = [[NSMutableArray alloc] initWithArray:[NSKeyedUnarchiver unarchiveObjectWithData:countrySourcesData]];
    
    NSData *boundSourcesData = [prefs objectForKey:@"boundSourcesData"];
    if (boundSourcesData != nil)
        boundSources = [[NSMutableArray alloc] initWithArray:[NSKeyedUnarchiver unarchiveObjectWithData:boundSourcesData]];
    else
        boundSources = [[NSMutableArray alloc] init];
    
    NSData *languageSourcesData = [prefs objectForKey:@"languageSourcesData"];
    if (languageSourcesData != nil)
        languageSources = [[NSMutableArray alloc] initWithArray:[NSKeyedUnarchiver unarchiveObjectWithData:languageSourcesData]];
        
    languagesSelected = [[NSMutableArray alloc] init];
    
    
    if (allSourcesData == nil) {
        allSources = [[NSMutableArray alloc] init];
        Source *recentSource = [[Source alloc] initWithName:@"Most Recent" feed_link:0 andSourceType:allSource];
        [recentSource setSelected:TRUE];
        [allSources addObject:recentSource];
        [allSources addObject:[[Source alloc] initWithName:@"Most Reputable" feed_link:1 andSourceType:allSource]];
        [allSources addObject:[[Source alloc] initWithName:@"Real Time" feed_link:2 andSourceType:allSource]];
        
        allSourcesData = [NSKeyedArchiver archivedDataWithRootObject:allSources];
        [prefs setObject:allSourcesData forKey:@"allSourcesData"];
        
        sourcesSelected = allSourcesSelected;
    } else {
        if ([self itemSelectedInArray:allSources])
            sourcesSelected = allSourcesSelected;
        else if ([self itemSelectedInArray:feedSources])
            sourcesSelected = feedSourcesSelected;
        else if ([self itemSelectedInArray:countrySources])
            sourcesSelected = countrySourcesSelected;
        else if ([self itemSelectedInArray:boundSources])
            sourcesSelected = boundSourcesSelected;
    }
    
    if (feedSources == nil) {
        NSLog(@"Feed sources nil");
        feedSources = [[NSMutableArray alloc] init];
        
        GetFeaturedFeeds *getFeaturedFeeds = [[GetFeaturedFeeds alloc] initWithViewController:self];
        [simulatorQueue addOperation:getFeaturedFeeds];
    } else {
        numSourcesSelected = 0;
        
        for (Source *feedSource in countrySources)
            if ([feedSource selected])
                numSourcesSelected++;
        
    }
    
    if (countrySources == nil) {
        countrySources = [[NSMutableArray alloc] init];
        [countrySources addObject:[[Source alloc] initWithName:@"Australia" andSourceType:countrySource andSource_Location:@"AU"]];
        [countrySources addObject:[[Source alloc] initWithName:@"Canada"andSourceType:countrySource andSource_Location:@"CA"]];
        [countrySources addObject:[[Source alloc] initWithName:@"India"andSourceType:countrySource andSource_Location:@"IN"]];
        [countrySources addObject:[[Source alloc] initWithName:@"Iran"andSourceType:countrySource andSource_Location:@"IR"]];
        [countrySources addObject:[[Source alloc] initWithName:@"Ireland"andSourceType:countrySource andSource_Location:@"IE"]];
        [countrySources addObject:[[Source alloc] initWithName:@"Israel"andSourceType:countrySource andSource_Location:@"IL"]];
        [countrySources addObject:[[Source alloc] initWithName:@"Japan"andSourceType:countrySource andSource_Location:@"JP"]];
        [countrySources addObject:[[Source alloc] initWithName:@"Mexico"andSourceType:countrySource andSource_Location:@"MX"]];
        [countrySources addObject:[[Source alloc] initWithName:@"New Zealand"andSourceType:countrySource andSource_Location:@"NZ"]];
        [countrySources addObject:[[Source alloc] initWithName:@"Russia"andSourceType:countrySource andSource_Location:@"RU"]];
        [countrySources addObject:[[Source alloc] initWithName:@"United Kingdom"andSourceType:countrySource andSource_Location:@"GB"]];
        [countrySources addObject:[[Source alloc] initWithName:@"United States"andSourceType:countrySource andSource_Location:@"US"]];
        
        countrySourcesData = [NSKeyedArchiver archivedDataWithRootObject:countrySources];
        [prefs setObject:countrySourcesData forKey:@"countrySourcesData"];
    } else {
        numSourcesSelected = 0;
        
        for (Source *feedSource in countrySources)
            if ([feedSource selected])
                numSourcesSelected++;
    }
    
    if (languageSources == nil) {
        languageSources = [[NSMutableArray alloc] init];
        [languageSources addObject:[[Source alloc] initWithName:@"العربية" andEnglishName:@"Arabic" andLanguageCode:@"ar"]];
        [languageSources addObject:[[Source alloc] initWithName:@"汉语/漢語" andEnglishName:@"Chinese" andLanguageCode:@"zh"]];
        [languageSources addObject:[[Source alloc] initWithName:@"Nederlands" andEnglishName:@"Dutch" andLanguageCode:@"nl"]];
        Source *englishLanguageSource = [[Source alloc] initWithName:@"English" andEnglishName:@"English" andLanguageCode:@"en"];
        [englishLanguageSource setSelected:YES];
        [languageSources addObject:englishLanguageSource];
        [languageSources addObject:[[Source alloc] initWithName:@"Français" andEnglishName:@"French" andLanguageCode:@"fr"]];
        [languageSources addObject:[[Source alloc] initWithName:@"Deutsch" andEnglishName:@"German" andLanguageCode:@"de"]];
        [languageSources addObject:[[Source alloc] initWithName:@"ελληνικά" andEnglishName:@"Greek" andLanguageCode:@"el"]];
        [languageSources addObject:[[Source alloc] initWithName:@"עִבְרִית" andEnglishName:@"Hebrew" andLanguageCode:@"he"]];
        [languageSources addObject:[[Source alloc] initWithName:@"हिंदी" andEnglishName:@"Hindi" andLanguageCode:@"hi"]];
        [languageSources addObject:[[Source alloc] initWithName:@"Italiano" andEnglishName:@"Italian" andLanguageCode:@"it"]];
        [languageSources addObject:[[Source alloc] initWithName:@"日本語" andEnglishName:@"Japanese" andLanguageCode:@"ja"]];
        [languageSources addObject:[[Source alloc] initWithName:@"فارسی" andEnglishName:@"Persian" andLanguageCode:@"fa"]];
        [languageSources addObject:[[Source alloc] initWithName:@"Português" andEnglishName:@"Portuguese" andLanguageCode:@"pt"]];
        [languageSources addObject:[[Source alloc] initWithName:@"ру́сский язы́к" andEnglishName:@"Russian" andLanguageCode:@"ru"]];
        [languageSources addObject:[[Source alloc] initWithName:@"Español" andEnglishName:@"Spanish" andLanguageCode:@"es"]];
        //[languageSources addObject:[[Source alloc] initWithName:@"اردو" andEnglishName:@"Urdu" andLanguageCode:@"ur"]];
        languageSourcesData = [NSKeyedArchiver archivedDataWithRootObject:languageSources];
        [prefs setObject:languageSourcesData forKey:@"languageSourcesData"];
        
    } else {
        for (Source *languageSource in languageSources) 
            if ([languageSource selected]) 
                [languagesSelected addObject:[languageSource lang_code]];
            
    }
    
    [self setSourceAndCancelButton];
}

-(void) addBoundRegionWithSource:(Source *)boundSource
{
    int i = 0;
    for (Source *currentBound in boundSources) {
        if ([currentBound selected])
            [[boundSources objectAtIndex:i] setSelected:NO];
            
        i++;
    }
    
    [boundSources addObject:boundSource];
    boundSources = [[NSMutableArray alloc] initWithArray:[boundSources sortedArrayUsingSelector:@selector(compare:)]];
}

-(void) removeBoundRegionWithName:(NSString *)boundName
{
    for (Source *currentBound in boundSources) {
        if ([[currentBound name] isEqualToString:boundName]) {
            [boundSources removeObject:currentBound];
            break;
        }
    }
}

-(IBAction)sourceButtonSelected:(id)sender
{
    
    //If only one source selected, do nothing
    if (numSourcesSelected < 2) {
        return;
    }
    
    NSString *sourceButtonText;
    
    if (sourcesSelected == allSourcesSelected) {
        if(!([languagesSelected count] == 1) || ![languagesSelected containsObject:@"en"]) {
            NSString *curr_lang_code = @"";
            int secondSelected = 0;
            
            if (sourceDisplayed+1 >= [languagesSelected count]) {
                curr_lang_code = [languagesSelected objectAtIndex:0];
                sourceDisplayed = 0;
            } else {
                curr_lang_code = [languagesSelected objectAtIndex:sourceDisplayed+1];
                sourceDisplayed++;
            }
                
            int languageCount = [languageSources count];
            
            for (int i = 0; i < languageCount; i++) 
                if ([[[languageSources objectAtIndex:i] lang_code] isEqualToString:curr_lang_code]) {
                    secondSelected = i;
                    break;
                }
            
            sourceButtonText = [NSString stringWithFormat:@"Languages: %@...", [[languageSources objectAtIndex:secondSelected] name]];
        }
    } else if (sourcesSelected == feedSourcesSelected) {
        int secondSelected = -1;
        int feedCount = [feedSources count];
        for (int i = sourceDisplayed+1; i < feedCount; i++) 
            if ([[feedSources objectAtIndex:i] selected]) {
                secondSelected = i;
                break;
            }
        
        if (secondSelected == -1) 
            for (int i = 0; i < sourceDisplayed; i++) 
                if ([[feedSources objectAtIndex:i] selected]) {
                    secondSelected = i;
                    break;
                }
        
        sourceButtonText = [NSString stringWithFormat:@"Sources: %@...", [[feedSources objectAtIndex:secondSelected] name]];
        sourceDisplayed = secondSelected;
    } else if (sourcesSelected == countrySourcesSelected) {
        int secondSelected = -1;
        int countryCount = [countrySources count];
        for (int i = sourceDisplayed+1; i < countryCount; i++) 
            if ([[countrySources objectAtIndex:i] selected])  {
                secondSelected = i;
                break;
            }
        
        if (secondSelected == -1) {
            for (int i = 0; i < sourceDisplayed; i++) 
                if ([[countrySources objectAtIndex:i] selected]) {
                    secondSelected = i;
                    break;
                }
        }
        
        sourceButtonText = [NSString stringWithFormat:@"Sources from: %@...", [[countrySources objectAtIndex:secondSelected] name]];

        sourceDisplayed = secondSelected;
    } else {
        //Shouldn't reach - Consistency / Error Checking
    }

    [sourceButton setTitle:sourceButtonText forState:UIControlStateNormal];
}

// Update number of documents for sources
- (void) updateNumSources
{
    NSLog(@"Update num sources called");
    
    if (feedSources != nil && [feedSources count] != 0) {
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSData *feedSourcesData = [NSKeyedArchiver archivedDataWithRootObject:feedSources];
        [prefs setObject:feedSourcesData forKey:@"feedSourcesData"];
        
        
        //Changed to SimulatorQueue to avoid request queue from cancelled
        SourcesNumDocs *sourcesNumDocs = [[SourcesNumDocs alloc] initWithViewController:self forMode:1];
        [simulatorQueue addOperation:sourcesNumDocs];
        sourcesNumDocs = [[SourcesNumDocs alloc] initWithViewController:self forMode:2];
        [simulatorQueue addOperation:sourcesNumDocs];
        sourcesNumDocs = [[SourcesNumDocs alloc] initWithViewController:self forMode:3];
        [simulatorQueue addOperation:sourcesNumDocs];
    }
}

#pragma mark - iPad

-(void)removeDetailViewControllerFromSuperview
{
    [padDetailViewController.view removeFromSuperview];
}

-(void)dismissDetailViewController
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:.4];
    [padDetailViewController.view setAlpha:0.0];
    [blackButton setAlpha:0.0];
    [UIView commitAnimations];
    [NSTimer scheduledTimerWithTimeInterval:.41 target:self selector:@selector(removeDetailViewControllerFromSuperview) userInfo:nil repeats:NO];
}

#pragma mark - NSXMLParser Callback

- (void) parseEnded:(NSMutableArray *)resultAnnotations
{
    NSLog(@"View Controller found %d annotations", [resultAnnotations count]);
    
    
    [mapView removeAnnotations:mapView.annotations];
    if (annotations != nil) {
        [annotations removeAllObjects];
        annotations = nil;
    }
    
    NSMutableArray *imageURLs = [[NSMutableArray alloc] init];
    
    if (standMode == 2) {
        annotations = [[NSMutableArray alloc] init];
        for (NewsAnnotation *currentAnnotation in resultAnnotations) {
            if (![imageURLs containsObject:[currentAnnotation img_url]]) {
                if ([[currentAnnotation img_url] rangeOfString:@"yahoo.com"].location == NSNotFound) {
                    [annotations addObject:currentAnnotation];
                    [imageURLs addObject:[currentAnnotation img_url]];
                }
            }
        }
    } else {
        annotations = [[NSMutableArray alloc] initWithArray:resultAnnotations];
    }
        
    if (checkForMarker && [annotations count] == 0) {
        MKCoordinateSpan span = MKCoordinateSpanMake(mapView.region.span.latitudeDelta +.02, mapView.region.span.longitudeDelta +.02);
        MKCoordinateRegion region;
        region.span = span;
        region.center = mapView.region.center;
        [mapView setRegion:region animated: YES];
    } else {
        checkForMarker = FALSE;
    }
    
    [self mapSliderChangedValue:nil];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [activityIndicator stopAnimating];
}

@end









