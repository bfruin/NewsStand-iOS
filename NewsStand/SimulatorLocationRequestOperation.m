//
//  SimulatorLocationRequestOperation.m
//  NewsStand
//
//  Created by Hanan Samet on 2/16/12.
//  Copyright (c) 2012 University of Maryland. All rights reserved.
//

#import "SimulatorLocationRequestOperation.h"
#import "AppDelegate.h"
#import "ViewController.h"

@implementation SimulatorLocationRequestOperation 

@synthesize requestString;
@synthesize currentString, parser;

- (void) main
{
    requestString = @"http://api.ipinfodb.com/v3/ip-city/?key=4f27ef0f9557b7644b639682939fa19ed23397641a54af8fe6d50308c18c207a&format=xml";
    NSURL *url = [NSURL URLWithString:requestString];
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
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    ViewController *viewController = [[[appDelegate navigationController] viewControllers] objectAtIndex:0];
    [viewController setSimulatorLat:lat];
    [viewController setSimulatorLon:lon];
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

}

-(void)parser:(NSXMLParser*)parserIn didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    NSString *currentStringTrimmed = [currentString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([elementName isEqualToString:@"latitude"])  {
        lat = [currentStringTrimmed floatValue];
        NSLog(@"Lat %f", lat);
    } else if ([elementName isEqualToString:@"longitude"]) {
        lon = [currentStringTrimmed floatValue];
        NSLog(@"Lon %f", lon);
    }
        
        
    
    
    currentString = nil;
}



@end
