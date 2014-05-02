//
//  TopStoriesViewController.m
//  NewsStand
//
//  Created by Brendan on 1/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TopStoriesViewController.h"
#import "TopStoriesCell.h"
#import "CustomWebView.h"
#import "DetailViewController.h"
#import "SettingsViewController.h"
#import "SourcesViewController.h"
#import "ImageViewer.h"
#import "TopMarkersRequestOperation.h"
#import "NewsAnnotationView.h"
#import "VideoViewController.h"
#import "TopStoriesRequestOperation.h"

#import "UIDevice-ORMMA.h"


@implementation TopStoriesViewController

@synthesize tableView, mapView, mapSlider;
@synthesize annotations, incomingAnnotations;
@synthesize refreshButton, plusButton, minusButton;
@synthesize modeLabel, searchLabel, searchCancelButton, sourceButton, sourceCancelButton;
@synthesize queryString;
@synthesize tabBar;
@synthesize allSources, feedSources, countrySources, boundSources;
@synthesize botFirstItem, botSecondItem, botThirdItem, botFourthItem, botFifthItem, botSixthItem;
@synthesize motionManager;
@synthesize checkOrientation;
@synthesize activityIndicator;
@synthesize currentMarker, markers;
@synthesize searchAlertView;
@synthesize queue, currentString, parser;
@synthesize topPadDetailViewController, blackButton;
@synthesize topStoriesViewControllerRotated;

BOOL detailViewShown = FALSE;
static NSString * const GMAP_ANNOTATION_SELECTED = @"gMapAnnotationSelected";
static float MOTION_SCALE = 5.0;

#pragma mark - Update Top Stories

- (void)updateTopStories
{
    ViewController *viewController = [[self.navigationController viewControllers] objectAtIndex:0];
    
    NSString *sourceParamString = [viewController sourceParamString];
    NSString *settingsParamString = [viewController settingsParamString];
    
    standMode = [viewController standMode];
    
    NSString *mode = @"newsstand";
    if (standMode == 1) {
        mode = @"twitterstand";
        queryString = [[NSString alloc] initWithString:[NSString stringWithFormat:@"http://%@.umiacs.umd.edu/news/iphone_results?a=5%@", mode, settingsParamString]];
    } else {
        queryString = [[NSString alloc] initWithString:[NSString stringWithFormat:@"http://%@.umiacs.umd.edu/news/iphone_results?a=5%@%@", mode, sourceParamString, settingsParamString]];
    }
    
    queryString = [self URLEncodeString:queryString];

    TopStoriesRequestOperation *topStoriesRequestionOperation = [[TopStoriesRequestOperation alloc] initWithRequestString:queryString andTopStoriesViewController:self];
    [queue addOperation:topStoriesRequestionOperation];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

-(NSString *) URLEncodeString:(NSString *) str
{
    
    NSMutableString *tempStr = [NSMutableString stringWithString:str];
    [tempStr replaceOccurrencesOfString:@" " withString:@"+" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [tempStr length])];
    
    
    return [[NSString stringWithFormat:@"%@",tempStr] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

#pragma mark - Table View Data Source  /  Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
   return [annotations count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"";
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int row = [indexPath row];
    
    TopStoriesCell *cell = [aTableView dequeueReusableCellWithIdentifier:@"TopStoriesCell"];
    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"TopStoriesCell" owner:nil options:nil];
        for (id currentObject in topLevelObjects) {
            if ([currentObject isKindOfClass:[UITableViewCell class]]) {
                cell = (TopStoriesCell *)currentObject;
                break;
            }
        }
    }
    
    UIView *bgColorView = [[UIView alloc] init];
    bgColorView.backgroundColor = [UIColor colorWithRed:(76.0/255.0) green:(161.0/255.0) blue:(255.0/255.0) alpha:1.0]; // perfect color suggested by @mohamadHafez
    bgColorView.layer.masksToBounds = YES;
    cell.selectedBackgroundView = bgColorView;
    
    NewsAnnotation *currAnnotation = [annotations objectAtIndex:row];
    if (![currAnnotation display_translate_title])
        [[cell linkButton] setTitle:[currAnnotation subtitle] forState:UIControlStateNormal];
    else 
        [[cell linkButton] setTitle:[currAnnotation translate_title] forState:UIControlStateNormal];
    
    [[cell timeLabel] setText:[currAnnotation time]];
    [[cell domainLabel] setText:[currAnnotation domain]];
    
    if ([currAnnotation translate_title] != nil && ![[currAnnotation translate_title] isEqualToString:@""]) {
        [[cell translateButton] setHidden:NO];
        [[cell translatePageButton] setHidden:NO];
    } else {
        [[cell translateButton] setHidden:YES];
        [[cell translatePageButton] setHidden:YES];
    }
    
    if ([currAnnotation num_images] > 0)
        [[cell imageButton] setHidden:NO];
    else
        [[cell imageButton] setHidden:YES];
    
    if ([currAnnotation num_videos] > 0)
        [[cell videoButton] setHidden:NO];
    else
        [[cell videoButton] setHidden:YES];
    
    if ([currAnnotation num_docs] > 0)
        [[cell relatedButton] setHidden:NO];
    else
        [[cell relatedButton] setHidden:YES];

    
    cell.linkButton.tag = row;
    cell.translateButton.tag = row;
    cell.translatePageButton.tag = row;
    cell.imageButton.tag = row;
    cell.videoButton.tag = row;
    cell.relatedButton.tag = row;
    
    [[cell descriptionLabel] setText:[currAnnotation description]];

    NSString * imageName = @"";
    if ([[currAnnotation topic] isEqualToString:@"Health"] || [[currAnnotation topic] isEqualToString:@"Sports"])
        imageName = [currAnnotation.topic stringByAppendingString:@".png"];
    else
        imageName = [currAnnotation.topic stringByAppendingString:@".gif"];
    
	[cell.topicImageView setImage:[UIImage imageNamed:imageName]];
    
    return cell;
}

