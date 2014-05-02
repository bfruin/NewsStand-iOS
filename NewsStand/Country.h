//
//  Country.h
//  NewsStand
//
//  Created by Hanan Samet on 7/18/12.
//  Copyright (c) 2012 University of Maryland. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Country : NSObject
{
    NSString *country_code;
    NSString *country_name;
    NSString *native_name;
}

@property (nonatomic, retain) NSString *country_code;
@property (nonatomic, retain) NSString *country_name;
@property (nonatomic, retain) NSString *native_name;

-(id)initWithCountryCode:(NSString*)code andName:(NSString*)english_name andNativeName:(NSString*)nativeName;

@end
