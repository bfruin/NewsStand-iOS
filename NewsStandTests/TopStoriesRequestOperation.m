//
//  TopStoriesRequestOperation.m
//  NewsStand
//
//  Created by Hanan Samet on 1/24/12.
//  Copyright (c) 2012 University of Maryland. All rights reserved.
//

#import "TopStoriesRequestOperation.h"
#import "AppDelegate.h"
#import "ViewController.h"

@implementation TopStoriesRequestOperation
@synthesize currentString;
@synthesize currentAnnotation, annotations;
@synthesize requestString, parser;

-(id) initWithRequestString:(NSString*)request andTopStoriesViewController:(TopStoriesViewController *)topStoriesViewContr
{
    if (self = [super init]) {
        requestString = request;
        topStoriesViewController = topStoriesViewContr;
    }
    return self;
}

- (void) main
{
    NSLog(@"Top Stories Request: %@", requestString);
    NSURL *url = [NSURL URLWithString:requestString];
    NSData *dataXML = [[NSData alloc] initWithContentsOfURL:url];
    
    parser =  [[NSXMLParser alloc] initWithData:dataXML];
    
    annotations = [[NSMutableArray alloc] init];
    
    [self performSelectorOnMainThread:@selector(refreshCallback) withObject:nil waitUntilDone:NO];
}

-(void)refreshCallback
{
    [parser setDelegate:self];
    [parser parse];
}

-(void) parserDidStartDocument:(NSXMLParser *)parser
{
    
}

-(void)parserDidEndDocument:(NSXMLParser *)parser
{
    AppDelegate *appDelegate= [[UIApplication sharedApplication] delegate];
    ViewController *viewController = [appDelegate viewController];
    [viewController setTopStoriesAnnotations:annotations];
    
    if (topStoriesViewController != nil)  {
        [topStoriesViewController setAnnotations:annotations];
        [[topStoriesViewController tableView] reloadData];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }
}

-(void)parser:(NSXMLParser*)parserIn foundCharacters:(NSString *)string
{
    if (!currentString) {
        currentString = [[NSMutableString alloc] init];
    }
    
    [currentString appendString:string];
}

-(void)parser:(NSXMLParser*)parserIn didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    if ([elementName isEqualToString:@"item"]) 
        currentAnnotation = [[NewsAnnotation alloc] init];
}

-(void)parser:(NSXMLParser*)parserIn didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    NSString *currentStringTrimmed = [currentString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([elementName isEqualToString:@"item"]) 
        [annotations addObject:currentAnnotation];
    else if ([elementName isEqualToString:@"title"]) {
        [currentAnnotation setTitle:currentStringTrimmed];
        [currentAnnotation setSubtitle:currentStringTrimmed];
    } else if ([elementName isEqualToString:@"translate_title"]) 
        [currentAnnotation setTranslate_title:currentStringTrimmed];
    else if ([elementName isEqualToString:@"description"])
        [currentAnnotation setDescription:currentStringTrimmed];
    else if ([elementName isEqualToString:@"domain"])
        [currentAnnotation setDomain:currentStringTrimmed];
    else if ([elementName isEqualToString:@"url"])
        [currentAnnotation setUrl:currentStringTrimmed];
    else if ([elementName isEqualToString:@"time"])
        [currentAnnotation setTime:currentStringTrimmed];
    else if ([elementName isEqualToString:@"topic"])
        [currentAnnotation setTopic:currentStringTrimmed];
    else if ([elementName isEqualToString:@"cluster_id"])
        [currentAnnotation setCluster_id:[currentStringTrimmed intValue]];
    else if ([elementName isEqualToString:@"num_docs"])
        [currentAnnotation setNum_docs:[currentStringTrimmed intValue]];
    else if ([elementName isEqualToString:@"num_images"])
        [currentAnnotation setNum_images:[currentStringTrimmed intValue]];
    else if ([elementName isEqualToString:@"num_videos"])
        [currentAnnotation setNum_videos:[currentStringTrimmed intValue]];

    
    currentString = nil;
}



@end
