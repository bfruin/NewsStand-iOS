//
//  ViewController.h
//  NewsStand
//
//  Created by Brendan on 12/29/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <MapKit/MKMapView.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreLocation/CLGeocoder.h>
#import <CoreMotion/CMError.h>
#import <CoreMotion/CMErrorDomain.h>
#import <CoreMotion/CMMotionManager.h>
#import <libxml/tree.h>
#import <QuartzCore/QuartzCore.h>

#import "NewsAnnotation.h"
#import "Source.h"

#import "CustomWebView.h"
#import "DetailViewController.h"

typedef enum {
    iconLayer,
    locationLayer,
    keywordLayer,
    peopleLayer,
    diseaseLayer,
} NewsStandLayer;

typedef enum {
    allSourcesSelected,
    feedSourcesSelected,
    countrySourcesSelected,
    boundSourcesSelected,
} SourcesSelected;

@interface ViewController : UIViewController <MKMapViewDelegate, UITabBarDelegate, UINavigationControllerDelegate, UIAlertViewDelegate, UIGestureRecognizerDelegate>
{
    // Map and Bars
    IBOutlet MKMapView *mapView;
    IBOutlet UITabBar *topTabBar;
    IBOutlet UITabBar *botTabBar;
    IBOutlet UISlider *mapSlider;
    
    //Buttons
    IBOutlet UIButton *refreshButton;
    IBOutlet UIButton *plusButton;
    IBOutlet UIButton *minusButton;
    
    //Activity Indiciation
    IBOutlet UIActivityIndicatorView *activityIndicator;
    
    //Labels & Cancel Buttons
    IBOutlet UILabel *modeLabel;
    IBOutlet UILabel *searchLabel;
    IBOutlet UIButton *sourceButton;
    IBOutlet UIButton *searchCancelButton;
    IBOutlet UIButton *sourceCancelButton;
    
    //Boolean Control
    BOOL isPad;
    bool alertShown;
    BOOL hasInet;
    BOOL checkForMarker;
    
    //Annotations
    NSMutableArray *annotations;
    float lastSliderValue;
    
    //Marker Images
    UIImage *generalImage;
    UIImage *businessImage;
    UIImage *healthImage;
    UIImage *sciTechImage;
    UIImage *entertainmentImage;
    UIImage *sportsImage;
    
    //Fonts
    UIFont *locationFont;
    
    //Settings
    int layerSelected;
    NSMutableArray *topics;
    NSMutableArray *topicsSelected;
    int imageFilterSelected;
    int videoFilterSelected;
    NSString *searchKeyword;
    
    //Sources
    NSMutableArray *allSources;
    NSMutableArray *feedSources;
    NSMutableArray *countrySources;
    NSMutableArray *boundSources;
    NSMutableArray *languageSources;
    SourcesSelected sourcesSelected;
    
    NSMutableArray *languagesSelected;
    
    int sourceDisplayed;
    int numSourcesSelected;
    
    //  Standmode 
    //    NewsStand - 0
    //    TwitterStand - 1
    //    PhotoStand - 2
    int standMode;
    
    //Handmode Bar Control
    IBOutlet UITabBarItem *botFirstItem;
    IBOutlet UITabBarItem *botSecondItem;
    IBOutlet UITabBarItem *botThirdItem;
    IBOutlet UITabBarItem *botFourthItem;
    IBOutlet UITabBarItem *botFifthItem;
    IBOutlet UITabBarItem *botSixthItem;
    
    //Handmode Updating
    BOOL automaticHandMode;
    CMMotionManager *motionManager;
    
    //Top Stories
    BOOL portraitFirst;
    NSMutableArray *topStoriesAnnotations;
    
    //Geocoder
    CLGeocoder *geocoder;
    
    int handMode;
    float currentSpan; // The current span of the map
    
    //UIAlertViews
    UIAlertView *locateAlertView;
    UIAlertView *searchAlertView;
    
    
    //NSXMLParser
    NSURLRequest *URLrequest;
    NSOperationQueue *queue;
    int currentRequestID;
    
    //iPad UIViewController
    DetailViewController *padDetailViewController;
    
    //iPad Buttons
    IBOutlet UIButton *blackButton;
    
    //Simulator
    float simulatorLat;
    float simulatorLon;
    NSOperationQueue *simulatorQueue;
    
}

//The Map and bars
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) IBOutlet UITabBar *topTabBar;
@property (strong, nonatomic) IBOutlet UITabBar *botTabBar;

//Buttons
@property (strong, nonatomic) IBOutlet UIButton *refreshButton;
@property (strong, nonatomic) IBOutlet UIButton *plusButton;
@property (strong, nonatomic) IBOutlet UIButton *minusButton;
@property (strong, nonatomic) IBOutlet UIButton *searchCancelButton;
@property (strong, nonatomic) IBOutlet UIButton *sourceCancelButton;

//Activity Indicator
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;;

//Labels & Source/Keyword Button
@property (strong, nonatomic) IBOutlet UILabel *modeLabel;
@property (strong, nonatomic) IBOutlet UILabel *searchLabel;
@property (strong, nonatomic) IBOutlet UIButton *sourceButton;

@property (nonatomic, readwrite) BOOL isPad;
@property (nonatomic, readwrite) BOOL hasInet;

