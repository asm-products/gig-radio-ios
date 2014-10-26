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
-(void)fetchArtistNamed:(NSString *)artistName completion:(void (^)(SoundCloudUser *))completionBlock{
    SoundCloudArtistSearchRequest * searchRequest = [SoundCloudArtistSearchRequest requestWithArtistName:artistName];
    SoundCloudArtistSearchOperation * searchOperation = [[SoundCloudArtistSearchOperation alloc] initWithRequest:searchRequest];
    __weak SoundCloudArtistSearchOperation * wSearch = searchOperation;
    [searchOperation setJsonParseCompletionBlock:^{
        if(!wSearch.foundUserId){
            NSLog(@"No artist was found named %@", artistName);
            completionBlock(nil);
            return;
        }
        [[RLMRealm defaultRealm] beginWriteTransaction];
        SongKickArtist * artist = [[SongKickArtist objectsWhere:@"displayName == %@", artistName] firstObject];
        artist.soundCloudUserId = wSearch.foundUserId;
        [[RLMRealm defaultRealm] commitWriteTransaction];
        NSInteger soundCloudUserId = artist.soundCloudUserId;
        NSLog(@"got the artist (%@), will now get some tracks", @(wSearch.foundUserId));
        SoundCloudArtistTracksRequest * tracksRequest = [SoundCloudArtistTracksRequest requestWithUserId:wSearch.foundUserId];
        SoundCloudArtistTracksSyncOperation * tracksOperation = [[SoundCloudArtistTracksSyncOperation alloc] initWithRequest:tracksRequest];
        [self.syncOperations addOperation:tracksOperation];
        
        [tracksOperation setJsonParseCompletionBlock:^{
            completionBlock([SoundCloudUser findById:soundCloudUserId]);
        }];
        
    }];
    [self.syncOperations addOperation:searchOperation];
    
}
@end
