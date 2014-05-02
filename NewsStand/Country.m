//
//  Country.m
//  NewsStand
//
//  Created by Hanan Samet on 7/18/12.
//  Copyright (c) 2012 University of Maryland. All rights reserved.
//

#import "Country.h"

@implementation Country

@synthesize country_code, country_name, native_name;

-(id)initWithCountryCode:(NSString*)code andName:(NSString*)english_name andNativeName:(NSString*)nativeName
{
    if (self = [super init]) {
        country_code = code;
        country_name = english_name;
        native_name = nativeName;
    }
    
    return self;
}

@end
