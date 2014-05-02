//
//  SnippetViewController.m
//  NewsStand
//
//  Created by Hanan Samet on 1/17/12.
//  Copyright (c) 2012 University of Maryland. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "SnippetViewController.h"
#import "NewsAnnotation.h"
#import "CustomWebView.h"
#import "ImageViewer.h"
#import "VideoViewController.h"
#import "TopStoriesViewController.h"
#import "PrefetchRequestOperation.h"

@implementation SnippetViewController

@synthesize webView;
@synthesize segmentedControl;
@synthesize annotations, annotationIndex;
@synthesize constraints;
@synthesize navigationBar, leftBarButtonItem;

#pragma mark - Web View Delegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        ViewController *viewController = [[self.navigationController viewControllers] objectAtIndex:0];
        int standMode = [viewController standMode];
        
        NSString *urlRequest = [[request URL] absoluteString];
        UIViewController *controller = [[self.navigationController viewControllers] objectAtIndex:1];
        
        AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
        UINavigationController *navigationController = [delegate navigationController];
        
        if (isPad) 
            if ([[navigationController viewControllers] count] > 1)
                controller = [[navigationController viewControllers] objectAtIndex:1];
        
        if ([urlRequest rangeOfString:@"/news/cluster_images"].location != NSNotFound) {
            ImageViewer *imageViewer;
            if (!isPad) {
                NSLog(@"Not iPad");
                if ([controller isKindOfClass:[TopStoriesViewController class]]) {
                    imageViewer = [[ImageViewer alloc] initWithImageTopic:@"Images" withImageId:[[annotations objectAtIndex:annotationIndex] cluster_id] andStandMode:standMode andConstraints:@"" andSecondButtonTitle:@"Top Stories"];
                } else {
                    imageViewer = [[ImageViewer alloc] initWithImageTopic:@"Images" withImageId:[[annotations objectAtIndex:annotationIndex] cluster_id] andStandMode:standMode andConstraints:@"" andSecondButtonTitle:@"Map"];
                }
                [self.navigationController pushViewController:imageViewer animated:YES];
            } else {
                NSLog(@"Annotations count %d", [annotations count]);
                if ([controller isKindOfClass:[TopStoriesViewController class]]) {
                    TopStoriesViewController *topViewController = (TopStoriesViewController *)[navigationController topViewController]; 
                    [topViewController setCheckOrientation:YES];
                    imageViewer = [[ImageViewer alloc] initWithImageTopic:@"Images" withImageId:[[annotations objectAtIndex:annotationIndex] cluster_id] andStandMode:standMode andConstraints:@""];
                } else {
                    imageViewer = [[ImageViewer alloc] initWithImageTopic:@"Images" withImageId:[[annotations objectAtIndex:annotationIndex] cluster_id] andStandMode:standMode andConstraints:@""];
                }

                [navigationController pushViewController:imageViewer animated:YES];
            }
        } else if ([urlRequest rangeOfString:@"/news/cluster_videos"].location != NSNotFound) {
            VideoViewController *videoViewController;
            if (!isPad) {
                if ([controller isKindOfClass:[TopStoriesViewController class]]) {
                    videoViewController = [[VideoViewController alloc] initWithClusterID:[[annotations objectAtIndex:annotationIndex] cluster_id]];
                } else {
                    videoViewController =  [[VideoViewController alloc] initWithClusterID:[[annotations objectAtIndex:annotationIndex] cluster_id]];
                }
                [self.navigationController pushViewController:videoViewController animated:YES];
            } else {
                if ([controller isKindOfClass:[TopStoriesViewController class]]) {
                    TopStoriesViewController *topViewController = (TopStoriesViewController *)[self.navigationController topViewController]; 
                    [topViewController setCheckOrientation:YES];
                    videoViewController = [[VideoViewController alloc] initWithClusterID:[[annotations objectAtIndex:annotationIndex] cluster_id] andStandMode:standMode];
                } else {
                    videoViewController =  [[VideoViewController alloc] initWithClusterID:[[annotations objectAtIndex:annotationIndex] cluster_id] andStandMode:standMode];
                }

                [navigationController pushViewController:videoViewController animated:YES];
            }
        } else if ([urlRequest rangeOfString:@"/bteitler_error_report_not_loc"].location != NSNotFound) {
            UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Report Error" message:@"\n\n\n" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Report", nil];
            [errorAlertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
            [errorAlertView setMessage:[NSString stringWithFormat:@"Report %@ is not a location", [[annotations objectAtIndex:annotationIndex] name]]];
            [[errorAlertView textFieldAtIndex:0] setPlaceholder:@"Comments"];
            [errorAlertView show];
            error_type = 1;
        } else if ([urlRequest rangeOfString:@"/bteitler_error_report_loc"].location != NSNotFound) {
            UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Report Error" message:@"\n\n\n" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Report", nil];
            [errorAlertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
            [errorAlertView setMessage:[NSString stringWithFormat:@"Report %@ is at wrong location", [[annotations objectAtIndex:annotationIndex] name]]];
            [[errorAlertView textFieldAtIndex:0] setPlaceholder:@"Comments"];
            [errorAlertView show];
            error_type = 2;
        } else if ([urlRequest rangeOfString:@"/bfruin_report_correct"].location != NSNotFound) {
            UIAlertView *correctAlertView = [[UIAlertView alloc] initWithTitle:@"Report Correct" message:@"\n\n\n" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Report", nil];
            [correctAlertView setMessage:[NSString stringWithFormat:@"Report %@ is at correct location", [[annotations objectAtIndex:annotationIndex] name]]];
            [correctAlertView show];
            error_type = 3;
        } else if ([urlRequest rangeOfString:@"/bfruin_show_translated"].location != NSNotFound) {
            NSURL *bundleURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] resourcePath] isDirectory:YES];
            if (!showing_translated) {
                [self.webView loadHTMLString:[[annotations objectAtIndex:annotationIndex] translate_markup] baseURL:bundleURL];
            } else {
                [self.webView loadHTMLString:[[annotations objectAtIndex:annotationIndex] markup] baseURL:bundleURL];
            }
            showing_translated = !showing_translated;
            [self.webView setNeedsDisplay];
        } else {
            CustomWebView *customWebView;
            urlRequest = [self URLEncodeString:urlRequest];
            NSMutableString *urlStringMutable = [urlRequest mutableCopy];
            
            if ([urlRequest hasPrefix:@"http://translate.google.com"]) {
                NSRange foundRange = [urlRequest rangeOfString:@"&u"];
                foundRange.length = foundRange.location + 3;
                foundRange.location = 0;
                
                if (foundRange.location != NSNotFound) 
                    [urlStringMutable replaceCharactersInRange:foundRange withString:@""];
                
                urlRequest = [NSString stringWithFormat:@"http://translate.google.com/translate_p?hl=en&sl=auto&tl=en&u=%@", urlStringMutable]; 
            }
            
            if (!isPad) {
                if ([controller isKindOfClass:[TopStoriesViewController class]]) {
                    customWebView = [[CustomWebView alloc] initWithString:urlRequest andTitle:@"News"];
                } else {
                    customWebView = [[CustomWebView alloc] initWithString:urlRequest andTitle:@"News"];
                }
                [self.navigationController pushViewController:customWebView animated:YES];
            } else {
                if ([controller isKindOfClass:[TopStoriesViewController class]]) {
                    TopStoriesViewController *topViewController = (TopStoriesViewController *)[self.navigationController topViewController]; 
                    [topViewController setCheckOrientation:YES];
                    customWebView = [[CustomWebView alloc] initWithString:urlRequest andTitle:@"News Story"];
                } else {
                    customWebView = [[CustomWebView alloc] initWithString:urlRequest andTitle:@"News Story"];
                }

                [navigationController pushViewController:customWebView animated:YES];
            }
        }
        return NO;
    } else {
        return YES;
    }
}

