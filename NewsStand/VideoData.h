//
//  VideoData.h
//  NewsStand
//
//  Created by Hanan Samet on 1/19/12.
//  Copyright (c) 2012 University of Maryland. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VideoData : NSObject
{
    //Video URL Attributes
    NSString *img_url; //Preview Image
    NSString *story_url;   //Story URL
   
    //Video Text Attributes
    NSString *title;
    NSString *feed_name;
    NSString *domain;
    NSString *pub_date;
    NSString *length;
}

//Video URL Attributes
@property (strong, nonatomic) NSString *img_url;
@property (strong, nonatomic) NSString *story_url;

//Video Text Attributes
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *feed_name;
@property (strong, nonatomic) NSString *domain;
@property (strong, nonatomic) NSString *pub_date;
@property (strong, nonatomic) NSString *length;

@end
