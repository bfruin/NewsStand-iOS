//
//  TopMarkersRequestOperation.m
//  NewsStand
//
//  Created by Hanan Samet on 1/12/12.
//  Copyright (c) 2012 University of Maryland. All rights reserved.
//

#import "TopMarkersRequestOperation.h"
#import "AppDelegate.h"

@implementation TopMarkersRequestOperation

@synthesize requestString;

- (id)initWithRequestString:(NSString *)request andRequestID:(int)idOfRequest andTopStories:(TopStoriesViewController *)topStories
{
    if (self = [super init]) {
        requestString = request;
        requestID = idOfRequest;
        topStoriesViewController = topStories;
    }
    return self;
}

- (void) main
{
    NSLog(@"Getting markers from url: %@", requestString);
    
    NSURL *url = [NSURL URLWithString:requestString];
    NSData *dataXML = [[NSData alloc] initWithContentsOfURL:url];
    NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithData:dataXML];
    
    if (topStoriesViewController == nil) {
        return;
    }
    
    [topStoriesViewController performSelectorOnMainThread:@selector(refreshCallback:) withObject:xmlParser waitUntilDone:NO];
    
}

@end
