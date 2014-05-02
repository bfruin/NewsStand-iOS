//
//  AddFeedViewController.h
//  NewsStand
//
//  Created by Hanan Samet on 1/23/12.
//  Copyright (c) 2012 University of Maryland. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddFeedViewController : UIViewController <UITableViewDelegate, UISearchBarDelegate, UITextFieldDelegate>
{
    IBOutlet UISearchBar *searchBar;
    IBOutlet UITableView *tableView;
    
    NSMutableArray *isSelectedAtIndex;
    NSMutableArray *indices;
    NSMutableArray *alphabet;
    
    NSMutableArray *theCopyListOfItems;
    BOOL searching;
    BOOL letUserSelectRow;
    
    int numSelected;
    
    NSMutableArray *countries;
    
    // NSXMLParser
    NSOperationQueue *queue;
    
    NSMutableArray *theNewFeeds;
    NSMutableArray *originalFeeds;
}

@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSMutableArray *isSelectedAtIndex;
@property (strong, nonatomic) NSMutableArray *indices;
@property (strong, nonatomic) NSMutableArray *alphabet;

@property (strong, nonatomic) NSMutableArray *theCopyListOfItems;

@property (strong, nonatomic) NSMutableArray *countries;

@property (strong, nonatomic) NSOperationQueue *queue;

@property (strong, nonatomic) NSMutableArray *theNewFeeds;
@property (strong, nonatomic) NSMutableArray *originalFeeds;

//Done Button
-(void)doneButtonPressed;

//Search Bar
-(void)searchTableView;
-(void)refreshIndexes;

//Parser
- (void)parseEnded:(NSMutableArray *)sources;

//Initialization
- (id)initWithFeeds:(NSMutableArray*)feeds andCountries:(NSMutableArray*)source_countries;

@end
