//
//  DetailViewRequestOperation.h
//  NewsStand
//
//  Created by Hanan Samet on 3/16/12.
//  Copyright (c) 2012 University of Maryland. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NewsAnnotation.h"
#import "DetailViewController.h"

@interface DetailViewRequestOperation : NSOperation <NSXMLParserDelegate>
{
    NSString *requestString;
    DetailViewController *detailViewController;
    
    //Annotion Info
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
@property (strong, nonatomic) NSMutableString *currentString;
@property (strong, nonatomic) NSXMLParser *parser;

-(id)initWithRequestString:(NSString*)request andDetailViewController:(DetailViewController*)detailViewer;
-(void)refreshCallback:(NSXMLParser*)parser;

@end
