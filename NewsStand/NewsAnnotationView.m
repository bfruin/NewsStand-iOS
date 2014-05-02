//
//  NewsAnnotationView.m
//  NewsStand
//
//  Created by Brendan on 1/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NewsAnnotationView.h"
#import "ViewController.h"
#import "AppDelegate.h"


@implementation NewsAnnotationView

static double EPSILON = 5.96e-08;

@synthesize newsAnnotation;
@synthesize font;
@synthesize image_url;
@synthesize observing, topStories;

- (id) initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier]) {
        //self.backgroundColor = [UIColor blackColor];
        self.backgroundColor = [UIColor clearColor];
        [self setNeedsDisplay];
    }
    
    return self;
}

- (void) cache:(JMImageCache *)c didDownloadImage:(UIImage *)i forURL:(NSString *)url
{
    if ([url isEqualToString:image_url]) {
        [self setImage:i];
       
        [self setNeedsLayout];
        [self setNeedsDisplay];
        
        AppDelegate *appDelegate= [[UIApplication sharedApplication] delegate];
        ViewController *viewController = [appDelegate viewController];
        [self setNeedsDisplay];
        [self setNeedsLayout];
        
        NSArray *annotations = [viewController.mapView annotations];
        
        if (annotations != nil) {
        for (NewsAnnotation *currentAnnotation in annotations) {
            NSLog(@"A");
            if (currentAnnotation != nil && newsAnnotation != nil
                && fabs(currentAnnotation.coordinate.latitude - newsAnnotation.coordinate.latitude) < EPSILON
                && fabs(currentAnnotation.coordinate.longitude - newsAnnotation.coordinate.longitude) < EPSILON) {
                [viewController.mapView removeAnnotation:currentAnnotation];
                [viewController.mapView addAnnotation:currentAnnotation];
                break;
            }
        }
        }
    }
}