#pragma mark - Initialization

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    
    [self prefetchQueries];
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil andAnnotations:(NSMutableArray*)annotationsArray andAnnotationIndex:(int)index andConstraints:(NSString*)constr
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nil]) {
        annotations = [[NSMutableArray alloc] initWithArray:annotationsArray];
        annotationIndex = index;
        constraints = constr;
    }
    
    isPad = TRUE;
    [self prefetchQueries];
    return self;
}

-(id)initWithNibName:(NSString *)nibNameOrNil andAnnotations:(NSMutableArray*)annotationsArray andAnnotationIndex:(int)index andConstraints:(NSString*)constr andBackTitle:(NSString *)backTitle
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nil]) {
        annotations = [[NSMutableArray alloc] initWithArray:annotationsArray];
        annotationIndex = index;
        constraints = constr;
        leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:backTitle style:UIBarButtonItemStylePlain target:self action:@selector(leftButtonPressed)];
    }
    [self prefetchQueries];
    isPad = TRUE;
    
    return self;
}

- (id) initWithAnnotations:(NSMutableArray*)annotationsArray andAnnotationIndex:(int)index andConstraints:(NSString*)constr
{
    if (self = [super init]) {
        annotations = [[NSMutableArray alloc] initWithArray:annotationsArray];
        annotationIndex = index;
        constraints = constr;
    }
    [self prefetchQueries];
    return self;
}

-(NSString *) URLEncodeString:(NSString *) str
{
    
    NSMutableString *tempStr = [NSMutableString stringWithString:str];
    [tempStr replaceOccurrencesOfString:@" " withString:@"+" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [tempStr length])];
    
    
    return [[NSString stringWithFormat:@"%@",tempStr] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Segmented Control
-(IBAction)segmentAction:(id)sender
{
    NSLog(@"Called");
    UISegmentedControl *control = (UISegmentedControl *)sender;
	int selectedSegmentIndex = control.selectedSegmentIndex;
    
    if (selectedSegmentIndex == 0) {
        annotationIndex--;
        if (annotationIndex == 0) {
            [segmentedControl setEnabled:NO forSegmentAtIndex:0];
        }
        [segmentedControl setEnabled:YES forSegmentAtIndex:1];
    } else if (selectedSegmentIndex == 1) {
        annotationIndex++;
        if (annotationIndex + 1 == [annotations count]) {
            [segmentedControl setEnabled:NO forSegmentAtIndex:1];
        }
        [segmentedControl setEnabled:YES forSegmentAtIndex:0];
    }
    NSURL *bundleURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] resourcePath] isDirectory:YES];
    [webView loadHTMLString:[[annotations objectAtIndex:annotationIndex] markup] baseURL:bundleURL];
    [webView setNeedsDisplay];
    [self prefetchQueries];
}

