//
//  SnippetViewController.h
//  NewsStand
//
//  Created by Hanan Samet on 1/17/12.
//  Copyright (c) 2012 University of Maryland. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DetailViewController.h"

@interface SnippetViewController : UIViewController <UIWebViewDelegate, UIAlertViewDelegate>
{
    //Web Viewer
    IBOutlet UIWebView *webView;
    
    //Segment Control
    IBOutlet UISegmentedControl *segmentedControl;
    
    //Annotations
    NSMutableArray *annotations;
    int annotationIndex;
    
    //Constraints
    NSString *constraints;
    
    BOOL showing_translated;
    BOOL isPad;

    //Error Reporting
    int error_type;
    
    //iPad Navigation Bar
    IBOutlet UINavigationBar *navigationBar;
    UIBarButtonItem *leftBarButtonItem;
}

//Web Viewer
@property (strong, nonatomic) IBOutlet UIWebView *webView;

//Segment Control
@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

//Annotations
@property (strong, nonatomic) NSMutableArray *annotations;
@property (nonatomic, readwrite) int annotationIndex;

//Constraints
@property (strong, nonatomic) NSString *constraints;

//iPad Navigation Bar
@property (strong, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (strong, nonatomic) UIBarButtonItem *leftBarButtonItem;

//Initializers
-(id)initWithNibName:(NSString *)nibNameOrNil andAnnotations:(NSMutableArray*)annotationsArray andAnnotationIndex:(int)index andConstraints:(NSString*)constr;
-(id)initWithNibName:(NSString *)nibNameOrNil andAnnotations:(NSMutableArray*)annotationsArray andAnnotationIndex:(int)index andConstraints:(NSString*)constr andBackTitle:(NSString *)backTitle;
-(id)initWithAnnotations:(NSMutableArray*)annotationsArray andAnnotationIndex:(int)index andConstraints:(NSString*)constr;
-(NSString *)URLEncodeString:(NSString *)str;

//Segment Control
-(IBAction)segmentAction:(id)sender;

//iPad
-(void)leftButtonPressed;

@end
