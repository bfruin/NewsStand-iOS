//
//  SourcesNumDocs.h
//  NewsStand
//
//  Created by Hanan Samet on 4/16/12.
//  Copyright (c) 2012 University of Maryland. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ViewController.h"

@interface SourcesNumDocs : NSOperation
{
    ViewController *viewController;
    //Feedlinks - mode 1
    //Countries - mode 2
    //Languages - mode 3
    int mode;
}

-(id)initWithViewController:(ViewController*) viewController forMode:(int)mode;
-(NSString *) URLEncodeString:(NSString *) str;
-(NSString *) replaceFirstNewLine:(NSString*) original;

@end
