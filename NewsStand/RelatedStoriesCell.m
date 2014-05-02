//
//  RelatedStoriesCell.m
//  NewsStand
//
//  Created by Brendan Fruin on 11/26/12.
//
//

#import "RelatedStoriesCell.h"
#import "AppDelegate.h"
#import "ViewController.h"
#import "RelatedStoriesViewController.h"

@implementation RelatedStoriesCell

@synthesize domainLabel, descriptionLabel, timeLabel;
@synthesize linkButton, topicImageView;

- (IBAction)linkButtonPushed:(id)sender
{
	NSLog( @"Link button pushed! Row %d", [sender tag]);
	AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    RelatedStoriesViewController *relatedStoriesViewController = (RelatedStoriesViewController *)[[[appDelegate navigationController] viewControllers] lastObject];
    
    int row = [sender tag];
    [relatedStoriesViewController titleButtonPressedOnRow:row];
}

- (IBAction) cellSelected:(id)sender
{
	
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
