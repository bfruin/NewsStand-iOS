//
//  TopMarkersRequestOperation.h
//  NewsStand
//
//  Created by Hanan Samet on 1/12/12.
//  Copyright (c) 2012 University of Maryland. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TopStoriesViewController.h"

@interface TopMarkersRequestOperation : NSOperation
{
    NSString *requestString;
    int requestID;
    TopStoriesViewController *topStoriesViewController;
}

@property (strong, nonatomic) NSString *requestString;

-(id)initWithRequestString:(NSString *)request andRequestID:(int)idOfRequest andTopStories:(TopStoriesViewController*)topStories;

@end
