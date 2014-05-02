//
//  ImageViewer.h
//  NewsStand
//
//  Created by Brendan on 1/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SSToolkit/SSToolkit.h>
#import <libxml/tree.h>

#import "SCImageCollectionViewItem.h"
#import "ImageData.h"

typedef enum {
    allImages,
    markDuplicates,
    removeDuplicates,
    clusterImagesType,
} ImageViewType;

@interface ImageViewer : SSCollectionViewController <UIScrollViewDelegate>
{
    //Image Arrays
    NSMutableArray *imagesData;
	NSMutableArray *noDupesImagesData;
    NSMutableArray *clusterImages;
	NSMutableArray *clustersAdded;
	NSMutableArray *currClusterImages;
    NSMutableArray *noDupesCurrentCluster;
    
    //Settings
    NSString *image_topic;
    NSString *image_constraints;
    int standMode;
    int image_id;
    BOOL isPad;
    NSString *secondLeftButtonTitle;
    
    //UIBarButtonItems
    UIBarButtonItem *secondLeftButton;
    UISegmentedControl *pageSegmentedControl;
    UIBarButtonItem *gridButton;
    UIBarButtonItem *actionButton;
    UIBarButtonItem *magnifyButton;
    UIBarButtonItem *allInTopicButton;
    UISegmentedControl *displaySegmentedControl;
    UISegmentedControl *allTopicsSegmentedControl;
    
    //Segment Control
    BOOL backEnabled;
    BOOL forwardEnabled;
    
    //Enlarging Image
    UIButton *blackButton;
    UIImageView *enlargeImageView;
    UIImageView *imageBorder;
    UILabel *captionLabel;
    BOOL stopDismiss;
    
    //Page Control
    ImageViewType viewingType;
    int numItems;
    int pageNum;
    int numPages;
    int selectedIndex;
    int selectedPageIndex;
    
    //NSXMLParser
    NSOperationQueue *queue;
}

//Image Arrays
@property (strong, nonatomic) NSMutableArray *imagesData;
@property (strong, nonatomic) NSMutableArray *noDupesImagesData;
@property (strong, nonatomic) NSMutableArray *clusterImages;
@property (strong, nonatomic) NSMutableArray *clustersAdded;
@property (strong, nonatomic) NSMutableArray *currClusterImages;
@property (strong, nonatomic) NSMutableArray *noDupesCurrentCluster;

//Settings
@property (strong, nonatomic) NSString *image_topic;
@property (strong, nonatomic) NSString *image_constraints;
@property (nonatomic, readwrite) int standMode;
@property (nonatomic, readwrite) int image_id;
@property (strong, nonatomic) NSString *secondLeftButtonTitle;

//Buttons
@property (strong, nonatomic) UIBarButtonItem *secondLeftButton;
@property (strong, nonatomic) UISegmentedControl *pageSegmentedControl;
@property (strong, nonatomic) UIBarButtonItem *gridButton;
@property (strong, nonatomic) UIBarButtonItem *actionButton;
@property (strong, nonatomic) UIBarButtonItem *magnifyButton;
@property (strong, nonatomic) UIBarButtonItem *allInTopicButton;
@property (strong, nonatomic) UISegmentedControl *displaySegmentedControl;
@property (strong, nonatomic) UISegmentedControl *allTopicsSegmentedControl;

//Enlarging Image
@property (strong, nonatomic) UIButton *blackButton;
@property (strong, nonatomic) UIImageView *enlargeImageView;
@property (strong, nonatomic) UIImageView *imageBorder;
@property (strong, nonatomic) UILabel *captionLabel;

//Page Control
@property (nonatomic, readwrite) int numItems;
@property (nonatomic, readwrite) int pageNum;
@property (nonatomic, readwrite) int numPages;
@property (nonatomic, readwrite) int selectedIndex;
@property (nonatomic, readwrite) int selectedPageIndex;

//NSXMLParser
@property (strong, nonatomic) NSOperationQueue *queue;


//Initialize
-(id) initWithImageTopic:(NSString*)topic withImageId:(int)num andStandMode:(int)mode andConstraints:(NSString *)constraints;
-(id) initWithImageTopic:(NSString*)topic withImageId:(int)num andStandMode:(int)mode andConstraints:(NSString *)constraints andSecondButtonTitle:(NSString *)secondButtonTitle;
-(id) initWithImageTopic:(NSString*)topic withImagesData:(NSMutableArray *)images andDupesImageData:(NSMutableArray *)dupes;

//Setup Gesture Recognizers
-(void)setupGestureRecognizers;
-(IBAction)handleSingleTap:(id)sender;
-(IBAction)handleDoubleTap:(id)sender;
-(IBAction)handleRightSwipe:(id)sender;
-(IBAction)handleLeftSwipe:(id)sender;
-(IBAction)handleUpSwipe:(id)sender;
-(IBAction)handleDownSwipe:(id)sender;

//Button Actions
-(void)magnifyButtonSelected;

//Populate Tabbar
-(void)setTabBarForAllTopics;
-(void)setTabBarNormal;

//Enlarge Image Action
-(void)dismissBlackCover;
-(void)shareItemPressed;

//NSXMLParser Callback
-(void)parseEnded:(NSMutableArray*)imagesArray;
-(void)noParseSetup;

@end
