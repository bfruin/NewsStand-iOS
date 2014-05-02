//
//  BoundingBoxViewController.h
//  NewsStand
//
//  Created by Hanan Samet on 1/25/12.
//  Copyright (c) 2012 University of Maryland. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <MapKit/MKMapView.h>

#import "Source.h"

@interface BoundingBoxViewController : UIViewController <MKMapViewDelegate, UIAlertViewDelegate, UITextFieldDelegate>
{
    IBOutlet MKMapView *mapView;
    IBOutlet UIButton *plusButton;
    IBOutlet UIButton *minusButton;
    
    NSMutableArray *existingRegions;
    
    //AlertView and Buttons
    UIAlertView *alertView;
    
    //Modes
    BOOL isPad;
    int handMode;
    BOOL editMode;
    Source *boundSourceIn;
    NSString *originalName;
}

@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) IBOutlet UIButton *plusButton;
@property (strong, nonatomic) IBOutlet UIButton *minusButton;

@property (strong, nonatomic) IBOutlet NSMutableArray *existingRegions;

@property (strong, nonatomic) UIAlertView *alertView;

@property (strong, nonatomic) NSString *originalName;

//Initialize 
-(id)initWithHandMode:(int)mode andIsPad:(BOOL)pad;
-(id)initWithSource:(Source *)source andHandMode:(int)mode andIsPad:(BOOL)pad;

//Initialize Map
-(void)setDefaultMapRegion;

//Control Map Button Placement
-(void)updateMapButtonsOnHandMode;

//Button Actions
-(IBAction)plusButtonPressed:(id)sender;
-(IBAction)minusButtonPressed:(id)sender;
-(void)createItemPressed;
-(void)editItemPressed;

//Setup Navigation Bar
-(void)configureNavigationBar;

@end
