//
//  BoundingBoxViewController.m
//  NewsStand
//
//  Created by Hanan Samet on 1/25/12.
//  Copyright (c) 2012 University of Maryland. All rights reserved.
//

#import "BoundingBoxViewController.h"
#import "ViewController.h"
#import "SourcesViewController.h"

@implementation BoundingBoxViewController
@synthesize mapView, plusButton, minusButton;
@synthesize existingRegions;
@synthesize alertView;
@synthesize originalName;

- (id) initWithHandMode:(int)mode andIsPad:(BOOL)pad 
{
    if (self = [super init]) {
        boundSourceIn = nil;
        originalName = @"";
        editMode = FALSE;
        handMode = mode;
        isPad = pad;
    }
    return self;
}
- (id) initWithSource:(Source *)source andHandMode:(int)mode andIsPad:(BOOL)pad
{
    if (self = [super init]) {
        boundSourceIn = source;
        originalName = [source name];
        editMode = TRUE;
        handMode = mode;
        isPad = pad;
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
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - Default Map Region

-(void)setDefaultMapRegion
{
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    CLLocationCoordinate2D center;
    
    UIInterfaceOrientation currentOrientation = [[UIApplication sharedApplication] statusBarOrientation];

    if (editMode) {
        span = MKCoordinateSpanMake([boundSourceIn
                                                      latDelta], [boundSourceIn lonDelta]);
        center.latitude = [boundSourceIn centerLat];
        center.longitude = [boundSourceIn centerLon];
        region.center = center;
        region.span = span;
    } else {
        if (isPad) {
            if (UIInterfaceOrientationIsPortrait(currentOrientation)) { // Portrait
                span = MKCoordinateSpanMake(164.863431, 270.0);
                region.span = span;
            
                center.latitude = 20.303418;
                center.longitude = 8.789062;
                region.center = center;
            
            } else {
                span = MKCoordinateSpanMake(147.112657, 360.0);
                region.span = span;
            
                center.latitude = 19.973349;
                center.longitude = 0.0;
                region.center = center;
            }
        } else {	
            if (UIInterfaceOrientationIsPortrait(currentOrientation)) { // Portrait
                span = MKCoordinateSpanMake(115, 115);
                region.span = span;
            
                center.latitude = 20;
                center.longitude = -20;
            
                region.center = center;
            
            } else {
                span = MKCoordinateSpanMake(111.696806, 337.50);
                region.span = span;
            
                center.latitude = 21.289374;
                center.longitude = 11.25;
                region.center = center;
            }
        }	
    }
    [mapView setRegion:region animated:NO];
}

#pragma mark - Textfield Changed

- (BOOL) isValidRegionName:(NSString *)name
{
    if ([name isEqualToString:originalName])
        return YES;
    
    for (Source *curr in existingRegions)
        if ([[curr name] isEqualToString:name])
            return NO;
        
        
    return YES;
}

- (void) textFieldDidChange
{
    NSLog(@"Text field did change");
    NSString *alertViewText = [[alertView textFieldAtIndex:0] text];
    
    
    if ([alertViewText isEqualToString:@""]) {
        [alertView setMessage:@"Please Enter Region Name"];
        for (UIViewController *view in alertView.subviews) {
            if ([view isKindOfClass:[UIButton class]])  {
                UIButton *button = (UIButton *)view;
                if ([[[button titleLabel] text] isEqualToString:@"Create Region"] || [[[button titleLabel] text] isEqualToString:@"Edit Region"]) {
                    [button setEnabled:NO];
                    break;
                } 
            }
        } 
    } else if (![self isValidRegionName:alertViewText]) {
        [alertView setMessage:@"Region Name Already Taken"];
        for (UIViewController *view in alertView.subviews) {
            if ([view isKindOfClass:[UIButton class]])  {
                UIButton *button = (UIButton *)view;
                if ([[[button titleLabel] text] isEqualToString:@"Create Region"] || [[[button titleLabel] text] isEqualToString:@"Edit Region"]) {
                    [button setEnabled:NO];
                    break;
                } 
            }
        }
    } else {
        for (UIViewController *view in alertView.subviews) {
            [alertView setMessage:@"Please Enter Region Name"];
            if ([view isKindOfClass:[UIButton class]])  {
                UIButton *button = (UIButton *)view;
                if ([[[button titleLabel] text] isEqualToString:@"Create Region"] || [[[button titleLabel] text] isEqualToString:@"Edit Region"]) {
                    [button setEnabled:YES];
                    break;
                } 
            }
        }
    }
    } 



#pragma mark - Map Buttons
- (void)updateMapButtonsOnHandMode
{
    UIInterfaceOrientation currentOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    //If not a pad handle handmode
    if (!isPad) {
        if (UIInterfaceOrientationIsLandscape(currentOrientation)) {
            if (handMode == 0) { // Neutral (Default)
                plusButton.frame = CGRectMake(422.0, 30.0, 50.0, 50.0);
                minusButton.frame = CGRectMake(422.0, 94.0, 50.0, 50.0);
                [plusButton setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
                [minusButton setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
            } else if (handMode == 1) { // Left hand mode
                plusButton.frame = CGRectMake(385.0, 18.0, 50.0, 50.0);
                minusButton.frame = CGRectMake(427.0, 94.0, 50.0, 50.0);
                [plusButton setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
                [minusButton setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
            } else {
                plusButton.frame = CGRectMake(55.0, 18.0, 50.0, 50.0);
                minusButton.frame = CGRectMake(13.0, 94.0, 50.0, 50.0);
                [plusButton setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin];
                [minusButton setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin];
            }
        } else {
            if (handMode == 0) { // Neutral (Default)
                plusButton.frame = CGRectMake(262.0, 30.0, 50.0, 50.0);
                minusButton.frame = CGRectMake(262.0, 94.0, 50.0, 50.0);
                [plusButton setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
                [minusButton setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
            } else if (handMode == 1) { // Left hand mode
                plusButton.frame = CGRectMake(225.0, 18, 50.0, 50.0);
                minusButton.frame = CGRectMake(267.0, 94.0, 50.0, 50.0);
                [plusButton setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
                [minusButton setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
            } else {
                plusButton.frame = CGRectMake(55.0, 18.0, 50.0, 50.0);
                minusButton.frame = CGRectMake(13.0, 94.0, 50.0, 50.0);
                
                [plusButton setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin];
                [minusButton setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin];
            }
        }
    }
}

#pragma mark - Alert View Delegate

- (void)alertView:(UIAlertView *)localAlertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [[alertView textFieldAtIndex:0] setText:originalName];
    } else {
        ViewController *viewController = [[self.navigationController viewControllers] objectAtIndex:0];
        
        CLLocationCoordinate2D center = [mapView centerCoordinate];
        CLLocationDegrees lat = center.latitude;
        CLLocationDegrees lon = center.longitude;
        
        MKCoordinateRegion region = [mapView region];
        MKCoordinateSpan span = region.span;
        
        NSString *regionName = [[alertView textFieldAtIndex:0] text];
        
        Source *newBoundSource = [[Source alloc] initWithName:regionName SourceType:boundSource centerLat:lat centerLon:lon latDelta:span.latitudeDelta lonDelta:span.longitudeDelta];
        
        [newBoundSource setSelected:YES];
        
        if (editMode) {
            [viewController removeBoundRegionWithName:originalName];  
        } 
        
        [viewController addBoundRegionWithSource:newBoundSource];
        [viewController setSourcesSelected:boundSourcesSelected];
        
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - Map Buttons
-(IBAction)plusButtonPressed:(id)sender 
{
    MKCoordinateRegion newRegion = [mapView region];
    MKCoordinateSpan newSpan = MKCoordinateSpanMake(newRegion.span.latitudeDelta / 2.0, newRegion.span.longitudeDelta / 2.0);
    newRegion.span = newSpan;
    
    [mapView setRegion:newRegion animated:YES];
}
-(IBAction)minusButtonPressed:(id)sender 
{
    MKCoordinateRegion newRegion = [mapView region];
    
    if (newRegion.span.latitudeDelta > 90.0 || newRegion.span.longitudeDelta > 90.0)
        return;
    
    MKCoordinateSpan newSpan = MKCoordinateSpanMake(newRegion.span.latitudeDelta * 1.75, newRegion.span.longitudeDelta * 1.75);
    newRegion.span = newSpan;
    
    [mapView setRegion:newRegion animated:YES];
}

#pragma mark - Bar Button Item Pressed
- (void) createItemPressed
{
    NSLog(@"CREATE ITEM PRESSED");
    if (alertView == nil) {
        alertView = [[UIAlertView alloc] initWithTitle:@"Create Region" message:@"Please Enter Region Name" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Create Region", nil];
        [alertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
        [[alertView textFieldAtIndex:0] setDelegate:self];
        [[alertView textFieldAtIndex:0] addTarget:self action:@selector(textFieldDidChange) forControlEvents:UIControlEventEditingChanged];
        [[alertView textFieldAtIndex:0] setClearButtonMode:UITextFieldViewModeAlways];
        
        
        for (UIViewController *view in alertView.subviews) {
            if ([view isKindOfClass:[UIButton class]])  {
                UIButton *button = (UIButton *)view;
                if ([[[button titleLabel] text] isEqualToString:@"Create Region"]) {
                    [button setEnabled:NO];
                    break;
                } 
            }
        } 
        
    }
    [alertView show];
}

- (void) editItemPressed
{
    if (alertView == nil) {
        alertView = [[UIAlertView alloc] initWithTitle:@"Edit Region" message:@"Please Enter Region Name" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Finished Editing", nil];
        [alertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
        [[alertView textFieldAtIndex:0] setDelegate:self];
        [[alertView textFieldAtIndex:0] addTarget:self action:@selector(textFieldDidChange) forControlEvents:UIControlEventEditingChanged];
        [[alertView textFieldAtIndex:0] setText:originalName];
        [[alertView textFieldAtIndex:0] setClearButtonMode:UITextFieldViewModeAlways];
    }
    
    [alertView show];
}

#pragma mark - Configure Navigation Bar
-(void)configureNavigationBar
{
    if (editMode) {
        [self setTitle:[NSString stringWithFormat:@"Edit %@", originalName]];
        UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStyleDone target:self action:@selector(editItemPressed)];
        [self.navigationItem setRightBarButtonItem:rightButton];
    } else {
        [self setTitle:@"Create Region"];
        UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Create" style:UIBarButtonItemStyleDone target:self action:@selector(createItemPressed)];
        [self.navigationItem setRightBarButtonItem:rightButton];
    }
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self updateMapButtonsOnHandMode];
    [self configureNavigationBar];
    
    [self setDefaultMapRegion];
    [self updateMapButtonsOnHandMode];
    
    ViewController *viewController = [[self.navigationController viewControllers] objectAtIndex:0];
    existingRegions = [[NSMutableArray alloc] initWithArray:[viewController boundSources]];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
