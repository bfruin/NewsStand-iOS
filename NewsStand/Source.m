//
//  Source.m
//  NewsStand
//
//  Created by Brendan on 1/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Source.h"
#import "NSString-Compare.h"

@implementation Source

@synthesize name, english_name, lang_code, source_location;
@synthesize feed_link, sourceType;
@synthesize selected, flag_selected;
@synthesize centerLat, centerLon, latDelta, lonDelta;
@synthesize num_docs, num_hybrid2_docs;

-(id)initWithName:(NSString *)aName feed_link:(float) aFeed_link andSourceType:(SourceType)aSourceType
{
    if (self = [super init]) {
        name = aName;
        feed_link = aFeed_link;
        sourceType = aSourceType;
        num_docs = 0;
    }
    
    lang_code = @"en";
    
    return self;
}

-(id)initWithName:(NSString *)aName feed_link:(float) aFeed_link andSourceType:(SourceType)aSourceType andLanguageCode:(NSString*)code
{
    if (self = [super init]) {
        name = aName;
        feed_link = aFeed_link;
        sourceType = aSourceType;
        lang_code = code;
        num_docs = 0;
    }
    
    return self;
}

-(id)initWithName:(NSString *)aName andSourceType:(SourceType)aSourceType
{
    if (self = [super init]) {
        name = aName;
        sourceType = aSourceType;
    }
    
    return self;
}

-(id)initWithName:(NSString *)aName andSourceType:(SourceType)aSourceType andSource_Location:(NSString *)sourceLoc
{
    if (self = [super init]) {
        name = aName;
        sourceType = aSourceType;
        source_location = sourceLoc;
    }
    
    return self;
}

-(id)initWithName:(NSString *)aName andEnglishName:(NSString *)englishName andLanguageCode:(NSString *)languageCode 
{
    if (self = [super init]) {
        name = aName;
        english_name = englishName;
        lang_code = languageCode;
        sourceType = languageSource;
    }
    
    return self;
}

-(id)initWithName:(NSString *)aName SourceType:(SourceType)aSourceType centerLat:(float)cLat centerLon:(float)cLon latDelta:(float)dLat lonDelta:(float)dLon
{
    if (self = [super init]) {
        name = aName;
        sourceType = aSourceType;
        centerLat = cLat;
        centerLon = cLon;
        latDelta = dLat;
        lonDelta = dLon;
    }
    
    return self;
}

-(void)encodeWithCoder:(NSCoder *)coder
{
   
    [coder encodeObject:name forKey:@"name"];
    [coder encodeObject:english_name forKey:@"english_name"];
    [coder encodeObject:lang_code forKey:@"lang_code"];
    [coder encodeObject:source_location forKey:@"source_location"];
    [coder encodeInt:feed_link forKey:@"feed_link"];
    [coder encodeInt:sourceType forKey:@"sourceType"];
    [coder encodeBool:selected forKey:@"selectedSource"];
    [coder encodeFloat:centerLat forKey:@"centerLat"];
    [coder encodeFloat:centerLon forKey:@"centerLon"];
    [coder encodeFloat:latDelta forKey:@"latDelta"];
    [coder encodeFloat:lonDelta forKey:@"lonDelta"];
}

-(id)initWithCoder:(NSCoder *)coder
{
    self = [[Source alloc] init];
    if (self != nil) {
        name = [coder decodeObjectForKey:@"name"];
        english_name = [coder decodeObjectForKey:@"english_name"];
        lang_code = [coder decodeObjectForKey:@"lang_code"];
        source_location = [coder decodeObjectForKey:@"source_location"];
        feed_link = [coder decodeIntForKey:@"feed_link"];
        sourceType = [coder decodeIntForKey:@"sourceType"];
        selected = [coder decodeBoolForKey:@"selectedSource"];
        centerLat = [coder decodeFloatForKey:@"centerLat"];
        centerLon = [coder decodeFloatForKey:@"centerLon"];
        latDelta = [coder decodeFloatForKey:@"latDelta"];
        lonDelta = [coder decodeFloatForKey:@"lonDelta"];
    }
    return self;
}

- (NSComparisonResult)compare:(Source *)otherObject {
    if (sourceType != languageSource) {
        return [self.name compareMinusArticles:otherObject.name andObjLang:self.lang_code andCompareLang:otherObject.lang_code];
    } else {
        return [self.english_name compareMinusArticles:otherObject.english_name andObjLang:self.lang_code andCompareLang:otherObject.lang_code];
    }
}


@end
