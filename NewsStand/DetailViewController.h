//
//  DetailViewController.h
//  NewsStand
//
//  Created by Hanan Samet on 1/17/12.
//  Copyright (c) 2012 University of Maryland. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewsAnnotation.h"
#import "SnippetViewController.h"

@interface DetailViewController : UIViewController <UITableViewDelegate, UINavigationBarDelegate, MKMapViewDelegate>
{
    IBOutlet UITableView *tableView;
    IBOutlet MKMapView *mapView;
    
    IBOutlet UISlider *locationSlider;
    IBOutlet UISlider *keywordSlider;
    int lastLocationSliderValue;
    int lastKeywordSliderValue;
    
    //Cycling Buttons
    IBOutlet UIButton *locationPrevious;
    IBOutlet UIButton *locationNext;
    IBOutlet UIButton *keywordPrevious;
    IBOutlet UIButton *keywordNext;
    int highlightedLocation;
    int highlightedKeyword;
    IBOutlet UILabel *minimapText;
    
    //Info
    int standMode;
    int gaz_id;
    int cluster_id; //For Top Stories
    NSString *sourceParamString;
    NSString *settingsParamString;
    NSString *detailTitle;
    
    //The annotations
    NSMutableArray *annotations;
    NSMutableDictionary *clusterKeywordMarkers;
    NSMutableArray *previousClusterKeywordMarkers;
    NSMutableArray *locationNameMarkers;
    
    //Font for cells
    UIFont *detailViewFont;
    
    //Activity Indicator
    IBOutlet UIActivityIndicatorView *activityIndicator;

    
    //Marker Images
    UIImage *locationImage;
    UIImage *keywordImage;
    UIImage *highlightedLocationImage;
    UIImage *highlightedKeywordImage;
    UIImage *currentImage;
    
    BOOL isPad;
    
    //Snippet Viewer for iPad
    SnippetViewController *snippetViewController;
    
    //Navigation Bar
    BOOL translated_titles;
    UIBarButtonItem *translateBarButtonItem;
    
    //Navigation Bar for iPad
    IBOutlet UINavigationBar *navigationBar;
    IBOutlet UIBarButtonItem *leftBarButtonItem;
    
    //Selected Row
    int selectedIndex;
    
    // Rotation
    BOOL rotated;
    BOOL dismissParent;
    int controllerIndex;
    
    //NSXMLParser
    NSOperationQueue *queue;
}
//The table and map
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet MKMapView *mapView;

//Minimap sliders
@property (strong, nonatomic) IBOutlet UISlider *locationSlider;
@property (strong, nonatomic) IBOutlet UISlider *keywordSlider;

//Cycling Buttons
@property (strong, nonatomic) IBOutlet UIButton *locationPrevious;
@property (strong, nonatomic) IBOutlet UIButton *locationNext;
@property (strong, nonatomic) IBOutlet UIButton *keywordPrevious;
@property (strong, nonatomic) IBOutlet UIButton *keywordNext;
@property (strong, nonatomic) IBOutlet UILabel *minimapText;

//The annotations
@property (strong, nonatomic) NSMutableArray *annotations;
@property (strong, nonatomic) NSMutableDictionary *clusterKeywordMarkers;
@property (strong, nonatomic) NSMutableArray *locationNameMarkers;

//Font for cells
@property (strong, nonatomic) UIFont *detailViewFont;

//Activity Indicator
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

//Marker Images
@property (strong, nonatomic) UIImage *locationImage;
@property (strong, nonatomic) UIImage *keywordImage;
@property (strong, nonatomic) UIImage *highlightedLocationImage;
@property (strong, nonatomic) UIImage *highlightedKeywordImage;
@property (strong, nonatomic) UIImage *currentImage;

//Specify where results will be located
@property (nonatomic, readonly) int standMode;
@property (nonatomic, readwrite) int gaz_id;
@property (strong, nonatomic) NSString *sourceParamString;
@property (strong, nonatomic) NSString *settingsParamString;
@property (strong, nonatomic) NSString *detailTitle;

@property (readwrite) int selectedIndex;

//Rotation
@property (nonatomic, readwrite) BOOL dismissParent;

//NSXMLParser
@property (strong, nonatomic) NSOperationQueue *queue;

//Navigation Bar
@property (strong, nonatomic) UIBarButtonItem *translateBarButtonItem;

//Navigation Bar for iPad
@property (strong, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *leftBarButtonItem;

//Snippet View Controller (used only for iPad)
@property (strong, nonatomic) SnippetViewController *snippetViewController;

-(id)initWithNibName:(NSString *)nibNameOrNil andGazId:(int)gazId andSourceString:(NSString*)sourceString andSettingsString:(NSString *)settingsString withTitle:(NSString *)title andStandMode:(int)mode;
-(id)initWithNibName:(NSString *)nibNameOrNil andGazId:(int)gazId andSourceString:(NSString*)sourceString andSettingsString:(NSString *)settingsString withTitle:(NSString *)title andStandMode:(int)mode andClusterID:(int)clusterID;
-(id)initWithGazId:(int)gazId andSourceString:(NSString*)sourceString andSettingsString:(NSString*)settingsString withTitle:(NSString*)title andStandMode:(int)mode;
-(id)initWithGazId:(int)gazId andSourceString:(NSString*)sourceString andSettingsString:(NSString*)settingsString withTitle:(NSString*)title andStandMode:(int)mode
       andClusterID:(int)clusterID;
-(NSString *)URLEncodeString:(NSString *)str;

//Translate Bar Button Item Selected
-(void)translateBarButtonItemSelected;

//Sliders
-(IBAction)locationSliderChangedValue:(id)sender;
-(IBAction)keywordSliderChangedValue:(id)sender;

//NSXMLParser Callback
-(void)parseEnded:(NSMutableArray*)annotationsArray;
-(void)parseEndedClusterKeyword:(NSMutableArray*)clusterKeywordArray;
-(void)parseEndedLocationName:(NSMutableArray*)locationNameArray;

//iPad Navigation Control
-(IBAction)leftBarButtonItemSelected:(id)sender;

//iPad Remove Snippet View
-(void)removeSnippetViewController;

@end
