//
//  AddFeedRequestOperation.h
//  NewsStand
//
//  Created by Hanan Samet on 1/23/12.
//  Copyright (c) 2012 University of Maryland. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AddFeedViewController.h"
#import "NewFeed.h"

@interface AddFeedRequestOperation : NSOperation <NSXMLParserDelegate>
{
    AddFeedViewController *addFeedsViewController;

    //Video Info
    NewFeed *currentFeed;
    NSMutableArray *feedsData;

    //NSXMLParserDelegate
    NSMutableString *currentString;
    NSXMLParser *parser;
}

//Video Info
@property (strong, nonatomic) NewFeed *currentFeed;
@property (strong, nonatomic) NSMutableArray *feedsData;

//NSXMLParser
@property(strong, nonatomic) NSMutableString *currentString;
@property(strong, nonatomic) NSXMLParser *parser;

-(id) initWithAddFeedViewController:(AddFeedViewController *)addFeedViewContr;

-(void)refreshCallback:(NSXMLParser*)xmlParser;
@end
