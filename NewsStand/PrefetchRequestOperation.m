//
//  PrefetchRequestOperation.m
//  NewsStand
//
//  Created by Hanan Samet on 10/9/13.
//
//

#import "PrefetchRequestOperation.h"

@implementation PrefetchRequestOperation
@synthesize requestString;

-(id)initWithRequestString:(NSString*)request
{
    if (self = [super init]) {
        requestString = request;
    }
    return self;
}

-(void) main
{

    NSLog(@"Prefetching %@", requestString);
    
    NSURL *url = [NSURL URLWithString:requestString];
    NSData *dataXML = [[NSData alloc] initWithContentsOfURL:url];
}

@end
