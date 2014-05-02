//
//  RelatedStoriesViewController.h
//  NewsStand
//
//  Created by Hanan Samet on 11/26/12.
//
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <MapKit/MKMapView.h>

#import "ViewController.h"
#import "NewsAnnotation.h"

@interface RelatedStoriesViewController : UIViewController <UITableViewDelegate, MKMapViewDelegate, NSXMLParserDelegate>
{
    //Table and Map
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
    
    //Handmode Updating
    int handMode;
    BOOL automaticHandMode;
    CMMotionManager *motionManager;
    
    //Markers
    NewsAnnotation *currentMarker;
    NSMutableArray *markers;
    
    //NSXMLParser Parsing
    NSOperationQueue *queue;
    NSMutableString *currentString;
    NSXMLParser *parser;
    
    //Simulate hover
    int hoverIndex;
    int lastSelectedRow;

}

//Table and Map
@property(nonatomic, strong) IBOutlet UITableView *tableView;
@property(nonatomic, strong) IBOutlet MKMapView *mapView;

//Annotations
@property(nonatomic, strong) NSMutableArray *annotations;
@property(nonatomic, strong) NSMutableArray *incomingAnnotations;

//Map Buttons
@property (strong, nonatomic) IBOutlet UIButton *refreshButton;
@property (strong, nonatomic) IBOutlet UIButton *plusButton;
@property (strong, nonatomic) IBOutlet UIButton *minusButton;

//Automatic Updating HandMode
@property (strong, nonatomic) CMMotionManager *motionManager;

//Markers
@property (strong, nonatomic) NewsAnnotation *currentMarker;
@property (strong, nonatomic) NSMutableArray *markers;

//NSXMLParser Parsing
@property (strong, nonatomic) NSOperationQueue *queue;
@property (strong, nonatomic) NSMutableString *currentString;
@property (strong, nonatomic) NSXMLParser *parser;


//Cell Button Functions
-(void)titleButtonPressedOnRow:(int) row;

//Map Button Functions
-(IBAction)topRefreshButtonPressed:(id)sender;
-(IBAction)topPlusButtonPressed:(id)sender;
-(IBAction)topMinusButtonPressed:(id)sender;
-(void)updateMapButtonsOnHandMode;

//Slider Bar
-(IBAction)sliderChangedValue:(id)sender;
-(void)updateMaxSlider:(int)num;

//Marker Parsing (Using NSXMLParser)
-(void)refreshCallback:(NSXMLParser*)parser;

@end
