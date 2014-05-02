//
//  ImageViewer.m
//  NewsStand
//
//  Created by Brendan on 1/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ImageViewer.h"
#import "TopStoriesViewController.h"
#import "ImageViewRequestOperation.h"
#import "UIImageResizing.h"
#import "UIDevice-ORMMA.h"
#import "CustomWebView.h"
#import "JMImageCache.h"
#import "MWPhoto.h"
#import "MWPhotoBrowser.h"

#import <SSToolkit/SSLabel.h>
#import <SSToolkit/SSCollectionViewItem.h>

@implementation ImageViewer


@synthesize imagesData, noDupesImagesData, clusterImages, clustersAdded, currClusterImages, noDupesCurrentCluster;
@synthesize image_topic, standMode, image_constraints, image_id, secondLeftButtonTitle;
@synthesize secondLeftButton, pageSegmentedControl, actionButton, gridButton, magnifyButton, allInTopicButton, displaySegmentedControl, allTopicsSegmentedControl;
@synthesize blackButton, enlargeImageView, imageBorder, captionLabel;
@synthesize numItems, pageNum, numPages, selectedIndex, selectedPageIndex;
@synthesize queue;
#pragma mark - Class Methods

+ (NSString *)title {
	return @"Collection View";
}


#pragma mark - Button Actions
- (IBAction)pageSegmentAction:(id)sender
{
	UISegmentedControl *control = (UISegmentedControl *)sender;
	int selectedSegmentIndex = control.selectedSegmentIndex;
    
    if (selectedSegmentIndex == 0) { // Back button pressed
        pageNum--;
        if (pageNum == 0) {
            [pageSegmentedControl setEnabled:NO forSegmentAtIndex:0];
            backEnabled = NO;
        }
        [pageSegmentedControl setEnabled:YES forSegmentAtIndex:1];
        forwardEnabled = YES;
    } else {  // Forward button pressed
        pageNum++;
        if (pageNum == (numPages-1)) {
            [pageSegmentedControl setEnabled:NO forSegmentAtIndex:1];
            forwardEnabled = NO;
        }
        backEnabled = YES;
        [pageSegmentedControl setEnabled:YES forSegmentAtIndex:0];
    }

    [self.collectionView reloadData];
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:SSCollectionViewScrollPositionTop animated:YES];
}

- (IBAction)displaySegmentAction:(id)sender
{
    UISegmentedControl *control = (UISegmentedControl *)sender;
	int selectedSegmentIndex = control.selectedSegmentIndex;
    
    if (selectedSegmentIndex == 0) {
        numPages = [imagesData count] / 48;
        if ([imagesData count] % 48 != 0) 
            numPages ++;
        
        if (viewingType == removeDuplicates || viewingType == clusterImagesType) {
            pageNum = 0;
            [pageSegmentedControl setEnabled:NO forSegmentAtIndex:0];
            if (numPages > 1)
                [pageSegmentedControl setEnabled:YES forSegmentAtIndex:1];
            else
                [pageSegmentedControl setEnabled:NO forSegmentAtIndex:1];
            
            [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:SSCollectionViewScrollPositionMiddle animated:YES];
        }
        [self.collectionView setRowSpacing:3];
        [self.collectionView setMinimumColumnSpacing:3];
        
        
        if (viewingType == clusterImagesType) {
            NSMutableArray *botArray = [[NSMutableArray alloc] init];
            
            UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
            UIBarButtonItem *segmentBarItem = [[UIBarButtonItem alloc] initWithCustomView:displaySegmentedControl];
            
            [displaySegmentedControl setSelectedSegmentIndex:0];
            
            [botArray addObject:segmentBarItem];
            [botArray addObject:spacer];
            [botArray addObject:magnifyButton];
            [self setToolbarItems:botArray];
        }
        
        viewingType = allImages;
    } else if (selectedSegmentIndex == 1) {
        if (standMode < 2) {
            numPages = [imagesData count] / 48;
            if ([imagesData count] % 48 != 0) 
                numPages ++;
        
            if (viewingType == removeDuplicates) {
                pageNum = 0;
                [pageSegmentedControl setEnabled:NO forSegmentAtIndex:0];
                if (numPages > 1)
                    [pageSegmentedControl setEnabled:YES forSegmentAtIndex:1];
                else
                    [pageSegmentedControl setEnabled:NO forSegmentAtIndex:1];
            
                [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:SSCollectionViewScrollPositionMiddle animated:YES];
            }
            [self.collectionView setRowSpacing:3];
            [self.collectionView setMinimumColumnSpacing:3];
            
            viewingType = markDuplicates;
        } else {  //PhotoStand All Topics
            numPages = [clusterImages count] / 48;
            if ([clusterImages count] % 48 != 0)
                numPages++;
            
            pageNum = 0;
            [pageSegmentedControl setEnabled:NO forSegmentAtIndex:0];
            if (numPages > 1)
                [pageSegmentedControl setEnabled:YES forSegmentAtIndex:1];
            else
                [pageSegmentedControl setEnabled:NO forSegmentAtIndex:1];
            
            [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:SSCollectionViewScrollPositionMiddle animated:YES];
            
            [self.collectionView setRowSpacing:20];
            [self.collectionView setMinimumColumnSpacing:20];
            [self setTabBarForAllTopics];
            
            viewingType = clusterImagesType;
        }
    } else if (selectedSegmentIndex == 2) {
        if (standMode < 2) {
            numPages = [noDupesImagesData count] / 48;
            if ([noDupesImagesData count] % 48 != 0) 
                numPages ++;
        
            NSLog(@"NumPages %d total images %d", numPages, [noDupesImagesData count]);
        
            if (viewingType == allImages || viewingType == markDuplicates || viewingType == clusterImagesType) {
                pageNum = 0;
                [pageSegmentedControl setEnabled:NO forSegmentAtIndex:0];
                if (numPages > 1)
                    [pageSegmentedControl setEnabled:YES forSegmentAtIndex:1];
                else
                    [pageSegmentedControl setEnabled:NO forSegmentAtIndex:1];
            
                [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:SSCollectionViewScrollPositionMiddle animated:YES];
            }
            viewingType = removeDuplicates;
        } else {  //PhotoStand Mark Dupes
            numPages = [imagesData count] / 48;
            if ([imagesData count] % 48 != 0) 
                numPages ++;
            
            if (viewingType == removeDuplicates) {
                pageNum = 0;
                [pageSegmentedControl setEnabled:NO forSegmentAtIndex:0];
                if (numPages > 1)
                    [pageSegmentedControl setEnabled:YES forSegmentAtIndex:1];
                else
                    [pageSegmentedControl setEnabled:NO forSegmentAtIndex:1];
                
                [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:SSCollectionViewScrollPositionMiddle animated:YES];
            }
            [self.collectionView setRowSpacing:3];
            [self.collectionView setMinimumColumnSpacing:3];
            
            viewingType = markDuplicates;
        }
         
        [self.collectionView setRowSpacing:3];
        [self.collectionView setMinimumColumnSpacing:3];

    } else { //PhotoStand Hide Dups
        numPages = [noDupesImagesData count] / 48;
        if ([noDupesImagesData count] % 48 != 0) 
            numPages ++;
        
        NSLog(@"NumPages %d total images %d", numPages, [noDupesImagesData count]);
        
        if (viewingType == allImages || viewingType == markDuplicates || viewingType == clusterImagesType) {
            pageNum = 0;
            [pageSegmentedControl setEnabled:NO forSegmentAtIndex:0];
            if (numPages > 1)
                [pageSegmentedControl setEnabled:YES forSegmentAtIndex:1];
            else
                [pageSegmentedControl setEnabled:NO forSegmentAtIndex:1];
            
            [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:SSCollectionViewScrollPositionMiddle animated:YES];
        }
        [self.collectionView setRowSpacing:3];
        [self.collectionView setMinimumColumnSpacing:3];
        
        viewingType = removeDuplicates;
    }
    
    [self.collectionView reloadData];
}
- (void) magnifyButtonSelected
{
    
    if (imagesData == nil || [imagesData count] < 1) 
        return;
    
    NSMutableArray *photos = [[NSMutableArray alloc] init];
    NSMutableArray *captions = [[NSMutableArray alloc] init];
    NSMutableArray *sources = [[NSMutableArray alloc] init];
    
    if (viewingType == allImages || viewingType == markDuplicates) {
        for (ImageData *curr in imagesData) {
            [photos addObject:[MWPhoto photoWithURL:[NSURL URLWithString:[curr imageURL]]]];
            [captions addObject:[curr caption]];
            [sources addObject:[curr pageURL]]; 
        }
    } else if (viewingType == removeDuplicates) {
        for (ImageData *curr in noDupesImagesData) {
            [photos addObject:[MWPhoto photoWithURL:[NSURL URLWithString:[curr imageURL]]]];
            [captions addObject:[curr caption]];
            [sources addObject:[curr pageURL]]; 
        }
    } else { //Cluster
        for (ImageData *curr in clusterImages) {
            [photos addObject:[MWPhoto photoWithURL:[NSURL URLWithString:[curr imageURL]]]];
            [captions addObject:[curr caption]];
            [sources addObject:[curr pageURL]]; 
        }
    }
                 
    MWPhotoBrowser *photoBrowser = [[MWPhotoBrowser alloc] initWithPhotos:photos andCaptions:captions andSourceURLs:sources];
    [photoBrowser setInitialPageIndex:selectedIndex];
    [self.navigationController pushViewController:photoBrowser animated:YES];
    
             
}

