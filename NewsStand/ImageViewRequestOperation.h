//
//  ImageViewRequestOperation.h
//  NewsStand
//
//  Created by Hanan Samet on 2/1/12.
//  Copyright (c) 2012 University of Maryland. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ImageData.h"
#import "ImageViewer.h"

@interface ImageViewRequestOperation : NSOperation  <NSXMLParserDelegate>
{
    NSString *requestString;
    ImageViewer *imageViewer;
    int standMode;
    
    //Video Info
    ImageData *currentImage;
    NSMutableArray *imagesData;
    NSMutableArray *clusterImages;
    NSMutableArray *clustersAdded;
    
    //NSXMLParserDelegate
    NSMutableString *currentString;
    NSXMLParser *parser;
}

@property (strong, nonatomic) NSString *requestString;

//Video Info
@property (strong, nonatomic) ImageData *currentImage;
@property (strong, nonatomic) NSMutableArray *imagesData;

//NSXMLParser
@property (strong, nonatomic) NSMutableString *currentString;
@property (strong, nonatomic) NSXMLParser *parser;

-(id)initWithRequestString:(NSString*)request andImageViewer:(ImageViewer*)imageView andStandMode:(int)stand;

-(void)refreshCallback:(NSXMLParser*)xmlParser;
@end
