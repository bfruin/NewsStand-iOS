//
//  VideoViewController.m
//  NewsStand
//
//  Created by Hanan Samet on 1/19/12.
//  Copyright (c) 2012 University of Maryland. All rights reserved.
//

#import "VideoViewController.h"
#import "CustomWebView.h"
#import "VideoRequestOperation.h"
#import "JMImageCache.h"
#import "ViewController.h"

@implementation VideoViewController
@synthesize currentVideo, videosData;
@synthesize cluster_id;
@synthesize queue;

#pragma mark - Initialization

- (id) initWithClusterID:(int)num 
{
    if (self = [super init]) {
        cluster_id = num;
    }
    
    [self beginParsing];
    return self;
}

- (id) initWithClusterID:(int)num andStandMode:(int)mode
{
    if (self = [super init]) {
        cluster_id = num;
        standMode = mode;
    }
    
    [self beginParsing];
    return self;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [[JMImageCache sharedCache] removeAllObjects];
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTitle:@"Videos"];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    [[self.navigationController navigationBar] setBarStyle:UIBarStyleDefault];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[JMImageCache sharedCache] removeAllObjects];
    [queue cancelAllOperations];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [videosData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"VideoCell";
    int row = [indexPath row];
    
    VideosCell *cell = (VideosCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"VideosCell" owner:nil options:nil];
        for (id currentObject in topLevelObjects) {
            if ([currentObject isKindOfClass:[UITableViewCell class]]) {
                cell = (VideosCell *)currentObject;
                break;
            }
        }
    }
    
    VideoData *currVideo = [videosData objectAtIndex:row];
    
    [cell setImage_url:[currVideo img_url]];
    [cell.imageViewer setImage:[[JMImageCache sharedCache] imageForURL:[currVideo img_url] delegate:cell]];
    
        
    [[cell title] setText:[currVideo title]];
    [[cell duration] setText:[currVideo length]];
    [[cell pub_date] setText:[currVideo pub_date]];
    if ([currVideo feed_name] != nil && ![[currVideo feed_name] isEqualToString:@""])
        [[cell domain] setText:[currVideo feed_name]];
    else
        [[cell domain] setText:[currVideo domain]];
    
    return cell;
}

-(CGFloat) tableView:(UITableView *)aTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self tableView: aTableView cellForRowAtIndexPath:indexPath];
    return cell.bounds.size.height;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CustomWebView *customWebView = [[CustomWebView alloc] initWithString:[[videosData objectAtIndex:[indexPath row]] story_url] andTitle:@"News"];
    [self.navigationController pushViewController:customWebView animated:YES];
}

#pragma mark - Parsing
- (void)beginParsing
{
    NSString *urlRequestString;
    if (standMode == 0) {
        urlRequestString = [[NSString alloc] initWithFormat:@"http://newsstand.umiacs.umd.edu/news/xml_videos?cluster_id=%d", cluster_id];
    } else {
        urlRequestString = [[NSString alloc] initWithFormat:@"http://twitterstand.umiacs.umd.edu/news/xml_videos?cluster_id=%d", cluster_id];
    }
    NSLog(@"Video request: %@", urlRequestString);

    videosData = [[NSMutableArray alloc] init];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    queue = [[NSOperationQueue alloc] init];
    
    VideoRequestOperation *videoRequestOperation = [[VideoRequestOperation alloc] initWithRequestString:urlRequestString andVideoViewController:self];
    [queue addOperation:videoRequestOperation];
}

- (void)parseEnded:(NSMutableArray *)videos
{
    videosData = [[NSMutableArray alloc] initWithArray:videos];
    [self.tableView reloadData];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}



@end