#pragma mark - Enlarge Image Action
- (void) dismissBlackCover
{
    [blackButton setAlpha:0];
    [enlargeImageView removeFromSuperview];
    [imageBorder removeFromSuperview];
    [captionLabel removeFromSuperview];
    
    [pageSegmentedControl setEnabled:backEnabled forSegmentAtIndex:0];
    [pageSegmentedControl setEnabled:forwardEnabled forSegmentAtIndex:1];
    [displaySegmentedControl setEnabled:YES];
    
    UIBarButtonItem *segmentBarItem = [[UIBarButtonItem alloc] initWithCustomView:pageSegmentedControl];
	self.navigationItem.rightBarButtonItem = segmentBarItem;
    
    if (viewingType == clusterImagesType) {
        [self setTabBarForAllTopics];
    } else {
        [self setTabBarNormal];
    }
}

- (void) allImagesInTopicButtonSelected
{
    ImageViewer *imageViewer = [[ImageViewer alloc] initWithImageTopic:image_topic withImagesData:currClusterImages andDupesImageData:noDupesCurrentCluster];
    [self.navigationController pushViewController:imageViewer animated:NO];
}

#pragma mark - Gesture Recognizers
- (void)setupGestureRecognizers
{
    //Detect Taps
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    
    [singleTap setNumberOfTapsRequired:1];
    [doubleTap setNumberOfTapsRequired:2];
    
    [singleTap requireGestureRecognizerToFail:doubleTap];
    [singleTap setDelaysTouchesBegan:YES];
    
    [enlargeImageView addGestureRecognizer:singleTap];
    [enlargeImageView addGestureRecognizer:doubleTap];
    
    //Left & Right Swipe
    UISwipeGestureRecognizer *rightSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleRightSwipe:)];
    UISwipeGestureRecognizer *leftSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleLeftSwipe:)];
    [rightSwipe setNumberOfTouchesRequired:1];
    [leftSwipe setNumberOfTouchesRequired:1];
    [leftSwipe setDirection:UISwipeGestureRecognizerDirectionLeft];
    [enlargeImageView addGestureRecognizer:rightSwipe];
    [enlargeImageView addGestureRecognizer:leftSwipe];
    
    //Up & Down Swipe
    UISwipeGestureRecognizer *upSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleUpSwipe:)];
    UISwipeGestureRecognizer *downSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleDownSwipe:)];
    [upSwipe setNumberOfTouchesRequired:1];
    [downSwipe setNumberOfTouchesRequired:1];
    [upSwipe setDirection:UISwipeGestureRecognizerDirectionUp];
    [downSwipe setDirection:UISwipeGestureRecognizerDirectionDown];
    [enlargeImageView addGestureRecognizer:upSwipe];
    [enlargeImageView addGestureRecognizer:downSwipe];
}

