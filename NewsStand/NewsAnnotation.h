//
//  NewsAnnotation.h
//  NewsStand
//
//  Created by Brendan on 12/30/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface NewsAnnotation : NSObject <MKAnnotation>
{
    NSString *title;
    NSString *translate_title;
    NSString *subtitle;
    NSString *name;
    NSString *fullName;
    NSString *markup;
    NSString *translate_markup;
    NSString *description;
    NSString *topic;
    NSString *keyword;
    NSString *domain;
    NSString *time;
    NSString *url;
    NSString *img_url;
    NSString *caption;
    NSString *snippet;
    
    double latitude;
    double longitude;
    
    int cluster_id;
    int gaz_id;
    int gaztag_id;
    int num_images;
    int num_videos;
    int num_docs;
    int width;
    int height;
    
    int distinctiveness;
    
    BOOL locationMarker;
    BOOL displayed;
    BOOL imageFailed;
    BOOL display_translate_title;
}

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *translate_title;
@property (copy, nonatomic) NSString *subtitle;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *fullName;
@property (strong, nonatomic) NSString *markup;
@property (strong, nonatomic) NSString *translate_markup;
@property (strong, nonatomic) NSString *description;
@property (strong, nonatomic) NSString *topic;
@property (strong, nonatomic) NSString *keyword;
@property (strong, nonatomic) NSString *domain;
@property (strong, nonatomic) NSString *time;
@property (strong, nonatomic) NSString *url;
@property (strong, nonatomic) NSString *img_url;
@property (strong, nonatomic) NSString *caption;
@property (strong, nonatomic) NSString *snippet;

@property (nonatomic) double latitude;
@property (nonatomic) double longitude;

@property (nonatomic) int cluster_id;
@property (nonatomic) int gaz_id;
@property (nonatomic) int gaztag_id;
@property (nonatomic) int num_images;
@property (nonatomic) int num_videos;
@property (nonatomic) int num_docs;
@property (nonatomic) int width;
@property (nonatomic) int height;

@property (nonatomic) int distinctiveness;

@property (nonatomic, readwrite) BOOL locationMarker;
@property (nonatomic, readwrite) BOOL displayed;
@property (nonatomic, readwrite) BOOL imageFailed;
@property (nonatomic, readwrite) BOOL display_translate_title;

@end
