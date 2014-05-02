//
//  VideosCell.h
//  NewsStand
//
//  Created by Brendan Christopher Fruin on 8/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JMImageCache.h"

@interface VideosCell : UITableViewCell <JMImageCacheDelegate> {
	IBOutlet UIImageView *imageViewer;
	IBOutlet UILabel *title;
	IBOutlet UILabel *duration;
	IBOutlet UILabel *pub_date;
	IBOutlet UILabel *domain;
    
    NSString *image_url;
}

@property (strong, nonatomic) IBOutlet UIImageView *imageViewer;
@property (strong, nonatomic) IBOutlet UILabel *title;
@property (strong, nonatomic) IBOutlet UILabel *duration;
@property (strong, nonatomic) IBOutlet UILabel *pub_date;
@property (strong, nonatomic) IBOutlet UILabel *domain;

@property (strong, nonatomic) NSString *image_url;

@end
