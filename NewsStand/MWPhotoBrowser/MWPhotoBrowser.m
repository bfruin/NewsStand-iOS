//
//  MWPhotoBrowser.m
//  MWPhotoBrowser
//
//  Created by Michael Waterfall on 14/10/2010.
//  Copyright 2010 d3i. All rights reserved.
/*
 Copyright (c) 2010 Michael Waterfall
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included
 in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */
//

#import "MWPhotoBrowser.h"
#import "ZoomingScrollView.h"
#import "CustomWebView.h"
#import "TopStoriesViewController.h"

#define PADDING 10

// Handle depreciations and supress hide warnings
@interface UIApplication (DepreciationWarningSuppresion)
- (void)setStatusBarHidden:(BOOL)hidden animated:(BOOL)animated;
@end

// MWPhotoBrowser
@implementation MWPhotoBrowser

@synthesize secondLeftButton;

- (id)initWithPhotos:(NSArray *)photosArray andCaptions:(NSArray *)captionsArray andSourceURLs:(NSArray *)sourcesArray {
	if ((self = [super init])) {
		
		// Store photos
		photos = [[NSMutableArray alloc] initWithArray:photosArray];
		captions = [[NSMutableArray alloc] initWithArray:captionsArray];
		urlArray = [[NSMutableArray alloc] initWithArray:sourcesArray];
		
        // Defaults
		self.wantsFullScreenLayout = YES;
        self.hidesBottomBarWhenPushed = YES;
		currentPageIndex = 0;
		performingLayout = NO;
		rotating = NO;
		
		currentCaption = [[UILabel alloc] init];
		currentCaption.backgroundColor = [UIColor clearColor];
		currentCaption.textColor = [UIColor whiteColor];
		currentCaption.textAlignment = UITextAlignmentCenter;
		currentCaption.numberOfLines = 2;
		
		
	}
	return self;
}

#pragma mark -
#pragma mark Memory

- (void)didReceiveMemoryWarning {
	
	// Release any cached data, images, etc that aren't in use.
	
	// Release images
	[photos makeObjectsPerformSelector:@selector(releasePhoto)];
	[recycledPages removeAllObjects];
	NSLog(@"didReceiveMemoryWarning");
	
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
}

// Release any retained subviews of the main view.
- (void)viewDidUnload {
	currentPageIndex = 0;
}

#pragma mark -
#pragma mark View

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

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    self.navigationItem.backBarButtonItem =
    [[UIBarButtonItem alloc] initWithTitle:@"Image"
                                     style:UIBarButtonItemStylePlain
                                    target:nil
                                    action:nil];
	// View
	self.view.backgroundColor = [UIColor blackColor];
	//self.view.
	
	// Setup paging scrolling view
	CGRect pagingScrollViewFrame = [self frameForPagingScrollView];
	pagingScrollView = [[UIScrollView alloc] initWithFrame:pagingScrollViewFrame];
	pagingScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	pagingScrollView.pagingEnabled = YES;
	pagingScrollView.delegate = self;
	pagingScrollView.showsHorizontalScrollIndicator = NO;
	pagingScrollView.showsVerticalScrollIndicator = NO;
	pagingScrollView.backgroundColor = [UIColor blackColor];
    pagingScrollView.contentSize = [self contentSizeForPagingScrollView];
	pagingScrollView.contentOffset = [self contentOffsetForPageAtIndex:currentPageIndex];
	[self.view addSubview:pagingScrollView];
	
	// Setup pages
	visiblePages = [[NSMutableSet alloc] init];
	recycledPages = [[NSMutableSet alloc] init];
	[self tilePages];

	
    UIViewController *controller = [[self.navigationController viewControllers] objectAtIndex:1];
    if ([controller isKindOfClass:[TopStoriesViewController class]]) {
        secondLeftButtonTitle = @"Top Stories";
    } else {
        secondLeftButtonTitle = @" Map ";
    }
    
    if ([secondLeftButtonTitle isEqualToString:@"Top Stories"]) {
        secondLeftButton = [[UIBarButtonItem alloc] initWithTitle:@"Top Stories" style:UIBarButtonItemStylePlain target:self action:@selector(popToTopStories)];
    } else {
        secondLeftButton = [[UIBarButtonItem alloc] initWithTitle:@" Map " style:UIBarButtonItemStylePlain target:self action:@selector(popToMap)];
    }
    //[self.navigationItem setLeftItemsSupplementBackButton:YES];
    self.navigationItem.rightBarButtonItem = secondLeftButton;
    
	// Only show toolbar if there's more that 1 photo
    if (photos.count > 1) {
        
        // Toolbar Items
        previousButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"left.png"] style:UIBarButtonItemStylePlain target:self action:@selector(gotoPreviousPage)];
        sourceButton = [[UIBarButtonItem alloc] initWithTitle:@"Article" style:UIBarButtonItemStylePlain target:self action:@selector(handleSourceButton)];
        nextButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"right.png"] style:UIBarButtonItemStylePlain target:self action:@selector(gotoNextPage)];
        UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
        NSMutableArray *items = [[NSMutableArray alloc] init];
        [items addObject:space];
        if (photos.count > 1) [items addObject:previousButton];
        [items addObject:space];
        [items addObject:sourceButton];
        [items addObject:space];
        if (photos.count > 1) [items addObject:nextButton];
        [items addObject:space];
        [self setToolbarItems:items];
    }
	
	// Super
    [super viewDidLoad];
	
}
									 
