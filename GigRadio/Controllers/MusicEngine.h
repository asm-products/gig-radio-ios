//
//  MusicEngine.h
//  GigRadio
//
//  Created by Michael Forrest on 25/10/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import <NCMusicEngine.h>
#import "SoundCloudTrack.h"
@interface MusicEngine : NCMusicEngine
@property (nonatomic, strong) SoundCloudTrack * currentlyPlayingTrack;
-(void)playSoundCloudTrack:(SoundCloudTrack*)track;
@end
