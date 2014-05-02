//
//  AppDelegate.m
//  NewsStand
//
//  Created by Brendan on 12/29/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "Reachability.h"

#import "ViewController.h"
#import "Source.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize navigationController = _navigationController;
@synthesize viewController = _viewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    int cacheSizeMemory = 4*1024*1024; // 4MB
    int cacheSizeDisk = 32*1024*1024; // 32MB
    NSURLCache *sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:cacheSizeMemory diskCapacity:cacheSizeDisk diskPath:@"nsurlcache"];
    [NSURLCache setSharedURLCache:sharedCache];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        self.viewController = [[ViewController alloc] initWithNibName:@"ViewController_iPhone" bundle:nil];
        self.navigationController = [[UINavigationController alloc] initWithRootViewController:self.viewController];
        [self.navigationController setNavigationBarHidden:YES];
    } else {
        self.viewController = [[ViewController alloc] initWithNibName:@"ViewController_iPad" bundle:nil];
        self.navigationController = [[UINavigationController alloc] initWithRootViewController:self.viewController];
        [self.navigationController setNavigationBarHidden:YES];
    }
    self.window.rootViewController = self.navigationController;
    [self.window makeKeyAndVisible];
 
    return YES;

}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    NSData *allSourcesData = [NSKeyedArchiver archivedDataWithRootObject:[self.viewController allSources]];
    [prefs setObject:allSourcesData forKey:@"allSourcesData"];
    
    NSData *feedSourcesData = [NSKeyedArchiver archivedDataWithRootObject:[self.viewController feedSources]];
    [prefs setObject:feedSourcesData forKey:@"feedSourcesData"];
    
    NSData *countrySourcesData = [NSKeyedArchiver archivedDataWithRootObject:[self.viewController countrySources]];
    [prefs setObject:countrySourcesData forKey:@"countrySourcesData"];
    
    NSLog(@"application will resign active");
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    NSData *allSourcesData = [NSKeyedArchiver archivedDataWithRootObject:[self.viewController allSources]];
    [prefs setObject:allSourcesData forKey:@"allSourcesData"];
    
    NSData *feedSourcesData = [NSKeyedArchiver archivedDataWithRootObject:[self.viewController feedSources]];
    [prefs setObject:feedSourcesData forKey:@"feedSourcesData"];
    
    NSData *countrySourcesData = [NSKeyedArchiver archivedDataWithRootObject:[self.viewController countrySources]];
    [prefs setObject:countrySourcesData forKey:@"countrySourcesData"];
    
    NSLog(@"application did enter background");
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

-(void)inetAvailabilityChanged:(NSNotification *)notice {
    Reachability *r = (Reachability *)[notice object];
    BOOL hasInet = [r currentReachabilityStatus] != NotReachable;
    [self.viewController setHasInet:hasInet];
    if (!hasInet) {
        [self.navigationController popToRootViewControllerAnimated:YES];
        UIAlertView *myAlert = [[UIAlertView alloc] initWithTitle:@"Network Problem" message:@"There appears to be a problem with your connection. Please check your connectivity in your device's Settings and reopen the application." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [self.navigationController popToRootViewControllerAnimated:YES];
        [[self.navigationController navigationBar] setAlpha:1.0];
        [[self.navigationController navigationBar] setBarStyle:UIBarStyleBlackOpaque];
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        [[self.navigationController toolbar] setAlpha:1.0];
        [self.navigationController setToolbarHidden:YES animated:YES];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:YES];
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
		[myAlert show];
    } else {
        [self.viewController refreshMap];
    }
    
}


- (void)applicationDidBecomeActive:(UIApplication *)application
{
    BOOL hasInet;
    Reachability *connectionMonitor = [Reachability reachabilityForInternetConnection];
    [[NSNotificationCenter defaultCenter]
     addObserver: self
     selector: @selector(inetAvailabilityChanged:)
     name:  kReachabilityChangedNotification
     object: connectionMonitor];
    
    hasInet = [connectionMonitor currentReachabilityStatus] != NotReachable;
    [self.viewController setHasInet:hasInet];
    if (!hasInet) {
        [self.navigationController popToRootViewControllerAnimated:YES];
        [[self.navigationController navigationBar] setAlpha:1.0];
        [[self.navigationController navigationBar] setBarStyle:UIBarStyleBlackOpaque];
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        [[self.navigationController toolbar] setAlpha:1.0];
        [self.navigationController setToolbarHidden:YES animated:YES];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:YES];
        [[UIApplication sharedApplication] setStatusBarHidden:NO];


        UIAlertView *myAlert = [[UIAlertView alloc] initWithTitle:@"Network Problem" message:@"There appears to be a problem with your connection. Please check your connectivity in your device's Settings and reopen the application." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
		[myAlert show];
        [[self.viewController queue] cancelAllOperations];
        [[self.viewController activityIndicator] stopAnimating];
    } else {
        [self.viewController refreshMap];
        [self.viewController updateNumSources];
    }
    
    

}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    NSData *allSourcesData = [NSKeyedArchiver archivedDataWithRootObject:[self.viewController allSources]];
    [prefs setObject:allSourcesData forKey:@"allSourcesData"];
    
    NSData *feedSourcesData = [NSKeyedArchiver archivedDataWithRootObject:[self.viewController feedSources]];
    [prefs setObject:feedSourcesData forKey:@"feedSourcesData"];
    
    NSData *countrySourcesData = [NSKeyedArchiver archivedDataWithRootObject:[self.viewController countrySources]];
    [prefs setObject:countrySourcesData forKey:@"countrySourcesData"];
    
    
    NSLog(@"Application will terminate");
}


@end