-(IBAction)handleSingleTap:(id)sender
{
    NSString *news_link = @"";
    if (viewingType == allImages || viewingType == markDuplicates) {
        news_link = [[imagesData objectAtIndex:selectedIndex] pageURL];
    } else if (viewingType == removeDuplicates) {
        news_link = [[noDupesImagesData objectAtIndex:selectedIndex] pageURL];
    } else if (viewingType == clusterImagesType)
        news_link = [[clusterImages objectAtIndex:selectedIndex] pageURL];
    
    CustomWebView *customWebView = [[CustomWebView alloc] initWithString:news_link andTitle:@"News Story"];
    [self.navigationController pushViewController:customWebView animated:YES];
}

-(IBAction)handleDoubleTap:(id)sender
{
    [self dismissBlackCover];
}

-(IBAction)handleRightSwipe:(id)sender
{
    if (selectedPageIndex > 0) {
        [self.collectionView selectItemAtIndexPath:[NSIndexPath indexPathForRow:selectedPageIndex-1 inSection:0] animated:YES scrollPosition:SSCollectionViewScrollPositionMiddle];
    } 

}

-(IBAction)handleLeftSwipe:(id)sender
{
    if (selectedPageIndex < numItems - 1) {
        [self.collectionView selectItemAtIndexPath:[NSIndexPath indexPathForRow:selectedPageIndex+1 inSection:0] animated:YES scrollPosition:SSCollectionViewScrollPositionMiddle];
    } 
}

-(IBAction)handleUpSwipe:(id)sender
{
    
     NSLog(@"UpSwipe");
    if (isPad) {
        
    } else {
        if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
            if (selectedPageIndex < numItems - 1 - 4) {
                [self.collectionView selectItemAtIndexPath:[NSIndexPath indexPathForRow:selectedPageIndex+4 inSection:0] animated:YES scrollPosition:SSCollectionViewScrollPositionMiddle];
            }
        } else {
            if (selectedPageIndex < numItems - 1 - 6) {
                [self.collectionView selectItemAtIndexPath:[NSIndexPath indexPathForRow:selectedPageIndex+6 inSection:0] animated:YES scrollPosition:SSCollectionViewScrollPositionMiddle];
                
            }
        }
    }
}

-(IBAction)handleDownSwipe:(id)sender
{
    NSLog(@"DownSwipe");
    if (isPad) {
        
    } else {
        if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
            if (selectedPageIndex > 3) {
                [self.collectionView selectItemAtIndexPath:[NSIndexPath indexPathForRow:selectedPageIndex-4 inSection:0] animated:YES scrollPosition:SSCollectionViewScrollPositionMiddle];
            }
        } else {
            if (selectedPageIndex > 5) 
                [self.collectionView selectItemAtIndexPath:[NSIndexPath indexPathForRow:selectedPageIndex-6 inSection:0] animated:YES scrollPosition:SSCollectionViewScrollPositionMiddle];
        }
    }
}

#pragma mark - Initialize & Setup

-(id) initWithImageTopic:(NSString*) topic withImageId:(int)image_num andStandMode:(int)mode andConstraints:(NSString *)constraints
{
    
    if (self = [super init]) {
        image_topic = topic;
        standMode = mode;
        image_id = image_num;
        if (constraints != nil) 
            image_constraints = constraints;
        else
            image_constraints = @"";
    }
    return self;
}

-(id) initWithImageTopic:(NSString*)topic withImageId:(int)num andStandMode:(int)mode andConstraints:(NSString *)constraints andSecondButtonTitle:(NSString *)secondButtonTitle;
{
    if (self = [super init]) {
        image_topic = topic;
        standMode = mode;
        image_id = num;
        secondLeftButtonTitle = secondButtonTitle;
        image_constraints = constraints;
    }
    return self;
}

-(id) initWithImageTopic:(NSString*)topic withImagesData:(NSMutableArray *)images andDupesImageData:(NSMutableArray *)dupes
{
    if (self = [super init]) {
        image_topic = topic;
        viewingType = allImages;
        imagesData = [[NSMutableArray alloc] initWithArray:images];
        noDupesImagesData = [[NSMutableArray alloc] initWithArray:dupes];
    }
    return self;
}

- (void) popToMap 
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void) popToTopStories 
{
    UIViewController *controller = [[self.navigationController viewControllers] objectAtIndex:2];
    if ([controller isKindOfClass:[TopStoriesViewController class]]) {
        [self.navigationController popToViewController:[[self.navigationController viewControllers] objectAtIndex:2] animated:YES];
    } else {
        [self.navigationController popToViewController:[[self.navigationController viewControllers] objectAtIndex:1] animated:YES];
    }
}

- (void) setupNavBar
{
    [self setTitle:image_topic];
    
    pageSegmentedControl = [[UISegmentedControl alloc] initWithItems:
                            [NSArray arrayWithObjects:
                             [UIImage imageNamed:@"left.png"],
                             [UIImage imageNamed:@"right.png"],
                             nil]];
	[pageSegmentedControl addTarget:self action:@selector(pageSegmentAction:) forControlEvents:UIControlEventValueChanged];
	pageSegmentedControl.frame = CGRectMake(0, 0, 90, 30);
	pageSegmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
	pageSegmentedControl.momentary = YES;
    [pageSegmentedControl setEnabled:NO forSegmentAtIndex:0];
    [pageSegmentedControl setEnabled:NO forSegmentAtIndex:1];
	UIBarButtonItem *segmentBarItem = [[UIBarButtonItem alloc] initWithCustomView:pageSegmentedControl];
    
	self.navigationItem.rightBarButtonItem = segmentBarItem;
    
    gridButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"grid24.png"] landscapeImagePhone:[UIImage imageNamed:@"grid20.png"] style:UIBarButtonItemStylePlain target:self action:@selector(dismissBlackCover)];
}

- (void) setupEnlargeImage
{
    blackButton =[UIButton buttonWithType:UIButtonTypeRoundedRect];
    blackButton.tintColor = [UIColor blackColor];
    [blackButton setImage:[UIImage imageNamed:@"black.jpg"] forState:UIControlStateNormal];
    [blackButton addTarget:self action:@selector(dismissBlackCover) forControlEvents:UIControlEventTouchUpInside];
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
    
    enlargeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(width/2, height/2, width, height)];
    [enlargeImageView setAlpha:0.0];

    imageBorder = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"black.jpg"]];
    [imageBorder setAlpha:0.0];
    
    captionLabel = [[UILabel alloc] init];
    [captionLabel setBackgroundColor:[UIColor clearColor]];
    [captionLabel setTextColor:[UIColor whiteColor]];
    [captionLabel setTextAlignment:UITextAlignmentCenter];
    [captionLabel setNumberOfLines:2];
    [captionLabel setFrame:CGRectMake(0, height-60, width, 40)];
    [captionLabel setShadowColor:[UIColor blackColor]];
}

