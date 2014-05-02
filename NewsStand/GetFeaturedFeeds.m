//
//  GetFeaturedFeeds.m
//  NewsStand
//
//  Created by Hanan Samet on 9/20/12.
//
//

#import "GetFeaturedFeeds.h"
#import "AppDelegate.h"
#import "ViewController.h"

@implementation GetFeaturedFeeds

@synthesize current_source, currentString, feedSources;

-(id) initWithViewController:(ViewController*)viewControllerIn
{
    NSLog(@"init view");
    
    if (self = [super init]) {
        viewController = viewControllerIn;
    }
    
    return self;
}

- (void) main
{
    NSLog(@"In featured feed");
    feedSources = [[NSMutableArray alloc] init];
    
    NSURL *url = [NSURL URLWithString:@"http://newsstand.umiacs.umd.edu/news/get_featured_sources_xml"];
    NSData *dataXML = [[NSData alloc] initWithContentsOfURL:url];
    parser =  [[NSXMLParser alloc] initWithData:dataXML];
    [parser setDelegate:self];
    [parser parse];
}

-(void) parserDidStartDocument:(NSXMLParser *)parser
{
    
}

-(void)parserDidEndDocument:(NSXMLParser *)parser
{
    if (viewController != nil) {
        feedSources = [[NSMutableArray alloc] initWithArray:[feedSources sortedArrayUsingSelector:@selector(compare:)]];
        [viewController performSelectorOnMainThread:@selector(setFeedSources:) withObject:feedSources waitUntilDone:NO];
        [viewController performSelectorOnMainThread:@selector(updateNumSources) withObject:nil waitUntilDone:NO];
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
    if ([elementName isEqualToString:@"object"])
        current_source = [[Source alloc] init];
}

-(void)parser:(NSXMLParser*)parserIn didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    NSString *currentStringTrimmed = [currentString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([elementName isEqualToString:@"object"])
        [feedSources addObject:current_source];
    else if ([elementName isEqualToString:@"name"])
        [current_source setName:currentStringTrimmed];
    else if ([elementName isEqualToString:@"feed-link"])
        [current_source setFeed_link:[currentStringTrimmed intValue]];
    else if ([elementName isEqualToString:@"ccode"]) 
        [current_source setSource_location:[currentStringTrimmed lowercaseString]];
    else if ([elementName isEqualToString:@"lang"])
        [current_source setLang_code:currentStringTrimmed];
    
    currentString = nil;
}


@end
