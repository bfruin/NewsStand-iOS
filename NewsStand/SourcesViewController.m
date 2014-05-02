//
//  SourcesViewController.m
//  NewsStand
//
//  Created by Brendan on 1/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SourcesViewController.h"
#import "AddFeedViewController.h"
#import "BoundingBoxViewController.h"
#import "Country.h"

@implementation SourcesViewController

@synthesize tableView;
@synthesize allSources, feedSources, countrySources, boundSources, languageSources;
@synthesize languagesSelected, feedsForLanguagesSelected;
@synthesize countries;
@synthesize sourcesSelected;

#pragma mark - Table View Setup

- (NSInteger)numberOfSectionsInTableView:(UITableView *)localTableView 
{
    return 6;
}

- (NSInteger)tableView:(UITableView *)localTableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) //All Sources
        return 3;
    else if (section == 1)
        return [feedsForLanguagesSelected count];
    else if (section == 2)
        return 1;
    else if (section == 3)
        return [countrySources count];
    else if (section == 4)
        return [languageSources count];
    else if (section == 5)
        if (sourcesSelected == boundSourcesSelected)
            return [boundSources count] + 2;
        else
            return [boundSources count] + 1;
    
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0)
        return @"All Sources";
    else if (section == 1)
        return @"Feeds";
    else if (section == 2)
        return @"";
    else if (section == 3)
        return @"Countries";
    else if (section == 4)
        return @"Languages";
    else if (section == 5)
        if ([boundSources count] > 0)
            return @"Bounding Region";
        else
            return @"";
    
    return @"None";
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int row = [indexPath row];
    int section = [indexPath section];
    
    UITableViewCell *cell;
    
    
    cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    
    [cell.detailTextLabel setText:@""];
    [cell.imageView setImage:nil];
    
    if (section == 0) { // All Sources
        [cell.textLabel setText:[[allSources objectAtIndex:row] name]];
        if ([[allSources objectAtIndex:row] selected])
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        else
            [cell setAccessoryType:UITableViewCellAccessoryNone];
    } else if (section == 1) {  // Feeds
        Source *feedSource = [feedsForLanguagesSelected objectAtIndex:row];
        NSString *source_location = [feedSource source_location];
        
        [cell.textLabel setText:[feedSource name]];
        if (source_location != nil && ![source_location isEqualToString:@""]) {
            NSString *image_name = [NSString stringWithFormat:@"%@.png", [source_location lowercaseString]];
            [cell.imageView setImage:[UIImage imageNamed:image_name]];
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(feedFlagTapped:)];
            [tap setNumberOfTapsRequired:1];
            [cell.imageView setUserInteractionEnabled:YES];
            [cell.imageView setTag:row];
            [cell.imageView addGestureRecognizer:tap];
        } else {
            [cell.imageView setImage:[UIImage imageNamed:@"_world.png"]];
        }
        
        NSString *num_docs;
        if (![feedSource flag_selected]) {
            if ([languagesSelected count] > 1) 
                if ([feedSource num_docs] == 1) {
                    num_docs = [NSString stringWithFormat:@"%d article (%@)", [feedSource num_docs], [feedSource lang_code]];
                } else {
                    num_docs = [NSString stringWithFormat:@"%d articles (%@)", [feedSource num_docs], [feedSource lang_code]];
                }
            else 
                if ([feedSource num_docs] == 1) {
                    num_docs = [NSString stringWithFormat:@"%d article", [feedSource num_docs]];
                } else {
                    num_docs = [NSString stringWithFormat:@"%d articles", [feedSource num_docs]];
                }
        } else {
            Country *country = nil;
            NSString *country_code = [feedSource source_location];
            for (Country *current_country in countries) {
                if ([[current_country country_code] isEqualToString:country_code]) {
                    country = current_country;
                    break;
                }
            }
            
            if (country != nil) {
                if ([country native_name] != nil && ![[country native_name] isEqualToString:@""]) {
                    if ([[feedSource lang_code] isEqualToString:@"ar"] || [[feedSource lang_code] isEqualToString:@"he"]) {
                        num_docs = [NSString stringWithFormat:@"(%@) %@", [country country_name], [country native_name]];
                    } else {
                        num_docs = [NSString stringWithFormat:@"%@ (%@)", [country native_name], [country country_name]];
                    }
                } else {
                    num_docs = [country country_name];
                }
            } else {
                if ([languagesSelected count] > 1) 
                    num_docs = [NSString stringWithFormat:@"%d articles (%@)", [feedSource num_docs], [feedSource lang_code]];
                else 
                    num_docs = [NSString stringWithFormat:@"%d articles", [feedSource num_docs]];
            }
        }
        [cell.detailTextLabel setText:num_docs];
        if ([[feedsForLanguagesSelected objectAtIndex:row] selected])
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        else
            [cell setAccessoryType:UITableViewCellAccessoryNone];
    } else if (section == 2) {
        [cell.textLabel setText:@"Add Feeds"];
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    } else if (section == 3) {  // Countries
        Source *countrySource = [countrySources objectAtIndex:row];
        [cell.textLabel setText:[countrySource name]];
        [cell.detailTextLabel setText:[NSString stringWithFormat:@"%d articles", [countrySource num_docs]]];
        [cell.imageView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@.png", [countrySource source_location]]]];
        if ([countrySource selected])
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        else
            [cell setAccessoryType:UITableViewCellAccessoryNone];
    } else if (section == 4) {
        Source *languageSource = [languageSources objectAtIndex:row];
        NSString *name = [languageSource name];
        [cell.textLabel setText:[NSString stringWithFormat:@"%@", name]];
        [cell.detailTextLabel setText:[NSString stringWithFormat:@"%d articles", [languageSource num_docs]]];
        
        if ([languageSource selected]) 
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        else
            [cell setAccessoryType:UITableViewCellAccessoryNone];
    } else if (section == 5) { //Bounding Box
        if (row == 0) {
            [cell.textLabel setText:@"Create Bounding Region"];
            [cell setAccessoryType:UITableViewCellAccessoryNone];
        } else if (row == 1) {
            if (sourcesSelected == boundSourcesSelected) {
                [cell.textLabel setText:@"Edit Selected Region"];
                [cell setAccessoryType:UITableViewCellAccessoryNone];            } else {
                [cell.textLabel setText:[[boundSources objectAtIndex:0] name]];
                if ([[boundSources objectAtIndex:0] selected])
                    [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
                else
                    [cell setAccessoryType:UITableViewCellAccessoryNone];
            }
        } else {
            if (sourcesSelected == boundSourcesSelected) {
                [cell.textLabel setText:[[boundSources objectAtIndex:(row-2)] name]];
                if ([[boundSources objectAtIndex:(row-2)] selected])
                    [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
                else
                    [cell setAccessoryType:UITableViewCellAccessoryNone];
            } else {
                [cell.textLabel setText:[[boundSources objectAtIndex:(row-1)] name]];
                if ([[boundSources objectAtIndex:(row-1)] selected])
                    [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
                else
                    [cell setAccessoryType:UITableViewCellAccessoryNone];
            }
        }
    }
    
    return cell;
}

#pragma mark - Setting Selected

- (void) setAllSourcesUnselectedExceptSelected
{
    if (sourcesSelected != allSourcesSelected) 
        for (int i = 0; i < [allSources count]; i++) 
            [[allSources objectAtIndex:i] setSelected:FALSE];
    
    if (sourcesSelected != feedSourcesSelected)
        for (int i = 0; i < [feedsForLanguagesSelected count]; i++) 
            [[feedsForLanguagesSelected objectAtIndex:i] setSelected:FALSE];
    
    if (sourcesSelected != countrySourcesSelected)
        for (int i = 0; i < [countrySources count]; i++) 
            [[countrySources objectAtIndex:i] setSelected:FALSE];
    
   // if (sourcesSelected != languageSourcesSelected) 
     //   for (int i = 0; i < [languageSources count]; i++) 
       //     [[languageSources objectAtIndex:i] setSelected:FALSE];
    
    if (sourcesSelected != boundSourcesSelected)
        for (int i = 0; i < [boundSources count]; i++)
            [[boundSources objectAtIndex:i] setSelected:FALSE];
}

- (void) setAllSourceArraysUnselected
{
    for (int i = 0; i < [allSources count]; i++) 
        [[allSources objectAtIndex:i] setSelected:FALSE];
    
    for (int i = 0; i < [feedsForLanguagesSelected count]; i++) 
        [[feedsForLanguagesSelected objectAtIndex:i] setSelected:FALSE];
    
    for (int i = 0; i < [countrySources count]; i++) 
        [[countrySources objectAtIndex:i] setSelected:FALSE];
    
   // for (int i = 0; i < [languageSources count]; i++) 
     //   [[languageSources objectAtIndex:i] setSelected:FALSE];
    
    for (int i = 0; i < [boundSources count]; i++)
        [[boundSources objectAtIndex:i] setSelected:FALSE];
}

- (BOOL) itemSelectedInArray:(NSMutableArray *)array
{
    for (int i = 0; i < [array count]; i++)
        if ([[array objectAtIndex:i] selected])
            return YES;

    return NO;
}

#pragma mark - Gesture Recognizers
-(void)feedFlagTapped:(UIGestureRecognizer*)sender
{
    int row = sender.view.tag;
    BOOL selected = [[feedsForLanguagesSelected objectAtIndex:row] flag_selected];
    [[feedsForLanguagesSelected objectAtIndex:row] setFlag_selected:!selected];
    [tableView reloadData];
}

#pragma mark - Language

-(void)updateLanguagesSelected
{
    [languagesSelected removeAllObjects];
    for (int i = 0; i < [languageSources count]; i++) {
        if ([[languageSources objectAtIndex:i] selected]) {
            [languagesSelected addObject:[[languageSources objectAtIndex:i] lang_code]];
        }
    }
}

-(CGPoint)updateFeedsForLanguagesSelected
{
    CGPoint offset = self.tableView.contentOffset;
    int origNumFeeds = [feedsForLanguagesSelected count];
    
    [feedsForLanguagesSelected removeAllObjects];
    
    for (int i = 0; i < [feedSources count]; i++) {
        if ([languagesSelected containsObject:[[feedSources objectAtIndex:i] lang_code]]) {
            [feedsForLanguagesSelected addObject:[feedSources objectAtIndex:i]];
        }
    }
    
    int numFeeds = [feedsForLanguagesSelected count];
    
    float cellHeight = [self.tableView rowHeight];
    
    if (numFeeds > origNumFeeds) {
        offset.y += (numFeeds - origNumFeeds)*cellHeight;
    } else {
        offset.y -= (origNumFeeds - numFeeds)*cellHeight;
    }
    
    return offset;
}

-(void)setSelected:(BOOL)selected ForFeedAtRow:(int) row
{
    for (int i = 0; i < [feedSources count]; i++) {
        if ([[[feedSources objectAtIndex:i] name] isEqualToString:[[feedsForLanguagesSelected objectAtIndex:row] name]]) {
            [[feedSources objectAtIndex:i] setSelected:selected];
            break;
        }
    }
}
         
- (void) setEnglishSelected
{
    for (int i = 0; i < [languageSources count]; i++) {
        if ([[[languageSources objectAtIndex:i] lang_code] isEqualToString:@"en"]) {
            [[languageSources objectAtIndex:i] setSelected:YES];
            break;
        }
    }
    
    [languagesSelected removeAllObjects];
    [languagesSelected addObject:@"en"];
}

#pragma mark - Table View Delegate

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    int row = [indexPath row];
    int section = [indexPath section];
    
    CGPoint offset = self.tableView.contentOffset;
    
    changedSources = TRUE;
    
    if (section == 0) {  // All Sources
        [self setAllSourceArraysUnselected];
        [[allSources objectAtIndex:row] setSelected:TRUE];
        sourcesSelected = allSourcesSelected;
    } else if (section == 1) {  // Feed Sources
        if (sourcesSelected != feedSourcesSelected) {
            [self setAllSourceArraysUnselected];
        }
        [[feedsForLanguagesSelected objectAtIndex:row] setSelected:![[feedsForLanguagesSelected objectAtIndex:row] selected]];
        if ([self itemSelectedInArray:feedsForLanguagesSelected])
            sourcesSelected = feedSourcesSelected;
        else {
            [[allSources objectAtIndex:0] setSelected:TRUE];
            sourcesSelected = allSourcesSelected;
        }
        
        [self setSelected:[[feedsForLanguagesSelected objectAtIndex:row] selected] ForFeedAtRow:row];
    } else if (section == 2) {  // Add Source
        AddFeedViewController *addFeedViewController = [[AddFeedViewController alloc] initWithFeeds:feedSources andCountries:countries];
        [self.navigationController pushViewController:addFeedViewController animated:YES];
    } else if (section == 3) { // Country Sources
        if (sourcesSelected != countrySourcesSelected)
           [self setAllSourceArraysUnselected];
        
        [[countrySources objectAtIndex:row] setSelected:![[countrySources objectAtIndex:row] selected]];
        if ([self itemSelectedInArray:countrySources])
            sourcesSelected = countrySourcesSelected;
        else {
            [[allSources objectAtIndex:0] setSelected:TRUE];
            sourcesSelected = allSourcesSelected;
        }
    } else if (section == 4) {  // Language Source
        if ([[languageSources objectAtIndex:row] selected]) {
            [[languageSources objectAtIndex:row] setSelected:NO];
            
            BOOL languageSelected = FALSE;
            for (int i = 0; i < [languageSources count]; i++) {
                if ([[languageSources objectAtIndex:i] selected]) {
                    languageSelected = TRUE;
                }
            }
            
            if (!languageSelected)
                [self setEnglishSelected];
        } else {
            [[languageSources objectAtIndex:row] setSelected:YES];
        }
        
        [self updateLanguagesSelected];
        offset = [self updateFeedsForLanguagesSelected];
        
        BOOL feedsSelectedForLanguagesSelected = FALSE;
        for (int i = 0; i < [feedsForLanguagesSelected count]; i++) {
            if ([[feedsForLanguagesSelected objectAtIndex:i] selected]) 
                feedsSelectedForLanguagesSelected = TRUE;
        }
            
        if (feedsSelectedForLanguagesSelected) 
            sourcesSelected = feedSourcesSelected;
        else 
            sourcesSelected = allSourcesSelected;
        
    } else { // Bounding Sources
        ViewController *viewController = [[self.navigationController viewControllers] objectAtIndex:0];
        if (row == 0) {
            BoundingBoxViewController *boundingBoxViewController = [[BoundingBoxViewController alloc] initWithHandMode:[viewController handMode] andIsPad:[viewController isPad]];
            [self.navigationController pushViewController:boundingBoxViewController animated:YES];
        } else if (sourcesSelected && row == 1) { //Edit Region
            for (Source *currentBoundSource in boundSources) {
                if ([currentBoundSource selected]) {
                    BoundingBoxViewController *boundingBoxViewController = [[BoundingBoxViewController alloc] initWithSource:currentBoundSource andHandMode:[viewController handMode] andIsPad:[viewController isPad]];
                    [self.navigationController pushViewController:boundingBoxViewController animated:YES];
                    break;
                }
            }
        } else {
            if (sourcesSelected == boundSourcesSelected) { //Selected Must Unselect
                [[boundSources objectAtIndex:(row-2)] setSelected:NO];
                [[allSources objectAtIndex:0] setSelected:TRUE];
                
                sourcesSelected = allSourcesSelected;
            } else { //Unselect set selected
                [self setAllSourceArraysUnselected];
                [[boundSources objectAtIndex:(row-1)] setSelected:YES];
                
                sourcesSelected = boundSourcesSelected;
            }
        }
    } 
    
    [self.tableView reloadData];
    [self.tableView setContentOffset:offset];
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    int section = [indexPath section];
    int row = [indexPath row];
    
    if (section == 1 || (section == 4 && ((sourcesSelected == boundSourcesSelected && row > 1) || (sourcesSelected != boundSourcesSelected && row > 0))))
        return YES;
    
    return NO;
}

- (void)tableView:(UITableView *)localTableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    int section = [indexPath section];
    int row = [indexPath row];
    
    if (section == 1)
    {
        if (editingStyle == UITableViewCellEditingStyleDelete) {
            [feedSources removeObjectAtIndex:row];
            if (![self itemSelectedInArray:feedSources]) {
                [[allSources objectAtIndex:0] setSelected:YES];
                sourcesSelected = allSourcesSelected;
            }
        }		
    } else if ([indexPath section] == 4)
    {	 
        if (sourcesSelected == boundSourcesSelected) {
            if ([[boundSources objectAtIndex:(row-2)] selected]) {
                [[allSources objectAtIndex:0] setSelected:YES];
                sourcesSelected = allSourcesSelected;
            }
            [boundSources removeObjectAtIndex:(row-2)];
        } else {
            if ([[boundSources objectAtIndex:(row-1)] selected]) {
                [[allSources objectAtIndex:0] setSelected:YES];
                sourcesSelected = allSourcesSelected;
            }
            [boundSources removeObjectAtIndex:(row-1)];
        }
    }
    changedSources = YES;
    [tableView reloadData];
}

#pragma mark - Initialization & Memory


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

#pragma mark - Edit Button
//Buttons
- (void) editButtonPressed
{
    if (!editEnabled) {
		[tableView setEditing:YES animated:YES];
		editEnabled = YES;
	} else {
		[tableView setEditing:NO animated: YES];
		editEnabled = NO;
	}
}

#pragma mark - View lifecycle

- (void)setupNavigationBar
{
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStyleDone target:self action:@selector(editButtonPressed)]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTitle:@"Sources"];
    [self setupNavigationBar];
    [self initializeCountries];
}

