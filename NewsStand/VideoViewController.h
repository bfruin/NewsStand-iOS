//
//  VideoViewController.h
//  NewsStand
//
//  Created by Hanan Samet on 1/19/12.
//  Copyright (c) 2012 University of Maryland. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VideoData.h"
#import "VideosCell.h"

@interface VideoViewController : UITableViewController
{
    //Current Videos
    VideoData *currentVideo;
    NSMutableArray *videosData;
    
    //Initialization Info
    int cluster_id;
    
    //NSXMLParser
    NSOperationQueue *queue;
    
    int standMode;
}

//Current Videos
@property(strong, nonatomic) VideoData *currentVideo;
@property(strong, nonatomic) NSMutableArray *videosData;

//Initialization Info
@property(nonatomic, readwrite) int cluster_id;

//NSXMLParser
@property(strong, nonatomic) NSOperationQueue *queue;

//Initialization
-(id) initWithClusterID:(int)num;
-(id) initWithClusterID:(int)num andStandMode:(int)mode;

//Parsing
-(void)beginParsing;
-(void)parseEnded:(NSMutableArray*)videos;

@end
