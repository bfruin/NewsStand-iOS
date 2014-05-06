//
//  MapKeywordRequestOperation.m
//  NewsStand
//
//  Created by Hanan Samet on 5/2/14.
//
//

#import "MapKeywordRequestOperation.h"

@implementation MapKeywordRequestOperation
@synthesize requestString;
@synthesize currentAnnotation, annotations;
@synthesize currentString, parser;

-(id)initWithRequestString:(NSString *)request andDetailViewController:(DetailViewController *)detailViewer andLayer:(int)currentLayer isClusterOrKeyword:(BOOL)clusterKeyword
{
    if (self = [super init]) {
        requestString = request;
        detailViewController = detailViewer;
        layer = currentLayer;
        clusterOrKeyword = clusterKeyword;
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
    {
        if (clusterOrKeyword) {
            [detailViewController performSelectorOnMainThread:@selector(parseEndedClusterKeyword:) withObject:annotations waitUntilDone:NO];
        } else {
            [detailViewController performSelectorOnMainThread:@selector(parseEndedLocationName:) withObject:annotations waitUntilDone:NO];
        }
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
    if ([elementName isEqualToString:@"item"]) {
        currentAnnotation = [[NewsAnnotation alloc] init];
        if (!clusterOrKeyword) {
            [currentAnnotation setLocationMarker:YES];
        }
    }
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
    else if ([elementName isEqualToString:@"name"]) {
        [currentAnnotation setName:currentStringTrimmed];
        [currentAnnotation setTitle:currentStringTrimmed];
    } else if ([elementName isEqualToString:@"full_name"])
        [currentAnnotation setFullName:currentStringTrimmed];
    else if ([elementName isEqualToString:@"cluster_id"])
        [currentAnnotation setCluster_id:[currentStringTrimmed intValue]];
    else if ([elementName isEqualToString:@"title"])
        [currentAnnotation setSubtitle:currentStringTrimmed];
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


