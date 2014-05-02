//
//  SourcesViewController.h
//  NewsStand
//
//  Created by Brendan on 1/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Source.h"
#import "ViewController.h"


@interface SourcesViewController : UIViewController
{
    IBOutlet UITableView *tableView;
    
    NSMutableArray *allSources;
    NSMutableArray *feedSources;
    NSMutableArray *countrySources;
    NSMutableArray *boundSources;
    NSMutableArray *languageSources;
    
    NSMutableArray *languagesSelected;
    NSMutableArray *feedsForLanguagesSelected;
    
    NSMutableArray *countries;
    
    SourcesSelected sourcesSelected;
    
    BOOL editEnabled;
    BOOL changedSources;
}

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSMutableArray *allSources;
@property (strong, nonatomic) NSMutableArray *feedSources;
@property (strong, nonatomic) NSMutableArray *countrySources;
@property (strong, nonatomic) NSMutableArray *boundSources;
@property (strong, nonatomic) NSMutableArray *languageSources;

@property (strong, nonatomic) NSMutableArray *languagesSelected;
@property (strong, nonatomic) NSMutableArray *feedsForLanguagesSelected;

@property (strong, nonatomic) NSMutableArray *countries;

@property (nonatomic, readwrite) SourcesSelected sourcesSelected;

//Buttons
-(void)editButtonPressed;

//Gesture Recognizers
-(void)feedFlagTapped:(UIGestureRecognizer*)sender;

//Language
-(void)updateLanguagesSelected;
-(CGPoint)updateFeedsForLanguagesSelected;

- (void) setAllSourceArraysUnselected;
- (BOOL) itemSelectedInArray:(NSMutableArray *)array;
- (void) updateViewController;

//Country Initialization
-(void)initializeCountries;

@end