#pragma mark - Prefetch Operations

- (void) prefetchQueries
{
    ViewController *viewController = [[self.navigationController viewControllers] objectAtIndex:0];
    int standMode = [viewController standMode];
    
    NewsAnnotation *currentAnnotation = [annotations objectAtIndex:annotationIndex];
    NSString *stand = @"newsstand";
    if (standMode == 1)
        stand = @"twitterstand";
    
    
    NSString *imageQuery = [[NSString alloc] initWithFormat:@"http://%@.umiacs.umd.edu/news/xml_images?cluster_id=%d", stand, [currentAnnotation cluster_id]];
    NSString *videoQuery = [[NSString alloc] initWithFormat:@"http://%@.umiacs.umd.edu/news/xml_videos?cluster_id=%d", stand, [currentAnnotation cluster_id]];
    
    NSOperationQueue *ignoreQueue = [[NSOperationQueue alloc] init];
    PrefetchRequestOperation *imagePrefetchOperation = [[PrefetchRequestOperation alloc] initWithRequestString:imageQuery];
    PrefetchRequestOperation *videoPrefetchOperation = [[PrefetchRequestOperation alloc] initWithRequestString:videoQuery];
    [ignoreQueue addOperation:imagePrefetchOperation];
    [ignoreQueue addOperation:videoPrefetchOperation];
}

#pragma mark - View lifecycle

- (void)setupNavBar
{
    [self setTitle:@"Snippet"];
    
    if (!isPad) {
        segmentedControl = [[UISegmentedControl alloc] initWithItems:
                                [NSArray arrayWithObjects:
                                 [UIImage imageNamed:@"up.png"],
                                 [UIImage imageNamed:@"down.png"],
                                 nil]];
        segmentedControl.frame = CGRectMake(0, 0, 90, 30);
    } else {
        navigationBar.topItem.leftBarButtonItem = leftBarButtonItem;
    }
    
    [segmentedControl addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
    segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
    segmentedControl.momentary = YES;
    
    if ([annotations count] > 1) {
        UIBarButtonItem *segmentBarItem = [[UIBarButtonItem alloc] initWithCustomView:segmentedControl];
        self.navigationItem.rightBarButtonItem = segmentBarItem;
    }
    
    if (annotationIndex == 0)
        [segmentedControl setEnabled:NO forSegmentAtIndex:0];
    
    if (annotationIndex + 1 == [annotations count])
        [segmentedControl setEnabled:NO forSegmentAtIndex:1];
}

#pragma mark - UIAlertView Delegate

- (void)alertView:(UIAlertView  *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    NSString *error = @"";
    NSString *comment = @"";
    
    if (buttonIndex == 0) //Cancel Button
        return; //Do nothing
    
    if (error_type == 1) {
        error = @"NOT_LOC";
    } else if (error_type == 2){
        error = @"WRONG_LOC";
    } else if (error_type == 3) {
        error = @"CORRECT_LOC";
    }
    
    if (error_type != 3) {
        comment = [[alertView textFieldAtIndex:0] text];
    }
    
    NSString *requestString = [NSString stringWithFormat:@"http://newsstand.umiacs.umd.edu/mike/feedback?gaztagid=%d&errtype=%@&comment='%@'", [[annotations objectAtIndex:annotationIndex] gaztag_id], error, comment];
    NSLog(@"Reporting error: %@", requestString);
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    ViewController *viewController = [appDelegate viewController];
    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:requestString]] queue:[viewController queue] completionHandler:nil];
    
    //NSURLResponse *response;
    //NSError *error;
    //[NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:requestString]] returningResponse:&response error:&error];
}
#pragma mark - iPad
-(void) leftButtonPressed
{
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    ViewController *viewController = [delegate viewController];
    [viewController.padDetailViewController removeSnippetViewController];
}
                
                             
#pragma mark - Setup
- (void)viewDidLoad
{
    [super viewDidLoad];
    [[webView scrollView] setBounces:NO];
    NSURL *bundleURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] resourcePath] isDirectory:YES];
    [webView loadHTMLString:[[annotations objectAtIndex:annotationIndex] markup] baseURL:bundleURL];
    [self setupNavBar];
}

- (void)viewWillAppear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:YES];
    [[self.navigationController navigationBar] setBarStyle:UIBarStyleBlackOpaque];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [self.navigationController setToolbarHidden:YES animated:YES];
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

@end
