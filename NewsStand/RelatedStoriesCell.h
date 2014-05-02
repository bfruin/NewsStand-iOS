//
//  RelatedStoriesCell.h
//  NewsStand
//
//  Created by Brendan Fruin on 11/26/12.
//
//

#import <UIKit/UIKit.h>

@interface RelatedStoriesCell : UITableViewCell
{
    UILabel * domainLabel;
    UILabel * descriptionLabel;
    UILabel * timeLabel;

    IBOutlet UIButton *linkButton;
    UIImageView * topicImageView;
}

@property(strong, nonatomic) IBOutlet UILabel * domainLabel;
@property(strong, nonatomic) IBOutlet UILabel * descriptionLabel;
@property(strong, nonatomic) IBOutlet UILabel * timeLabel;

@property (strong, nonatomic) IBOutlet UIButton *linkButton;
@property (strong, nonatomic) IBOutlet UIImageView * topicImageView;

-(IBAction)linkButtonPushed:(id)sender;
-(IBAction)cellSelected:(id)sender;

@end
