//
//  VideoRequestOperation.m
//  NewsStand
//
//  Created by Hanan Samet on 1/19/12.
//  Copyright (c) 2012 University of Maryland. All rights reserved.
//

#import "VideoRequestOperation.h"

@implementation VideoRequestOperation
@synthesize requestString;
@synthesize currentVideo, videosData;
@synthesize currentString, parser;

-(id) initWithRequestString:(NSString*)request andVideoViewController:(VideoViewController*)videoViewContr
{
    if (self = [super init]) {
        requestString = request;
        videoViewController = videoViewContr;
    }
    return self;
}

-(void) main
{
    if (videoViewController == nil)
        return;
    
    NSURL *url = [NSURL URLWithString:requestString];
    NSData *dataXML = [[NSData alloc] initWithContentsOfURL:url];
    parser =  [[NSXMLParser alloc] initWithData:dataXML];
    
    if (videoViewController == nil)
        return;
    
    if (videosData == nil)
        videosData = [[NSMutableArray alloc] init];
    [videosData removeAllObjects];
 
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
    NSLog(@"Found %d videos", [videosData count]);
    if (videoViewController != nil)
        [videoViewController performSelectorOnMainThread:@selector(parseEnded:) withObject:videosData waitUntilDone:NO];
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
        currentVideo = [[VideoData alloc] init];
}

-(void)parser:(NSXMLParser*)parserIn didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    NSString *currentStringTrimmed = [currentString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([elementName isEqualToString:@"item"]) 
        [videosData addObject:currentVideo];
    else if ([elementName isEqualToString:@"url"])
        [currentVideo setStory_url:currentStringTrimmed];
    else if ([elementName isEqualToString:@"title"])
        [currentVideo setTitle:currentStringTrimmed];
    else if ([elementName isEqualToString:@"name"])
        [currentVideo setFeed_name:currentStringTrimmed];
    else if ([elementName isEqualToString:@"domain"])
        [currentVideo setDomain:currentStringTrimmed];
    else if ([elementName isEqualToString:@"pub_date"])
        [currentVideo setPub_date:currentStringTrimmed];
    else if ([elementName isEqualToString:@"preview"])
        [currentVideo setImg_url:currentStringTrimmed];
    else if ([elementName isEqualToString:@"length"])
        [currentVideo setLength:currentStringTrimmed];
    
    
    
    currentString = nil;
}


@end
