//
//  CustomWebView.h
//  NewsStand
//
//  Created by Brendan on 12/30/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomWebView : UIViewController <UIWebViewDelegate>
{
    IBOutlet UIWebView *webView;
    NSString *firstPage;
    int textFontSize;
    
    IBOutlet UIActivityIndicatorView *activityIndicator;
    UISegmentedControl *segmentedControl;
    
    NSString *articleTitle;
}

@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) NSString *firstPage;

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) UISegmentedControl *segmentedControl;

@property (strong, nonatomic) NSString *articleTitle;

-(id)initWithString:(NSString *)URLString andTitle:(NSString *)title;
-(id)initWithString:(NSString *)URLString andTitle:(NSString *)title andArticleTitle:(NSString*)article;

//Bottom Bar Functionality
-(void)shareItemPressed;
-(void)textPlusItemPressed;
-(void)textMinusItemPressed;

@end
