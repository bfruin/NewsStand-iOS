//
//  VideosCell.m
//  NewsStand
//
//  Created by Brendan Christopher Fruin on 8/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "VideosCell.h"


@implementation VideosCell

@synthesize imageViewer, title, duration, pub_date, domain;
@synthesize image_url;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code.
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state.
}

- (void) cache:(JMImageCache *)c didDownloadImage:(UIImage *)i forURL:(NSString *)url
{
    if ([url isEqualToString:image_url]) {
        [self.imageViewer setImage:i];
        [self setNeedsLayout];
    }
}

@end
