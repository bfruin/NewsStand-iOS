//
//  DetailViewController.m
//  NewsStand
//
//  Created by Hanan Samet on 1/17/12.
//  Copyright (c) 2012 University of Maryland. All rights reserved.
//

#import "DetailViewController.h"
#import "AppDelegate.h"
#import "NewsAnnotationView.h"
#import "DetailViewRequestOperation.h"
#import "MapKeywordRequestOperation.h"
#import "ViewController.h"
#import "UIDevice-ORMMA.h"
#import "UIImageResizing.h"

@implementation DetailViewController
@synthesize tableView, mapView;
@synthesize locationSlider, keywordSlider;
@synthesize locationPrevious, locationNext, keywordPrevious, keywordNext, minimapText;
@synthesize standMode, gaz_id, sourceParamString, settingsParamString, detailTitle;
@synthesize annotations, clusterKeywordMarkers, locationNameMarkers;
@synthesize detailViewFont;
@synthesize activityIndicator;
@synthesize snippetViewController;
@synthesize translateBarButtonItem;
@synthesize locationImage, keywordImage;
@synthesize navigationBar, leftBarButtonItem;
@synthesize dismissParent;
@synthesize queue;

BOOL first;


#pragma mark - Initialization

- (id)initWithNibName:(NSString *)nibNameOrNil andGazId:(int)gazId andSourceString:(NSString*)sourceString andSettingsString:(NSString *)settingsString withTitle:(NSString *)title andStandMode:(int)mode
{
    
    NSString *modeParam = @"newsstand";
    NSString *urlString;
    
    
    self = [super initWithNibName:nibNameOrNil bundle:nil];
    
    //isPad = TRUE;
    
    
    if (self) {
        gaz_id = gazId;
        sourceParamString = sourceString;
        settingsParamString = settingsString;
        detailTitle = title;
        standMode = mode;
        
        if (standMode == 1)
            modeParam = @"twitterstand";
        urlString = [NSString stringWithFormat:@"http://%@.umiacs.umd.edu/news/xml_top_locations?gaz_id=%d%@%@", modeParam, gaz_id, sourceParamString, settingsParamString];
        NSLog(@"Detail View URL: %@", urlString);
        
        UIBarButtonItem *backButton = [[UIBarButtonItem alloc]
                                       initWithTitle: @"Map"
                                       style: UIBarButtonItemStyleBordered
                                       target: nil action: nil];
        
        [self.navigationItem setBackBarButtonItem: backButton];
    }
    urlString = [self URLEncodeString:urlString];
    
    queue = [[NSOperationQueue alloc] init];
    DetailViewRequestOperation *detailViewRequestOperation = [[DetailViewRequestOperation alloc] initWithRequestString:urlString andDetailViewController:self];
    [queue addOperation:detailViewRequestOperation];
    
    first = true;
    
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil andGazId:(int)gazId andSourceString:(NSString*)sourceString andSettingsString:(NSString *)settingsString withTitle:(NSString *)title andStandMode:(int)mode andClusterID:(int)clusterID
{
    NSString *modeParam = @"newsstand";
    NSString *urlString;
    
    self = [super initWithNibName:nibNameOrNil bundle:nil];
    
    isPad = TRUE;
    
    if (self) {
        gaz_id = gazId;
        sourceParamString = sourceString;
        settingsParamString = settingsString;
        detailTitle = title;
        standMode = mode;
        cluster_id = clusterID;
        
        if (standMode == 1)
            modeParam = @"twitterstand";
        urlString = [NSString stringWithFormat:@"http://%@.umiacs.umd.edu/news/xml_top_locations?gaz_id=%d&cluster_id=%d%@%@", modeParam, gaz_id, cluster_id, sourceParamString, settingsParamString];
        NSLog(@"Detail View URL: %@", urlString);
    }
    urlString = [self URLEncodeString:urlString];
    
    queue = [[NSOperationQueue alloc] init];
    DetailViewRequestOperation *detailViewRequestOperation = [[DetailViewRequestOperation alloc] initWithRequestString:urlString andDetailViewController:self];
    [queue addOperation:detailViewRequestOperation];
    
    first = true;
    
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    
    first = true;
    return self;
}

-(id) initWithGazId:(int)gazId andSourceString:(NSString*)sourceString andSettingsString:(NSString *)settingsString withTitle:(NSString *)title andStandMode:(int)mode
{
    NSString *modeParam = @"newsstand";
    NSString *urlString;
    
    
    if (self = [super init]) {
        gaz_id = gazId;
        sourceParamString = sourceString;
        settingsParamString = settingsString;
        detailTitle = title;
        standMode = mode;
        
        if (standMode == 1)
            modeParam = @"twitterstand";
        urlString = [NSString stringWithFormat:@"http://%@.umiacs.umd.edu/news/xml_top_locations?gaz_id=%d%@%@", modeParam, gaz_id, sourceParamString, settingsParamString];
        NSLog(@"Detail View URL: %@", urlString);
        [self.tableView setHidden:YES];
    }
    urlString = [self URLEncodeString:urlString];
    
    queue = [[NSOperationQueue alloc] init];
    DetailViewRequestOperation *detailViewRequestOperation = [[DetailViewRequestOperation alloc] initWithRequestString:urlString andDetailViewController:self];
    [queue addOperation:detailViewRequestOperation];
    
    first = true;

    
    return self;
}

-(id) initWithGazId:(int)gazId andSourceString:(NSString*)sourceString andSettingsString:(NSString *)settingsString withTitle:(NSString *)title andStandMode:(int)mode
andClusterID:(int)clusterID
{
    NSString *modeParam = @"newsstand";
    NSString *urlString;
    
    
    if (self = [super init]) {
        gaz_id = gazId;
        sourceParamString = sourceString;
        settingsParamString = settingsString;
        detailTitle = title;
        standMode = mode;
        cluster_id = clusterID;
        
        if (standMode == 1)
            modeParam = @"twitterstand";
        urlString = [NSString stringWithFormat:@"http://%@.umiacs.umd.edu/news/xml_top_locations?gaz_id=%d&cluster_id=%d%@%@", modeParam, gaz_id, cluster_id, sourceParamString, settingsParamString];
        NSLog(@"Detail View URL: %@", urlString);
        [self.tableView setHidden:YES];
        
    }
    urlString = [self URLEncodeString:urlString];

    queue = [[NSOperationQueue alloc] init];
    DetailViewRequestOperation *detailViewRequestOperation = [[DetailViewRequestOperation alloc] initWithRequestString:urlString andDetailViewController:self];
    [queue addOperation:detailViewRequestOperation];
    
    first = true;

    
    return self;
}

-(NSString *) URLEncodeString:(NSString *) str
{
    
    NSMutableString *tempStr = [NSMutableString stringWithString:str];
    [tempStr replaceOccurrencesOfString:@" " withString:@"+" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [tempStr length])];
    
    
    return [[NSString stringWithFormat:@"%@",tempStr] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}


#pragma mark - Memory

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


#pragma mark - View lifecycle


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTitle:detailTitle];
    [navigationBar.topItem setTitle:detailTitle];
    detailViewFont = [UIFont systemFontOfSize:14.5];
    
    [self initializeMarkerImages];
    
    if (annotations == nil || [annotations count] == 0) {
        [activityIndicator startAnimating];
    }

    if (isPad) {
        CGSize screenDimensions;
        if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation]))
            screenDimensions = [[UIDevice currentDevice] screenSizeForOrientation:UIDeviceOrientationPortrait];
        else
            screenDimensions = [[UIDevice currentDevice] screenSizeForOrientation:UIDeviceOrientationLandscapeLeft];


        //padDetailViewController.view.frame = CGRectMake(screenWidth / 5, screenHeight / 5, screenWidth * .6, screenHeight * .6);
        
        float screenWidth = screenDimensions.width;
        float screenHeight = screenDimensions.height;
        
        float activityIndicatorXCoord = (screenWidth * .6)/2.0 - activityIndicator.frame.size.width/2.0;
        float activityIndicatorYCoord = (screenHeight * .6)/2.0 - activityIndicator.frame.size.height/2.0;
        
        [activityIndicator setFrame:CGRectMake(activityIndicatorXCoord, activityIndicatorYCoord, activityIndicator.frame.size.width, activityIndicator.frame.size.height)];
    }
    
    translateBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"translate.png"] style:UIBarButtonItemStylePlain target:self action:@selector(translateBarButtonItemSelected)];
    controllerIndex = [self.navigationController.viewControllers indexOfObject:self];
    
    lastLocationSliderValue = locationSlider.value;
    lastKeywordSliderValue = keywordSlider.value;
}

