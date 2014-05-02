//
//  DiscretizedWindow.m
//  NewsStand
//
//  Created by Hanan Samet on 5/28/13.
//
//

#import "DiscretizedWindow.h"

@interface DiscretizedWindow ()

@end

@implementation DiscretizedWindow

@synthesize upperLeftQuad, upperRightQuad, lowerLeftQuad, lowerRightQuad;

- (id)initWithCoordinates:(CGPoint)upperRight andLowerLeft:(CGPoint)lowerLeft
{
    self = [super init];
    
    if (self) {
        
    }
    
    return self;
}


@end
