//
//  AppDelegate.m
//  BackgroundAudio
//
//  Created by Matt Bridges on 1/3/13.
//  Copyright (c) 2013 Matt Bridges. All rights reserved.
//

#import "AppDelegate.h"
@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    if (TARGET_IPHONE_SIMULATOR) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning!" message:@"Background audio doesn't work in the simulator." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
    return YES;
}

@end
