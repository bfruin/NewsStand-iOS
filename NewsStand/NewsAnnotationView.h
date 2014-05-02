//
//  NewsAnnotationView.h
//  NewsStand
//
//  Created by Brendan on 1/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "NewsAnnotation.h"
#import "JMImageCache.h"

@interface NewsAnnotationView : MKAnnotationView <JMImageCacheDelegate>
{
    NewsAnnotation *newsAnnotation;
    UIFont *font;
    NSString *image_url;
    
    BOOL observing;
    BOOL topStories;
    BOOL viewDisplayed;

}

@property (strong, nonatomic) NewsAnnotation *newsAnnotation;
@property (strong, nonatomic) UIFont *font;
@property (strong, nonatomic) NSString *image_url;

@property (nonatomic, readwrite) BOOL observing;
@property (nonatomic, readwrite) BOOL topStories;

@end
