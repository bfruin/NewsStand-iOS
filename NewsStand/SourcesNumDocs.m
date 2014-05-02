//
//  SourcesNumDocs.m
//  NewsStand
//
//  Created by Hanan Samet on 4/16/12.
//  Copyright (c) 2012 University of Maryland. All rights reserved.
//

#import "SourcesNumDocs.h"
#import "Source.h"
#import "SourcesViewController.h"

@implementation SourcesNumDocs

- (id)initWithViewController:(ViewController *)viewControllerIn forMode:(int)modeIn
{
    if (self = [super init]) {
        viewController = viewControllerIn;
        mode = modeIn;
    }
    return self;
}

- (NSString *) replaceFirstNewLine:(NSString*) original
{
    NSMutableString * newString = [[NSMutableString alloc] initWithString:original];
    
    NSRange foundRange = [original rangeOfString:@"\n"];
    if (foundRange.location != NSNotFound)
    {
        [newString replaceCharactersInRange:foundRange
                                 withString:@""];
    }
    
    return newString;
}


- (void) main 
{
    if (viewController != nil) {
        NSString *requestURL, *secondRequest;
        NSMutableArray *feedSources, *countrySources, *languageSources;
        int sourceCount = 0;
        
        
        if (mode == 1) {
            feedSources = [viewController feedSources];
            sourceCount = [feedSources count];
            NSString *feedlinks = @"";
            
            BOOL first = TRUE;
            for (Source *currSource in feedSources) {
                if (first)
                    feedlinks = [NSString stringWithFormat:@"%d", [currSource feed_link]];
                else 
                    feedlinks = [feedlinks stringByAppendingFormat:@",%d", [currSource feed_link]];
                
                first = FALSE;
            }
            requestURL = [NSString stringWithFormat:@"http://newsstand.umiacs.umd.edu/news/num_feedlink_docs?feedlinks=%@", feedlinks];
            secondRequest = [NSString stringWithFormat:@"http://newsstand.umiacs.umd.edu/news/num_feedlink_docs?feed_locs=%@", feedlinks];
        } else if (mode == 2) {
            countrySources = [viewController countrySources];
            sourceCount = [countrySources count];
            NSString *countries = @"";
            
            BOOL first = TRUE;
            for (Source *currSource in countrySources) {
                if (first)
                    countries = [NSString stringWithFormat:@"%@", [currSource name]];
                else 
                    countries = [countries stringByAppendingFormat:@",%@", [currSource name]];
                
                first = FALSE;
            }
            
            requestURL = [NSString stringWithFormat:@"http://newsstand.umiacs.umd.edu/news/num_feedlink_docs?countries=%@", countries];
        } else if (mode == 3) {
            languageSources = [viewController languageSources];
            sourceCount = [languageSources count];
            NSString *languages = @"";
            
            BOOL first = TRUE;
            for (Source *currSource in languageSources) {
                if (first)
                    languages = [NSString stringWithFormat:@"%@", [currSource lang_code]];
                else 
                    languages = [languages stringByAppendingFormat:@",%@", [currSource lang_code]];
                
                first = FALSE;
            }
            
            requestURL = [NSString stringWithFormat:@"http://newsstand.umiacs.umd.edu/news/num_feedlink_docs?languages=%@", languages];
        } 
        
        requestURL = [self URLEncodeString:requestURL];
        NSLog(@"Num Source Request : %@", requestURL);

        NSURL *url = [NSURL URLWithString:requestURL];
        NSData *pageData = [[NSData alloc] initWithContentsOfURL:url];
        
        if (pageData == nil)
            NSLog(@"Page data nil for mode %d", mode);
        
        
        NSString *results = [[NSString alloc] initWithData:pageData encoding:NSUTF8StringEncoding];
        NSMutableArray *resArray = [[results componentsSeparatedByString: @","] mutableCopy];
        
        
        if ([resArray count] != sourceCount) {
            NSLog(@"Source count %d %d", sourceCount, [resArray count]);
            
            int dif = sourceCount - [resArray count];
            
            for (int i = 0; i < dif; i++) {
                [resArray addObject:@"0"];
            }
        }
  
        int i = 0;
        
        if (mode == 1) {
            for (Source *currSource in feedSources) {
                [currSource setNum_docs:[[resArray objectAtIndex:i] intValue]];
                i++;
            }
            
            secondRequest = [self URLEncodeString:secondRequest];
            NSLog(@"Num Source Request : %@", secondRequest);
            
            NSURL *url = [NSURL URLWithString:secondRequest];
            NSData *pageData = [[NSData alloc] initWithContentsOfURL:url];
            
            if (pageData == nil)
                NSLog(@"Page data nil for mode %d", mode);
            
            
            NSString *results = [[NSString alloc] initWithData:pageData encoding:NSUTF8StringEncoding];
            resArray = [[results componentsSeparatedByString: @","] mutableCopy];
            
            i = 0;
            
            for (Source *currSource in feedSources) {
                //[currSource setSource_location:[self replaceFirstNewLine:[[resArray objectAtIndex:i] stringByTrimmingCharactersInSet:
                  //                              [NSCharacterSet whitespaceCharacterSet]]]];
                i++;
            }
            
            [viewController setFeedSources:feedSources];
        } else if (mode == 2) {
            for (Source *currSource in countrySources) {
                 [currSource setNum_docs:[[resArray objectAtIndex:i] intValue]];
                 i++;
            }
            
            [viewController setCountrySources:countrySources];
        } else if (mode == 3) {
            for (Source *currSource in languageSources) {
                [currSource setNum_docs:[[resArray objectAtIndex:i] intValue]];
                i++;
            }
            
            [viewController setLanguageSources:languageSources];
        } 
    }
    
    if ([[viewController.navigationController viewControllers] count] > 1 && [[[viewController.navigationController viewControllers] objectAtIndex:1] isKindOfClass:[SourcesViewController class]]) {
        SourcesViewController *sourcesViewController = [[viewController.navigationController viewControllers] objectAtIndex:1];
        [[sourcesViewController tableView] reloadData];
    }
}

-(NSString *) URLEncodeString:(NSString *) str
{
    
    NSMutableString *tempStr = [NSMutableString stringWithString:str];
    [tempStr replaceOccurrencesOfString:@" " withString:@"+" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [tempStr length])];
    
    
    return [[NSString stringWithFormat:@"%@",tempStr] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}


@end