- (void) updateViewController
{
    ViewController *viewController = [self.navigationController.viewControllers objectAtIndex:0];
    [viewController setAllSources:allSources];
    [viewController setFeedSources:feedSources];
    [viewController setCountrySources:countrySources];
    [viewController setLanguageSources:languageSources];
    [viewController setBoundSources:boundSources];
    
    [viewController setSourcesSelected:sourcesSelected];
    [viewController setLanguagesSelected:languagesSelected];
    
    [viewController setSourceAndCancelButton];
}

- (void)viewWillAppear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:YES];
    [[self.navigationController navigationBar] setBarStyle:UIBarStyleBlackOpaque];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    
    ViewController *viewController = [self.navigationController.viewControllers objectAtIndex:0];
    allSources = [[NSMutableArray alloc] initWithArray:[viewController allSources]];
    feedSources = [[NSMutableArray alloc] initWithArray:[viewController feedSources]];
    countrySources = [[NSMutableArray alloc] initWithArray:[viewController countrySources]];
    languageSources = [[NSMutableArray alloc] initWithArray:[viewController languageSources]];
    boundSources = [[NSMutableArray alloc] initWithArray:[viewController boundSources]];

    languagesSelected = [[NSMutableArray alloc] init];
    feedsForLanguagesSelected = [[NSMutableArray alloc] init];
    
    [self updateLanguagesSelected];
    [self updateFeedsForLanguagesSelected];
    
    NSLog(@"Bound source count %d", [boundSources count]);
    
    sourcesSelected = [viewController sourcesSelected];
    [self setAllSourcesUnselectedExceptSelected];
    [tableView reloadData];
}
     
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (changedSources)
        [self updateViewController];
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

