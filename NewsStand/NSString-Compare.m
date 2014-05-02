//
//  NSString-Compare.m
//  NewsStand
//
//  Created by Hanan Samet on 7/17/12.
//  Copyright (c) 2012 University of Maryland. All rights reserved.
//

#import "NSString-Compare.h"

@implementation NSString (CompareMinusArticles)

- (NSString*)removeArticlesForLang:(NSString*)lang
{
    NSRange range = NSMakeRange(NSNotFound, 0);

    if ([lang isEqualToString:@"en"]) {
        if ([self hasPrefix:@"A "]) {
            range = [self rangeOfString:@"A "];
        } else if ([self hasPrefix:@"An "]) {
            range = [self rangeOfString:@"An "];
        } else if ([self hasPrefix:@"The "]) {
            range = [self rangeOfString:@"The "];
        }
    } else if ([lang isEqualToString:@"fr"]) {
        if ([self hasPrefix:@"Le "]) {
            range = [self rangeOfString:@"Le "];
        } else if ([self hasPrefix:@"La "]) {
            range = [self rangeOfString:@"La "];
        } else if ([self hasPrefix:@"L'"]) {
            range = [self rangeOfString:@"L'"];
        }
    } else if ([lang isEqualToString:@"de"]) {
        if ([self hasPrefix:@"Der "]) {
            range = [self rangeOfString:@"Der "];
        } else if ([self hasPrefix:@"Die "]) {
            range = [self rangeOfString:@"Die "];
        }
    } else if ([lang isEqualToString:@"es"]) {
        if ([self hasPrefix:@"El "]) {
            range = [self rangeOfString:@"El "];
        } else if ([self hasPrefix:@"Los "]) {
            range = [self rangeOfString:@"Los "];
        } else if ([self hasPrefix:@"Las "]) {
            range = [self rangeOfString:@"Las "];
        }
    }
    
    if (range.location != NSNotFound) {
        return [self substringFromIndex:range.length];
    } else {
        return self;
    }
}


-(NSComparisonResult)compareMinusArticles:(NSString*)aString andObjLang:(NSString*)objLang andCompareLang:(NSString*)compareLang
{
    NSString *selfTrimmed = [self removeArticlesForLang:objLang];
    NSString *aStringTrimmed = [aString removeArticlesForLang:compareLang];
    return [selfTrimmed compare:aStringTrimmed];
}

@end
