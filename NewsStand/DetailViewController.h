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

@interface DetailViewController : UIViewController <UITableViewDelegate, UINavigationBarDelegate>
{
    IBOutlet UITableView *tableView;
    IBOutlet MKMapView *mapView;
    
    //Info
    int standMode;
    int gaz_id;
    int cluster_id; //For Top Stories
    NSString *sourceParamString;
    NSString *settingsParamString;
    NSString *detailTitle;
    
    //The annotations
    NSMutableArray *annotations;
    
    //Font for cells
    UIFont *detailViewFont;
    
    //Activity Indicator
    IBOutlet UIActivityIndicatorView *activityIndicator;

    BOOL isPad;
    
    //Snippet Viewer for iPad
    SnippetViewController *snippetViewController;
    
    //Navigation Bar
    BOOL translated_titles;
    UIBarButtonItem *translateBarButtonItem;
    
    //Navigation Bar for iPad
    IBOutlet UINavigationBar *navigationBar;
    IBOutlet UIBarButtonItem *leftBarButtonItem;
    
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

//The annotations
@property (strong, nonatomic) NSMutableArray *annotations;

//Font for cells
@property (strong, nonatomic) UIFont *detailViewFont;

//Activity Indicator
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

//Specify where results will be located
@property (nonatomic, readonly) int standMode;
@property (nonatomic, readwrite) int gaz_id;
@property (strong, nonatomic) NSString *sourceParamString;
@property (strong, nonatomic) NSString *settingsParamString;
@property (strong, nonatomic) NSString *detailTitle;

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

//NSXMLParser Callback
-(void)parseEnded:(NSMutableArray*)annotationsArray;

//iPad Navigation Control
-(IBAction)leftBarButtonItemSelected:(id)sender;

//iPad Remove Snippet View
-(void)removeSnippetViewController;

@end