//Annotations
@property (strong, nonatomic) NSMutableArray *annotations;

//Marker Images
@property (strong, nonatomic) UIImage *generalImage;
@property (strong, nonatomic) UIImage *businessImage;
@property (strong, nonatomic) UIImage *healthImage;
@property (strong, nonatomic) UIImage *sciTechImage;
@property (strong, nonatomic) UIImage *entertainmentImage;
@property (strong, nonatomic) UIImage *sportsImage;

//Fonts
@property (strong, nonatomic) UIFont *locationFont;

//Settings
@property (nonatomic, readwrite) int layerSelected;
@property (strong, nonatomic) NSMutableArray *topics;
@property (strong, nonatomic, readwrite) NSMutableArray *topicsSelected;
@property (nonatomic, readwrite) int imageFilterSelected;
@property (nonatomic, readwrite) int videoFilterSelected;
@property (nonatomic, readwrite) int handMode;
@property (strong, nonatomic) NSString *searchKeyword;

//Sources
@property (strong, nonatomic) NSMutableArray *allSources;
@property (strong, nonatomic) NSMutableArray *feedSources;
@property (strong, nonatomic) NSMutableArray *countrySources;
@property (strong, nonatomic) NSMutableArray *boundSources;
@property (strong, nonatomic) NSMutableArray *languageSources;
@property (nonatomic, readwrite) SourcesSelected sourcesSelected;
@property (strong, nonatomic) NSMutableArray *languagesSelected;
@property (nonatomic, readwrite) int sourceDisplayed;
@property (nonatomic, readwrite) int numSourcesSelected;

//Standmode
@property (nonatomic, readwrite) int standMode;

//Handmode Bar Control
@property (strong, nonatomic) IBOutlet UITabBarItem *botFirstItem;
@property (strong, nonatomic) IBOutlet UITabBarItem *botSecondItem;
@property (strong, nonatomic) IBOutlet UITabBarItem *botThirdItem;
@property (strong, nonatomic) IBOutlet UITabBarItem *botFourthItem;
@property (strong, nonatomic) IBOutlet UITabBarItem *botFifthItem;
@property (strong, nonatomic) IBOutlet UITabBarItem *botSixthItem;

//Handmode Updating
@property (strong, nonatomic) CMMotionManager *motionManager;
@property (nonatomic, readwrite) BOOL automaticHandMode;

//Top Stories
@property (nonatomic, readwrite) BOOL portraitFirst;
@property (strong, nonatomic) NSMutableArray *topStoriesAnnotations;

//Geocoder
@property (strong, nonatomic) CLGeocoder *geocoder;

//Alert View
@property (strong, nonatomic) UIAlertView *locateAlertView;
@property (strong, nonatomic) UIAlertView *searchAlertView;

//NSXML
@property (strong, nonatomic) NSURLRequest *URLrequest;
@property (strong, nonatomic) NSOperationQueue *queue;
@property (nonatomic, readwrite) int currentRequestID;

//iPad Views
@property (strong, nonatomic) DetailViewController *padDetailViewController;

//iPad Buttons
@property (strong, nonatomic) IBOutlet UIButton *blackButton;

//Simulator
@property (nonatomic, readwrite) float simulatorLat;
@property (nonatomic, readwrite) float simulatorLon;
@property (strong, nonatomic) NSOperationQueue *simulatorQueue;


//Map
-(NSString *)URLEncodeString:(NSString *)str;
-(void)refreshMap;
-(void)addMapGestureRecognizers; 
-(void)loadUnloadMap;

//Buttons
-(IBAction)refreshButtonPressed:(id)sender;
-(IBAction)plusButtonPressed:(id)sender;
-(IBAction)minusButtonPressed:(id)sender;

//Handmode
-(void)updateMapButtonsOnHandMode;

//Settings
-(void) initializeSettings;
-(void) initializeViewDidUnload;
-(void) setHomeLocation;
-(NSString *)settingsParamString;
-(IBAction)searchCancelButtonPushed:(id)sender;
-(void)disableItemsForStandMode;

//Sources
-(NSString *)sourceParamString;
-(BOOL) itemSelectedInArray:(NSMutableArray *)array;
-(void) initializeSources;
-(void) setSourceAndCancelButton;
-(void) addBoundRegionWithSource:(Source *)boundSource;
-(void) removeBoundRegionWithName:(NSString *)boundName;
-(IBAction)sourceButtonSelected:(id)sender;
-(void) updateNumSources;

-(IBAction)sourceCancelButtonPressed:(id)sender;

//Top Tab Bar Functions
-(void) homeItemPushed;
-(void) localItemPushed;
-(IBAction)mapSliderChangedValue:(id)sender;
-(void) worldItemPushed;
-(void) locateItemPushed;

//Bottom Tab Bar Functions
-(void) infoItemPushed;
-(void) searchItemPushed;
-(void) settingsItemPushed;
-(void) sourcesItemPushed;
-(void) modeItemPushed;
-(void) topStoriesItemPushed;
- (void) unselectBotTabBar;

//Initialization
-(void)initImagesAndFonts;

//iPad
-(void)dismissDetailViewController;

//NSXMLParser
-(void)parseEnded:(NSMutableArray*)resultAnnotations;


@end
