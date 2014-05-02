//
//  TopStoriesCell.m
//  NewsStand
//
//  Created by Hanan Samet on 10/31/10.
//  Copyright 2010 University of Maryland. All rights reserved.
//

#import "TopStoriesCell.h"
#import "AppDelegate.h"
#import "ViewController.h"
#import "TopStoriesViewController.h"

@implementation TopStoriesCell

@synthesize domainLabel;
@synthesize descriptionLabel;
@synthesize translateButton, translatePageButton, imageButton, videoButton, relatedButton;
@synthesize timeLabel;
@synthesize detailButton;
@synthesize topicImageView;
@synthesize linkButton;


- (IBAction)detailButtonPressed:(id)sender
{
    
}

- (IBAction)linkButtonPushed:(id)sender
{
	NSLog( @"Link button pushed! Row %d", [sender tag]);    
	AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    TopStoriesViewController *topStoriesViewController = (TopStoriesViewController *)[[appDelegate navigationController] topViewController];
    
    int row = [sender tag];
    [topStoriesViewController titleButtonPressedOnRow:row];
}

- (IBAction)translateButtonPressed:(id)sender
{
    NSLog( @"Translate button pushed! Row %d", [sender tag]);    
	AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    TopStoriesViewController *topStoriesViewController = (TopStoriesViewController *)[[appDelegate navigationController] topViewController];
    
    int row = [sender tag];
    [topStoriesViewController translateButtonPressedOnRow:row];
}

- (IBAction)translatePageButtonPressed:(id)sender
{
    NSLog( @"Translate button pushed! Row %d", [sender tag]);    
	AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    TopStoriesViewController *topStoriesViewController = (TopStoriesViewController *)[[appDelegate navigationController] topViewController];
    
    int row = [sender tag];
    [topStoriesViewController translatePageButtonPressedOnRow:row];
}

- (IBAction)imageButtonPushed:(id)sender
{	
	NSLog( @"Image button pushed! Row %d", [sender tag]);
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    TopStoriesViewController *topStoriesViewController = (TopStoriesViewController *)[[appDelegate navigationController] topViewController];
    
    int row = [sender tag];
    [topStoriesViewController imageButtonPressedOnRow:row];
}

- (IBAction)videoButtonPushed:(id)sender
{
    NSLog( @"Video button pushed! Row %d", [sender tag]);
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    TopStoriesViewController *topStoriesViewController = (TopStoriesViewController *)[[appDelegate navigationController] topViewController];
    
    int row = [sender tag];
    [topStoriesViewController videoButtonPressedOnRow:row];
}

- (IBAction)relatedButtonPushed:(id)sender
{
    NSLog( @"Related button pushed!" );
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    TopStoriesViewController *topStoriesViewController = (TopStoriesViewController *)[[appDelegate navigationController] topViewController];
    
    int row = [sender tag];
    [topStoriesViewController relatedButtonPressedOnRow:row];
	
}

- (IBAction) cellSelected:(id)sender
{
	
}


@end
