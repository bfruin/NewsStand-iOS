//
//  Source.h
//  NewsStand
//
//  Created by Brendan on 1/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    allSource,
    feedSource,
    countrySource,
    languageSource,
    boundSource,
} SourceType;

@interface Source : NSObject
{
    NSString *name;
    NSString *english_name; //For languages
    NSString *lang_code;
    NSString *source_location;
    
    int feed_link;
    SourceType sourceType;
    
    BOOL selected;
    BOOL flag_selected;
    
    //For Bounding Region
    float centerLat;
    float centerLon;
    float latDelta;
    float lonDelta;
    
    int num_docs;
    int num_hybrid2_docs;
}

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *english_name;
@property (strong, nonatomic) NSString *lang_code;
@property (strong, nonatomic) NSString *source_location;

@property (nonatomic, readwrite) int feed_link;
@property (nonatomic, readwrite) SourceType sourceType;

@property (nonatomic, readwrite) BOOL selected;
@property (nonatomic, readwrite) BOOL flag_selected;

//For Bounding Region
@property (nonatomic, readwrite) float centerLat;
@property (nonatomic, readwrite) float centerLon;
@property (nonatomic, readwrite) float latDelta;
@property (nonatomic, readwrite) float lonDelta;

@property (nonatomic, readwrite) int num_docs;
@property (nonatomic, readwrite) int num_hybrid2_docs;

-(id)initWithName:(NSString *)aName feed_link:(float) aFeed_link andSourceType:(SourceType)aSourceType;
-(id)initWithName:(NSString *)aName feed_link:(float) aFeed_link andSourceType:(SourceType)aSourceType andLanguageCode:(NSString*)code;
-(id)initWithName:(NSString *)aName andSourceType:(SourceType)aSourceType;
-(id)initWithName:(NSString *)aName andSourceType:(SourceType)aSourceType andSource_Location:(NSString *)sourceLoc;
-(id)initWithName:(NSString *)aName SourceType:(SourceType)aSourceType centerLat:(float)cLat centerLon:(float)cLon
          latDelta:(float)dLat lonDelta:(float)dLon;
-(id)initWithName:(NSString *)aName andEnglishName:(NSString *)englishName andLanguageCode:(NSString *)languageCode;

-(void)encodeWithCoder:(NSCoder *)coder;
-(id)initWithCoder:(NSCoder *)coder;
@end
