//
//  SettingsViewController.h
//  NewsStand
//
//  Created by Brendan on 12/29/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsViewController : UIViewController <UITableViewDelegate>
{
    IBOutlet UITableView *tableView;
    
    int standMode;
    
    int layerIndexSelected;
    bool setHome;
    int imageFilterSelected;
    int videoFilterSelected;
    int handMode;
    BOOL automaticHandMode;
    BOOL alwaysShowTouches;
    
    NSMutableArray *layers;
    NSMutableArray *topics;
    NSMutableArray *topicsSelected;
}

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSMutableArray *layers;
@property (strong, nonatomic) NSMutableArray *topics;
@property (strong, nonatomic) NSMutableArray *topicsSelected;

-(void) updateViewController;

@end