-(void) tableView:(UITableView *)localTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    int row = [indexPath row];
    currentRequestID++;
       
    //[queue cancelAllOperations];
    
    ViewController *viewController = [self.navigationController.viewControllers objectAtIndex:0];
    
    NSString *urlRequestString;
    if (standMode == 0) {
     urlRequestString = [[NSString alloc] initWithFormat:@"http://newsstand.umiacs.umd.edu/news/xml_map?cluster_id=%d%@%@", [[annotations objectAtIndex:row] cluster_id], [viewController sourceParamString], [viewController settingsParamString]];
    } else {
      urlRequestString = [[NSString alloc] initWithFormat:@"http://twitterstand.umiacs.umd.edu/news/xml_map?cluster_id=%d%@", [[annotations objectAtIndex:row] cluster_id], [viewController settingsParamString]];  
    }
    
    TopMarkersRequestOperation *topMarkersRequestOperation = [[TopMarkersRequestOperation alloc] initWithRequestString:urlRequestString andRequestID:currentRequestID andTopStories:self];
    
    [queue addOperation:topMarkersRequestOperation];
    
    hoverIndex = row - [[[localTableView indexPathsForVisibleRows] objectAtIndex:0] row];
    lastSelectedRow = row;
}


-(CGFloat) tableView:(UITableView *)aTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self tableView: aTableView cellForRowAtIndexPath:indexPath];
    return cell.bounds.size.height;
}

#pragma mark - ScrollView Delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [modeLabel setHidden:YES];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    int numVisible = [[tableView indexPathsForVisibleRows] count];
    int index, i = 0;
    
    if (hoverIndex > numVisible)
        index = numVisible-1;
    else
        index = hoverIndex;
    
    for (NSIndexPath * path in [tableView indexPathsForVisibleRows]) {
        int row = [path row];
        if (i == index) {
            [tableView selectRowAtIndexPath:path animated:NO scrollPosition:UITableViewScrollPositionNone];
            if (row != lastSelectedRow) {
                [self tableView:tableView didSelectRowAtIndexPath:path];
                lastSelectedRow = row;
            }
        }
        i += 1;
    }
}

#pragma mark - Initialization 

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andAnnotations:(NSMutableArray*)topAnnotations
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        annotations = topAnnotations;
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - Map

-(MKAnnotationView *) mapView:(MKMapView *)localMapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    
    NewsAnnotationView *annotationView = (NewsAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"newsview"];
    if (annotationView == nil)
        annotationView = [[NewsAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"newsview"];
    
    NewsAnnotation *newsAnnotation = (NewsAnnotation *)annotation;
    annotationView.canShowCallout = YES;
    [annotationView setAnnotation:annotation];
    
    NSString *topic = [newsAnnotation topic];
    
    ViewController *viewController = [[self.navigationController viewControllers] objectAtIndex:0];
    
    if ([topic isEqualToString:@"General"]) 
        [annotationView setImage:[viewController generalImage]];
    else if ([topic isEqualToString:@"Business"])
        [annotationView setImage:[viewController businessImage]];
    else if ([topic isEqualToString:@"Health"])
        [annotationView setImage:[viewController healthImage]];
    else if ([topic isEqualToString:@"SciTech"])
        [annotationView setImage:[viewController sciTechImage]];
    else if ([topic isEqualToString:@"Entertainment"])
        [annotationView setImage:[viewController entertainmentImage]];
    else if ([topic isEqualToString:@"Sports"])
        [annotationView setImage:[viewController sportsImage]];
    
    [annotationView setRightCalloutAccessoryView:[UIButton buttonWithType:UIButtonTypeDetailDisclosure]];    
    
    [annotationView addObserver:self forKeyPath:@"selected" options:NSKeyValueObservingOptionNew context:(void*)("gMapAnnotationSelected")];
    //[annotationView setObserving:YES];
    
    return annotationView;
}

