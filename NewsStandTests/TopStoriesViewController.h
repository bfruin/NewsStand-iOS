//
//  TopStoriesViewController.h
//  NewsStand
//
//  Created by Brendan on 1/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <MapKit/MKMapView.h>
#import <libxml/tree.h>

#import "ViewController.h"
#import "NewsAnnotation.h"

@interface TopStoriesViewController : UIViewController <MKMapViewDelegate, UITableViewDelegate, UITabBarDelegate, NSXMLParserDelegate, UIAlertViewDelegate>
{
    //Table, Map and Slider
    IBOutlet UITableView *tableView;
    IBOutlet MKMapView *mapView;
    IBOutlet UISlider *mapSlider;
    
    //Annotations
    NSMutableArray *annotations;
    NSMutableArray *incomingAnnotations;
    
    //Buttons
    IBOutlet UIButton *refreshButton;
    IBOutlet UIButton *plusButton;
    IBOutlet UIButton *minusButton;
    
    //Labels & Cancel Buttons
    IBOutlet UILabel *modeLabel;
    IBOutlet UILabel *searchLabel;
    IBOutlet UIButton *sourceButton;
    IBOutlet UIButton *searchCancelButton;
    IBOutlet UIButton *sourceCancelButton;
    
    //Query
    NSString *queryString;
    
    //Tab bar
    IBOutlet UITabBar *tabBar;
    
    //Sources
    NSMutableArray *allSources;
    NSMutableArray *feedSources;
    NSMutableArray *countrySources;
    NSMutableArray *boundSources;
    SourcesSelected sourcesSelected;
    
    //Handmode Bar Control
    IBOutlet UITabBarItem *botFirstItem;
    IBOutlet UITabBarItem *botSecondItem;
    IBOutlet UITabBarItem *botThirdItem;
    IBOutlet UITabBarItem *botFourthItem;
    IBOutlet UITabBarItem *botFifthItem;
    IBOutlet UITabBarItem *botSixthItem;
    
    //Settings
    int standMode;
    int handMode;
    BOOL initialCall;
    
    //Handmode Updating
    BOOL automaticHandMode;
    CMMotionManager *motionManager;
    
    //Update source or settings
    BOOL settingsChanged;
    BOOL sourcesChanged;
    
    //For Controlling XIB Swaps
    UIInterfaceOrientation orientationBefore;
    BOOL checkOrientation;
    
    //Activity Indicator
    IBOutlet UIActivityIndicatorView *activityIndicator;
    
    //Markers
    NewsAnnotation *currentMarker;
    NSMutableArray *markers;
    
    //Search Alert
    UIAlertView *searchAlertView;
    BOOL alertShown;
    
    //NSXMLParser Parsing
    NSOperationQueue *queue;
    NSMutableString *currentString;
    NSXMLParser *parser;
    int currentRequestID;
    
    //Simulate hover
    BOOL updatePosition;
    int hoverIndex;
    int lastSelectedRow;
    
    //iPad
    BOOL isPad;
    DetailViewController *topPadDetailViewController;
    UIButton *blackButton;
    TopStoriesViewController *topStoriesViewControllerRotated;
}
//Table, Map and Slider
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) IBOutlet UISlider *mapSlider;

//Annotations
@property (strong, nonatomic) NSMutableArray *annotations;
@property (strong, nonatomic) NSMutableArray *incomingAnnotations;

//Map Buttons
@property (strong, nonatomic) IBOutlet UIButton *refreshButton;
@property (strong, nonatomic) IBOutlet UIButton *plusButton;
@property (strong, nonatomic) IBOutlet UIButton *minusButton;

//Labels & Cancel Buttons
@property (strong, nonatomic) IBOutlet UILabel *modeLabel;
@property (strong, nonatomic) IBOutlet UILabel *searchLabel;
@property (strong, nonatomic) IBOutlet UIButton *sourceButton;
@property (strong, nonatomic) IBOutlet UIButton *searchCancelButton;
@property (strong, nonatomic) IBOutlet UIButton *sourceCancelButton;