- (void) handleBackButton
{
	[self actionForDoubleTap];
}
					 
- (void) handleSourceButton
{
	[self actionForSingleTap];
						 
}

- (void)viewWillAppear:(BOOL)animated {
    
	// Super
	[super viewWillAppear:animated];
	
	// Layout
	[self performLayout];
    
    // Set status bar style to black translucent
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent animated:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [[self.navigationController navigationBar] setBarStyle:UIBarStyleBlackOpaque];
    [[self.navigationController toolbar] setBarStyle:UIBarStyleBlackOpaque];
    [self.navigationController setToolbarHidden:NO];
    	
	// Navigation
	[self updateNavigation];
	[self hideControlsAfterDelay];
	[self didStartViewingPageAtIndex:currentPageIndex]; // initial
	
    customViewVisible = FALSE;
}

- (void)viewWillDisappear:(BOOL)animated {
	
	// Super
	[super viewWillDisappear:animated];

	// Cancel any hiding timers
	[self cancelControlHiding];
	[self.navigationItem setLeftBarButtonItem:nil];
}

#pragma mark -
#pragma mark Layout

// Layout subviews
- (void)performLayout {
	
	// Flag
	performingLayout = YES;
	
	// Remember index
	NSUInteger indexPriorToLayout = currentPageIndex;
	
	// Get paging scroll view frame to determine if anything needs changing
	CGRect pagingScrollViewFrame = [self frameForPagingScrollView];
		
	// Frame needs changing
	pagingScrollView.frame = pagingScrollViewFrame;
	
	// Recalculate contentSize based on current orientation
	pagingScrollView.contentSize = [self contentSizeForPagingScrollView];
	
	// Adjust frames and configuration of each visible page
	for (ZoomingScrollView *page in visiblePages) {
		page.frame = [self frameForPageAtIndex:page.index];
		[page setMaxMinZoomScalesForCurrentBounds];
	}
	
	// Adjust contentOffset to preserve page location based on values collected prior to location
	pagingScrollView.contentOffset = [self contentOffsetForPageAtIndex:indexPriorToLayout];
	
	// Reset
	currentPageIndex = indexPriorToLayout;
	performingLayout = NO;

}

#pragma mark -
#pragma mark Photos

// Get image if it has been loaded, otherwise nil
- (UIImage *)imageAtIndex:(NSUInteger)index {
	if (photos && index < photos.count) {

		// Get image or obtain in background
		MWPhoto *photo = [photos objectAtIndex:index];
		if ([photo isImageAvailable]) {
			return [photo image];
		} else {
			[photo obtainImageInBackgroundAndNotify:self];
		}
		
	}
	return nil;
}

- (void) displayCaption
{
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:.13];
	[currentCaption removeFromSuperview];
	[currentCaption setTextAlignment:UITextAlignmentCenter];
	currentCaption.text = [captions objectAtIndex:currentPageIndex];
	currentCaption.frame = CGRectMake(0, self.view.frame.size.height-80, self.view.frame.size.width, 40);
    
	[self.view addSubview:currentCaption];
	[UIView commitAnimations];
}