- (void)mapView:(MKMapView *)_mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control 
{   
    NewsAnnotation *annotation = [view annotation];
    ViewController *viewController = [[self.navigationController viewControllers] objectAtIndex:0];
    
    orientationBefore = [[UIApplication sharedApplication] statusBarOrientation];
    
    if (!isPad) {
        checkOrientation = TRUE;
        
        if (viewController.layerSelected == iconLayer || viewController.layerSelected == locationLayer) {        
            DetailViewController *detailViewController = [[DetailViewController alloc] initWithGazId:[annotation gaz_id] andSourceString:[viewController sourceParamString]andSettingsString:[viewController settingsParamString] withTitle:[annotation name] andStandMode:standMode andClusterID:[annotation cluster_id]];
            [self.navigationController pushViewController:detailViewController animated:YES];
        } else if (viewController.layerSelected == peopleLayer) {
            DetailViewController *detailViewController = [[DetailViewController alloc] initWithGazId:[annotation gaz_id] andSourceString:[viewController sourceParamString] andSettingsString:[viewController settingsParamString] withTitle:[NSString stringWithFormat:@"People in %@", [annotation name]]  andStandMode:standMode andClusterID:[annotation cluster_id]];
            [self.navigationController pushViewController:detailViewController animated:YES];
        } else {
            DetailViewController *detailViewController = [[DetailViewController alloc] initWithGazId:[annotation gaz_id] andSourceString:[viewController sourceParamString] andSettingsString:[viewController settingsParamString] withTitle:[NSString stringWithFormat:@"Diseases in %@", [annotation name]]  andStandMode:standMode andClusterID:[annotation cluster_id]];
            [self.navigationController pushViewController:detailViewController animated:YES];
        }
    } else { //iPad
        CGSize screenDimensions;
        detailViewShown = TRUE;
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
            
            if (viewController.layerSelected == iconLayer || viewController.layerSelected == locationLayer) {
                topPadDetailViewController = [[DetailViewController alloc] initWithNibName:@"DetailViewController_iPad" andGazId:[annotation gaz_id] andSourceString:[viewController sourceParamString] andSettingsString:[viewController settingsParamString] withTitle:[annotation name] andStandMode:standMode andClusterID:[annotation cluster_id]];
            } else if (viewController.layerSelected == peopleLayer) {
                topPadDetailViewController = [[DetailViewController alloc] initWithNibName:@"DetailViewController_iPad" andGazId:[annotation gaz_id] andSourceString:[viewController sourceParamString] andSettingsString:[viewController settingsParamString] withTitle:[NSString stringWithFormat:@"People in %@", [annotation name]]  andStandMode:standMode andClusterID:[annotation cluster_id]];
            } else {
                topPadDetailViewController = [[DetailViewController alloc] initWithNibName:@"DetailViewController_iPad" andGazId:[annotation gaz_id] andSourceString:[viewController sourceParamString] andSettingsString:[viewController settingsParamString] withTitle:[NSString stringWithFormat:@"Diseases in %@", [annotation name]] andStandMode:standMode andClusterID:[annotation cluster_id]];
            }
            
            [topPadDetailViewController.view.layer setCornerRadius:30.0f];
            [topPadDetailViewController.view.layer setBorderColor:[UIColor lightGrayColor].CGColor];
            [topPadDetailViewController.view.layer setBorderWidth:1.5f];
            [topPadDetailViewController.view.layer setShadowColor:[UIColor blackColor].CGColor];
            [topPadDetailViewController.view.layer setShadowOpacity:.8];
            [topPadDetailViewController.view.layer setShadowRadius:3.0];
            [topPadDetailViewController.view.layer setShadowOffset:CGSizeMake(2.0, 2.0)];
            
            
            if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
                topPadDetailViewController.view.frame = CGRectMake(screenWidth / 5, screenHeight / 5, screenWidth * .6, screenHeight * .6);
            } else {
                topPadDetailViewController.view.frame = CGRectMake(screenWidth / 5, screenHeight / 5, screenWidth * .6, screenHeight * .6);
            }
            
            topPadDetailViewController.view.clipsToBounds = YES;
            topPadDetailViewController.view.layer.shadowOpacity = 1.0;
            topPadDetailViewController.view.layer.cornerRadius = 5;
            [self.view addSubview:topPadDetailViewController.view];
        }
    }
}
 

- (void) toggleDisplayingMapButtons:(BOOL)displayButtons
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:.2];
    if (displayButtons) {
        [refreshButton setAlpha:0.0];
        [plusButton setAlpha:0.0];
        [minusButton setAlpha:0.0];
        [mapSlider setAlpha:0.0];
        [modeLabel setHidden:YES];
    } else {
        [refreshButton setAlpha:0.5];
        [plusButton setAlpha:0.5];
        [minusButton setAlpha:0.5];
        [mapSlider setAlpha:1.0];
    }
    [UIView commitAnimations];
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)localContext {
    char *actionCharStr = (char*)localContext;
    NSString *action = [NSString stringWithCString:actionCharStr encoding:NSStringEncodingConversionAllowLossy];
    
	if ([action isEqualToString:GMAP_ANNOTATION_SELECTED]) {
		BOOL annotationAppeared = [[change valueForKey:@"new"] boolValue];
		[self toggleDisplayingMapButtons:annotationAppeared];
	}
    
}

- (void) mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
    
    if (!initialCall) 
        [modeLabel setHidden:YES];
        
    initialCall = FALSE;
}

#pragma mark - Cell Buttons
-(void)titleButtonPressedOnRow:(int) row
{
    checkOrientation = TRUE;
    orientationBefore = [[UIApplication sharedApplication] statusBarOrientation];
    NewsAnnotation *selectedAnnotation = [annotations objectAtIndex:row];
    CustomWebView *customWebView = [[CustomWebView alloc] initWithString:selectedAnnotation.url andTitle:@"News" andArticleTitle:selectedAnnotation.subtitle];
    
    [self.navigationController pushViewController:customWebView animated:YES];
}
-(void)translateButtonPressedOnRow:(int)row
{
    NewsAnnotation *selectedAnnotation = [annotations objectAtIndex:row];
    [selectedAnnotation setDisplay_translate_title:![selectedAnnotation display_translate_title]];
    [tableView reloadData];
}

-(void)translatePageButtonPressedOnRow:(int)row
{
    checkOrientation = TRUE;
    orientationBefore = [[UIApplication sharedApplication] statusBarOrientation];
    NewsAnnotation *selectedAnnotation = [annotations objectAtIndex:row];
    NSString *translate_url = [NSString stringWithFormat:@"http://translate.google.com/translate_p?hl=en&sl=auto&tl=en&u=%@", [selectedAnnotation url]];
    CustomWebView *customWebView = [[CustomWebView alloc] initWithString:translate_url andTitle:@"News" andArticleTitle:[selectedAnnotation subtitle]];
    
    [self.navigationController pushViewController:customWebView animated:YES];
}