- (void) setupToolbar
{
    NSMutableArray *botArray = [[NSMutableArray alloc] init];
    
    NSArray *segmentTextContent, *allTopicsTextContent;
    if (standMode < 2)
        segmentTextContent = [NSArray arrayWithObjects:NSLocalizedString(@"All Images", @""), NSLocalizedString(@"Mark Dups", @""), NSLocalizedString(@"Hide Dups", @""),nil];
    else { //PhotoStand 
        segmentTextContent = [NSArray arrayWithObjects:NSLocalizedString(@"All Images", @""), NSLocalizedString(@"Topics", @""), NSLocalizedString(@"Mark Dups", @""), NSLocalizedString(@"Hide Dups", @""), nil];
        allTopicsTextContent = [NSArray arrayWithObjects:NSLocalizedString(@"All Images", @""), NSLocalizedString(@"Topics", @""), nil];
    }
    displaySegmentedControl = [[UISegmentedControl alloc] initWithItems:segmentTextContent];
    [displaySegmentedControl addTarget:self action:@selector(displaySegmentAction:) forControlEvents:UIControlEventValueChanged];
	displaySegmentedControl.frame = CGRectMake(0, 0, 260, 30);
	displaySegmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
    [displaySegmentedControl setEnabled:NO forSegmentAtIndex:0];
    [displaySegmentedControl setEnabled:NO forSegmentAtIndex:1];
    [displaySegmentedControl setEnabled:NO forSegmentAtIndex:2];
    if (standMode >= 2) {
        [displaySegmentedControl setEnabled:NO forSegmentAtIndex:3];
    }
    
    actionButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareItemPressed)];
                  
    magnifyButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"search20.png"] landscapeImagePhone:[UIImage imageNamed:@"search16.png"] style:UIBarButtonItemStylePlain target:self action:@selector(magnifyButtonSelected)];
    
    allInTopicButton = [[UIBarButtonItem alloc] initWithTitle:@"All in Topic" style:UIBarButtonItemStyleBordered target:self action:@selector(allImagesInTopicButtonSelected)];
    
    [magnifyButton setEnabled:NO];
    
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    
    for (int i = 0; i < [displaySegmentedControl.subviews count]; i++) {
        [[displaySegmentedControl.subviews objectAtIndex:i] setTintColor:[UIColor darkGrayColor]];
    }
    
    if (imagesData != nil && [imagesData count] > 0) {
        UIBarButtonItem *segmentItem = [[UIBarButtonItem alloc] initWithCustomView:displaySegmentedControl];
        [botArray addObject:segmentItem];
    }
    
    [botArray addObject:spacer];
    [botArray addObject:magnifyButton];
    
    [self setToolbarItems:botArray];
    
    if (standMode >= 2) {
        allTopicsSegmentedControl = [[UISegmentedControl alloc] initWithItems:allTopicsTextContent];
        [allTopicsSegmentedControl addTarget:self action:@selector(displaySegmentAction:) forControlEvents:UIControlEventValueChanged];
        allTopicsSegmentedControl.frame = CGRectMake(0, 0, 130, 30);
        allTopicsSegmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
        [allTopicsSegmentedControl setSelectedSegmentIndex:1];
        
        [[allTopicsSegmentedControl.subviews objectAtIndex:0] setTintColor:[UIColor darkGrayColor]];
        [[allTopicsSegmentedControl.subviews objectAtIndex:1] setTintColor:[UIColor darkGrayColor]];
    }
}

- (void)didReceiveMemoryWarning
{
    NSLog(@"Image viewer received memory warning");
    [super didReceiveMemoryWarning];
}

#pragma mark - Update when Appear

- (void)updateImageViewerOnAppear
{
    ImageData *curr_img;
    
    if (viewingType == allImages || viewingType == markDuplicates) {
        curr_img = [imagesData objectAtIndex:selectedIndex];
    } else if (viewingType == removeDuplicates) {
        curr_img = [noDupesImagesData objectAtIndex:selectedIndex];
    } else if (viewingType == clusterImagesType) {
        curr_img = [clusterImages objectAtIndex:selectedIndex];
    }
    
    float img_width = [curr_img width];
    float img_height = [curr_img height];
    
    CGSize screenDimensions;
    if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation]))
        screenDimensions = [[UIDevice currentDevice] screenSizeForOrientation:UIDeviceOrientationPortrait];
    else
        screenDimensions = [[UIDevice currentDevice] screenSizeForOrientation:UIDeviceOrientationLandscapeLeft];

    float view_width = screenDimensions.width;
    float view_height = screenDimensions.height;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:.2];
    
    
    [enlargeImageView setFrame:CGRectMake(view_width/2, (view_height-80)/2, 1, 1)];
    [imageBorder setFrame:CGRectMake(view_width/2, (view_height-80)/2, 1, 1)];
    float startX, startY, height, width;
    if (view_width < view_height) { //Portrait
        startX = view_width / 5.0;
        startY = (view_height - 80.0) / 5.0;
    } else { //Landscape
        startX = view_width / 4.0;
        startY = (view_height - 42.0) / 5.0 - 42;
    }
    
    float factor;
    if (img_height >= img_width) {
        if (view_width < view_height) {
            factor = (view_height/2.0-42.0)/img_height;
            width = img_width * factor;
            height = view_height/2.0-42.0;
        } else {
            factor = (view_height/2.0)/img_height;
            width = img_width * factor;
            height = factor * img_height;
        }
        
        [enlargeImageView setUserInteractionEnabled:TRUE];
        [enlargeImageView setFrame:CGRectMake(view_width/2-(.5*width), startY, width, height)];
    } else { // Image Width is larger
        if (view_width < view_height) { //Portrait
            factor = (startX*3.0)/img_width;
            height = img_height * factor;
            width = startX*3.0;
            
            [enlargeImageView setFrame:CGRectMake(startX, ((view_height-80)/2)-(.5*height), width, height)];
        } else {
            factor = (view_width/2.0 - 38.0)/img_width;
            height = img_height * factor;
            width = img_width * factor; 
            
            [enlargeImageView setFrame:CGRectMake(startX+10.5, ((view_height-80)/2)-(.5*height) - 21.0, width, height)];
        }
        
        [enlargeImageView setUserInteractionEnabled:TRUE];
        
    }
    [blackButton setAlpha:.4];
    
    [imageBorder setAlpha:.68];
    [imageBorder setFrame:CGRectMake(enlargeImageView.frame.origin.x-4, enlargeImageView.frame.origin.y-4, enlargeImageView.frame.size.width+8, enlargeImageView.frame.size.height+8)];
    [captionLabel setText:[curr_img caption]];
    [captionLabel setFrame:CGRectMake(0.0, enlargeImageView.frame.origin.y + enlargeImageView.frame.size.height + 10, view_width, 40)];
    [UIView commitAnimations];
}

