//
//  SettingsViewController.m
//  NewsStand
//
//  Created by Brendan on 12/29/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SettingsViewController.h"
#import "ViewController.h"
#import "QTouchposeApplication.h"

@implementation SettingsViewController

@synthesize  tableView;
@synthesize  layers, topics, topicsSelected;

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

#pragma mark - Table View Data Source  /  Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    UIUserInterfaceIdiom deviceType = [[UIDevice currentDevice] userInterfaceIdiom];
    
    if (deviceType == UIUserInterfaceIdiomPhone) {
        if (standMode == 0)
            return 7;
        else
            return 6;
    } else { //iPad
        if (standMode == 0)
            return 6;
        else
            return 5;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (standMode > 0)
        section++;
    
    if (section == [tableView numberOfSections]-1)
        return 1;
    
    if (section == 0) //Layer options
        return [layers count];
    else if (section == 1)
        return 2;
    else if (section == 2)
        return [topics count];
    else if (section == 3 || section == 4)
        return 4;
    else
        return 4;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (standMode > 0) {
        section++;
    }
    if (section == 0)
        return @"Choose Layer";
    else if (section == 1)
        return @"Home Settings";
    else if (section == 2)
        return @"Choose Topic";
    else if (section == 3)
        return @"Filter Images";
    else if (section == 4)
        return @"Filter Videos";
    else if (section == 5)
        return @"One-Handed Preference";
    else
        return @"Show Touches Preference";
    
    return @"None";
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int row = [indexPath row];
    int section = [indexPath section];
    
    UITableViewCell *cell = nil;
    if (standMode > 0)
        section++;
    
    if (section == 2 || section == 5) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"subtitle"];
        if (cell == nil)
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"subtitle"];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
        if (cell == nil)
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    }
    
    if (section == 0) { // Layer Options
        cell.textLabel.text = [layers objectAtIndex:row];
        
        if (row == layerIndexSelected) {
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        } else {
            [cell setAccessoryType:UITableViewCellAccessoryNone];
        }
    } else if (section == 1) { // Setting Home
        if (row == 0) {
            cell.textLabel.text = @"Set Current View as Home";
            if (setHome)
                [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
            else
                [cell setAccessoryType:UITableViewCellAccessoryNone];
        } else {
            cell.textLabel.text = @"Go Home";
        }
    } else if (section == 2) {  // Topics Options
        cell.textLabel.text = [topics objectAtIndex:row];
        [[cell imageView] setImage:[UIImage imageNamed:[[topics objectAtIndex:row] stringByAppendingString:@".gif"]]];
        
        if (row == 5)
            [[cell imageView] setImage:[UIImage imageNamed:@"Health.png"]];
        
        if (row == 6)
            [[cell imageView] setImage:[UIImage imageNamed:@"Sports.png"]];
        
        if ([[topicsSelected objectAtIndex:row] boolValue])
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        else
            [cell setAccessoryType:UITableViewCellAccessoryNone];
    } else if (section == 3) { //Image Filter
        if (row == 0)
            cell.textLabel.text = @"No filter";
        else if (row == 1)
            cell.textLabel.text = @"At least 1 image";
        else if (row == 2)
            cell.textLabel.text = @"At least 10 images";
        else
            cell.textLabel.text = @"At least 50 images";
        
        if (row == imageFilterSelected)
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        else
            [cell setAccessoryType:UITableViewCellAccessoryNone];
    } else if (section == 4) {  // Video Filter
        if (row == 0)
            cell.textLabel.text = @"No filter";
        else if (row == 1)
            cell.textLabel.text = @"At least 1 video";
        else if (row == 2)
            cell.textLabel.text = @"At least 5 videos";
        else
            cell.textLabel.text = @"At least 10 videos";
        
        if (row == videoFilterSelected)
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        else
            [cell setAccessoryType:UITableViewCellAccessoryNone];
    } else if (section == 5){  // One Hand Mode
        switch (row) {
            case 0:
                cell.textLabel.text = @"Automatic";
                [cell.imageView setImage:nil];
                break;
            case 1:
                cell.textLabel.text = @"Neutral";
                [cell.imageView setImage:[UIImage imageNamed:@"neutral.png"]];
                break;
            case 2:
                cell.textLabel.text = @"Holding in Left Hand";
                [cell.imageView setImage:[UIImage imageNamed:@"leftDoubleArrow.png"]];
                break;
            case 3:
                cell.textLabel.text = @"Holding in Right Hand";
                [cell.imageView setImage:[UIImage imageNamed:@"rightDoubleArrow.png"]];
                break;
        }
        
        if (row == handMode)
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        else
            [cell setAccessoryType:UITableViewCellAccessoryNone];
    } else {
        cell.textLabel.text = @"Always Show Touches";
        [cell.imageView setImage:nil];
        
        if (alwaysShowTouches)
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        else
            [cell setAccessoryType:UITableViewCellAccessoryNone];
    }
    
    return cell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    int row = [indexPath row];
    int section = [indexPath section];
    
    if (standMode > 0)
        section++;
    
    if (section == 0)
        layerIndexSelected = row;
    else if (section == 1) {
        if (row == 0)
            setHome = !setHome;
        else if (row == 1) {
            ViewController *viewController = [self.navigationController.viewControllers objectAtIndex:0];
            
            if (setHome)
                [viewController setHomeLocation];
            
            [viewController homeItemPushed];
            [self updateViewController];
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    } else if (section == 2) {
        if (row > 0) {
            bool selectedVal = ![[topicsSelected objectAtIndex:row] boolValue];
            
            [topicsSelected replaceObjectAtIndex:row withObject:[NSNumber numberWithBool:selectedVal]];
            
            int numSelected = 0;
            for (NSNumber *currNumber in topicsSelected) {
                if ([currNumber boolValue]) {
                    numSelected++;
                }
            }
            
            if (numSelected == 0) {
                [topicsSelected replaceObjectAtIndex:0 withObject:[NSNumber numberWithBool:FALSE]];
            } else {
                [topicsSelected replaceObjectAtIndex:0 withObject:[NSNumber numberWithBool:FALSE]];
            }
        } else {
            [topicsSelected replaceObjectAtIndex:0 withObject:[NSNumber numberWithBool:TRUE]];
            
            for (int i = 1; i < [topicsSelected count]; i++)
                [topicsSelected replaceObjectAtIndex:i withObject:[NSNumber numberWithBool:FALSE]];
        }
    } else if (section == 3) {
        imageFilterSelected = row;
    } else if (section == 4) {
        videoFilterSelected = row;
    } else if (section == 5){
        handMode = row;
        if (handMode == 0) {
            automaticHandMode = TRUE;
        } else {
            automaticHandMode = FALSE;
        }
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        [prefs setInteger:row forKey:@"handMode"];
        [prefs setBool:automaticHandMode forKey:@"automaticHandMode"];
    } else {
        alwaysShowTouches = !alwaysShowTouches;
    }
    
    [self.tableView reloadData];
}

#pragma mark - View lifecycle


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTitle:@"Settings"];
    
    ViewController *viewController = [self.navigationController.viewControllers objectAtIndex:0];
    
    standMode = [viewController standMode];
    if (standMode == 0) { // Not NewsStand
        layers = [[NSMutableArray alloc] init];
        [layers addObject:@"Icon Layer"];
        [layers addObject:@"Location Layer"];
        [layers addObject:@"Keyword Layer"];
        [layers addObject:@"People Layer"];
        [layers addObject:@"Disease Layer"];
        layerIndexSelected = [viewController layerSelected];
    }
    
    topics = [[NSMutableArray alloc] init];
    [topics addObject:@"All"];
    [topics addObject:@"General"];
    [topics addObject:@"Business"];
    [topics addObject:@"SciTech"];
    [topics addObject:@"Entertainment"];
    [topics addObject:@"Health"];
    [topics addObject:@"Sports"];
    
    
    topicsSelected = [[NSMutableArray alloc] initWithArray:[viewController topicsSelected]];
    imageFilterSelected = [viewController imageFilterSelected];
    videoFilterSelected = [viewController videoFilterSelected];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    alwaysShowTouches = [prefs boolForKey:@"alwaysShowTouches"];
    
    if ([viewController automaticHandMode]) {
        handMode = 0;
        automaticHandMode = TRUE;
    } else {
        handMode = [viewController handMode];
        automaticHandMode = FALSE;
    }
    
}

- (void)updateViewController
{
    ViewController *viewController = [self.navigationController.viewControllers objectAtIndex:0];
    [viewController setLayerSelected:layerIndexSelected];
    [viewController setTopicsSelected:topicsSelected];
    [viewController setImageFilterSelected:imageFilterSelected];
    [viewController setVideoFilterSelected:videoFilterSelected];
    [viewController setHandMode:handMode];
    [viewController setAutomaticHandMode:automaticHandMode];
    
    [viewController updateMapButtonsOnHandMode];
    
    QTouchposeApplication *application = (QTouchposeApplication*)[UIApplication sharedApplication];
    [application setShowTouches:alwaysShowTouches];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setBool:alwaysShowTouches forKey:@"alwaysShowTouches"];
    
    if (setHome)
        [viewController setHomeLocation];
}

- (void)viewWillAppear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:YES];
    [[self.navigationController navigationBar] setBarStyle:UIBarStyleBlackOpaque];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self updateViewController];
    [super viewWillDisappear:animated];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
