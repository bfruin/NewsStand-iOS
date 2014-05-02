//
//  RelatedStoriesViewController.m
//  NewsStand
//
//  Created by Hanan Samet on 11/26/12.
//
//

#import "RelatedStoriesViewController.h"
#import "RelatedStoriesCell.h"

@interface RelatedStoriesViewController ()

@end

@implementation RelatedStoriesViewController

@synthesize tableView, mapView;
@synthesize annotations, incomingAnnotations;
@synthesize refreshButton, plusButton, minusButton;
@synthesize motionManager;
@synthesize currentMarker, markers;
@synthesize queue, currentString, parser;

#pragma mark - Initialization and Memory Management
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View Delegate & Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [annotations count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"";
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int row = [indexPath row];
    
    RelatedStoriesCell *cell = [aTableView dequeueReusableCellWithIdentifier:@"RelatedStoriesCell"];
    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"TopStoriesCell" owner:nil options:nil];
        for (id currentObject in topLevelObjects) {
            if ([currentObject isKindOfClass:[UITableViewCell class]]) {
                cell = (RelatedStoriesCell *)currentObject;
                break;
            }
        }
    }
    
    NewsAnnotation *currAnnotation = [annotations objectAtIndex:row];
    if (![currAnnotation display_translate_title])
        [[cell linkButton] setTitle:[currAnnotation subtitle] forState:UIControlStateNormal];
    else
        [[cell linkButton] setTitle:[currAnnotation translate_title] forState:UIControlStateNormal];
    
    [[cell timeLabel] setText:[currAnnotation time]];
    [[cell domainLabel] setText:[currAnnotation domain]];
    
    cell.linkButton.tag = row;
    [[cell descriptionLabel] setText:[currAnnotation description]];
    
    NSString * imageName = @"";
    if ([[currAnnotation topic] isEqualToString:@"Health"] || [[currAnnotation topic] isEqualToString:@"Sports"])
        imageName = [currAnnotation.topic stringByAppendingString:@".png"];
    else
        imageName = [currAnnotation.topic stringByAppendingString:@".gif"];
    
	[cell.topicImageView setImage:[UIImage imageNamed:imageName]];
    
    return cell;
}


#pragma mark - ScrollView Delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    int numVisible = [[tableView indexPathsForVisibleRows] count];
    int index, i = 0;
    
    if (hoverIndex > numVisible)
        index = numVisible-1;
    else
        index = hoverIndex;
    
    for (NSIndexPath * path in [tableView indexPathsForVisibleRows]) {
        int row = [path row];
        if (i == index) {
            [tableView selectRowAtIndexPath:path animated:NO scrollPosition:UITableViewScrollPositionNone];
            if (row != lastSelectedRow) {
                [self tableView:tableView didSelectRowAtIndexPath:path];
                lastSelectedRow = row;
            }
        }
        i += 1;
    }
}



#pragma mark - Map Buttons


@end
