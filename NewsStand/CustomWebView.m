//
//  CustomWebView.m
//  NewsStand
//
//  Created by Brendan on 12/30/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "CustomWebView.h"

@implementation CustomWebView

@synthesize webView, firstPage;
@synthesize activityIndicator, segmentedControl;
@synthesize articleTitle;

- (void) leftBarButtonAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (id)initWithString:(NSString *)URLString andTitle:(NSString *)title
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:YES];
    if (self = [super init]) {
        firstPage = URLString;
        [self setTitle:title];
    }
        
    return self;
}

- (id)initWithString:(NSString *)URLString andTitle:(NSString *)title andArticleTitle:(NSString *)article
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:YES];
    if (self = [super init]) {
        firstPage = URLString;
        [self setTitle:title];
        [self setArticleTitle:article];
    }
    
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - Web View
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    [activityIndicator startAnimating];
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [activityIndicator stopAnimating];
    if ([self.webView canGoBack]) {
        [segmentedControl setEnabled:YES forSegmentAtIndex:0];
    } else {
        [segmentedControl setEnabled:NO forSegmentAtIndex:0];
    }
    
    if ([self.webView canGoForward]) {
        [segmentedControl setEnabled:YES forSegmentAtIndex:1];
    } else {
        [segmentedControl setEnabled:NO forSegmentAtIndex:1];
    }

    textFontSize = 100;
}

#pragma mark - Segment Control

// The segmented control was clicked, handle it here 
- (IBAction)segmentAction:(id)sender
{
	UISegmentedControl *control = (UISegmentedControl *)sender;
	int selectedSegmentIndex = control.selectedSegmentIndex;
    
    if (selectedSegmentIndex == 0) { // Back button pressed
        [webView goBack];
        [segmentedControl setEnabled:YES forSegmentAtIndex:1];
        if (![webView canGoBack]) 
            [segmentedControl setEnabled:NO forSegmentAtIndex:0];
    } else {  // Forward button pressed
        [webView goForward];
        [segmentedControl setEnabled:YES forSegmentAtIndex:0];
        if (![webView canGoForward])
            [segmentedControl setEnabled:NO forSegmentAtIndex:1];
    }
}

#pragma mark - Bottom Bar

- (void)changeTextFontSize:(int) textSize 
{
	NSString *jsString = [[NSString alloc] initWithFormat:@"document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust = '%d%%'", textSize];
    NSString *jsStringSpacing = [[NSString alloc] initWithFormat:@"document.getElementsByTagName('body')[0].style.lineHeight= '%dpx'", textSize/5];
	
    [webView stringByEvaluatingJavaScriptFromString:jsString];
    [webView stringByEvaluatingJavaScriptFromString:jsStringSpacing];
}


- (void) textPlusItemPressed
{
    textFontSize += 50;
    [self changeTextFontSize:textFontSize];
}

- (void) textMinusItemPressed
{
    textFontSize -= 25;
    [self changeTextFontSize:textFontSize];
}

#pragma mark - View lifecycle

- (void) setUpNavBar
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    [activityIndicator setColor:[UIColor blackColor]];
    [[self.navigationController navigationBar] setAlpha:1.0];
    [self.navigationController setNavigationBarHidden:NO];
    [[self.navigationController navigationBar] setBarStyle:UIBarStyleBlackOpaque];
    segmentedControl = [[UISegmentedControl alloc] initWithItems:
                                            [NSArray arrayWithObjects:
                                             [UIImage imageNamed:@"left.png"],
                                             [UIImage imageNamed:@"right.png"],
                                             nil]];
	[segmentedControl addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
	segmentedControl.frame = CGRectMake(0, 0, 90, 30);
	segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
	segmentedControl.momentary = YES;
    [segmentedControl setEnabled:NO forSegmentAtIndex:0];
    [segmentedControl setEnabled:NO forSegmentAtIndex:1];
	UIBarButtonItem *segmentBarItem = [[UIBarButtonItem alloc] initWithCustomView:segmentedControl];
     
	self.navigationItem.rightBarButtonItem = segmentBarItem;

}

- (void) setUpBottomBar
{
    UIBarButtonItem *actionButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareItemPressed)];
    
    UIBarButtonItem *textPlusItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"textPlus.png"] landscapeImagePhone:[UIImage imageNamed:@"textPlus.png"] style:UIBarButtonItemStylePlain target:self action:@selector(textPlusItemPressed)];
    UIBarButtonItem *textMinusItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"textMinus.png"] landscapeImagePhone:[UIImage imageNamed:@"textMinus.png"] style:UIBarButtonItemStylePlain target:self action:@selector(textMinusItemPressed)];
    
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    
    NSMutableArray *items = [[NSMutableArray alloc] init];
    [items addObject:actionButton];
    [items addObject:spacer];
    [items addObject:spacer];
    [items addObject:spacer];
    [items addObject:textPlusItem];
    [items addObject:spacer];
    [items addObject:textMinusItem];

    [self setToolbarItems:items];
    
    [[self.navigationController toolbar] setAlpha:1.0];
    [[self.navigationController toolbar] setBarStyle:UIBarStyleBlackOpaque];
    [self.navigationController setToolbarHidden:NO animated:YES];
    
}

- (void)viewDidLoad
{
    NSLog(@"link: %@", firstPage);
    NSURL *url = [NSURL URLWithString:firstPage];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    [webView setScalesPageToFit:YES];
    [webView loadRequest:urlRequest];
    
   //[[UIApplication sharedApplication] openURL: [NSURL URLWithString: firstPage]]; 
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self setUpNavBar];
    [self setUpBottomBar];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [webView stopLoading];
    webView = nil;
}

/*
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}
 */

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

 
@end
