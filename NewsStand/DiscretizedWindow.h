//
//  DiscretizedWindow.h
//  NewsStand
//
//  Created by Hanan Samet on 5/28/13.
//
//

#import <UIKit/UIKit.h>

@interface DiscretizedWindow : NSObject
{
    NSMutableArray *upperLeftQuad;
    NSMutableArray *upperRightQuad;
    NSMutableArray *lowerLeftQuad;
    NSMutableArray *lowerRightQuad;
    
    double x;
    double y;
    int d;
}

@property(strong, nonatomic) NSMutableArray *upperLeftQuad;
@property(strong, nonatomic) NSMutableArray *upperRightQuad;
@property(strong, nonatomic) NSMutableArray *lowerLeftQuad;
@property(strong, nonatomic) NSMutableArray *lowerRightQuad;

-(id)initWithCoordinates:(CGPoint)upperRight andLowerLeft:(CGPoint)lowerLeft;

@end
