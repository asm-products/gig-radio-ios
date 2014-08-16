//
//  SoundCloudSyncController.m
//  GigRadio
//
//  Created by Michael Forrest on 16/08/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import "SoundCloudSyncController.h"
#import "SoundCloudArtistSearchOperation.h"
#import "SoundCloudArtistTracksSyncOperation.h"
#import "SoundCloudArtistSearchRequest.h"
#import "SoundCloudArtistTracksRequest.h"
#import "SongKickArtist.h"
@implementation SoundCloudSyncController

-(NSOperationQueue *)syncOperations{
    if(!_syncOperations){
        _syncOperations = [NSOperationQueue new];
    }
    return _syncOperations;
}
-(void)refreshWithArtistNamed:(NSString *)artistName completion:(void (^)())completionBlock{
    SoundCloudArtistSearchRequest * searchRequest = [SoundCloudArtistSearchRequest requestWithArtistName:artistName];
    SoundCloudArtistSearchOperation * searchOperation = [[SoundCloudArtistSearchOperation alloc] initWithRequest:searchRequest];
    __weak SoundCloudArtistSearchOperation * wSearch = searchOperation;
    [searchOperation setJsonParseCompletionBlock:^{
        if(!wSearch.foundUserId){
            NSLog(@"No artist was found named %@", artistName);
            return;
        }
        [[RLMRealm defaultRealm] beginWriteTransaction];
        SongKickArtist * artist = [[SongKickArtist objectsWhere:@"displayName == %@", artistName] firstObject];
        artist.soundCloudUserId = wSearch.foundUserId;
        [[RLMRealm defaultRealm] commitWriteTransaction];

        NSLog(@"got the artist (%@), will now get some tracks", @(wSearch.foundUserId));
        SoundCloudArtistTracksRequest * tracksRequest = [SoundCloudArtistTracksRequest requestWithUserId:wSearch.foundUserId];
        SoundCloudArtistTracksSyncOperation * tracksOperation = [[SoundCloudArtistTracksSyncOperation alloc] initWithRequest:tracksRequest];
        [self.syncOperations addOperation:tracksOperation];
        
        [tracksOperation setJsonParseCompletionBlock:^{
            completionBlock();
        }];
        
    }];
    [self.syncOperations addOperation:searchOperation];
    
}
@end
