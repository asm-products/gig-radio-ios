//
//  MusicEngine.m
//  GigRadio
//
//  Created by Michael Forrest on 25/10/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import "MusicEngine.h"

@implementation MusicEngine
-(void)playSoundCloudTrack:(SoundCloudTrack *)track{
    [self playUrl:track.playbackURL];
    self.currentlyPlayingTrack = track;
}
@end
