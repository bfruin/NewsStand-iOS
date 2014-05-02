//
//  NSString-Compare.h
//  NewsStand
//
//  Created by Hanan Samet on 7/17/12.
//  Copyright (c) 2012 University of Maryland. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (CompareMinusArticles)
-(NSComparisonResult)compareMinusArticles:(NSString*)aString andObjLang:(NSString*)objLang andCompareLang:(NSString*)compareLang;
@end
