//
//  RelatedStoriesRequestOperation.h
//  NewsStand
//
//  Created by Hanan Samet on 12/3/12.
//
//

#import <Foundation/Foundation.h>
#import "NewsAnnotation.h"
#import "RelatedStoriesViewController.h"

@interface RelatedStoriesRequestOperation : NSOperation <NSXMLParserDelegate>
{
    NSString *requestString;
    RelatedStoriesViewController *relatedStoriesViewController;
    
    //Annotation Info
    NewsAnnotation *currentAnnotation;
    NSMutableArray *annotations;
    
    //NSXmlParserDelegate
    NSMutableString *currentString;
    NSXMLParser *parser;
}



@end
