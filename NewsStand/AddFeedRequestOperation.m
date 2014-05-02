//
//  AddFeedRequestOperation.m
//  NewsStand
//
//  Created by Hanan Samet on 1/23/12.
//  Copyright (c) 2012 University of Maryland. All rights reserved.
//

#import "AddFeedRequestOperation.h"

@implementation AddFeedRequestOperation
@synthesize currentFeed, feedsData;
@synthesize currentString, parser;

-(id) initWithAddFeedViewController:(AddFeedViewController *)addFeedViewContr
{
    if (self = [super init]) {
        addFeedsViewController = addFeedViewContr;
    }
    return self;
}

-(void) main
{
    if (addFeedsViewController == nil)
        return;
    
    NSString *requestString = @"http://newsstand.umiacs.umd.edu/news/xml_get_sources";
    
    NSURL *url = [NSURL URLWithString:requestString];
    NSData *dataXML = [[NSData alloc] initWithContentsOfURL:url];
    parser =  [[NSXMLParser alloc] initWithData:dataXML];
    
    if (addFeedsViewController == nil)
        return;
    
    if (feedsData == nil)
        feedsData = [[NSMutableArray alloc] init];
    [feedsData removeAllObjects];
    
    [self performSelectorOnMainThread:@selector(refreshCallback:) withObject:nil waitUntilDone:NO];
}

#pragma mark - Marker Parsing (Using NSXMLParser)

-(void)refreshCallback:(NSXMLParser*)xmlParser
{
    [parser setDelegate:self];
    [parser parse];
}

-(void) parserDidStartDocument:(NSXMLParser *)parser
{
    
}

-(void)parserDidEndDocument:(NSXMLParser *)parser
{
    NSLog(@"Found %d sources", [feedsData count]);
    if (addFeedsViewController != nil)
        [addFeedsViewController performSelectorOnMainThread:@selector(parseEnded:) withObject:feedsData waitUntilDone:NO];
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
        currentFeed = [[NewFeed alloc] init];
}

-(void)parser:(NSXMLParser*)parserIn didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    NSString *currentStringTrimmed = [currentString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([elementName isEqualToString:@"item"]) 
        [feedsData addObject:currentFeed];
    else if ([elementName isEqualToString:@"title"])
        [currentFeed setName:currentStringTrimmed];
    else if ([elementName isEqualToString:@"feed_link"])
        [currentFeed setFeed_link:[currentStringTrimmed intValue]];
    else if ([elementName isEqualToString:@"lang"])
        [currentFeed setLanguage:currentStringTrimmed];
    else if ([elementName isEqualToString:@"ccode"])
        [currentFeed setCountry_code:currentStringTrimmed];

    currentString = nil;
}


@end
