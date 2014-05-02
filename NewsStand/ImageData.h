//
//  ImageData.h
//  NewsStand
//
//  Created by Brendan on 1/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageData : NSObject
{
    NSString *imageURL;
    NSString *pageURL;
    NSString *caption;
    
    int height;
    int width;
    
    int cluster_id;
    int image_cluster_id;
    float cluster_score;
    
    BOOL isDupe;
}

@property (strong, nonatomic) NSString *imageURL;
@property (strong, nonatomic) NSString *pageURL;
@property (strong, nonatomic) NSString *caption;

@property (nonatomic, readwrite) int height;
@property (nonatomic, readwrite) int width;

@property (nonatomic, readwrite) int cluster_id;
@property (nonatomic, readwrite) int image_cluster_id;
@property (nonatomic, readwrite) float cluster_score;

@property (nonatomic, readwrite) BOOL isDupe;

- (NSComparisonResult)compare:(ImageData *)otherObject;

@end