- (void)initializeMarkerImages
{
    locationImage = [[UIImage imageNamed:@"blue_ball.png"] scaleToSize:CGSizeMake(12.0, 12.0)];
    keywordImage = [[UIImage imageNamed:@"yellow_ball.png"] scaleToSize:CGSizeMake(12.0, 12.0)];
}


- (void) viewDidAppear:(BOOL)animated
{
    if (annotations != nil && [annotations count] > 1)
        [tableView reloadData];
    else if (!first && [annotations count] == 1) {
            [self.navigationController popViewControllerAnimated:NO];
        }
    first = false;
    
    if (dismissParent) {
        [activityIndicator setCenter:self.view.center];
        [activityIndicator startAnimating];
        [NSTimer scheduledTimerWithTimeInterval:.000001 target:self selector:@selector(popView) userInfo:nil repeats:NO];
    }
}

- (void) popView
{
    [self.navigationController popViewControllerAnimated:NO];
}

- (void) viewWillAppear:(BOOL)animated
{

    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:YES];
    [[self.navigationController navigationBar] setBarStyle:UIBarStyleBlackOpaque];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [self.navigationController setToolbarHidden:YES];
    
    if (dismissParent) {
        [tableView setAlpha:0.0];
        [mapView setAlpha:0.0];
        [self.view setBackgroundColor:[UIColor whiteColor]];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    UIInterfaceOrientation currentOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    ViewController *viewController = [self.navigationController.viewControllers objectAtIndex:0];
    BOOL portraitFirst = [viewController portraitFirst];
    
    if (self.isMovingFromParentViewController) {
        if (UIDeviceOrientationIsLandscape(currentOrientation) && !portraitFirst) {
            NSLog(@"Land");
            
        } else if (!UIDeviceOrientationIsLandscape(currentOrientation) && portraitFirst) {
            rotated = false;
        } else if (!rotated) {
            NSLog(@"Not Rotated");
            DetailViewController *parentController = [self.navigationController.viewControllers objectAtIndex:controllerIndex-1];
            //[self.navigationController popToRootViewControllerAnimated:NO];
            [parentController setDismissParent:YES];
            NSLog(@"Not Rotated");
        }
    }
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    UIInterfaceOrientation currentOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    ViewController *viewController = [self.navigationController.viewControllers objectAtIndex:0];
    BOOL portraitFirst = [viewController portraitFirst];
    
    if (toInterfaceOrientation == currentOrientation) {
        // do nothing
    } else if (UIDeviceOrientationIsLandscape(currentOrientation) && UIDeviceOrientationIsLandscape(toInterfaceOrientation)) {
        // do nothing
    } else if (toInterfaceOrientation == UIInterfaceOrientationPortrait) {
        rotated = true;
        if (portraitFirst) {
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            DetailViewController *detailViewController = [[DetailViewController alloc] initWithNibName:@"DetailViewController" andGazId:gaz_id andSourceString:sourceParamString andSettingsString:settingsParamString withTitle:detailTitle andStandMode:standMode];
            [self.navigationController pushViewController:detailViewController animated:YES];
        }
    } else {
        rotated = true;
        if (portraitFirst) {
            DetailViewController *detailViewController = [[DetailViewController alloc] initWithNibName:@"DetailViewController_Landscape" andGazId:gaz_id andSourceString:sourceParamString andSettingsString:settingsParamString withTitle:detailTitle andStandMode:standMode];
            [self.navigationController pushViewController:detailViewController animated:YES];
        } else {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}



- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
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
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    
    if (row == selectedIndex) {
        cell.backgroundColor = [UIColor colorWithRed:(76.0/255.0) green:(161.0/255.0) blue:(255.0/255.0) alpha:1.0]; // perfect color suggested by @mohamadHafez
        [[cell textLabel] setTextColor:[UIColor whiteColor]];
    } else {
        cell.backgroundColor = [UIColor whiteColor];
        [[cell textLabel] setTextColor:[UIColor blueColor]];
    }
    
    NewsAnnotation *currAnnotation = [annotations objectAtIndex:row];
    
    if ([currAnnotation keyword] != nil) {
        if (translated_titles) {
            if ([currAnnotation translate_title] != nil && ![[currAnnotation translate_title] isEqualToString:@""]) 
                [[cell textLabel] setText:[[currAnnotation keyword] stringByAppendingFormat:@": %@", [currAnnotation translate_title]]];
            else
                [[cell textLabel] setText:[[currAnnotation keyword] stringByAppendingFormat:@": %@", [currAnnotation title]]];
        } else {
                [[cell textLabel] setText:[[currAnnotation keyword] stringByAppendingFormat:@": %@", [currAnnotation title]]];
        }
    } else {
        if (translated_titles) {
            if ([currAnnotation translate_title] != nil && ![[currAnnotation translate_title] isEqualToString:@""]) 
                 [[cell textLabel] setText:[currAnnotation translate_title]];
            else
                 [[cell textLabel] setText:[currAnnotation title]];
        } else {
            [[cell textLabel] setText:[currAnnotation title]];
        }
        
    }
    [[cell textLabel] setFont:detailViewFont];
        
    return cell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    int row = [indexPath row];
    
    if (!isPad) {
        if (selectedIndex == row) {
            snippetViewController = [[SnippetViewController alloc] initWithAnnotations:annotations andAnnotationIndex:row andConstraints:[sourceParamString stringByAppendingString:settingsParamString]];
            [self.navigationController pushViewController:snippetViewController animated:YES];
        } else {
            selectedIndex = row;
            [self.tableView reloadData];
            
            int currentClusterID = [[annotations objectAtIndex:selectedIndex] cluster_id];
            
            if ([clusterKeywordMarkers objectForKey:[NSNumber numberWithInt:currentClusterID]] != nil) {
                NSMutableArray *currentClusterMarkers = [clusterKeywordMarkers objectForKey:[NSNumber numberWithInt:currentClusterID]];
                if (currentClusterMarkers != nil && [currentClusterMarkers count] > 1) {
                    [keywordSlider setHidden:NO];
                } else {
                    [keywordSlider setHidden:YES];
                }
                [mapView removeAnnotations:previousClusterKeywordMarkers];
                [self keywordSliderChangedValue:nil];
            } else {
                ViewController *viewController = [[self.navigationController viewControllers] objectAtIndex:0];
                int layer = [viewController layerSelected];
            
                NSString *modeParam = @"newsstand";
            
                if (layer != 3) {
                    NSString *urlStringClusterKeyword;
                    if (layer == 0) { // Use cluster_id for icon layer
                        urlStringClusterKeyword = [NSString stringWithFormat:@"http://%@.umiacs.umd.edu/news/xml_map?%@%@&cluster_id=%d", modeParam, sourceParamString, settingsParamString, [[annotations objectAtIndex:selectedIndex] cluster_id]];
                    } else { // Use keyword for other layers
                        urlStringClusterKeyword = [NSString stringWithFormat:@"http://%@.umiacs.umd.edu/news/map_keyword?%@%@&keyword=%@&layer=%d", modeParam, sourceParamString, settingsParamString, [[annotations objectAtIndex:selectedIndex] keyword], layer];
                    }
                
                    MapKeywordRequestOperation *mapClusterKeywordRequest = [[MapKeywordRequestOperation alloc] initWithRequestString:urlStringClusterKeyword andDetailViewController:self   andLayer:layer isClusterOrKeyword:true];
                    [queue addOperation:mapClusterKeywordRequest];
                
                    NSLog([NSString stringWithFormat:@"Cluster/Keyword request: %@", urlStringClusterKeyword]);
                }
            }
            [self fitMapToMarkers];
        }
    } else {
        snippetViewController = [[SnippetViewController alloc] initWithNibName:@"SnippetViewController_iPad" andAnnotations:annotations andAnnotationIndex:row andConstraints:[sourceParamString stringByAppendingString:settingsParamString] andBackTitle:[self title]];
        [snippetViewController.view setFrame:CGRectMake(snippetViewController.self.view.frame.origin.x, snippetViewController.self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height)];
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:1.0];
        [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight
                               forView:snippetViewController.view
                                 cache:YES];
        [self.view addSubview:snippetViewController.view];
        [UIView commitAnimations];
    }
}

