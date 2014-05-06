//
//  NewsAnnotation.m
//  NewsStand
//
//  Created by Brendan on 12/30/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "NewsAnnotation.h"

@implementation NewsAnnotation

@synthesize title, translate_title, subtitle, name, fullName, markup, translate_markup, description, topic;
@synthesize keyword, domain, time, url, img_url, caption, snippet;
@synthesize latitude, longitude;
@synthesize cluster_id, gaz_id, gaztag_id, num_images, num_videos, num_docs, width, height;
@synthesize distinctiveness;
@synthesize locationMarker, displayed, imageFailed, display_translate_title;

- (CLLocationCoordinate2D)coordinate
{
    CLLocationCoordinate2D coord = {self.latitude, self.longitude};
    return coord;
}

@end