#pragma mark -
#pragma mark MWPhotoDelegate

- (void)photoDidFinishLoading:(MWPhoto *)photo {
	NSUInteger index = [photos indexOfObject:photo];
	if (index != NSNotFound) {
		if ([self isDisplayingPageForIndex:index]) {

			// Tell page to display image again
			ZoomingScrollView *page = [self pageDisplayedAtIndex:index];
			if (page) [page displayImage];
		}
	}
}

- (void)photoDidFailToLoad:(MWPhoto *)photo {
	NSUInteger index = [photos indexOfObject:photo];
	if (index != NSNotFound) {
		if ([self isDisplayingPageForIndex:index]) {
			
			// Tell page it failed
			ZoomingScrollView *page = [self pageDisplayedAtIndex:index];
			if (page) [page displayImageFailure];
			
		}
	}
}


#pragma mark -
#pragma mark Handle Tap Calls from UIImageViewTap
- (void)actionForSingleTap
{
    
    if (!customViewVisible) {
        CustomWebView *customWebView = [[CustomWebView alloc] initWithString:[urlArray objectAtIndex:currentPageIndex] andTitle:@"Article"];

        [self.navigationController pushViewController:customWebView animated:YES];
    }
    
    customViewVisible = TRUE;
}
- (void)actionForDoubleTap
{
	
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:NO animated:YES];
	self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
	[self.navigationController popViewControllerAnimated:YES];
}