#pragma mark - Map / Delegate
-(MKAnnotationView *)mapView:(MKMapView *)localMapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    NewsAnnotationView *annotationView = (NewsAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"newsview"];
    if (annotationView == nil)
        annotationView = [[NewsAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"newsview"];
    
    NewsAnnotation *newsAnnotation = (NewsAnnotation *)annotation;
    annotationView.canShowCallout = YES;
    
    if (newsAnnotation.locationMarker) {
        annotationView.image = locationImage;
    } else {
        annotationView.image = keywordImage;
    }
    
    annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    
    return annotationView;
}

-(void)fitMapToMarkers
{
    float minLon = 500.0;
    float maxLon = -500.0;
    float minLat = 500.0;
	float maxLat = -500.0;
    
    if (locationNameMarkers != nil) {
        for (NewsAnnotation *marker in locationNameMarkers) {
            if ([marker latitude] > maxLat)
                maxLat = [marker latitude];
            if ([marker latitude] < minLat)
                minLat = [marker latitude];
        
            if ([marker longitude] > maxLon)
                maxLon = [marker longitude];
            if ([marker longitude] < minLon)
                minLon = [marker longitude];
        }
    }
    
    if (previousClusterKeywordMarkers != nil) {
        for (NewsAnnotation *marker in previousClusterKeywordMarkers) {
            if ([marker latitude] > maxLat)
                maxLat = [marker latitude];
            if ([marker latitude] < minLat)
                minLat = [marker latitude];
            
            if ([marker longitude] > maxLon)
                maxLon = [marker longitude];
            if ([marker longitude] < minLon)
                minLon = [marker longitude];
        }
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

    [mapView setRegion:region animated: NO];
}

#pragma mark - Translation
- (void) translateBarButtonItemSelected
{
    translated_titles = !translated_titles;
    [self.tableView reloadData];
}

#pragma mark - Sliders

//Sliders
-(IBAction)locationSliderChangedValue:(id)sender
{
    int i = 0;
    int max = (int)(locationSlider.value * locationNameMarkers.count + 1);
    int lastMax = (int)(lastLocationSliderValue * locationNameMarkers.count + 1);
    
    lastLocationSliderValue = locationSlider.value;
    
    while (i < locationNameMarkers.count) {
        if (i <= lastMax) {
            [mapView addAnnotation:[locationNameMarkers objectAtIndex:i]];
        } else if (i > max) {
            [mapView removeAnnotation:[locationNameMarkers objectAtIndex:i]];
        }
        
        i+=1;
    }
}
-(IBAction)keywordSliderChangedValue:(id)sender
{
    NSLog(@"CALLED");
    
    int i = 0;
    if (previousClusterKeywordMarkers != nil) {
        int max = (int)(keywordSlider.value * previousClusterKeywordMarkers.count + 1);
        int lastMax = (int)(lastKeywordSliderValue * previousClusterKeywordMarkers.count + 1);
    
        lastKeywordSliderValue = keywordSlider.value;
    
        while (i < previousClusterKeywordMarkers.count) {
            if (i <= lastMax) {
                [mapView addAnnotation:[previousClusterKeywordMarkers objectAtIndex:i]];
            } else if (i > max) {
                [mapView removeAnnotation:[previousClusterKeywordMarkers objectAtIndex:i]];
            }
        
            i+=1;
        }
    }
}

#pragma mark - Minimap Cycling
-(void)setMinimapText:(NSString*)text isLocation:(BOOL)isLocation
{
    [minimapText setHidden:NO];
    if (isLocation) {
        [minimapText setTextColor:[UIColor blueColor]];
    } else {
        [minimapText setTextColor:[UIColor yellowColor]];
    }
    
    [minimapText setText:text];
}

-(IBAction)locationPreviousPressed:(id)sender
{
    highlightedLocation--;
    
    [locationNext setHidden:NO];
    if (highlightedLocation < 1) {
        [locationPrevious setHidden:YES];
    }
    
    [self setMinimapText:[[locationNameMarkers objectAtIndex:highlightedLocation] fullName] isLocation:YES];
}

-(IBAction)locationNextPressed:(id)sender
{
    highlightedLocation++;
    
    [locationPrevious setHidden:NO];
    if (highlightedLocation >= [locationNameMarkers count]-1) {
        [locationNext setHidden:YES];
    }
    
    [self setMinimapText:[[locationNameMarkers objectAtIndex:highlightedLocation] fullName] isLocation:YES];
}

#pragma mark - iPad
-(IBAction)leftBarButtonItemSelected:(id)sender
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    UINavigationController *navigationController = [appDelegate navigationController];
    if ([[navigationController viewControllers] count] > 1) {
        //Handle top stories
    } else {
        ViewController *viewController = [[navigationController viewControllers] objectAtIndex:0];
        [viewController dismissDetailViewController];
    }
}

