//
//  ViewControllerRequestOperation.m
//  NewsStand
//
//  Created by Hanan Samet on 1/24/12.
//  Copyright (c) 2012 University of Maryland. All rights reserved.
//

#import "ViewControllerRequestOperation.h"
#import "AppDelegate.h"
#import "ViewController.h"

@implementation ViewControllerRequestOperation
@synthesize requestString;
@synthesize dataXML;
@synthesize currentAnnotation, annotations, boundingRects;
@synthesize currentString, parser;

- (id) initWithRequestData:(NSData*)data andRequestId:(int)idOfRequest
{
    if (self = [super init]) {
        dataXML = [[NSData alloc] initWithData:data];
        requestID = idOfRequest;
    }
    
    [self addObserver:self forKeyPath:@"isCancelled" options:0 context:NULL];
    
    return self;
}

- (void) main 
{
    AppDelegate *appDelegate= [[UIApplication sharedApplication] delegate];
    ViewController *viewController = [appDelegate viewController];
    
    standMode = [viewController standMode];
    
    if ([viewController currentRequestID] == requestID) {
        parser =  [[NSXMLParser alloc] initWithData:dataXML];
        annotations = [[NSMutableArray alloc] init];
        boundingRects = [[NSMutableArray alloc] init];
        [self performSelectorOnMainThread:@selector(refreshCallback) withObject:nil waitUntilDone:NO];
    }
    
}
//dataXML = [[NSData alloc] initWithContentsOfURL:url];
#pragma mark - Key Value Observer
- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    NSLog(@"Cancel Request");
    
    if (parser != nil)
        [parser abortParsing];
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    NSLog(@"Parser error: %@",parseError );
    

}

#pragma mark - NSXML Parsing

- (void) refreshCallback
{
    [parser setDelegate:self];
    BOOL parserSucceeded = [parser parse];
    
    if (!parserSucceeded) {
        NSLog(@"Parser aborted in ViewControllerRequestOperation");
        AppDelegate *appDelegate= [[UIApplication sharedApplication] delegate];
        ViewController *viewController = [appDelegate viewController];
        [viewController performSelectorOnMainThread:@selector(parseEnded:) withObject:annotations waitUntilDone:NO];
    }
}

-(void) parserDidStartDocument:(NSXMLParser *)parser
{

}

