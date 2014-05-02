//
//  main.m
//  NewsStand
//
//  Created by Brendan on 12/29/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MKMapView.h>

#import "AppDelegate.h"
#import "QTouchposeApplication.h"

int main(int argc, char *argv[])
{
    @autoreleasepool {
        //return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
        return UIApplicationMain(argc, argv,
                                 NSStringFromClass([QTouchposeApplication class]),
                                 NSStringFromClass([AppDelegate class]));
    }
}