//Query
@property (strong, nonatomic) NSString *queryString;

//Tab bar
@property (strong, nonatomic) IBOutlet UITabBar *tabBar;

//Automatic Updating HandMode
@property (strong, nonatomic) CMMotionManager *motionManager;

//Sources
@property (strong, nonatomic) NSMutableArray *allSources;
@property (strong, nonatomic) NSMutableArray *feedSources;
@property (strong, nonatomic) NSMutableArray *countrySources;
@property (strong, nonatomic) NSMutableArray *boundSources;

//Handmode Bar Control
@property (strong, nonatomic) IBOutlet UITabBarItem *botFirstItem;
@property (strong, nonatomic) IBOutlet UITabBarItem *botSecondItem;
@property (strong, nonatomic) IBOutlet UITabBarItem *botThirdItem;
@property (strong, nonatomic) IBOutlet UITabBarItem *botFourthItem;
@property (strong, nonatomic) IBOutlet UITabBarItem *botFifthItem;
@property (strong, nonatomic) IBOutlet UITabBarItem *botSixthItem;

//Activity Indicator
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

//For Controlling XIB Swaps
@property (readwrite, nonatomic) BOOL checkOrientation;

//Markers
@property (strong, nonatomic) NewsAnnotation *currentMarker;
@property (strong, nonatomic) NSMutableArray *markers;

//Search Alert
@property (strong, nonatomic) UIAlertView *searchAlertView;

//NSXMLParser Parsing
@property (strong, nonatomic) NSOperationQueue *queue;
@property (strong, nonatomic) NSMutableString *currentString;
@property (strong, nonatomic) NSXMLParser *parser;

//iPad
@property (strong, nonatomic) DetailViewController *topPadDetailViewController;
@property (strong, nonatomic) UIButton *blackButton;
@property (strong, nonatomic) TopStoriesViewController *topStoriesViewControllerRotated;

//Update Top Stories
-(NSString *)URLEncodeString:(NSString *)str;

//Cell Buttons
-(void)titleButtonPressedOnRow:(int) row;
-(void)translateButtonPressedOnRow:(int)row;
-(void)translatePageButtonPressedOnRow:(int)row;
-(void)imageButtonPressedOnRow:(int) row;
-(void)videoButtonPressedOnRow:(int) row;
-(void)relatedButtonPressedOnRow:(int) row;

//Initialization
- (id)initWithNibName:(NSString *)nibNameOrNil andAnnotations:(NSMutableArray*)topAnnotations withHoverIndex:(int)hoverIn lastSelectedRow:(int)lastRow withMarkers:(NSMutableArray*)lastMarkers;
-(void) initQueryAndSources:(BOOL)updateSources;

//Tab Bar Items
-(void)infoItemPushed;
-(void)searchItemPushed;
-(void)settingsItemPushed;
-(void)sourcesItemPushed;
-(void)modeItemPushed;
-(void)mapItemPushed;
-(void)disableItemsForStandMode;

//Detail View Controller
-(void)dismissDetailViewController;

//Map Buttons
-(IBAction)topRefreshButtonPressed:(id)sender;
-(IBAction)topPlusButtonPressed:(id)sender;
-(IBAction)topMinusButtonPressed:(id)sender;
-(void)updateMapButtonsOnHandMode;

//Slider Bar
-(IBAction)sliderChangedValue:(id)sender;
-(void)updateMaxSlider:(int)num;

//Search & Source Buttons
-(IBAction)topSearchCancelButtonPushed:(id)sender;
-(IBAction)topSourceCancelButtonPressed:(id)sender;
-(IBAction)topSourceButtonPressed:(id)sender;

//Marker Parsing (Using NSXMLParser)
-(void)refreshCallback:(NSXMLParser*)parser;

@end