#pragma mark - View Controller

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
		return toInterfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
	}
    

	return YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.collectionView reloadData];

}

- (void)viewWillAppear:(BOOL)animated
{
    //UILabel *topLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.navigationController.navigationBar.frame.origin.x+30, self.navigationController.navigationBar.frame.origin.y, 60.0f, 40.0f)];
    if (secondLeftButtonTitle != nil && [secondLeftButtonTitle isEqualToString:@"Top Stories"]) {
        if (secondLeftButton == nil) {
            /*[topLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:12]];
            [topLabel setBackgroundColor:[UIColor clearColor]];
            [topLabel setTextColor:[UIColor whiteColor]];
            [topLabel setText:@"Top\nStories"];
            [topLabel setNumberOfLines:2];
            [topLabel setTextAlignment:UITextAlignmentCenter];
            */
            
            //secondLeftButton = [[UIBarButtonItem alloc] initWithCustomView:topLabel];
            //[secondLeftButton setStyle:UIBarButtonItemStylePlain];
            //[secondLeftButton setAction:@selector(popToTopStories)];
            
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button setTitle:@"Top\nStories" forState:UIControlStateNormal];
            UIFont *font = [UIFont fontWithName:@"Helvetica-Bold" size:12];
            [button.titleLabel setFont:font];
            [button.titleLabel setShadowColor:[UIColor whiteColor]];
            [button.titleLabel setShadowOffset:CGSizeMake(0, 1)];
            [button.titleLabel setNumberOfLines:2];
            [button.titleLabel setTextAlignment:UITextAlignmentCenter];
            //Add 15 to the width for a left-right buffer
            [button setFrame:CGRectMake(0.0, 0.0, 50, 30)];
            [button addTarget:self action:@selector(popToTopStories) forControlEvents:UIControlEventTouchUpInside];
            
            secondLeftButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"topStories2.png"] style:UIBarButtonItemStylePlain target:self action:@selector(popToTopStories)];
            
           // secondLeftButton = [[UIBarButtonItem alloc] initWithCustomView:button];
        }
    } else if (secondLeftButtonTitle != nil && [secondLeftButtonTitle isEqualToString:@"Map"]) {
        if (secondLeftButton == nil) {
            secondLeftButton = [[UIBarButtonItem alloc] initWithTitle:@" Map " style:UIBarButtonItemStylePlain target:self action:@selector(popToMap)];
        }
    }
    [self.navigationItem setLeftItemsSupplementBackButton:YES];
    [self.navigationItem setLeftBarButtonItem:secondLeftButton animated:NO];
    //[self.view addSubview:topLabel];
    
    stopDismiss = FALSE;
    [super viewWillAppear:animated];
    [[self.navigationController navigationBar] setAlpha:1.0];
    [[self.navigationController navigationBar] setBarStyle:UIBarStyleBlackOpaque];
    [[self.navigationController toolbar] setBarStyle:UIBarStyleBlackOpaque];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [[self.navigationController toolbar] setAlpha:1.0];
    [self.navigationController setToolbarHidden:NO animated:YES];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
    [self.collectionView reloadData];

    if ([blackButton alpha] > 0.0) {
        [self updateImageViewerOnAppear];
    }
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if (blackButton != nil && [blackButton alpha] > 0) {
        UIInterfaceOrientation currentOrientation = [[UIApplication sharedApplication] statusBarOrientation];
        
        if (toInterfaceOrientation == currentOrientation) {
            // do Nothing
        } else if (UIDeviceOrientationIsLandscape(currentOrientation) && UIDeviceOrientationIsLandscape(toInterfaceOrientation)) {
            // do Nothing
        } else {
            ImageData *curr_img;
            
            if (viewingType == allImages || viewingType == markDuplicates) {
                curr_img = [imagesData objectAtIndex:selectedIndex];
            } else if (viewingType == removeDuplicates) {
                curr_img = [noDupesImagesData objectAtIndex:selectedIndex];
            } else if (viewingType == clusterImagesType) {
                curr_img = [clusterImages objectAtIndex:selectedIndex];
            }
            
            float img_width = [curr_img width];
            float img_height = [curr_img height];
            
            CGSize screenDimensions = [[UIDevice currentDevice] screenSizeForOrientation:[[UIDevice currentDevice] orientation]];
            float view_width = screenDimensions.width;
            float view_height = screenDimensions.height;
            
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:.2];
        
            
            [enlargeImageView setFrame:CGRectMake(view_width/2, (view_height-80)/2, 1, 1)];
            [imageBorder setFrame:CGRectMake(view_width/2, (view_height-80)/2, 1, 1)];
            float startX, startY, height, width;
            if (view_width < view_height) { //Portrait
                startX = view_width / 5.0;
                startY = (view_height - 80.0) / 5.0;
            } else { //Landscape
                startX = view_width / 4.0;
                startY = (view_height - 42.0) / 5.0 - 42;
            }
            
            float factor;
            if (img_height >= img_width) {
                if (view_width < view_height) {
                    factor = (view_height/2.0-42.0)/img_height;
                    width = img_width * factor;
                    height = view_height/2.0-42.0;
                } else {
                    factor = (view_height/2.0)/img_height;
                    width = img_width * factor;
                    height = factor * img_height;
                }
                
                [enlargeImageView setUserInteractionEnabled:TRUE];
                [enlargeImageView setFrame:CGRectMake(view_width/2-(.5*width), startY, width, height)];
            } else { // Image Width is larger
                if (view_width < view_height) { //Portrait
                    factor = (startX*3.0)/img_width;
                    height = img_height * factor;
                    width = startX*3.0;
                    
                    [enlargeImageView setFrame:CGRectMake(startX, ((view_height-80)/2)-(.5*height), width, height)];
                } else {
                    factor = (view_width/2.0 - 38.0)/img_width;
                    height = img_height * factor;
                    width = img_width * factor; 
                    
                    [enlargeImageView setFrame:CGRectMake(startX+10.5, ((view_height-80)/2)-(.5*height) - 21.0, width, height)];
                }
                
                [enlargeImageView setUserInteractionEnabled:TRUE];
                
            }
            [blackButton setAlpha:.4];
            
            [imageBorder setAlpha:.68];
            [imageBorder setFrame:CGRectMake(enlargeImageView.frame.origin.x-4, enlargeImageView.frame.origin.y-4, enlargeImageView.frame.size.width+8, enlargeImageView.frame.size.height+8)];
            [captionLabel setText:[curr_img caption]];
            [captionLabel setFrame:CGRectMake(0.0, enlargeImageView.frame.origin.y + enlargeImageView.frame.size.height + 10, view_width, 40)];
            [UIView commitAnimations];
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.navigationItem setLeftBarButtonItem:nil];
    if (queue != nil)
        [queue cancelAllOperations];
    if (viewingType == allImages) {
        self.navigationItem.backBarButtonItem =
        [[UIBarButtonItem alloc] initWithTitle:@"All Images"
                                         style:UIBarButtonItemStylePlain
                                        target:nil
                                        action:nil];
    } else if (viewingType == clusterImagesType) {
        self.navigationItem.backBarButtonItem =
        [[UIBarButtonItem alloc] initWithTitle:@"Topics"
                                         style:UIBarButtonItemStylePlain
                                        target:nil
                                        action:nil];
    } else if (viewingType == markDuplicates) {
        self.navigationItem.backBarButtonItem =
        [[UIBarButtonItem alloc] initWithTitle:@"No Dups"
                                         style:UIBarButtonItemStylePlain
                                        target:nil
                                        action:nil];
    } else {
        self.navigationItem.backBarButtonItem =
        [[UIBarButtonItem alloc] initWithTitle:@"Hide Dups"
                                         style:UIBarButtonItemStylePlain
                                        target:nil
                                        action:nil];
    }
    if (!stopDismiss)
        [NSTimer scheduledTimerWithTimeInterval:.4 target:self selector:@selector(dismissBlackCover) userInfo:nil repeats:NO];
}

