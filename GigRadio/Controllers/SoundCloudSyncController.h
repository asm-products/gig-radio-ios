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
/**
 *  Performs two requests; one for the user info, then another for all the user's tracks
 *
 *  @param artistName      we'll lean on SoundCloud's search in the hope of getting this right
 *  @param completionBlock when both requests have completed
 */
-(void)fetchArtistNamed:(NSString*)artistName completion:(void(^)(SoundCloudUser*artist))completionBlock;
@property (nonatomic, strong) NSOperationQueue * syncOperations;
@end
