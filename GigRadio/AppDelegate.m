//
//  AppDelegate.m
//  GigRadio
//
//  Created by Michael Forrest on 16/08/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import "AppDelegate.h"
//#import <TestFlight.h>
#import <Crashlytics/Crashlytics.h>
#import <RLMRealm.h>
@import AVFoundation;

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
//    [TestFlight takeOff:@"61ab335a-e585-4f3f-99b4-e0404e483607"];
    [Crashlytics startWithAPIKey:@"3254ccee18a98f4b57c4dc9d4fdd5d961828f59d"];
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    NSLog(@"Started app in dir %@", [RLMRealm defaultRealmPath]);
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
}

- (void)applicationWillTerminate:(UIApplication *)application
{
}

@end