- (void)setCollectionViewProperties
{
    [self.collectionView setRowSpacing:3];
    [self.collectionView setMinimumColumnSpacing:3];
    [self.collectionView setBackgroundColor:[UIColor scrollViewTexturedBackgroundColor]];
    [self.collectionView setExtremitiesStyle:SSCollectionViewExtremitiesStyleScrolling];
}


- (void)viewDidLoad
{
    NSString *url_str;
    NSLog(@"ImageViewer with standmode : %d", standMode);
    if (imagesData == nil || [imagesData count] == 0) {
        if (standMode == 0)
            url_str = [NSString stringWithFormat:@"http://newsstand.umiacs.umd.edu/news/xml_images?cluster_id=%d%@", image_id,image_constraints];
        else if (standMode == 1) 
            url_str = [NSString stringWithFormat:@"http://twitterstand.umiacs.umd.edu/news/xml_images?cluster_id=%d%@", image_id,image_constraints];
        else if (standMode == 2)
            url_str = [NSString stringWithFormat:@"http://newsstand.umiacs.umd.edu/news/xml_gaz_images?gaz_id=%d%@", image_id, image_constraints];
        else 
            url_str = [NSString stringWithFormat:@"http://twitterstand.umiacs.umd.edu/news/xml_gaz_images?gaz_id=%d%@", image_id, image_constraints];
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        queue = [[NSOperationQueue alloc] init];
        
        ImageViewRequestOperation *imageViewRequestOperation = [[ImageViewRequestOperation alloc] initWithRequestString:url_str andImageViewer:self andStandMode:standMode];
        [queue addOperation:imageViewRequestOperation];
    } 
    
    [self setupNavBar];
    [self setupEnlargeImage];
    [self setupToolbar];
    [self setCollectionViewProperties];
    
    if (imagesData != nil && [imagesData count] > 0) {
        [self noParseSetup];
    }
}

#pragma mark - SSCollectionViewDataSource

- (NSUInteger)numberOfSectionsInCollectionView:(SSCollectionView *)aCollectionView {
	return 1;
}


- (NSUInteger)collectionView:(SSCollectionView *)aCollectionView numberOfItemsInSection:(NSUInteger)section {
    if (viewingType == allImages || viewingType == markDuplicates) {
        numItems = [imagesData count] - 48*pageNum;
    } else if (viewingType == removeDuplicates) {
        numItems = [noDupesImagesData count] - 48*pageNum;
    } else if (viewingType == clusterImagesType)
        numItems = [clusterImages count] - 48*pageNum;
    
    if (numItems > 48)
        numItems = 48;
    
    return numItems;
}


- (SSCollectionViewItem *)collectionView:(SSCollectionView *)aCollectionView itemForIndexPath:(NSIndexPath *)indexPath {
    static NSString *const itemIdentifier = @"itemIdentifier";
	
    int row = [indexPath row];
    
    SCImageCollectionViewItem *item = (SCImageCollectionViewItem *)[aCollectionView dequeueReusableItemWithIdentifier:itemIdentifier];
	if (item == nil) {
		item = [[SCImageCollectionViewItem alloc] initWithReuseIdentifier:itemIdentifier];
	}
	
    int image_index = (pageNum*48)+row;
    if (viewingType == allImages || viewingType == markDuplicates) {
        ImageData *currImage = [imagesData objectAtIndex:image_index];
        item.imageURL = [currImage imageURL];
        if (viewingType == markDuplicates && [currImage isDupe]) 
            [item setDupeAlpha];
        else
            [item setFullAlpha];
        
    } else if (viewingType == removeDuplicates) {
        ImageData *currImage = [noDupesImagesData objectAtIndex:image_index];
        item.imageURL = [currImage imageURL];
        [item setFullAlpha];
    } else { //Cluster Type
        ImageData *currImage = [clusterImages objectAtIndex:image_index];
        item.imageURL = [currImage imageURL];
        [item setFullAlpha];
    }
    
	return item;
}


