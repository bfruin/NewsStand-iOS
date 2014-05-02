//
//  AddFeedViewController.m
//  NewsStand
//
//  Created by Hanan Samet on 1/23/12.
//  Copyright (c) 2012 University of Maryland. All rights reserved.
//

#import "AddFeedViewController.h"
#import "NewFeed.h"
#import "Source.h"
#import "AddFeedRequestOperation.h"
#import "ViewController.h"
#import "Country.h"

@implementation AddFeedViewController

@synthesize searchBar, tableView;
@synthesize isSelectedAtIndex, indices, alphabet;
@synthesize theCopyListOfItems;
@synthesize countries;
@synthesize queue;
@synthesize theNewFeeds, originalFeeds;

#pragma mark - Initialization
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithFeeds:(NSMutableArray*)feeds andCountries:(NSMutableArray *)source_countries
{
    if (self = [super init])  {
        originalFeeds = [[NSMutableArray alloc] initWithArray:feeds];
        countries = [[NSMutableArray alloc] initWithArray:source_countries];
        queue = [[NSOperationQueue alloc] init];
        AddFeedRequestOperation *addFeedRequestOperation = [[AddFeedRequestOperation alloc] initWithAddFeedViewController:self];
        [queue addOperation:addFeedRequestOperation];
    }    
    
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - Done Button

- (void) doneButtonPressed
{
    [searchBar resignFirstResponder];
    ViewController *viewController = [[self.navigationController viewControllers] objectAtIndex:0];
    
    for (int i = 0; i < [theNewFeeds count]; i++) {
        BOOL isChecked = [[isSelectedAtIndex objectAtIndex:i] boolValue];
        if (isChecked) {
            NewFeed *currFeed = [theNewFeeds objectAtIndex:i];
            Source *sourceToAdd = [[Source alloc] initWithName:[currFeed name] feed_link:[currFeed feed_link] andSourceType:feedSource];
            [sourceToAdd setLang_code:[currFeed language]];
            [sourceToAdd setSource_location:[currFeed country_code]];
            [sourceToAdd setSelected:YES];
            [viewController.feedSources addObject:sourceToAdd];
            [viewController setSourcesSelected:feedSourcesSelected];
            [viewController updateNumSources];
        }
    }
    
    [viewController setFeedSources:[[NSMutableArray alloc] initWithArray:[viewController.feedSources sortedArrayUsingSelector:@selector(compare:)]]];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Table View Data Source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)localTableView 
{
    if (indices == nil)
        return 1;
    return [alphabet count];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)localTableView
{
    return alphabet;
}

- (NSString *)tableView:(UITableView *)localTableView titleForHeaderInSection:(NSInteger)section
{
    return [alphabet objectAtIndex:section];
}

- (NSInteger)tableView:(UITableView *)localTableView numberOfRowsInSection:(NSInteger)section
{
    if (indices == nil)
        return 1;
    
    int occurrences = 0;
    for (NSString *currIndex in indices) 
        occurrences += ([currIndex isEqualToString:[alphabet objectAtIndex:section]]);
    
    return occurrences;
}

- (UITableViewCell *)tableView:(UITableView *)localTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [localTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    
    if (theNewFeeds == nil)
        return cell;
    
    int section = [indexPath section];
    int row = [indexPath row];
    int elementNum = 0;
    
    for (int i = 0; i < section; i++)
        elementNum += [tableView numberOfRowsInSection:i];
    
    [[cell detailTextLabel] setText:@""];
    
    NewFeed *feed;
    if (searching == NO && (searchBar.text == nil || [searchBar.text isEqualToString:@""])) {
        feed = [theNewFeeds objectAtIndex:elementNum + row];
        [[cell textLabel] setText:[[theNewFeeds objectAtIndex:elementNum + row] name]];
        [[cell textLabel] setText:[feed name]];
        
        BOOL isChecked = [[isSelectedAtIndex objectAtIndex:elementNum + row] boolValue];
        
        if (isChecked)
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        else
            [cell setAccessoryType:UITableViewCellAccessoryNone];
    } else {
        if ([theCopyListOfItems count] != 0) {
            
            [[cell textLabel] setText:[theCopyListOfItems objectAtIndex:elementNum + row]];
            NSString *currName = [theCopyListOfItems objectAtIndex:elementNum + row] ;
            int locInAll = -1;
            int count = 0;
            for (NewFeed *currFeed in theNewFeeds) {
                if ([[currFeed name] isEqualToString:currName]) {
                    locInAll = count;
                    break;
                }
                count += 1;
            }
            if (count >= 0) {
                BOOL isChecked = [[isSelectedAtIndex objectAtIndex:count] boolValue];
                if (isChecked)
                    [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
                else
                    [cell setAccessoryType:UITableViewCellAccessoryNone];
            }
            
            feed = [theNewFeeds objectAtIndex:locInAll];
        }
    }
    
    //Set Image
    NSString *country_code = [feed country_code];
    if (country_code != nil && ![country_code isEqualToString:@""]) {
        [cell.imageView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@.png", [country_code lowercaseString]]]];
    } else {
        [cell.imageView setImage:[UIImage imageNamed:@"_world.png"]];
    }
    
    if ([feed country_name] != nil && [feed language] != nil) {
        NSString *subtitle = [NSString stringWithFormat:@"%@ (%@)", [feed country_name], [feed language]];
        [[cell detailTextLabel] setText:subtitle];
    } else if ([feed country_name] != nil) {
        [[cell detailTextLabel] setText:[feed country_name]];
    } else if ([feed language] != nil) {
        [[cell detailTextLabel] setText:[NSString stringWithFormat:@"(%@)", [feed language]]];
    }
    
    
    return cell;
}

#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)localTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    int row = [indexPath row];
    int section = [indexPath section];
    int elementNum = 0;
    
    for (int i = 0; i < section; i++) {
        elementNum += [tableView numberOfRowsInSection:i];
    }
    
    if (searching == NO && (searchBar.text == nil || [searchBar.text isEqualToString:@""])) {
        BOOL isChecked = [[isSelectedAtIndex objectAtIndex:elementNum + row] boolValue];
        [isSelectedAtIndex replaceObjectAtIndex:elementNum + row withObject:[NSNumber numberWithBool:!isChecked]];
        if (isChecked)
            numSelected--;
        else
            numSelected++;
    } else {
        NSString *currName = [theCopyListOfItems objectAtIndex:elementNum + row];
        int locInAll = -1;
        int count = 0;
        for (NewFeed *currFeed in theNewFeeds) {
            if ([[currFeed name] isEqualToString:currName]) {
                locInAll = count;
                break;
            }
            count += 1;
        }
        if (count >= 0) {
            BOOL isChecked = [[isSelectedAtIndex objectAtIndex:count] boolValue];
            [isSelectedAtIndex replaceObjectAtIndex:count withObject:[NSNumber numberWithBool:!isChecked]];
            if (isChecked)
                numSelected--;
            else
                numSelected++;
        }
    }
    [localTableView reloadData];
}

- (NSIndexPath *)tableView:(UITableView *)localTableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([searchBar.text isEqualToString:@""]) {
        [searchBar resignFirstResponder];
        letUserSelectRow = YES;
        searching = NO;
        [tableView setScrollEnabled:YES];
    }
    
    if (letUserSelectRow)
        return indexPath;
    else
        return nil;
}

#pragma mark - Search Bar 

- (void) searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    searching = YES;
}

