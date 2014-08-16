//
//  AppDelegate.m
//  GigRadio
//
//  Created by Michael Forrest on 16/08/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import "AppDelegate.h"
#import "SongKickSyncController.h"
#import "LocationHelper.h"
@import CoreLocation;

@interface AppDelegate()
@property (nonatomic, strong) SongKickSyncController * songKickSyncController;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.songKickSyncController = [SongKickSyncController new]; 
    [LocationHelper lookupWithError:^(NSError *error) {
        NSLog(@"Error looking up location");
    } completion:^(CLLocation *location) {
        [self.songKickSyncController refreshWithLocation:location completion:^{
        }];
    }];
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
