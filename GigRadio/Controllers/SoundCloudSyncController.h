//
//  SoundCloudSyncController.h
//  GigRadio
//
//  Created by Michael Forrest on 16/08/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SoundCloudUser.h"
@interface SoundCloudSyncController : NSObject
-(void)fetchArtistNamed:(NSString*)artistName completion:(void(^)(SoundCloudUser*artist))completionBlock;
@property (nonatomic, strong) NSOperationQueue * syncOperations;
@end