- (void) temporarilyHideStatusBar {
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
        [self performSelector:@selector(showStatusBar) withObject:nil afterDelay:.5];
}
- (void) showStatusBar {
	[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
}



#pragma mark -
#pragma mark Paging

- (void)tilePages {
	
	// Calculate which pages should be visible
	// Ignore padding as paging bounces encroach on that
	// and lead to false page loads
	CGRect visibleBounds = pagingScrollView.bounds;
	int iFirstIndex = (int)((CGRectGetMinX(visibleBounds)+PADDING*2) / CGRectGetWidth(visibleBounds));
	int iLastIndex  = (int)floorf((CGRectGetMaxX(visibleBounds)-PADDING*2-1) / CGRectGetWidth(visibleBounds));
    if (iFirstIndex < 0) iFirstIndex = 0;
    if (iFirstIndex > photos.count - 1) iFirstIndex = photos.count - 1;
    if (iLastIndex < 0) iLastIndex = 0;
    if (iLastIndex > photos.count - 1) iLastIndex = photos.count - 1;
	
	// Recycle no longer needed pages
	for (ZoomingScrollView *page in visiblePages) {
		if (page.index < (NSUInteger)iFirstIndex || page.index > (NSUInteger)iLastIndex) {
			[recycledPages addObject:page];
			/*NSLog(@"Removed page at index %i", page.index);*/
			page.index = NSNotFound; // empty
			[page removeFromSuperview];
		}
	}
	[visiblePages minusSet:recycledPages];
	
	// Add missing pages
	for (NSUInteger index = (NSUInteger)iFirstIndex; index <= (NSUInteger)iLastIndex; index++) {
		if (![self isDisplayingPageForIndex:index]) {
			ZoomingScrollView *page = [self dequeueRecycledPage];
			if (!page) {
				page = [[ZoomingScrollView alloc] init];
				page.photoBrowser = self;
			}
			[self configurePage:page forIndex:index];
			[visiblePages addObject:page];
			[pagingScrollView addSubview:page];
			/*NSLog(@"Added page at index %i", page.index);*/
		}
	}
	
}

- (BOOL)isDisplayingPageForIndex:(NSUInteger)index {
	for (ZoomingScrollView *page in visiblePages)
		if (page.index == index) return YES;
	return NO;
}

- (ZoomingScrollView *)pageDisplayedAtIndex:(NSUInteger)index {
	ZoomingScrollView *thePage = nil;
	for (ZoomingScrollView *page in visiblePages) {
		if (page.index == index) {
			thePage = page; break;
		}
	}
	return thePage;
}

- (void)configurePage:(ZoomingScrollView *)page forIndex:(NSUInteger)index {
	page.frame = [self frameForPageAtIndex:index];
	page.index = index;
}
										  
- (ZoomingScrollView *)dequeueRecycledPage {
	ZoomingScrollView *page = [recycledPages anyObject];
	if (page) {
		[recycledPages removeObject:page];
	}
	return page;
}

// Handle page changes
- (void)didStartViewingPageAtIndex:(NSUInteger)index {
	[self displayCaption];
    NSUInteger i;
    if (index > 0) {
        
        // Release anything < index - 1
        for (i = 0; i < index-1; i++) { [(MWPhoto *)[photos objectAtIndex:i] releasePhoto]; /*NSLog(@"Release image at index %i", i);*/ }
        
        // Preload index - 1
        i = index - 1; 
        if (i < photos.count) { [(MWPhoto *)[photos objectAtIndex:i] obtainImageInBackgroundAndNotify:self]; /*NSLog(@"Pre-loading image at index %i", i);*/ }
        
    }
    if (index < photos.count - 1) {
        
        // Release anything > index + 1
        for (i = index + 2; i < photos.count; i++) { [(MWPhoto *)[photos objectAtIndex:i] releasePhoto]; /*NSLog(@"Release image at index %i", i);*/ }
    
        // Preload index + 1
        i = index + 1; 
        if (i < photos.count) { [(MWPhoto *)[photos objectAtIndex:i] obtainImageInBackgroundAndNotify:self]; /*NSLog(@"Pre-loading image at index %i", i);*/ }
        
    }
}

#pragma mark -
#pragma mark Frame Calculations

- (CGRect)frameForPagingScrollView {
    CGRect frame = self.view.bounds;// [[UIScreen mainScreen] bounds];
    frame.origin.x -= PADDING;
    frame.size.width += (2 * PADDING);
    return frame;
}

- (CGRect)frameForPageAtIndex:(NSUInteger)index {
    // We have to use our paging scroll view's bounds, not frame, to calculate the page placement. When the device is in
    // landscape orientation, the frame will still be in portrait because the pagingScrollView is the root view controller's
    // view, so its frame is in window coordinate space, which is never rotated. Its bounds, however, will be in landscape
    // because it has a rotation transform applied.
    CGRect bounds = pagingScrollView.bounds;
    CGRect pageFrame = bounds;
    pageFrame.size.width -= (2 * PADDING);
    pageFrame.origin.x = (bounds.size.width * index) + PADDING;
    return pageFrame;
}

- (CGSize)contentSizeForPagingScrollView {
    // We have to use the paging scroll view's bounds to calculate the contentSize, for the same reason outlined above.
    CGRect bounds = pagingScrollView.bounds;
    return CGSizeMake(bounds.size.width * photos.count, bounds.size.height);
}

- (CGPoint)contentOffsetForPageAtIndex:(NSUInteger)index {
	CGFloat pageWidth = pagingScrollView.bounds.size.width;
	CGFloat newOffset = index * pageWidth;
	return CGPointMake(newOffset, 0);
}

- (CGRect)frameForNavigationBarAtOrientation:(UIInterfaceOrientation)orientation {
	CGFloat height = UIInterfaceOrientationIsPortrait(orientation) ? 44 : 32;
	return CGRectMake(0, 20, self.view.bounds.size.width, height);
}

- (CGRect)frameForToolbarAtOrientation:(UIInterfaceOrientation)orientation {
	CGFloat height = UIInterfaceOrientationIsPortrait(orientation) ? 44 : 32;
	return CGRectMake(0, self.view.bounds.size.height - height, self.view.bounds.size.width, height);
}

#pragma mark -
#pragma mark UIScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	
	if (performingLayout || rotating) return;
	
	// Tile pages
	[self tilePages];
	
	// Calculate current page
	CGRect visibleBounds = pagingScrollView.bounds;
	int index = (int)(floorf(CGRectGetMidX(visibleBounds) / CGRectGetWidth(visibleBounds)));
    if (index < 0) index = 0;
	if (index > photos.count - 1) index = photos.count - 1;
	NSUInteger previousCurrentPage = currentPageIndex;
	currentPageIndex = index;
	if (currentPageIndex != previousCurrentPage) {
        [self didStartViewingPageAtIndex:index];
    }
	
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
	// Hide controls when dragging begins
    if (!customViewVisible)
        [self setControlsHidden:YES];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	// Update nav when page changes
	[self updateNavigation];
}

#pragma mark -
#pragma mark Navigation

