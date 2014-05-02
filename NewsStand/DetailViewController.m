//
//  DetailViewController.m
//  NewsStand
//
//  Created by Hanan Samet on 1/17/12.
//  Copyright (c) 2012 University of Maryland. All rights reserved.
//

#import "DetailViewController.h"
#import "AppDelegate.h"
#import "DetailViewRequestOperation.h"
#import "MapKeywordRequestOperation.h"
#import "ViewController.h"
#import "UIDevice-ORMMA.h"

@implementation DetailViewController
@synthesize tableView, mapView;
@synthesize standMode, gaz_id, sourceParamString, settingsParamString, detailTitle;
@synthesize annotations, clusterKeywordMarkers, locationNameMarkers;
@synthesize detailViewFont;
@synthesize activityIndicator;
@synthesize snippetViewController;
@synthesize translateBarButtonItem;
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

#pragma mark - Translation
- (void) translateBarButtonItemSelected
{
    translated_titles = !translated_titles;
    [self.tableView reloadData];
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
                NSLog(@"TRANSLATE TITLE BUTTON %@", [currentAnnotation translate_title]);
                break;
            }
        }
        
        [self.tableView reloadData];
        
        ViewController *viewController = [[self.navigationController viewControllers] objectAtIndex:0];
        int layer = [viewController layerSelected];
        
        NSString *modeParam = @"newsstand";
        if (layer != 3) {
            
        } else {
            
        }

        //NSString *urlString = [NSString stringWithFormat:@"http://%@.umiacs.umd.edu/news/map_keyword?%@%@", modeParam, sourceParamString, settingsParamString];
        //MapKeywordRequestOperation *mapKeyworRequest = [[MapKeywordRequestOperation alloc] initWithRequestString:<#(NSString *)#> andDetailViewController:<#(DetailViewController *)#> andLayer:<#(int)#> isClusterOrKeyword:<#(BOOL)#>]
        //[queue addOperation:detailViewRequestOperation];
    }
}

-(void)parseEndedClusterKeyword:(NSMutableArray*)clusterKeywordArray
{
    clusterKeywordMarkers = [[NSMutableArray alloc] initWithArray:clusterKeywordArray];
}

-(void)parseEndedLocationName:(NSMutableArray*)locationNameArray
{
    locationNameMarkers = [[NSMutableArray alloc] initWithArray:locationNameArray];
}


@end