- (void) searchBar:(UISearchBar *)theSearchBar textDidChange:(NSString *)searchText
{
    [theCopyListOfItems removeAllObjects];
    
    if ([searchText length] > 0) {
        searching = YES;
        letUserSelectRow = YES;
        [tableView setScrollEnabled:YES];
        [self searchTableView];
    }
    [tableView reloadData];
}

- (void) searchBarSearchButtonClicked:(UISearchBar *)theSearchBar
{
    [self searchTableView];
    [theSearchBar resignFirstResponder];
}

- (void) searchTableView
{
    NSString *searchText = [searchBar text];
    NSMutableArray *searchArray = [[NSMutableArray alloc] init];
    
    for (NewFeed *currFeed in theNewFeeds) {
        [searchArray addObject:[currFeed name]];
    }
    
    int count = 0;
    
    for (NSString *tempStr in searchArray) {
        NSRange titleResultsRange = [tempStr rangeOfString:searchText options:NSCaseInsensitiveSearch];
        
        if (titleResultsRange.location != NSNotFound) {
            [theCopyListOfItems addObject:tempStr];
        }
        count += 1;
    }
    
    if (indices == nil)
        indices = [[NSMutableArray alloc] init];
    
    [indices removeAllObjects];
    
    if (alphabet == nil)
        alphabet = [[NSMutableArray alloc] init];
    
    [alphabet removeAllObjects];
    
    for (int k = 0; k < [theCopyListOfItems count]; k++) {
        char currentIndex = toupper([[theCopyListOfItems objectAtIndex:k] characterAtIndex:0]);
        if (currentIndex < 65) {
            if (currentIndex == 47) {
                currentIndex = toupper([[theCopyListOfItems objectAtIndex:k] characterAtIndex:1]);
            } else {
                currentIndex = '#';
            }
        }
        NSString *indexString = [NSString stringWithFormat:@"%c", currentIndex];
        if (![alphabet containsObject:indexString])
            [alphabet addObject:indexString];
        [indices addObject:indexString];
    }
}

- (void) doneSearchingPressed:(id)sender
{
    [searchBar resignFirstResponder];
    
    letUserSelectRow = YES;
    searching = NO;
    [tableView setScrollEnabled:YES];
    
    [tableView reloadData];
}

