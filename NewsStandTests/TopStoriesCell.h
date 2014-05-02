//
//  TopStoriesCell.h
//  NewsStand
//
//  Created by Hanan Samet on 10/31/10.
//  Copyright 2010 University of Maryland. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface TopStoriesCell : UITableViewCell {
	UILabel * domainLabel;
	UILabel * descriptionLabel;
	UILabel * timeLabel;
    
    IBOutlet UIButton *linkButton;
    IBOutlet UIButton *translateButton;
    IBOutlet UIButton *translatePageButton;
	IBOutlet UIButton *imageButton;
	IBOutlet UIButton *videoButton;
	IBOutlet UIButton *relatedButton;
    
	UIButton * detailButton;
	UIImageView * topicImageView;
	

}

- (IBAction)linkButtonPushed:(id)sender;
- (IBAction)translateButtonPressed:(id)sender;
- (IBAction)translatePageButtonPressed:(id)sender;
- (IBAction)imageButtonPushed:(id)sender;
- (IBAction)videoButtonPushed:(id)sender;
- (IBAction)relatedButtonPushed:(id)sender;
- (IBAction)detailButtonPressed:(id)sender;
- (IBAction) cellSelected:(id)sender;

//@property (retain) IBOutlet UILabel * titleLabel;
@property (strong, nonatomic) IBOutlet UILabel * domainLabel;
@property (strong, nonatomic) IBOutlet UILabel * descriptionLabel;
@property (strong, nonatomic) IBOutlet UILabel * timeLabel;

@property (strong, nonatomic) IBOutlet UIButton *linkButton;
@property (strong, nonatomic) IBOutlet UIButton *translateButton;
@property (strong, nonatomic) IBOutlet UIButton *translatePageButton;
@property (strong, nonatomic) IBOutlet UIButton *imageButton;
@property (strong, nonatomic) IBOutlet UIButton *videoButton;
@property (strong, nonatomic) IBOutlet UIButton *relatedButton;
@property (strong, nonatomic) IBOutlet UIButton *detailButton;
@property (strong, nonatomic) IBOutlet UIImageView * topicImageView;



@end