- (void) drawRect:(CGRect)rect
{
    NSLog(@"DRAW RECT CALLED");
    
    CGRect rect2 = rect;
    rect2.origin.x += 2;
    rect2.origin.y += 2;
    
    CGContextSetRGBFillColor(UIGraphicsGetCurrentContext(), 0.0, 0.0, 0.0, 1.0);
    
    if (newsAnnotation.keyword == nil)
        [newsAnnotation.title drawInRect:rect2 withFont:font];
    else
        [newsAnnotation.keyword drawInRect:rect2 withFont:font];
    
    
    CGContextSetRGBFillColor(UIGraphicsGetCurrentContext(), 0.0, 0.53, 0.0, 1.0);
    
    if (newsAnnotation.keyword == nil) {
        [newsAnnotation.title drawInRect:rect withFont:font];
    } else {
        [newsAnnotation.keyword drawInRect:rect withFont:font];
    }
    
    /*
    CGFloat stroke = 1.0;
	CGFloat radius = 7.0;
	CGMutablePathRef path = CGPathCreateMutable();
	UIColor *color;
	CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	//Fill Callout Bubble & Add Shadow
	color = [[UIColor blackColor] colorWithAlphaComponent:.6];
	[color setFill];
	CGContextAddPath(context, path);
	CGContextSaveGState(context);
	CGContextSetShadowWithColor(context, CGSizeMake (0, 6), 6, [UIColor colorWithWhite:0 alpha:.5].CGColor);
	CGContextFillPath(context);
	CGContextRestoreGState(context);
	
	//Stroke Callout Bubble
	color = [[UIColor darkGrayColor] colorWithAlphaComponent:.9];
	[color setStroke];
	CGContextSetLineWidth(context, stroke);
	CGContextSetLineCap(context, kCGLineCapSquare);
	CGContextAddPath(context, path);
	CGContextStrokePath(context);
	
	//Determine Size for Gloss
	CGRect glossRect = self.bounds;
	glossRect.size.width = rect.size.width - stroke;
	glossRect.size.height = (rect.size.height - stroke) / 2;
	glossRect.origin.x = rect.origin.x + stroke / 2;
	glossRect.origin.y += rect.origin.y + stroke / 2;
	
	CGFloat glossTopRadius = radius - stroke / 2;
	CGFloat glossBottomRadius = radius / 1.5;
	
	//Create Path For Gloss
	CGMutablePathRef glossPath = CGPathCreateMutable();
	CGPathMoveToPoint(glossPath, NULL, glossRect.origin.x, glossRect.origin.y + glossTopRadius);
	CGPathAddLineToPoint(glossPath, NULL, glossRect.origin.x, glossRect.origin.y + glossRect.size.height - glossBottomRadius);
	CGPathAddArc(glossPath, NULL, glossRect.origin.x + glossBottomRadius, glossRect.origin.y + glossRect.size.height - glossBottomRadius,
				 glossBottomRadius, M_PI, M_PI / 2, 1);
	CGPathAddLineToPoint(glossPath, NULL, glossRect.origin.x + glossRect.size.width - glossBottomRadius,
						 glossRect.origin.y + glossRect.size.height);
	CGPathAddArc(glossPath, NULL, glossRect.origin.x + glossRect.size.width - glossBottomRadius,
				 glossRect.origin.y + glossRect.size.height - glossBottomRadius, glossBottomRadius, M_PI / 2, 0.0f, 1);
	CGPathAddLineToPoint(glossPath, NULL, glossRect.origin.x + glossRect.size.width, glossRect.origin.y + glossTopRadius);
	CGPathAddArc(glossPath, NULL, glossRect.origin.x + glossRect.size.width - glossTopRadius, glossRect.origin.y + glossTopRadius,
				 glossTopRadius, 0.0f, -M_PI / 2, 1);
	CGPathAddLineToPoint(glossPath, NULL, glossRect.origin.x + glossTopRadius, glossRect.origin.y);
	CGPathAddArc(glossPath, NULL, glossRect.origin.x + glossTopRadius, glossRect.origin.y + glossTopRadius, glossTopRadius,
				 -M_PI / 2, M_PI, 1);
	CGPathCloseSubpath(glossPath);
	
	//Fill Gloss Path
	CGContextAddPath(context, glossPath);
	CGContextClip(context);
	CGFloat colors[] =
	{
		1, 1, 1, .3,
		1, 1, 1, .1,
	};
	CGFloat locations[] = { 0, 1.0 };
	CGGradientRef gradient = CGGradientCreateWithColorComponents(space, colors, locations, 2);
	CGPoint startPoint = glossRect.origin;
	CGPoint endPoint = CGPointMake(glossRect.origin.x, glossRect.origin.y + glossRect.size.height);
	CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
	
	//Gradient Stroke Gloss Path
	CGContextAddPath(context, glossPath);
	CGContextSetLineWidth(context, 2);
	CGContextReplacePathWithStrokedPath(context);
	CGContextClip(context);
	CGFloat colors2[] =
	{
		1, 1, 1, .3,
		1, 1, 1, .1,
		1, 1, 1, .0,
	};
	CGFloat locations2[] = { 0, .1, 1.0 };
	CGGradientRef gradient2 = CGGradientCreateWithColorComponents(space, colors2, locations2, 3);
	CGPoint startPoint2 = glossRect.origin;
	CGPoint endPoint2 = CGPointMake(glossRect.origin.x, glossRect.origin.y + glossRect.size.height);
	CGContextDrawLinearGradient(context, gradient2, startPoint2, endPoint2, 0);
	
	//Cleanup
	CGPathRelease(path);
	CGPathRelease(glossPath);
	CGColorSpaceRelease(space);
	CGGradientRelease(gradient);
	CGGradientRelease(gradient2);*/

}
/*
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    AppDelegate *appDelegate= [[UIApplication sharedApplication] delegate];
    ViewController *viewController = [appDelegate viewController];
    
    return [viewController mapView];
}
*/

- (void) dealloc
{
    if (observing) {
        AppDelegate *appDelegate= [[UIApplication sharedApplication] delegate];
        ViewController *viewController = [appDelegate viewController];
        [self removeObserver:viewController forKeyPath:@"selected"];
    }
    observing = NO;
}

@end