- (void)updateNavigation {
    self.title = @"Image";
	// Title
	if (photos.count > 1) {
		self.navigationItem.title = [NSString stringWithFormat:@"%i of %i", currentPageIndex+1, photos.count];		
	} else {
		self.navigationItem.title = @"1 of 1";
	}
	
	// Buttons
	previousButton.enabled = (currentPageIndex > 0);
	nextButton.enabled = (currentPageIndex < photos.count-1);
	
}

- (void)jumpToPageAtIndex:(NSUInteger)index {	
	// Change page
	if (index < photos.count) {
		CGRect pageFrame = [self frameForPageAtIndex:index];
		pagingScrollView.contentOffset = CGPointMake(pageFrame.origin.x - PADDING, 0);
		[self updateNavigation];
	}
	
	// Update timer to give more time
	[self hideControlsAfterDelay];
	
}

- (void)gotoPreviousPage { [self jumpToPageAtIndex:currentPageIndex-1]; }
- (void)gotoNextPage { [self jumpToPageAtIndex:currentPageIndex+1]; }

#pragma mark -
#pragma mark Control Hiding / Showing

- (void)setControlsHidden:(BOOL)hidden {
	
	// Get status bar height if visible
    if (customViewVisible) {
        return;
    }
	//CGFloat statusBarHeight;
	if (![UIApplication sharedApplication].statusBarHidden) {
		//CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
		//statusBarHeight = MIN(statusBarFrame.size.height, statusBarFrame.size.width);
	}
	
	// Status Bar
	if ([UIApplication instancesRespondToSelector:@selector(setStatusBarHidden:withAnimation:)]) {
		[[UIApplication sharedApplication] setStatusBarHidden:hidden withAnimation:UIStatusBarAnimationFade];
	} else {
		[[UIApplication sharedApplication] setStatusBarHidden:hidden animated:YES];
	}
	
	// Get status bar height if visible
	if (![UIApplication sharedApplication].statusBarHidden) {
		//CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
		//statusBarHeight = MIN(statusBarFrame.size.height, statusBarFrame.size.width);
	}
	
	// Set navigation bar frame
	
	// Bars
	//[UIView beginAnimations:nil context:nil];
	//[UIView setAnimationDuration:0.35];
	//[[self.navigationController navigationBar] setAlpha:hidden ? 0 : 1];
	//[[self.navigationController toolbar] setAlpha:hidden ? 0 : 1];
	//[UIView commitAnimations];    
    
    [self.navigationController setNavigationBarHidden:hidden animated:YES];
    [self.navigationController setToolbarHidden:hidden animated:YES];
	
	// Control hiding timer
	// Will cancel existing timer but only begin hiding if
	// they are visible
	[self hideControlsAfterDelay];
	
}

- (void)cancelControlHiding {
	// If a timer exists then cancel and release
	if (controlVisibilityTimer) {
		[controlVisibilityTimer invalidate];
		controlVisibilityTimer = nil;
	}
}

// Enable/disable control visiblity timer
- (void)hideControlsAfterDelay {
    if (!customViewVisible) {
        [self cancelControlHiding];
        if (![UIApplication sharedApplication].isStatusBarHidden) {
            controlVisibilityTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(hideControls) userInfo:nil repeats:NO];
        }
	}
}

- (void)hideControls { [self setControlsHidden:YES]; }
- (void)toggleControls { [self setControlsHidden:![UIApplication sharedApplication].isStatusBarHidden]; }

#pragma mark -
#pragma mark Rotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return toInterfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {

	// Remember page index before rotation
	pageIndexBeforeRotation = currentPageIndex;
	rotating = YES;
	
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	
	// Perform layout
	currentPageIndex = pageIndexBeforeRotation;
	[self performLayout];
	
	// Delay control holding
	[self hideControlsAfterDelay];
	
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	rotating = NO;
	[self displayCaption];
}

- (void)handleSingleTap
{
	NSLog(@"Single TAP IN PHOTO");
}

- (void)handleDoubleTap
{
	NSLog(@"DOUBLE TAP IN PHOTO");
}

#pragma mark -
#pragma mark Properties

- (void)setInitialPageIndex:(NSUInteger)index {

	if (![self isViewLoaded]) {
		if (index >= photos.count) {
			currentPageIndex = 0;
		} else {
			currentPageIndex = index;
		}
	}
}

@end