- (UIView *)collectionView:(SSCollectionView *)aCollectionView viewForHeaderInSection:(NSUInteger)section {
	return nil;
}


#pragma mark - SSCollectionViewDelegate

- (CGSize)collectionView:(SSCollectionView *)aCollectionView itemSizeForSection:(NSUInteger)section {
    float dim;
    if (!isPad) {
        if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
            dim = 305.0 / 4.0;
        } else {
            dim = 459.0 / 6.0;
        }
    } else {
        if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
            dim = 740 / 4.0;
        } else {
            dim = 1000 / 6.0;
        }
    }
        
    return CGSizeMake(dim, dim);
}


- (void)collectionView:(SSCollectionView *)aCollectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
	[self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:SSCollectionViewScrollPositionMiddle animated:YES];
    
    [enlargeImageView removeFromSuperview];
    [imageBorder removeFromSuperview];
    [captionLabel removeFromSuperview];
    
    
    selectedIndex = [indexPath row] + pageNum*48;
    selectedPageIndex = [indexPath row];
    
    ImageData *curr_img;
    
    if (viewingType == allImages || viewingType == markDuplicates) {
        curr_img = [imagesData objectAtIndex:selectedIndex];
    } else if (viewingType == removeDuplicates) {
        curr_img = [noDupesImagesData objectAtIndex:selectedIndex];
    } else if (viewingType == clusterImagesType)
        curr_img = [clusterImages objectAtIndex:selectedIndex];
    
    float img_width = [curr_img width];
    float img_height = [curr_img height];
    
    CGSize screenDimensions;
    if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation]))
        screenDimensions = [[UIDevice currentDevice] screenSizeForOrientation:UIDeviceOrientationPortrait];
    else
        screenDimensions = [[UIDevice currentDevice] screenSizeForOrientation:UIDeviceOrientationLandscapeLeft];
        
    float view_width = screenDimensions.width;
    float view_height = screenDimensions.height;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:.2];
    
    SSCollectionViewItem *item = [self collectionView:self.collectionView itemForIndexPath:indexPath];
    enlargeImageView = [item imageView];

    [enlargeImageView setFrame:CGRectMake(view_width/2, (view_height-80)/2, 1, 1)];
    [imageBorder setFrame:CGRectMake(view_width/2, (view_height-80)/2, 1, 1)];
    float startX, startY, height, width;
    if (view_width < view_height) { //Portrait
        startX = view_width / 5.0;
        startY = (view_height - 80.0) / 5.0;
    } else { //Landscape
        startX = view_width / 4.0;
        startY = (view_height - 42.0) / 5.0 - 42;
    }
   
    float factor;
    if (img_height >= img_width) {
        if (view_width < view_height) {
            factor = (view_height/2.0-42.0)/img_height;
            width = img_width * factor;
            height = view_height/2.0-42.0;
        } else {
            factor = (view_height/2.0)/img_height;
            width = img_width * factor;
            height = factor * img_height;
        }
        
        [enlargeImageView setUserInteractionEnabled:TRUE];
        [enlargeImageView setFrame:CGRectMake(view_width/2-(.5*width), startY, width, height)];
    } else { // Image Width is larger
        if (view_width < view_height) { //Portrait
            factor = (startX*3.0)/img_width;
            height = img_height * factor;
            width = startX*3.0;
            
            [enlargeImageView setFrame:CGRectMake(startX, ((view_height-80)/2)-(.5*height), width, height)];
        } else {
            factor = (view_width/2.0 - 38.0)/img_width;
            height = img_height * factor;
            width = img_width * factor; 
            
            [enlargeImageView setFrame:CGRectMake(startX+10.5, ((view_height-80)/2)-(.5*height) - 21.0, width, height)];
        }
        
        [enlargeImageView setUserInteractionEnabled:TRUE];
        
    }
    [blackButton setAlpha:.4];

    [imageBorder setAlpha:.68];
    [imageBorder setFrame:CGRectMake(enlargeImageView.frame.origin.x-4, enlargeImageView.frame.origin.y-4, enlargeImageView.frame.size.width+8, enlargeImageView.frame.size.height+8)];
    [captionLabel setText:[curr_img caption]];
    [captionLabel setFrame:CGRectMake(0.0, enlargeImageView.frame.origin.y + enlargeImageView.frame.size.height + 10, view_width, 40)];
    
    [self.view addSubview:imageBorder];
    [self.view addSubview:captionLabel];
    
    [self.view addSubview:enlargeImageView];
    
    [UIView commitAnimations];
    [self setupGestureRecognizers];
    
    self.navigationItem.rightBarButtonItem = gridButton;
    
    if (viewingType != clusterImagesType) {
        //Want to disable segmented controls as they do not have context here
        NSMutableArray *botArray = [[NSMutableArray alloc] init];
        UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
        
        [botArray addObject:actionButton];
        
        [botArray addObject:spacer];
        [botArray addObject:magnifyButton];
        [self setToolbarItems:botArray animated:YES];
        
        
    } else {
        [pageSegmentedControl setEnabled:NO forSegmentAtIndex:0];
        [pageSegmentedControl setEnabled:NO forSegmentAtIndex:1];
        
        int currentClusterID = [curr_img cluster_id];
        int totalInCluster = 0;
        
        currClusterImages = [[NSMutableArray alloc] init];
        noDupesCurrentCluster = [[NSMutableArray alloc] init];
        
        for (ImageData *curr in imagesData) {
            if ([curr cluster_id] == currentClusterID) {
                [currClusterImages addObject:curr];
                totalInCluster++;
                if (![curr isDupe]) {
                    [noDupesCurrentCluster addObject:curr];
                }
            }
        }
        
        if (totalInCluster > 1) {
            [allInTopicButton setEnabled:YES];
        } else {
            [allInTopicButton setEnabled:NO];
        }
        
        NSMutableArray *botArray = [[NSMutableArray alloc] init];
            
        UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
            
        [botArray addObject:actionButton];
        
        if (totalInCluster > 1) {
            [botArray addObject:spacer];
            [botArray addObject:allInTopicButton];            
        }
        
        [botArray addObject:spacer];
        [botArray addObject:magnifyButton];
        [self setToolbarItems:botArray animated:YES];
    }
}

- (CGFloat)collectionView:(SSCollectionView *)aCollectionView heightForHeaderInSection:(NSUInteger)section {
	return 0.0f;
}