-(void)imageButtonPressedOnRow:(int) row
{
    checkOrientation = TRUE;
    orientationBefore = [[UIApplication sharedApplication] statusBarOrientation];
    NewsAnnotation *selectedAnnotation = [annotations objectAtIndex:row];
    ImageViewer *imageViewer = [[ImageViewer alloc] initWithImageTopic:@"Images" withImageId:[selectedAnnotation cluster_id] andStandMode:standMode andConstraints:@""];
    [self.navigationController pushViewController:imageViewer animated:YES];
}

-(void)videoButtonPressedOnRow:(int) row
{
    checkOrientation = TRUE;
    orientationBefore = [[UIApplication sharedApplication] statusBarOrientation];
    VideoViewController *videoViewController = [[VideoViewController alloc] initWithClusterID:[[annotations objectAtIndex:row] cluster_id] andStandMode:standMode];
    [self.navigationController pushViewController:videoViewController animated:YES];
}

-(void)relatedButtonPressedOnRow:(int) row
{
    checkOrientation = TRUE;
    orientationBefore = [[UIApplication sharedApplication] statusBarOrientation];
    
    NSString *URLString;
    if (standMode == 0) {
        URLString = [NSString stringWithFormat:@"http://newsstand.umiacs.umd.edu/news/story_light?cluster_id=%d&limit=30&page=1", [[annotations objectAtIndex:row] cluster_id]];
    } else {
        URLString = [NSString stringWithFormat:@"http://twitterstand.umiacs.umd.edu/news/story_light?cluster_id=%d&limit=30&page=1", [[annotations objectAtIndex:row] cluster_id]];
    }
     
    CustomWebView *customWebView = [[CustomWebView alloc] initWithString:URLString andTitle:@"Related"];
    [self.navigationController pushViewController:customWebView animated:YES];
}

#pragma mark - Tab Bar Delegate Functions

- (void) setBotTabBarForHandMode
{
    if (handMode == 3) {
        [botFirstItem setImage:[UIImage imageNamed:@"map.png"]];
        [botFirstItem setTitle:@"Map"];
        
        switch (standMode) {
            case 0:
                [botSecondItem setImage:[UIImage imageNamed:@"bird.png"]];
                [botSecondItem setTitle:@"TwitterStand"];
                break;
            case 1:
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
                [botFifthItem setImage:[UIImage imageNamed:@"news_icon.png"]];
                [botFifthItem setTitle:@"NewsStand"];
                break;
        }
        
        [botSixthItem setImage:[UIImage imageNamed:@"map.png"]];
        [botSixthItem setTitle:@"Map"];
    }
}


// Automatically called when a tab bar item is selected
- (void) tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
   
    if (item.tag == 0) {
        if (handMode != 3)
            [self infoItemPushed];
        else
            [self mapItemPushed];
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
            [self mapItemPushed];
        else
            [self infoItemPushed];
    }
    
}

-(void)infoItemPushed 
{
    checkOrientation = TRUE;
    orientationBefore = [[UIApplication sharedApplication] statusBarOrientation];
    CustomWebView *customWebView = [[CustomWebView alloc] initWithString:@"http://www.cs.umd.edu/~hjs/newsstand-first-page.html" andTitle:@"Info"];
    [self.navigationController pushViewController:customWebView animated:YES];
}
-(void)searchItemPushed
{
    ViewController *viewController = [[self.navigationController viewControllers] objectAtIndex:0];
    if (searchAlertView == nil) {
        searchAlertView = [[UIAlertView alloc] initWithTitle:@"Enter a search keyword" message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Search", nil];
        searchAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;
        [[searchAlertView textFieldAtIndex:0] setClearButtonMode:UITextFieldViewModeWhileEditing];
    }
    
    [[searchAlertView textFieldAtIndex:0] setText:[viewController searchKeyword]];
    [searchAlertView show];
    alertShown = TRUE;
    
}
-(void)settingsItemPushed
{
    settingsChanged = TRUE;
    checkOrientation = TRUE;
    orientationBefore = [[UIApplication sharedApplication] statusBarOrientation];
    SettingsViewController *settingsViewController = [[SettingsViewController alloc] init];
    [self.navigationController pushViewController:settingsViewController animated:YES];
}
-(void)sourcesItemPushed
{
    sourcesChanged = TRUE;
    checkOrientation = TRUE;
    orientationBefore = [[UIApplication sharedApplication] statusBarOrientation];
    SourcesViewController *sourcesViewController = [[SourcesViewController alloc] init];
    [self.navigationController pushViewController:sourcesViewController animated:YES];
}
-(void)modeItemPushed
{
    UITabBarItem *modeItem;
    
    if (handMode != 3) {
        modeItem = botFifthItem;
    } else {
        modeItem = botSecondItem;
    }
    
    if (standMode == 0) { // In NewsStand switching to TwitterStand
        [modeItem setTitle:@"NewsStand"];
        [modeItem setImage:[UIImage imageNamed:@"camera.png"]];
        [modeLabel setText:@"TwitterStand"];
        [modeLabel setHidden:NO];
        [[[tabBar items] objectAtIndex:3] setEnabled:FALSE]; //disable Sources for TwitterStand
        standMode++;
    } else if (standMode == 1) { // In TwitterStand switching to NewsStand
        [modeItem setTitle:@"TwitterStand"];
        [modeItem setImage:[UIImage imageNamed:@"bird.png"]];
        [modeLabel setText:@"NewsStand"];
        [modeLabel setHidden:NO];
        [[[tabBar items] objectAtIndex:3] setEnabled:TRUE];
        standMode = 0;
    }
    
    [[[self.navigationController viewControllers] objectAtIndex:0] setStandMode:standMode];
    [self disableItemsForStandMode];
    
    [self setBotTabBarForHandMode];
    [self updateTopStories];
    [tabBar setSelectedItem:nil];
}
-(void)mapItemPushed
{
    [self.navigationController popToRootViewControllerAnimated:YES];
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
    }
}


