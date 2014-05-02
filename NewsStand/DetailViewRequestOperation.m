//
//  DetailViewRequestOperation.m
//  NewsStand
//
//  Created by Hanan Samet on 3/16/12.
//  Copyright (c) 2012 University of Maryland. All rights reserved.
//

#import "DetailViewRequestOperation.h"

@implementation DetailViewRequestOperation
@synthesize requestString;
@synthesize currentAnnotation, annotations;
@synthesize currentString, parser;

-(id) initWithRequestString:(NSString*)request andDetailViewController:(DetailViewController *)detailViewer
{
    if (self = [super init]) {
        requestString = request;
        detailViewController = detailViewer;
    }
    return self;
}

-(void) main
{
    if (detailViewController == nil)
        return;
    
    NSURL *url = [NSURL URLWithString:requestString];
    NSData *dataXML = [[NSData alloc] initWithContentsOfURL:url];
    parser =  [[NSXMLParser alloc] initWithData:dataXML];
    
    if (detailViewController == nil)
        return;
    
 
    annotations = [[NSMutableArray alloc] init];
    
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
    NSLog(@"Found %d annotations", [annotations count]);
 
    if (detailViewController != nil)
        [detailViewController performSelectorOnMainThread:@selector(parseEnded:) withObject:annotations waitUntilDone:NO];
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
    
    if ([elementName isEqualToString:@"item"]) {
        [annotations addObject:currentAnnotation];
    } else if ([elementName isEqualToString:@"latitude"]) 
        [currentAnnotation setLatitude:[currentStringTrimmed floatValue]];
    else if ([elementName isEqualToString:@"longitude"]) 
        [currentAnnotation setLongitude:[currentStringTrimmed floatValue]];
    else if ([elementName isEqualToString:@"gaz_id"]) 
        [currentAnnotation setGaz_id:[currentStringTrimmed intValue]];
    else if ([elementName isEqualToString:@"gaztag_id"])
        [currentAnnotation setGaztag_id:[currentStringTrimmed intValue]];
    else if ([elementName isEqualToString:@"name"]) 
        [currentAnnotation setName:currentStringTrimmed];
    else if ([elementName isEqualToString:@"cluster_id"]) 
        [currentAnnotation setCluster_id:[currentStringTrimmed intValue]];
    else if ([elementName isEqualToString:@"title"]) 
        [currentAnnotation setTitle:currentStringTrimmed];
    else if ([elementName isEqualToString:@"translate_title"]) 
        [currentAnnotation setTranslate_title:currentStringTrimmed];
    else if ([elementName isEqualToString:@"description"])
        [currentAnnotation setDescription:currentStringTrimmed];
    else if ([elementName isEqualToString:@"topic"])
        [currentAnnotation setTopic:@"topic"];
    else if ([elementName isEqualToString:@"markup"])
        [currentAnnotation setMarkup:currentStringTrimmed];
    else if ([elementName isEqualToString:@"translate_markup"])
        [currentAnnotation setTranslate_markup:currentStringTrimmed];
    else if ([elementName isEqualToString:@"snippet"])
        [currentAnnotation setSnippet:currentStringTrimmed];
    else if ([elementName isEqualToString:@"keyword"])
        [currentAnnotation setKeyword:currentStringTrimmed];
    
    currentString = nil;
}



@end

