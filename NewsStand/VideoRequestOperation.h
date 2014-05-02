//
//  VideoRequestOperation.h
//  NewsStand
//
//  Created by Hanan Samet on 1/19/12.
//  Copyright (c) 2012 University of Maryland. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VideoViewController.h"
#import "VideosCell.h"

@interface VideoRequestOperation : NSOperation  <NSXMLParserDelegate>
{
    NSString *requestString;
    VideoViewController *videoViewController;
    
    //Video Info
    VideoData *currentVideo;
    NSMutableArray *videosData;
    
    //NSXMLParserDelegate
    NSMutableString *currentString;
    NSXMLParser *parser;
}

@property (strong, nonatomic) NSString *requestString;

//Video Info
@property (strong, nonatomic) VideoData *currentVideo;
@property (strong, nonatomic) NSMutableArray *videosData;

//NSXMLParser
@property(strong, nonatomic) NSMutableString *currentString;
@property(strong, nonatomic) NSXMLParser *parser;

-(id) initWithRequestString:(NSString*)request andVideoViewController:(VideoViewController*)videoViewContr;

-(void)refreshCallback:(NSXMLParser*)xmlParser;
@end
