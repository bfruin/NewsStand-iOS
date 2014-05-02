//
//  TopStoriesRequestOperation.h
//  NewsStand
//
//  Created by Hanan Samet on 1/24/12.
//  Copyright (c) 2012 University of Maryland. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TopStoriesViewController.h"
#import "NewsAnnotation.h"

@interface TopStoriesRequestOperation : NSOperation <NSXMLParserDelegate>
{
    NSString *requestString;
    TopStoriesViewController *topStoriesViewController;

    //Annotation Info
    NewsAnnotation *currentAnnotation;
    NSMutableArray *annotations;

    //NSXMLParserDelegate
    NSMutableString *currentString;
    NSXMLParser *parser;
}

@property (strong, nonatomic) NSString *requestString;

//Annotation Info
@property (strong, nonatomic) NewsAnnotation *currentAnnotation;
@property (strong, nonatomic) NSMutableArray *annotations;

//NSXMLParser
@property(strong, nonatomic) NSMutableString *currentString;
@property(strong, nonatomic) NSXMLParser *parser;

-(id) initWithRequestString:(NSString*)request andTopStoriesViewController:(TopStoriesViewController *)topStoriesViewContr;

-(void)refreshCallback;
@end