#pragma mark - Initialize Countries (the long/quick way)
-(void)initializeCountries
{
    countries = [[NSMutableArray alloc] init];
    [countries addObject:[[Country alloc] initWithCountryCode:@"AF" andName:@"Afghanistan" andNativeName:@"افغانستان"]];
    [countries addObject:[[Country alloc] initWithCountryCode:@"AL" andName:@"Albania" andNativeName:@"Shqipëri"]];
    [countries addObject:[[Country alloc] initWithCountryCode:@"DZ" andName:@"Algeria" andNativeName:@"الجزائر‎,"]];
    [countries addObject:[[Country alloc] initWithCountryCode:@"AF" andName:@"Angola" andNativeName:@""]];
    [countries addObject:[[Country alloc] initWithCountryCode:@"AR" andName:@"Argentina" andNativeName:@""]];
    [countries addObject:[[Country alloc] initWithCountryCode:@"AU" andName:@"Australia" andNativeName:@""]];
    [countries addObject:[[Country alloc] initWithCountryCode:@"AT" andName:@"Austria" andNativeName:@"Österreich"]];
    [countries addObject:[[Country alloc] initWithCountryCode:@"BD" andName:@"Bangladesh" andNativeName:@"বাংলাদেশ"]];
    [countries addObject:[[Country alloc] initWithCountryCode:@"BE" andName:@"Belgium" andNativeName:@"België"]];
    [countries addObject:[[Country alloc] initWithCountryCode:@"BY" andName:@"Belarus" andNativeName:@"Беларусь"]];
    [countries addObject:[[Country alloc] initWithCountryCode:@"BO" andName:@"Bolivia" andNativeName:@""]];
    [countries addObject:[[Country alloc] initWithCountryCode:@"BR" andName:@"Brazil" andNativeName:@"Brasil"]];
    [countries addObject:[[Country alloc] initWithCountryCode:@"BG" andName:@"Bulgaria" andNativeName:@"اБългария"]];
    [countries addObject:[[Country alloc] initWithCountryCode:@"KH" andName:@"Cambodia" andNativeName:@"ព្រះរាជាណាចក្រកម្ពុជា"]];
    [countries addObject:[[Country alloc] initWithCountryCode:@"CA" andName:@"Canada" andNativeName:@""]];
    [countries addObject:[[Country alloc] initWithCountryCode:@"TD" andName:@"Chad" andNativeName:@"Tchad"]];
    [countries addObject:[[Country alloc] initWithCountryCode:@"CL" andName:@"Chile" andNativeName:@""]];
    [countries addObject:[[Country alloc] initWithCountryCode:@"CN" andName:@"China" andNativeName:@"中国"]];
    [countries addObject:[[Country alloc] initWithCountryCode:@"CO" andName:@"Colombia" andNativeName:@""]];
    [countries addObject:[[Country alloc] initWithCountryCode:@"CR" andName:@"Costa Rica" andNativeName:@""]];
    [countries addObject:[[Country alloc] initWithCountryCode:@"CU" andName:@"Cuba" andNativeName:@""]];
    [countries addObject:[[Country alloc] initWithCountryCode:@"CZ" andName:@"Czech Republic" andNativeName:@"Česká republika"]];
    [countries addObject:[[Country alloc] initWithCountryCode:@"CD" andName:@"Democratic Republic of Congo" andNativeName:@"République démocratique du Congo"]];
    [countries addObject:[[Country alloc] initWithCountryCode:@"DK" andName:@"Denmark" andNativeName:@"Danmark"]];
    
    [countries addObject:[[Country alloc] initWithCountryCode:@"DO" andName:@"Dominican Republic" andNativeName:@"República Dominicana"]];
    [countries addObject:[[Country alloc] initWithCountryCode:@"EC" andName:@"Ecuador" andNativeName:@""]];
    [countries addObject:[[Country alloc] initWithCountryCode:@"EG" andName:@"Egypt" andNativeName:@"مصر‎"]];
    [countries addObject:[[Country alloc] initWithCountryCode:@"SV" andName:@"El Salvador" andNativeName:@""]];
    [countries addObject:[[Country alloc] initWithCountryCode:@"EE" andName:@"Estonia" andNativeName:@"Eesti Vabariik"]];
    [countries addObject:[[Country alloc] initWithCountryCode:@"ET" andName:@"Ethiopia" andNativeName:@"ኢትዮጵያ"]];
    [countries addObject:[[Country alloc] initWithCountryCode:@"FJ" andName:@"Fiji" andNativeName:@"Viti"]];
    [countries addObject:[[Country alloc] initWithCountryCode:@"FI" andName:@"Finland" andNativeName:@"Suomi"]];
    [countries addObject:[[Country alloc] initWithCountryCode:@"FR" andName:@"France" andNativeName:@"Française"]];
    [countries addObject:[[Country alloc] initWithCountryCode:@"GE" andName:@"Georgia" andNativeName:@"საქართველო"]];
    [countries addObject:[[Country alloc] initWithCountryCode:@"DE" andName:@"Germany" andNativeName:@"Deutschland"]];
    
    [countries addObject:[[Country alloc] initWithCountryCode:@"GH" andName:@"Ghana" andNativeName:@""]];
    [countries addObject:[[Country alloc] initWithCountryCode:@"GR" andName:@"Greece" andNativeName:@"Ελλάδα"]];
    [countries addObject:[[Country alloc] initWithCountryCode:@"GU" andName:@"Guam" andNativeName:@"Guåhån"]];
    [countries addObject:[[Country alloc] initWithCountryCode:@"GT" andName:@"Guatemala" andNativeName:@""]];
    [countries addObject:[[Country alloc] initWithCountryCode:@"GY" andName:@"Guyana" andNativeName:@""]];
    [countries addObject:[[Country alloc] initWithCountryCode:@"HT" andName:@"Haiti" andNativeName:@"Haïti"]];
    [countries addObject:[[Country alloc] initWithCountryCode:@"HN" andName:@"Honduras" andNativeName:@""]];
    [countries addObject:[[Country alloc] initWithCountryCode:@"HK" andName:@"Hong Kong" andNativeName:@"香港"]];
    [countries addObject:[[Country alloc] initWithCountryCode:@"HU" andName:@"Hungary" andNativeName:@"Magyarország"]];
    [countries addObject:[[Country alloc] initWithCountryCode:@"IS" andName:@"Iceland" andNativeName:@"Ísland"]];
    [countries addObject:[[Country alloc] initWithCountryCode:@"IN" andName:@"India" andNativeName:@"Bhārat Gaṇarājya"]];
    [countries addObject:[[Country alloc] initWithCountryCode:@"ID" andName:@"Indonesia" andNativeName:@""]];
    [countries addObject:[[Country alloc] initWithCountryCode:@"IR" andName:@"Iran" andNativeName:@"ایران"]];
    [countries addObject:[[Country alloc] initWithCountryCode:@"IQ" andName:@"Iraq" andNativeName:@"العراق‎"]];
    [countries addObject:[[Country alloc] initWithCountryCode:@"IE" andName:@"Ireland" andNativeName:@"Éire"]];
    [countries addObject:[[Country alloc] initWithCountryCode:@"IM" andName:@"Isle of Man" andNativeName:@"Ellan Vannin"]];
    [countries addObject:[[Country alloc] initWithCountryCode:@"IL" andName:@"Israel" andNativeName:@"מְדִינַת יִשְׂרָאֵל"]];
    [countries addObject:[[Country alloc] initWithCountryCode:@"IT" andName:@"Italy" andNativeName:@"Italia"]];
    [countries addObject:[[Country alloc] initWithCountryCode:@"CI" andName:@"Ivory Coast" andNativeName:@"Côte d'Ivoire"]];
    [countries addObject:[[Country alloc] initWithCountryCode:@"JM" andName:@"Jamaica" andNativeName:@""]];
    [countries addObject:[[Country alloc] initWithCountryCode:@"JP" andName:@"Japan" andNativeName:@"日本"]];
    [countries addObject:[[Country alloc] initWithCountryCode:@"JO" andName:@"Jordan" andNativeName:@"اَلأُرْدُنّ"]];
    [countries addObject:[[Country alloc] initWithCountryCode:@"KZ" andName:@"Kazakhstan" andNativeName:@"Қазақстан"]];
    [countries addObject:[[Country alloc] initWithCountryCode:@"KE" andName:@"Kenya" andNativeName:@""]];
    [countries addObject:[[Country alloc] initWithCountryCode:@"KG" andName:@"Krygyzstan" andNativeName:@"Киргизия"]];
    [countries addObject:[[Country alloc] initWithCountryCode:@"LV" andName:@"Latvia" andNativeName:@"Latvija"]];
    [countries addObject:[[Country alloc] initWithCountryCode:@"LB" andName:@"Lebanon" andNativeName:@"لبنان‎"]];
    [countries addObject:[[Country alloc] initWithCountryCode:@"LS" andName:@"Lesotho" andNativeName:@""]];
    [countries addObject:[[Country alloc] initWithCountryCode:@"LY" andName:@"Libya" andNativeName:@"ليبيا‎"]];
    [countries addObject:[[Country alloc] initWithCountryCode:@"LT" andName:@"Lithuania" andNativeName:@"Lietuva"]];
    [countries addObject:[[Country alloc] initWithCountryCode:@"LU" andName:@"Luxembourg" andNativeName:@"Groussherzogtum Lëtzebuerg"]];
    [countries addObject:[[Country alloc] initWithCountryCode:@"MO" andName:@"Macau" andNativeName:@"澳門"]];
    [countries addObject:[[Country alloc] initWithCountryCode:@"MY" andName:@"Malaysia" andNativeName:@""]];
    [countries addObject:[[Country alloc] initWithCountryCode:@"MT" andName:@"Malta" andNativeName:@""]];
    [countries addObject:[[Country alloc] initWithCountryCode:@"MX" andName:@"Mexico" andNativeName:@"México"]];
    [countries addObject:[[Country alloc] initWithCountryCode:@"MD" andName:@"Moldova" andNativeName:@""]];
    [countries addObject:[[Country alloc] initWithCountryCode:@"MA" andName:@"Morocco" andNativeName:@"المغرب‎"]];
    [countries addObject:[[Country alloc] initWithCountryCode:@"NA" andName:@"Namibia" andNativeName:@"Republiek van Namibië"]];
    [countries addObject:[[Country alloc] initWithCountryCode:@"NP" andName:@"Nepal" andNativeName:@"नेपाल"]];
    [countries addObject:[[Country alloc] initWithCountryCode:@"NL" andName:@"Netherlands" andNativeName:@"Nederland"]];
    [countries addObject:[[Country alloc] initWithCountryCode:@"NZ" andName:@"New Zealand" andNativeName:@"Aotearoa"]];
    [countries addObject:[[Country alloc] initWithCountryCode:@"NI" andName:@"Nicaragua" andNativeName:@""]];
    [countries addObject:[[Country alloc] initWithCountryCode:@"PK" andName:@"Pakistan" andNativeName:@"پاکستان"]];
    [countries addObject:[[Country alloc] initWithCountryCode:@"PA" andName:@"Panama" andNativeName:@"Panamá"]];
    [countries addObject:[[Country alloc] initWithCountryCode:@"PY" andName:@"Paraguay" andNativeName:@""]];
    [countries addObject:[[Country alloc] initWithCountryCode:@"PE" andName:@"Peru" andNativeName:@"Perú"]];
    [countries addObject:[[Country alloc] initWithCountryCode:@"PH" andName:@"Phillipines" andNativeName:@"Pilipinas"]];
    [countries addObject:[[Country alloc] initWithCountryCode:@"PT" andName:@"Portugal" andNativeName:@""]];
    [countries addObject:[[Country alloc] initWithCountryCode:@"PR" andName:@"Puerto Rico" andNativeName:@""]];
    [countries addObject:[[Country alloc] initWithCountryCode:@"QA" andName:@"Qatar" andNativeName:@"قطر‎"]];
    [countries addObject:[[Country alloc] initWithCountryCode:@"RU" andName:@"Russia" andNativeName:@"Россия"]];
    [countries addObject:[[Country alloc] initWithCountryCode:@"RW" andName:@"Rwanda" andNativeName:@""]];
    [countries addObject:[[Country alloc] initWithCountryCode:@"SA" andName:@"Saudi Arabia" andNativeName:@"السعودية‎"]];
    [countries addObject:[[Country alloc] initWithCountryCode:@"SG" andName:@"Singapore" andNativeName:@""]];
    [countries addObject:[[Country alloc] initWithCountryCode:@"SO" andName:@"Somalia" andNativeName:@"Soomaaliya"]];
    [countries addObject:[[Country alloc] initWithCountryCode:@"ZA" andName:@"South Africa" andNativeName:@""]];
    [countries addObject:[[Country alloc] initWithCountryCode:@"KR" andName:@"South Korea" andNativeName:@"대한민국"]];
    [countries addObject:[[Country alloc] initWithCountryCode:@"ES" andName:@"Spain" andNativeName:@"España"]];
    [countries addObject:[[Country alloc] initWithCountryCode:@"LK" andName:@"Sri Lanka" andNativeName:@"ශ්‍රී ලංකාව"]];
    [countries addObject:[[Country alloc] initWithCountryCode:@"SJ" andName:@"Svalbard and Jan Mayen" andNativeName:@""]];
    [countries addObject:[[Country alloc] initWithCountryCode:@"SE" andName:@"Sweden" andNativeName:@"Sverige"]];
    [countries addObject:[[Country alloc] initWithCountryCode:@"CH" andName:@"Switzerland" andNativeName:@"Schweiz"]];
    [countries addObject:[[Country alloc] initWithCountryCode:@"TW" andName:@"Taiwan" andNativeName:@"臺灣"]];
    [countries addObject:[[Country alloc] initWithCountryCode:@"TJ" andName:@"Tajikistan" andNativeName:@"Республика"]];
    [countries addObject:[[Country alloc] initWithCountryCode:@"TH" andName:@"Thailand" andNativeName:@"ประเทศไทย"]];
    [countries addObject:[[Country alloc] initWithCountryCode:@"TT" andName:@"Trinidad and Tobago" andNativeName:@""]];
    [countries addObject:[[Country alloc] initWithCountryCode:@"TN" andName:@"Tunisia" andNativeName:@"تونس‎"]];
    [countries addObject:[[Country alloc] initWithCountryCode:@"UG" andName:@"Uganda" andNativeName:@""]];
    [countries addObject:[[Country alloc] initWithCountryCode:@"UA" andName:@"Ukraine" andNativeName:@"Україна"]];
    [countries addObject:[[Country alloc] initWithCountryCode:@"AE" andName:@"UAE" andNativeName:@"دولة الإمارات العربية المتحدة‎"]];
    [countries addObject:[[Country alloc] initWithCountryCode:@"GB" andName:@"United Kingdom" andNativeName:@""]];
    [countries addObject:[[Country alloc] initWithCountryCode:@"US" andName:@"United States" andNativeName:@""]];
    [countries addObject:[[Country alloc] initWithCountryCode:@"UY" andName:@"Uruguay" andNativeName:@""]];
    [countries addObject:[[Country alloc] initWithCountryCode:@"UZ" andName:@"Uzbekistan" andNativeName:@"Ўзбекистон Республикаси"]];
    [countries addObject:[[Country alloc] initWithCountryCode:@"VE" andName:@"Venezuela" andNativeName:@""]];
    [countries addObject:[[Country alloc] initWithCountryCode:@"EH" andName:@"Western Sahara" andNativeName:@"الصحراء الغربية"]];
    [countries addObject:[[Country alloc] initWithCountryCode:@"YE" andName:@"Yemen" andNativeName:@"الجمهورية اليمنية"]];
    [countries addObject:[[Country alloc] initWithCountryCode:@"ZW" andName:@"Zimbabwe" andNativeName:@""]];
}

@end
