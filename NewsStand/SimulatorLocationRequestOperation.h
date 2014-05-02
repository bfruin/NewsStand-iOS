//
//  SimulatorLocationRequestOperation.h
//  NewsStand
//
//  Created by Hanan Samet on 2/16/12.
//  Copyright (c) 2012 University of Maryland. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SimulatorLocationRequestOperation : NSOperation <NSXMLParserDelegate>
{
    NSString *requestString;
    
    float lat;
    float lon;
    
    //NSXMLParserDelegate
    NSMutableString *currentString;
    NSXMLParser *parser;
}

@property (strong, nonatomic) NSString *requestString;
@property (strong, nonatomic) NSMutableString *currentString;
@property (strong, nonatomic) NSXMLParser *parser;


@end