#pragma mark - View lifecycle

-(void)removeDetailViewControllerFromSuperview
{
    [topPadDetailViewController.view removeFromSuperview];
}

-(void)dismissDetailViewController
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:.4];
    [topPadDetailViewController.view setAlpha:0.0];
    [blackButton setAlpha:0.0];
    [UIView commitAnimations];
    [NSTimer scheduledTimerWithTimeInterval:.41 target:self selector:@selector(removeDetailViewControllerFromSuperview) userInfo:nil repeats:NO];
    
    if ([[[self navigationController] viewControllers] count] > 2 && detailViewShown) {
        detailViewShown = FALSE;
        [(TopStoriesViewController *)[[[self navigationController] viewControllers] objectAtIndex:1] dismissDetailViewController];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    ViewController *viewController = [self.navigationController.viewControllers objectAtIndex:0];
    handMode = [viewController handMode];
    automaticHandMode = [viewController automaticHandMode];
    motionManager = [viewController motionManager];
    
    updatePosition = TRUE;
    [self setTitle:@"Top Stories"];
    orientationBefore = [[UIApplication sharedApplication] statusBarOrientation];
    [activityIndicator setHidesWhenStopped:YES];
    queue = [[NSOperationQueue alloc] init];
    
    if (isPad) {
        if (UIDeviceOrientationIsLandscape(orientationBefore)) { 
            if ([[self.navigationController viewControllers] count] == 2) {
                topStoriesViewControllerRotated = [[TopStoriesViewController alloc] initWithNibName:@"TopStoriesViewController_iPad" andAnnotations:annotations withHoverIndex:hoverIndex lastSelectedRow:lastSelectedRow withMarkers:markers];
            } else {
                topStoriesViewControllerRotated = nil;
            }
        } else {
            if ([[self.navigationController viewControllers] count] == 2) {
                topStoriesViewControllerRotated = [[TopStoriesViewController alloc] initWithNibName:@"TopStoriesViewController_iPad_Land" andAnnotations:annotations withHoverIndex:hoverIndex lastSelectedRow:lastSelectedRow withMarkers:markers];
            } else {
                topStoriesViewControllerRotated = nil;
            }
        }
        
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
        
        float screenWidth = screenDimensions.width;
        float screenHeight = screenDimensions.height;
        [blackButton setFrame:CGRectMake(0.0, 0.0, screenWidth, screenHeight)];
        [blackButton setAlpha:0.0];
        [self.view addSubview:blackButton];
    }
    
    for (UITabBarItem *tabBarItem in tabBar.items) {
        [tabBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                            [UIColor whiteColor], UITextAttributeTextColor,
                                            [UIFont fontWithName:@"Helvetica" size:12.0], UITextAttributeFont, nil]
                                  forState:UIControlStateNormal];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    NSTimer *unhighlightTimer = [NSTimer timerWithTimeInterval:.2 target:self selector:@selector(unhighlightTabbar) userInfo:nil repeats:NO];
    [unhighlightTimer fire];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

#pragma mark - Initialization

- (id)initWithNibName:(NSString *)nibNameOrNil andAnnotations:(NSMutableArray*)topAnnotations withHoverIndex:(int)hoverIn lastSelectedRow:(int)lastRow withMarkers:(NSMutableArray *)lastMarkers
{
    self = [super initWithNibName:nibNameOrNil bundle:nil];
    
    if (self) {
        annotations = [[NSMutableArray alloc] initWithArray:topAnnotations];
        hoverIndex = hoverIn;
        lastSelectedRow = lastRow;
        markers = [[NSMutableArray alloc] initWithArray:lastMarkers];
    }
    
    isPad = ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad);
    
    return self;
}

- (void) initQueryAndSources:(BOOL)updateSources
{
    ViewController *viewController = [self.navigationController.viewControllers objectAtIndex:0];
    
    if (updateSources) {
        allSources = [[NSMutableArray alloc] initWithArray:[viewController allSources]];
        feedSources = [[NSMutableArray alloc] initWithArray:[viewController feedSources]];
        countrySources = [[NSMutableArray alloc] initWithArray:[viewController countrySources]];
        boundSources = [[NSMutableArray alloc] initWithArray:[viewController boundSources]];
        sourcesSelected = [viewController sourcesSelected];
    }
}

- (void) unhighlightTabbar 
{
    [tabBar setSelectedItem:nil];
}

- (void) addDetailViewToRotated
{
    CGSize screenDimensions;
    if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation]))
        screenDimensions = [[UIDevice currentDevice] screenSizeForOrientation:UIDeviceOrientationPortrait];
    else
        screenDimensions = [[UIDevice currentDevice] screenSizeForOrientation:UIDeviceOrientationLandscapeLeft];
    
    float screenWidth = screenDimensions.width;
    float screenHeight = screenDimensions.height;
        
    if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
        topPadDetailViewController.view.frame = CGRectMake(screenWidth / 5, screenHeight / 5, screenWidth * .6, screenHeight * .6);
    } else {
        topPadDetailViewController.view.frame = CGRectMake(screenWidth / 5, screenHeight / 5, screenWidth * .6, screenHeight * .6);
    }

    [topStoriesViewControllerRotated.view addSubview:topPadDetailViewController.view];
    [topStoriesViewControllerRotated setTopPadDetailViewController:topPadDetailViewController];
    [[topStoriesViewControllerRotated blackButton] setFrame:CGRectMake(0.0, 0.0, screenWidth, screenHeight)];
    [[topStoriesViewControllerRotated blackButton] addTarget:topStoriesViewControllerRotated action:@selector(dismissDetailViewController) forControlEvents:UIControlEventTouchUpInside];
    [[topStoriesViewControllerRotated blackButton] setAlpha:.3];
}

