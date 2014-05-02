//
//  ViewControllerRequestOperation.h
//  NewsStand
//
//  Created by Hanan Samet on 1/24/12.
//  Copyright (c) 2012 University of Maryland. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NewsAnnotation.h"

@interface ViewControllerRequestOperation : NSOperation <NSXMLParserDelegate>
{
    NSString *requestString;
    int requestID;
    int standMode;
    
    //Downloading
    NSData *dataXML;

    //Annotation Info
    NewsAnnotation *currentAnnotation;
    NSMutableArray *annotations;
    NSMutableArray *boundingRects;

    //NSXMLParserDelegate
    NSMutableString *currentString;
    NSXMLParser *parser;
}

@property (strong, nonatomic) NSString *requestString;

//Downloading
@property (strong, nonatomic) NSData *dataXML;

//Annotation Info
@property (strong, nonatomic) NewsAnnotation *currentAnnotation;
@property (strong, nonatomic) NSMutableArray *annotations;
@property (strong, nonatomic) NSMutableArray *boundingRects;

//NSXMLParser
@property(strong, nonatomic) NSMutableString *currentString;
@property(strong, nonatomic) NSXMLParser *parser;

-(id)initWithRequestData:(NSData*)data andRequestId:(int)idOfRequest;

-(void)refreshCallback;

@end