-(void)removeSnippetViewController 
{
    [tableView reloadData];
    [snippetViewController.view removeFromSuperview];
}

#pragma mark - NSXMLParser Callback Delegate

- (void) pushSnippetSingleArticle {
    if (cluster_id > 0) {
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Top Stories"
                                     style:UIBarButtonItemStylePlain
                                    target:nil
                                    action:nil];
    } else {
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"  Map  "
                                                                                 style:UIBarButtonItemStylePlain
                                                                                target:nil
                                                                                action:nil];
        
    }
    
    
    snippetViewController = [[SnippetViewController alloc] initWithAnnotations:annotations andAnnotationIndex:0 andConstraints:[sourceParamString stringByAppendingString:settingsParamString]];
    [self.navigationController pushViewController:snippetViewController animated:NO];
}

-(void)parseEnded:(NSMutableArray*)annotationsArray
{
    [activityIndicator stopAnimating];
    annotations = [[NSMutableArray alloc] initWithArray:annotationsArray];
    if ([annotations count] == 1) {
        if (!isPad) {
            [NSTimer scheduledTimerWithTimeInterval:.5 target:self selector:@selector(pushSnippetSingleArticle) userInfo:nil repeats:NO];
        } else {
            snippetViewController = [[SnippetViewController alloc] initWithNibName:@"SnippetViewController_iPad" andAnnotations:annotations andAnnotationIndex:0 andConstraints:[sourceParamString stringByAppendingString:settingsParamString] andBackTitle:[self title]];
            [snippetViewController.view setFrame:CGRectMake(snippetViewController.self.view.frame.origin.x, snippetViewController.self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height)];
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:1.0];
            [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight
                                   forView:snippetViewController.view
                                     cache:YES];
            [self.view addSubview:snippetViewController.view];
            [UIView commitAnimations];
        }
    } else {
        for (NewsAnnotation *currentAnnotation in annotations) {
            if ([currentAnnotation translate_title] != nil && ![[currentAnnotation translate_title] isEqualToString:@""]) {
                self.navigationItem.rightBarButtonItem = translateBarButtonItem;
                break;
            }
        }
        
        [self.tableView reloadData];
        
        ViewController *viewController = [[self.navigationController viewControllers] objectAtIndex:0];
        int layer = [viewController layerSelected];
        
        NSString *modeParam = @"newsstand";
        if (layer != 3) {
            NSString *urlStringClusterKeyword;
            if (layer == 0) { // Use cluster_id for icon layer
                urlStringClusterKeyword = [NSString stringWithFormat:@"http://%@.umiacs.umd.edu/news/xml_map?%@%@&cluster_id=%d", modeParam, sourceParamString, settingsParamString, [[annotations objectAtIndex:0] cluster_id]];
            } else { // Use keyword for other layers
                urlStringClusterKeyword = [NSString stringWithFormat:@"http://%@.umiacs.umd.edu/news/map_keyword?%@%@&keyword=%@&layer=%d", modeParam, sourceParamString, settingsParamString, [[annotations objectAtIndex:0] keyword], layer];
            }
            
            MapKeywordRequestOperation *mapClusterKeywordRequest = [[MapKeywordRequestOperation alloc] initWithRequestString:urlStringClusterKeyword andDetailViewController:self andLayer:layer isClusterOrKeyword:true];
            [queue addOperation:mapClusterKeywordRequest];
            
            NSLog([NSString stringWithFormat:@"Cluster/Keyword request: %@", urlStringClusterKeyword]);
            
            NSString *urlStringLoc = [NSString stringWithFormat:@"http://%@.umiacs.umd.edu/news/map_keyword?%@%@&layer=%d&location_name=%@", modeParam, sourceParamString, settingsParamString, layer, [[annotations objectAtIndex:0] name]];
            MapKeywordRequestOperation *mapLocRequest = [[MapKeywordRequestOperation alloc] initWithRequestString:urlStringLoc andDetailViewController:self andLayer:layer isClusterOrKeyword:false];
            
            
            NSLog([NSString stringWithFormat:@"Location request: %@", urlStringLoc]);
            [queue addOperation:mapLocRequest];
        } else {
            NSString *urlStringLoc = [NSString stringWithFormat:@"http://%@.umiacs.umd.edu/news/map_keyword?%@%@&keyword=%@&layer=%d", modeParam, sourceParamString, settingsParamString, [[annotations objectAtIndex:0] name], layer];
            MapKeywordRequestOperation *mapLocRequest = [[MapKeywordRequestOperation alloc] initWithRequestString:urlStringLoc andDetailViewController:self andLayer:layer isClusterOrKeyword:false];
            [queue addOperation:mapLocRequest];
        }
    }
}