- (void) viewWillAppear:(BOOL)animated
{
    NSLog(@"View Will Appear Called");
    ViewController *viewController = [[self.navigationController viewControllers] objectAtIndex:0];
    
    initialCall = TRUE;
    [self updateTopStories];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self.navigationController setToolbarHidden:YES animated:YES];
    if (!isPad)
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:YES];
    else 
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
    
    UIInterfaceOrientation currentOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (checkOrientation) {
        ViewController *viewController = [self.navigationController.viewControllers objectAtIndex:0];
        BOOL portraitFirst = [viewController portraitFirst];
    
        if (orientationBefore == currentOrientation) {
            // do Nothing
        } else if (UIDeviceOrientationIsLandscape(currentOrientation) && UIDeviceOrientationIsLandscape(orientationBefore)) {
            // do Nothing
        } else if (currentOrientation == UIInterfaceOrientationPortrait) {
            if (portraitFirst) {
                NSLog(@"Popped Landscape");
                [self.navigationController popViewControllerAnimated:YES];
            } else {
                if (!isPad) {
                    TopStoriesViewController *topStoriesViewControllerPortrait = [[TopStoriesViewController alloc] initWithNibName:@"TopStoriesViewController_iPhone" andAnnotations:annotations withHoverIndex:hoverIndex lastSelectedRow:lastSelectedRow withMarkers:markers];
                    [self.navigationController pushViewController:topStoriesViewControllerPortrait animated:YES];
                    NSLog(@"Pushed Portrait");
                } else {
                    if ([blackButton alpha] > 0) 
                        [self addDetailViewToRotated];
                    [self.navigationController pushViewController:topStoriesViewControllerRotated animated:YES];
                    NSLog(@"Pushed Portrait");
                }
            }
        } else {
            NSLog(@"Status bar is landscape");
            
            if (portraitFirst) {
                if (!isPad) {
                    TopStoriesViewController *topStoriesViewControllerLandscape = [[TopStoriesViewController alloc] initWithNibName:@"TopStoriesViewController_iPhone_Land" andAnnotations:annotations withHoverIndex:hoverIndex lastSelectedRow:lastSelectedRow withMarkers:markers];
                    [self.navigationController pushViewController:topStoriesViewControllerLandscape animated:YES];
                    NSLog(@"Pushed Landscape");
                } else {
                    if ([blackButton alpha] > 0) 
                        [self addDetailViewToRotated];
                    [self.navigationController pushViewController:topStoriesViewControllerRotated animated:YES];
                    NSLog(@"Pushed Landscape");
                }
            } else {
                [self.navigationController popViewControllerAnimated:YES];
                NSLog(@"Popped Portrait");
            }
        }
        checkOrientation = FALSE;
    }
    
    standMode = [viewController standMode];
    
    handMode = [viewController handMode];
    automaticHandMode = [viewController automaticHandMode];
    [self updateMapButtonsOnHandMode];
    [motionManager startAccelerometerUpdatesToQueue:[[NSOperationQueue alloc] init]
                                        withHandler:^(CMAccelerometerData *data, NSError *error) {
                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                double x = data.acceleration.x * MOTION_SCALE;
                                                if (automaticHandMode) {
                                                    if (x >= 1.0 && handMode != 3) {
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
    [motionManager setAccelerometerUpdateInterval:1.0];
    
    [searchLabel setText:[[viewController searchLabel] text]];
    [searchLabel setHidden:[[viewController searchLabel] isHidden]];
    [searchCancelButton setHidden:[[viewController searchCancelButton] isHidden]];
    [sourceButton setTitle:[[[viewController sourceButton] titleLabel] text] forState:UIControlStateNormal];
    [sourceCancelButton setHidden:[[viewController sourceCancelButton] isHidden]];
    
    [modeLabel setHidden:NO];
    if (standMode == 1) {
        [modeLabel setText:@"TwitterStand"];
    } else {
        [modeLabel setText:@"NewsStand"];
    }
    
    if ([viewController numSourcesSelected] == 1) {
        [sourceButton setEnabled:NO];
    } else {
        [sourceButton setEnabled:YES];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    ViewController *viewController = [self.navigationController.viewControllers objectAtIndex:0];
    [viewController setHandMode:handMode];
    [viewController setAutomaticHandMode:automaticHandMode];
    [viewController setStandMode:standMode];
    [motionManager stopAccelerometerUpdates];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (!isPad) 
        return (!alertShown && interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    else
        return (!alertShown && interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown && blackButton.alpha < .1);
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
 
    UIInterfaceOrientation currentOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    ViewController *viewController = [self.navigationController.viewControllers objectAtIndex:0];
    BOOL portraitFirst = [viewController portraitFirst];
    
    if (toInterfaceOrientation == currentOrientation) {
        // do Nothing
    } else if (UIDeviceOrientationIsLandscape(currentOrientation) && UIDeviceOrientationIsLandscape(toInterfaceOrientation)) {
        // do Nothing
    } else if (toInterfaceOrientation == UIInterfaceOrientationPortrait) {
        if (portraitFirst) {
            NSLog(@"Popped Landscape");
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            if (!isPad) {
                TopStoriesViewController *topStoriesViewControllerPortrait = [[TopStoriesViewController alloc] initWithNibName:@"TopStoriesViewController_iPhone" andAnnotations:annotations withHoverIndex:hoverIndex lastSelectedRow:lastSelectedRow withMarkers:markers];
                [self.navigationController pushViewController:topStoriesViewControllerPortrait animated:YES];
                NSLog(@"Pushed Portrait");
            } else {
                [self.navigationController pushViewController:topStoriesViewControllerRotated animated:YES];
                NSLog(@"Pushed Portrait");
            }
        }
    } else {
        if (portraitFirst) {
            if (!isPad) {
                TopStoriesViewController *topStoriesViewControllerLandscape = [[TopStoriesViewController alloc] initWithNibName:@"TopStoriesViewController_iPhone_Land" andAnnotations:annotations withHoverIndex:hoverIndex lastSelectedRow:lastSelectedRow withMarkers:markers];
                [self.navigationController pushViewController:topStoriesViewControllerLandscape animated:YES];
                NSLog(@"Pushed Landscape");
            } else {
                [self.navigationController pushViewController:topStoriesViewControllerRotated animated:YES];
                NSLog(@"Pushed Landscape");
            }
        } else {
            [self.navigationController popViewControllerAnimated:YES];
            NSLog(@"Popped Portrait");
        }
    }       
}

#pragma mark - Map Buttons
-(IBAction)topRefreshButtonPressed:(id)sender
{
    [self updateTopStories];
}
-(IBAction)topPlusButtonPressed:(id)sender
{
    MKCoordinateRegion newRegion = [mapView region];
    MKCoordinateSpan newSpan = MKCoordinateSpanMake(newRegion.span.latitudeDelta / 2.0, newRegion.span.longitudeDelta / 2.0);
    newRegion.span = newSpan;
    
    [mapView setRegion:newRegion animated:YES];
}
-(IBAction)topMinusButtonPressed:(id)sender
{
    MKCoordinateRegion newRegion = [mapView region];
    
    if (newRegion.span.latitudeDelta > 90.0 || newRegion.span.longitudeDelta > 90.0)
        return;
    
    MKCoordinateSpan newSpan = MKCoordinateSpanMake(newRegion.span.latitudeDelta * 1.75, newRegion.span.longitudeDelta * 1.75);
    newRegion.span = newSpan;
    
    [mapView setRegion:newRegion animated:YES];
}

-(void)updateMapButtonsOnHandMode
{
    UIInterfaceOrientation currentOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    CGRect refreshFrame = refreshButton.frame;
    CGRect plusFrame = plusButton.frame;
    CGRect minusFrame = minusButton.frame;
    if (!isPad && UIInterfaceOrientationIsPortrait(currentOrientation)) {
       if (handMode != 3) {
           [refreshButton setFrame:CGRectMake(7, refreshFrame.origin.y, refreshFrame.size.width, refreshFrame.size.height)];
           [plusButton setFrame:CGRectMake(271, plusFrame.origin.y, plusFrame.size.width, plusFrame.size.height)];
           [minusButton setFrame:CGRectMake(271, minusFrame.origin.y, minusFrame.size.width, minusFrame.size.height)];
       } else {
           [refreshButton setFrame:CGRectMake(273, refreshFrame.origin.y, refreshFrame.size.width, refreshFrame.size.height)];
           [plusButton setFrame:CGRectMake(7, plusFrame.origin.y, plusFrame.size.width, plusFrame.size.height)];
           [minusButton setFrame:CGRectMake(7, minusFrame.origin.y, minusFrame.size.width, minusFrame.size.height)];
       }
    }
    [self setBotTabBarForHandMode];
}

#pragma mark - Update Slider
-(IBAction)sliderChangedValue:(id)sender
{
    [mapView removeAnnotations:[mapView annotations]];
    [self parserDidEndDocument:nil];
}

-(void)updateMaxSlider:(int)max
{
    float newVal = max/2.0, newMax = (float) max;
    if (mapSlider.maximumValue != 0.0)
        newVal = (mapSlider.value / mapSlider.maximumValue) * newMax;
    
    mapSlider.maximumValue = newMax;
    mapSlider.value = newVal;
}

#pragma mark - Alert View
-(void) alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    ViewController *viewController = [[self.navigationController viewControllers] objectAtIndex:0];
    NSString *searchKeyword;
    
    if (alertView == searchAlertView) {
        if (buttonIndex == 0) {
            [[alertView textFieldAtIndex:0] setText:@""];
            searchKeyword = @"";
            [[viewController searchLabel] setText:searchKeyword];
            [[viewController searchLabel] setHidden:YES];
            [[viewController searchCancelButton] setHidden:YES];
            [searchLabel setText:searchKeyword];
            [searchLabel setHidden:YES];
            [searchCancelButton setHidden:YES];
        } else {
            searchKeyword = [[alertView textFieldAtIndex:0] text];
            [viewController setSearchKeyword:searchKeyword];
            [[viewController searchLabel] setText:[NSString stringWithFormat:@"Search Keyword: %@", searchKeyword]];
            [[viewController searchLabel] setHidden:NO];
            [[viewController searchCancelButton] setHidden:NO];
            [searchLabel setText:[NSString stringWithFormat:@"Search Keyword: %@", searchKeyword]];
            [searchLabel setHidden:NO];
            [searchCancelButton setHidden:NO];
        }
        [self updateTopStories];
        [tabBar setSelectedItem:nil];
    }
    alertShown = FALSE;
}


#pragma mark - Search & Source Buttons

-(IBAction)topSearchCancelButtonPushed:(id)sender
{
    ViewController *viewController = [[self.navigationController viewControllers] objectAtIndex:0];
    [viewController searchCancelButtonPushed:nil];
    
    [self updateTopStories];
    
    [searchLabel setHidden:YES];
    [searchCancelButton setHidden:YES];
}

-(IBAction)topSourceCancelButtonPressed:(id)sender
{
    ViewController *viewController = [self.navigationController.viewControllers objectAtIndex:0];
    
    [viewController sourceCancelButtonPressed:nil];
    [self updateTopStories];
    
    [sourceButton setTitle:[[[viewController sourceButton] titleLabel] text] forState:UIControlStateNormal];
    [sourceCancelButton setHidden:[[viewController sourceCancelButton] isHidden]];
    
    if ([viewController numSourcesSelected] == 1) 
        [sourceButton setEnabled:NO];
}

-(IBAction)topSourceButtonPressed:(id)sender
{
    ViewController *viewController = [self.navigationController.viewControllers objectAtIndex:0];
    
    [viewController sourceButtonSelected:nil];
    [sourceButton setTitle:[[[viewController sourceButton] titleLabel] text] forState:UIControlStateNormal];
}

#pragma mark - Marker Parsing (Using NSXMLParser)
-(void) refreshCallback:(NSXMLParser *)parserIn
{
    parser = parserIn;
    [parser setDelegate:self];
    [parser parse];
}

-(void) parserDidStartDocument:(NSXMLParser *)parser
{
    if (markers == nil) {
        markers = [[NSMutableArray alloc] init];
    }
    [markers removeAllObjects];
    [activityIndicator startAnimating];
}

-(void)parserDidEndDocument:(NSXMLParser *)parser
{
    NSLog(@"Found %d markers", [markers count]); 
    [self updateMaxSlider:[markers count]];
    
    [activityIndicator stopAnimating];
    if ([[mapView annotations] count] > 0) {
        for (NewsAnnotation *annotation in mapView.annotations) {
            [[mapView viewForAnnotation:annotation] removeObserver:self forKeyPath:@"selected"];
        }
    }
    [mapView removeAnnotations:mapView.annotations];
    
    float minLon = 500.0;
    float maxLon = -500.0;
    float minLat = 500.0;
	float maxLat = -500.0;
	
    float sliderValue = [mapSlider value];
    float markersAdded = 0.0;
    
	for(NewsAnnotation * marker in markers)		
	{
        if (markersAdded > sliderValue)
            break;
        
		if([marker latitude] > maxLat)
			maxLat = [marker latitude];
		if ([marker latitude] < minLat)
            minLat = [marker latitude];
    
		if([marker longitude] > maxLon)
			maxLon = [marker longitude];
		if([marker longitude] < minLon )
			minLon = [marker longitude];
        
        [mapView addAnnotation:marker];
        markersAdded += 1.0;
	}
	
	CLLocationCoordinate2D center;
	center.latitude = (maxLat + minLat) / 2;
	center.longitude = (maxLon + minLon) / 2;
	
	MKCoordinateSpan span = MKCoordinateSpanMake(fabs(maxLat - center.latitude) * 2, fabs(maxLon - center.longitude) * 2);

    if(span.latitudeDelta < 1)
        span.latitudeDelta = 5;
    if(span.longitudeDelta < 1)
        span.longitudeDelta = 5;
	
	MKCoordinateRegion region;
	region.span = span;
	region.center = center;
	
	if([markers count] > 0 ) {
        [mapView setRegion:region animated: NO];
	}
    
}

-(void)parser:(NSXMLParser*)parserIn foundCharacters:(NSString *)string
{
    if (!currentString) {
        currentString = [[NSMutableString alloc] init];
    }
    
    [currentString appendString:string];
}

-(void)parser:(NSXMLParser*)parserIn didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    if ([elementName isEqualToString:@"item"]) 
        currentMarker = [[NewsAnnotation alloc] init];
}

-(void)parser:(NSXMLParser*)parserIn didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    NSString *currentStringTrimmed = [currentString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([elementName isEqualToString:@"item"]) 
        [markers addObject:currentMarker];
    else if ([elementName isEqualToString:@"latitude"])
        [currentMarker setLatitude:[currentStringTrimmed floatValue]];
    else if ([elementName isEqualToString:@"longitude"])
        [currentMarker setLongitude:[currentStringTrimmed floatValue]];
    else if ([elementName isEqualToString:@"gaz_id"])
        [currentMarker setGaz_id:[currentStringTrimmed intValue]];
    else if ([elementName isEqualToString:@"name"]) {
        [currentMarker setTitle:currentStringTrimmed];
        [currentMarker setName:currentStringTrimmed];
    } else if ([elementName isEqualToString:@"cluster_id"])
        [currentMarker setCluster_id:[currentStringTrimmed intValue]];
    else if ([elementName isEqualToString:@"title"])
        [currentMarker setSubtitle:currentStringTrimmed];
    else if ([elementName isEqualToString:@"description"])
        [currentMarker setDescription:currentStringTrimmed];
    else if ([elementName isEqualToString:@"topic"])
        [currentMarker setTopic:currentStringTrimmed];
    
    currentString = nil;
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    for (NewsAnnotation *annotation in mapView.annotations) {
        [[mapView viewForAnnotation:annotation] removeObserver:self forKeyPath:@"selected"];
    }
}

@end

