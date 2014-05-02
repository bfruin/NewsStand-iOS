//
//  NewFeed.h
//  NewsStand
//
//  Created by Hanan Samet on 1/23/12.
//  Copyright (c) 2012 University of Maryland. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NewFeed : NSObject
{
    NSString *name;
    int feed_link;
    NSString *language;
    NSString *country_code;
    
    NSString *country_name;
    NSString *native_name;
}

@property (strong, nonatomic) NSString *name;
@property (nonatomic, readwrite) int feed_link;
@property (strong, nonatomic) NSString *language;
@property (strong, nonatomic) NSString *country_code;

@property (strong, nonatomic) NSString *country_name;
@property (strong, nonatomic) NSString *native_name;

@end
