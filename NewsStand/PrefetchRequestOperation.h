//
//  PrefetchRequestOperation.h
//  NewsStand
//
//  Created by Hanan Samet on 10/9/13.
//
//

#import <Foundation/Foundation.h>

@interface PrefetchRequestOperation : NSOperation <NSXMLParserDelegate>
{
    NSString *requestString;
}

@property (strong, nonatomic) NSString *requestString;

-(id)initWithRequestString:(NSString*)request;


@end
