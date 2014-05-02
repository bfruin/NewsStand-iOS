//
//  MapKeywordRequestOperation.h
//  NewsStand
//
//  Created by Hanan Samet on 5/2/14.
//
//

#import <Foundation/Foundation.h>
#import "DetailViewController.h"
#import "NewsAnnotation.h"

@interface MapKeywordRequestOperation : NSOperation <NSXMLParserDelegate>
{
    NSString *requestString;
    DetailViewController *detailViewController;
    
    int layer;
    BOOL clusterOrKeyword;
    
    //Annotation Info
    NewsAnnotation *currentAnnotation;
    NSMutableArray *annotations;
    
    //NSXMLParseDelegate
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

-(id)initWithRequestString:(NSString*)request andDetailViewController:
(DetailViewController*)detailViewer andLayer:(int)selectedLayer isClusterOrKeyword:(BOOL)clusterKeyword;
-(void)refreshCallback:(NSXMLParser*)parser;

@end