- (void) searchBarCancelButtonClicked:(UISearchBar *) theSearchBar
{
    NSLog(@"SEARCH BAR CANCEL");
    
    [theSearchBar setText:@""];
    [theSearchBar resignFirstResponder];
    searching = NO;
    letUserSelectRow = YES;
    [tableView setScrollEnabled:YES];
    [self refreshIndexes];
    
    [tableView reloadData];
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    [self performSelector:@selector(searchBarCancelButtonClicked:) withObject:searchBar afterDelay:.1];
    return YES;
}

- (void) refreshIndexes
{
    if (indices == nil)
        indices = [[NSMutableArray alloc] init];
    
    [indices removeAllObjects];
    
    if (alphabet == nil)
        alphabet = [[NSMutableArray alloc] init];
    
    [alphabet removeAllObjects];

    for (int k = 0; k < [theNewFeeds count]; k++) {
        char currentIndex = toupper([[[theNewFeeds objectAtIndex:k] name] characterAtIndex:0]);
        if (currentIndex < 65) 
            if (currentIndex == 47)
                currentIndex = toupper([[[theNewFeeds objectAtIndex:k] name] characterAtIndex:1]);
            else
                currentIndex = '#';
        
        NSString *indexString = [NSString stringWithFormat:@"%c", currentIndex];
        
        if (![alphabet containsObject:indexString])
            [alphabet addObject:indexString];
        [indices addObject:indexString];
    }
}

#pragma mark - Parser

- (void)parseEnded:(NSMutableArray *)sources
{
    NSLog(@"In parse ended");
    theNewFeeds = [[NSMutableArray alloc] initWithArray:sources];
    
    if (isSelectedAtIndex == nil)
        isSelectedAtIndex = [[NSMutableArray alloc] init];
    
    [isSelectedAtIndex removeAllObjects];
    
    NSMutableArray *sourcesToRemove = [[NSMutableArray alloc] init];
    int numRemoved = 0;
    
    NSMutableArray *originalFeedsFeedLinks = [[NSMutableArray alloc] init];
    for (int i = 0; i < [originalFeeds count]; i++) {
        [originalFeedsFeedLinks addObject:[NSNumber numberWithInt:[[originalFeeds objectAtIndex:i] feed_link]]];
    }
    
    for (int i = 0; i < [theNewFeeds count]; i++) {
        if ([originalFeedsFeedLinks containsObject:[NSNumber numberWithInt:[[theNewFeeds objectAtIndex:i] feed_link]]]) {
            [sourcesToRemove addObject:[NSNumber numberWithInt:i-numRemoved]];
            numRemoved += 1;
        }
    }
    
    for (NSNumber *currIndex in sourcesToRemove)
        [theNewFeeds removeObjectAtIndex:[currIndex intValue]];
    
    for (int j = 0; j < [theNewFeeds count]; j++)
        [isSelectedAtIndex addObject:[NSNumber numberWithBool:NO]];
    
    indices = [[NSMutableArray alloc] init];
    alphabet = [[NSMutableArray alloc] init];
    
    for (int k = 0; k < [theNewFeeds count]; k++) {
        char currentIndex = toupper([[[theNewFeeds objectAtIndex:k] name] characterAtIndex:0]);
        if (currentIndex < 65)
            if (currentIndex == 47)
                currentIndex = toupper([[[theNewFeeds objectAtIndex:k] name] characterAtIndex:1]);
            else
                currentIndex = '#';
        
        for (Country *country in countries) {
            if ([[country country_code] isEqualToString:[[theNewFeeds objectAtIndex:k] country_code]]) {
                [[theNewFeeds objectAtIndex:k] setCountry_name:[country country_name]];
                [[theNewFeeds objectAtIndex:k] setNative_name:[country native_name]];
                break;
            }
        }
        
        NSString *indexString = [NSString stringWithFormat:@"%c", currentIndex];
        
        if (![alphabet containsObject:indexString])
            [alphabet addObject:indexString];
        [indices addObject:indexString];
    }
    
    [tableView reloadData];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTitle:@"Add Feeds"];
    letUserSelectRow = YES;
    
    theCopyListOfItems = [[NSMutableArray alloc] init];
    
    for (UIView *view in searchBar.subviews) {
        if ([view conformsToProtocol:@protocol(UITextInputTraits)]) {
            @try {
                [(UITextField *)view setReturnKeyType:UIReturnKeyDone];
                [(UITextField *)view setEnablesReturnKeyAutomatically:NO];
                [(UITextField *)view setKeyboardAppearance:UIKeyboardAppearanceAlert];
                [(UITextField *)view setDelegate:self];
            }
            @catch (NSException *exception) {
                //ignore
            }
        }
    }
    
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonPressed)];
    [self.navigationItem setRightBarButtonItem:doneButton];
    
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
