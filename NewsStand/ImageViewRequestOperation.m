//
//  ImageViewRequestOperation.m
//  NewsStand
//
//  Created by Hanan Samet on 2/1/12.
//  Copyright (c) 2012 University of Maryland. All rights reserved.
//

#import "ImageViewRequestOperation.h"

@implementation ImageViewRequestOperation

@synthesize requestString;
@synthesize currentImage, imagesData;
@synthesize currentString, parser;

-(id) initWithRequestString:(NSString*)request andImageViewer:(ImageViewer *)imageView andStandMode:(int)stand
{
    if (self = [super init]) {
        requestString = request;
        imageViewer = imageView;
        standMode = stand;
    }
    return self;
}

-(void) main
{
    if (imageViewer == nil)
        return;
    
    NSLog(@"Image viewer request: %@", requestString);
    
    NSURL *url = [NSURL URLWithString:requestString];
    NSData *dataXML = [[NSData alloc] initWithContentsOfURL:url];
    parser =  [[NSXMLParser alloc] initWithData:dataXML];
    
    if (imageViewer == nil)
        return;
    
    if (standMode >= 2) {
        clusterImages = [[NSMutableArray alloc] init];
        clustersAdded = [[NSMutableArray alloc] init];
    }
    if (imagesData == nil)
        imagesData = [[NSMutableArray alloc] init];
    [imagesData removeAllObjects];
    
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
    NSLog(@"Found %d images", [imagesData count]);
    
    NSMutableArray *imagesArray = [[NSMutableArray alloc] init];
    [imagesArray addObject:imagesData];
    
    if (standMode >= 2) {
        clusterImages = [[clusterImages sortedArrayUsingSelector:@selector(compare:)] mutableCopy];
        [imagesArray addObject:clusterImages];
        
    }
    if (imageViewer != nil)
        [imageViewer performSelectorOnMainThread:@selector(parseEnded:) withObject:imagesArray waitUntilDone:NO];
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
        currentImage = [[ImageData alloc] init];
}

-(void)parser:(NSXMLParser*)parserIn didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    NSString *currentStringTrimmed = [currentString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([elementName isEqualToString:@"item"]) {
        static int count = 0;
        
        if ([[currentImage imageURL] isEqualToString:@"nil"])
            return;
        [imagesData addObject:currentImage];
        if (standMode >= 2) {
            NSNumber *currClusterID = [[NSNumber alloc] initWithInt:[currentImage cluster_id]];
            if (![clustersAdded containsObject:currClusterID]) {
                [clusterImages addObject:currentImage];
                [clustersAdded addObject:currClusterID];
            } 
        }
        count++;
    } else if ([elementName isEqualToString:@"media_html"]) {
        [currentImage setImageURL:currentStringTrimmed];
        if ([currentStringTrimmed rangeOfString:@"twitter.com"].location != NSNotFound)
            [currentImage setImageURL:@"nil"];
    } else if ([elementName isEqualToString:@"caption"]) {
        currentStringTrimmed = [[currentStringTrimmed stringByReplacingOccurrencesOfString:@"click image to enlarge " withString:@""] mutableCopy];
        currentStringTrimmed = [[currentStringTrimmed stringByReplacingOccurrencesOfString:@"click image to enlarge" withString:@""] mutableCopy];
        [currentImage setCaption:currentStringTrimmed];
    } else if ([elementName isEqualToString:@"width"]) 
        [currentImage setWidth:[currentStringTrimmed intValue]];
    else if ([elementName isEqualToString:@"height"]) 
        [currentImage setHeight:[currentStringTrimmed intValue]];
    else if ([elementName isEqualToString:@"redirect"]) 
        [currentImage setPageURL:currentStringTrimmed];
    else if ([elementName isEqualToString:@"isDupe"]) 
        if ([currentStringTrimmed intValue] == 0) 
            [currentImage setIsDupe:NO];
        else
            [currentImage setIsDupe:YES];
    else if ([elementName isEqualToString:@"cluster_id"]) 
        [currentImage setCluster_id:[currentStringTrimmed intValue]];
    else if ([elementName isEqualToString:@"cluster_score"]) 
        [currentImage setCluster_score:[currentStringTrimmed floatValue]];    
    else if ([elementName isEqualToString:@"image_cluster_id"]) 
        [currentImage setImage_cluster_id:[currentStringTrimmed intValue]];
    
    currentString = nil;
}


@end