-(void)parserDidEndDocument:(NSXMLParser *)parser
{
    
    AppDelegate *appDelegate= [[UIApplication sharedApplication] delegate];
    ViewController *viewController = [appDelegate viewController];
    [viewController performSelectorOnMainThread:@selector(parseEnded:) withObject:annotations waitUntilDone:NO];
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
        AppDelegate *appDelegate= [[UIApplication sharedApplication] delegate];
        ViewController *viewController = [appDelegate viewController];
        
        /* Ben's Code */
        CGPoint p;
        CLLocationCoordinate2D coord;
        coord.latitude = [currentAnnotation latitude];
        coord.longitude = [currentAnnotation longitude];

        p = [[viewController mapView] convertCoordinate:coord toPointToView:[viewController mapView]];
        
        CGSize textSize = [currentAnnotation.title sizeWithFont:[viewController locationFont]];
        CGRect rect;
        if (standMode < 2) {
            rect = CGRectMake(p.x, p.y, textSize.width, textSize.height);
        }

            
        NSEnumerator *enumerator = [boundingRects objectEnumerator];
        id obj;
        BOOL intersects = FALSE;
        
        if ([viewController layerSelected] != iconLayer && standMode < 2) {
            while (obj = [enumerator nextObject]) {
                NSArray *a = (NSArray *)obj;
                CGRect rect2 = CGRectMake( [( NSNumber * )[a objectAtIndex:0] floatValue], [( NSNumber * )[a objectAtIndex:1] floatValue], 
										  [( NSNumber * )[a objectAtIndex:2] floatValue], [( NSNumber * )[a objectAtIndex:3] floatValue]  );
				
				if( CGRectIntersectsRect( rect, rect2 ) == 1 )
				{
					intersects = true;
					break;
				}
            }
        } else if (standMode == 2 && [currentAnnotation distinctiveness] < 6) {
            intersects = YES;
        } else if (standMode == 3) { //TweetPhoto''
            float width = [currentAnnotation width], height = [currentAnnotation height], factor;
            
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
                if (width == 0 || height == 0) { // this looks wrong (first case)
                    width = 60;
                    height = 60;
                } else if (width >= height) {
                    factor = 60 / width;
                    width = factor * width;
                    height = factor * height;
                } else {
                    factor = 60 / height;
                    width = factor * width;
                    height = factor * height;
                }
                else {
                    if (width == 0 || height == 0) { // this looks wrong (first case)
                        width = 42;
                        height = 42;
                    } else if (width >= height) {
                        factor = 42.0 / width;
                        width = factor * width;
                        height = factor * height;
                    } else {
                        factor = 42.0 / height;
                        width = factor * width;
                        height = factor * height;
                    }
                }
            
            rect = CGRectMake(p.x, p.y, width*.8, height*.8);
            
            while (obj = [enumerator nextObject]) {
                NSArray *a = (NSArray *)obj;
                CGRect rect2 = CGRectMake( [( NSNumber * )[a objectAtIndex:0] floatValue], [( NSNumber * )[a objectAtIndex:1] floatValue],
										  [( NSNumber * )[a objectAtIndex:2] floatValue], [( NSNumber * )[a objectAtIndex:3] floatValue]  );
				
				if( CGRectIntersectsRect( rect, rect2 ) == 1 )
				{
					intersects = true;
					break;
				}
            }
        }
        
        if (!intersects) {
            [boundingRects addObject:[NSArray arrayWithObjects: [NSNumber numberWithFloat:p.x],
                                      [NSNumber numberWithFloat:p.y], 
                                      [NSNumber numberWithFloat:(textSize.width)], 
                                      [NSNumber numberWithFloat:(textSize.height)], nil]];
            [annotations addObject:currentAnnotation];
        
        }
        currentAnnotation = nil;
        
        /* End Ben's Code */
        
        
    } else if ([elementName isEqualToString:@"latitude"])
        [currentAnnotation setLatitude:[currentStringTrimmed floatValue]];
    else if ([elementName isEqualToString:@"longitude"])
         [currentAnnotation setLongitude:[currentStringTrimmed floatValue]];
    else if ([elementName isEqualToString:@"gaz_id"])
          [currentAnnotation setGaz_id:[currentStringTrimmed intValue]];
    else if ([elementName isEqualToString:@"name"]) {
        [currentAnnotation setName:currentStringTrimmed];
        [currentAnnotation setTitle:currentStringTrimmed];
    } else if ([elementName isEqualToString:@"cluster_id"])
        [currentAnnotation setCluster_id:[currentStringTrimmed intValue]];
    else if ([elementName isEqualToString:@"title"])
        [currentAnnotation setSubtitle:currentStringTrimmed];
    else if ([elementName isEqualToString:@"description"])
        [currentAnnotation setDescription:currentStringTrimmed];
    else if ([elementName isEqualToString:@"topic"])
        [currentAnnotation setTopic:currentStringTrimmed];
   // else if ([elementName isEqualToString:@"markup"])
     //   [currentAnnotation setMarkup:currentStringTrimmed];
    else if ([elementName isEqualToString:@"snippet"])
        [currentAnnotation setSnippet:currentStringTrimmed];
    else if ([elementName isEqualToString:@"img_url"])
        [currentAnnotation setImg_url:currentStringTrimmed];
    else if ([elementName isEqualToString:@"caption"]) {
        currentStringTrimmed = [[currentStringTrimmed stringByReplacingOccurrencesOfString:@"click image to enlarge " withString:@""] mutableCopy];
        currentStringTrimmed = [[currentStringTrimmed stringByReplacingOccurrencesOfString:@"click image to enlarge" withString:@""] mutableCopy];
        [currentAnnotation setCaption:currentStringTrimmed];
    } else if ([elementName isEqualToString:@"width"])
        [currentAnnotation setWidth:[currentStringTrimmed intValue]];
    else if ([elementName isEqualToString:@"height"])
        [currentAnnotation setHeight:[currentStringTrimmed intValue]];
    else if ([elementName isEqualToString:@"keyword"]) {
        if (currentStringTrimmed != nil && [currentStringTrimmed length] > 0 &&
            [[NSCharacterSet uppercaseLetterCharacterSet] characterIsMember:[currentStringTrimmed characterAtIndex:0]])
            [currentAnnotation setKeyword:currentStringTrimmed];
        else 
            [currentAnnotation setKeyword:[currentStringTrimmed capitalizedString]];
    } else if ([elementName isEqualToString:@"distinctiveness"]) {
        [currentAnnotation setDistinctiveness:[currentStringTrimmed intValue]];
    }
        
    currentString = nil;
}

@end
