//
//  GetFeaturedFeeds.h
//  NewsStand
//
//  Created by Hanan Samet on 9/20/12.
//
//

#import <Foundation/Foundation.h>
#import "Source.h"
#import "ViewController.h"

@interface GetFeaturedFeeds : NSOperation  <NSXMLParserDelegate>
{
    Source *current_source;
    NSMutableString *currentString;
    NSMutableArray *feedSources;
    
    NSXMLParser *parser;
    
    ViewController *viewController;
}

@property (strong, nonatomic) Source *current_source;
@property (strong, nonatomic) NSMutableString *currentString;
@property (strong, nonatomic) NSMutableArray *feedSources;
           
-(id) initWithViewController:(ViewController*)viewControllerIn;


@end