-(void)parseEndedClusterKeyword:(NSMutableArray*)clusterKeywordArray
{
    if (clusterKeywordMarkers == nil) {
        clusterKeywordMarkers = [[NSMutableDictionary alloc] init];
    } else {
        [mapView removeAnnotations:previousClusterKeywordMarkers];
    }
    
    previousClusterKeywordMarkers = clusterKeywordArray;
    [clusterKeywordMarkers setObject:clusterKeywordArray forKey:[NSNumber numberWithInt:[[annotations objectAtIndex:selectedIndex] cluster_id]]];
    if (clusterKeywordMarkers != nil && [clusterKeywordMarkers count] > 1) {
        [keywordSlider setHidden:NO];
        [self keywordSliderChangedValue:nil];
    } else {
        [keywordSlider setHidden:YES];
    }
    [self fitMapToMarkers];
}

-(void)parseEndedLocationName:(NSMutableArray*)locationNameArray
{
    locationNameMarkers = [[NSMutableArray alloc] initWithArray:locationNameArray];
    if (locationNameMarkers.count > 1) {
        [locationSlider setHidden:NO];
        [locationNext setHidden:NO];
        [self locationSliderChangedValue:nil];
    } else {
        [locationSlider setHidden:YES];
        [locationNext setHidden:YES];
    }
    [self fitMapToMarkers];
}


@end