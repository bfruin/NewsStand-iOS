//
//  ImageData.m
//  NewsStand
//
//  Created by Brendan on 1/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ImageData.h"

@implementation ImageData

@synthesize imageURL, pageURL, caption;
@synthesize height, width;
@synthesize cluster_id, image_cluster_id, cluster_score;
@synthesize isDupe;

- (NSComparisonResult) compare:(ImageData *)otherObject
{
    NSNumber *currentImageClusterScore = [[NSNumber alloc] initWithFloat:cluster_score];
    NSNumber *otherImageClusterScore = [[NSNumber alloc] initWithFloat:[otherObject cluster_score]];
    
    return [otherImageClusterScore compare:currentImageClusterScore];
}

@end
