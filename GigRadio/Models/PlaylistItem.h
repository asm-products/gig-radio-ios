//
//  PlaylistItem.h
//  GigRadio
//
//  Created by Michael Forrest on 26/10/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SongKickEvent.h"
#import "SongKickArtist.h"
#import "SongKickVenue.h"
#import "SoundCloudSyncController.h"
#import "SoundCloudUser.h"
#import "SoundCloudTrack.h"
@interface PlaylistItem : NSObject
@property (nonatomic, strong) SongKickEvent * event;
@property (nonatomic, strong) SongKickArtist * songKickArtist;
@property (nonatomic, strong) SoundCloudUser * soundCloudUser;
@property (nonatomic, strong) SoundCloudTrack * track;
@end