#pragma mark - ScrollView

#pragma mark - ScrollView Delegate
- (void) goToBottom {
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:47 inSection:0] atScrollPosition:SSCollectionViewScrollPositionBottom animated:NO];
}

- (void) goBackPageScrollToBottom
{
    pageNum--;
    if (pageNum == 0) {
        [pageSegmentedControl setEnabled:NO forSegmentAtIndex:0];
        backEnabled = NO;
    }
    [pageSegmentedControl setEnabled:YES forSegmentAtIndex:1];
    forwardEnabled = YES;

    [self.collectionView reloadData];    
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:36 inSection:0] atScrollPosition:SSCollectionViewScrollPositionTop animated:NO];
}

- (void) goForwardPageScrollToBottom
{
    pageNum++;
    if (pageNum == (numPages-1)) {
        [pageSegmentedControl setEnabled:NO forSegmentAtIndex:1];
        forwardEnabled = NO;
    }
    backEnabled = YES;
    [pageSegmentedControl setEnabled:YES forSegmentAtIndex:0];

    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:SSCollectionViewScrollPositionBottom animated:NO];
    [self.collectionView reloadData];
}

- (void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.collectionView.scrollView.contentOffset.y < - 48) {
        //If can go back, go back
        if (pageNum > 0) {
            [self goBackPageScrollToBottom];
        }
    } else if (self.collectionView.scrollView.contentOffset.y >= (self.collectionView.scrollView.contentSize.height - self.collectionView.scrollView.bounds.size.height + 48)) {
        if (pageNum < numPages - 1) {
            [self goForwardPageScrollToBottom];
        }
    }

}

#pragma mark - Populate Tabbar

- (void) setTabBarForAllTopics
{
    NSMutableArray *botArray = [[NSMutableArray alloc] init];
    
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem *segmentBarItem = [[UIBarButtonItem alloc] initWithCustomView:allTopicsSegmentedControl];
    
    [allTopicsSegmentedControl setSelectedSegmentIndex:1];
    
    [botArray addObject:segmentBarItem];
    [botArray addObject:spacer];
    [botArray addObject:magnifyButton];
    [self setToolbarItems:botArray];
}
 
- (void) setTabBarNormal
{
    NSMutableArray *botArray = [[NSMutableArray alloc] init];
    
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem *segmentBarItem = [[UIBarButtonItem alloc] initWithCustomView:displaySegmentedControl];
    
    [botArray addObject:segmentBarItem];            
    [botArray addObject:spacer];
    [botArray addObject:magnifyButton];
    
    [self setToolbarItems:botArray];
}

#pragma mark - NSXMLParser Callback
-(void)parseEnded:(NSMutableArray*)imagesArray
{
    imagesData = [[NSMutableArray alloc] initWithArray:[imagesArray objectAtIndex:0]];

    if (standMode >= 2) {
        clusterImages = [[NSMutableArray alloc] initWithArray:[imagesArray objectAtIndex:1]];
    }

    
    NSMutableArray *imageClustersSeen = [[NSMutableArray alloc] init];
    noDupesImagesData = [[NSMutableArray alloc] init];
    
    int totalImages = [imagesData count];
    
    NSLog(@"B");
    
    if (standMode >= 2) {
        for (int i = 0; i < totalImages; i++) {
            NSNumber *currImageCluster = [[NSNumber alloc] initWithInt:[[imagesData objectAtIndex:i] image_cluster_id]];
            if (![imageClustersSeen containsObject:currImageCluster]) {
                [[imagesData objectAtIndex:i] setIsDupe:NO];
                [noDupesImagesData addObject:[imagesData objectAtIndex:i]];
                [imageClustersSeen addObject:currImageCluster];
            } else {
                [[imagesData objectAtIndex:i] setIsDupe:YES];
            }
        }
    } else {
        for (ImageData *currentImage in imagesData) {
            if (![currentImage isDupe]) {
                [noDupesImagesData addObject:currentImage];
            }
        }
    }
    
    pageNum = 0;
    viewingType = allImages;
    backEnabled = NO;
    
    numPages = [imagesData count] / 48;
    if ([imagesData count] % 48 != 0) 
        numPages ++;
    
    [self.collectionView reloadData];
    
    NSLog(@"numPages %d", numPages);
    
    if ([imagesData count] > 0) {
        [magnifyButton setEnabled:YES];
        if ([imagesData count] > 48) {
            [pageSegmentedControl setEnabled:YES forSegmentAtIndex:1];
            forwardEnabled = YES;
        }
    }
    [displaySegmentedControl setEnabled:YES forSegmentAtIndex:0];
    [displaySegmentedControl setEnabled:YES forSegmentAtIndex:1];
    [displaySegmentedControl setEnabled:YES forSegmentAtIndex:2];
    if (standMode >= 2)
        [displaySegmentedControl setEnabled:YES forSegmentAtIndex:3];
    
    [displaySegmentedControl setSelectedSegmentIndex:0];
    
    NSLog(@"C");
    
    NSMutableArray *botArray = [[NSMutableArray alloc] init];
    UIBarButtonItem *segmentBarItem = [[UIBarButtonItem alloc] initWithCustomView:displaySegmentedControl];
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    
    [botArray addObject:segmentBarItem];
    [botArray addObject:spacer];
    [botArray addObject:magnifyButton];
     
    [self setToolbarItems:botArray animated:YES];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [self.collectionView reloadData];
}

- (void) noParseSetup
{
	[self.collectionView reloadData];
    
    pageNum = 0;
    viewingType = allImages;
    backEnabled = NO;
    
    numPages = [imagesData count] / 48;
    if ([imagesData count] % 48 != 0) 
        numPages ++;
    
    NSLog(@"numPages %d", numPages);
    
    if ([imagesData count] > 0) {
        [magnifyButton setEnabled:YES];
        if ([imagesData count] > 48) {
            [pageSegmentedControl setEnabled:YES forSegmentAtIndex:1];
            forwardEnabled = YES;
        }
    }
    [displaySegmentedControl setEnabled:YES forSegmentAtIndex:0];
    [displaySegmentedControl setEnabled:YES forSegmentAtIndex:1];
    [displaySegmentedControl setEnabled:YES forSegmentAtIndex:2];
    
    [displaySegmentedControl setSelectedSegmentIndex:0];
}

@end


