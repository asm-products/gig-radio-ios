//
//  Playlist.m
//  GigRadio
//
//  Created by Michael Forrest on 26/10/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import "Playlist.h"
#import <NSArray+F.h>
#import <YLMoment.h>

@interface Playlist()
@property (nonatomic, strong) RLMResults * events;
@property (nonatomic, strong) NSMutableArray * items;
@property (nonatomic, strong) SoundCloudSyncController * soundCloudSyncController;
@end

@implementation Playlist
CWL_SYNTHESIZE_SINGLETON_FOR_CLASS_WITH_ACCESSOR(Playlist, currentPlaylist)
-(SoundCloudSyncController *)soundCloudSyncController{
    if(!_soundCloudSyncController){
        _soundCloudSyncController = [SoundCloudSyncController new];
    }
    return _soundCloudSyncController;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        [self rebuild];
    }
    return self;
}
-(void)rebuild{
    if(!self.startDate) return;
    [self buildEvents];
    [self buildItems];
}
-(void)buildEvents{
    self.events = [SongKickEvent objectsWhere:@"start.datetime >= %@ ", [[YLMoment momentWithDate:self.startDate] startOf:@"day"].date];
    [[RLMRealm defaultRealm] beginWriteTransaction];
    for(SongKickEvent * event in self.events){
        event.distanceCache = event.venue.distanceCache;
    }
    [[RLMRealm defaultRealm] commitWriteTransaction];
}
-(void)buildItems{
    NSMutableArray * items = [[NSMutableArray alloc] initWithCapacity:100];
    [items addObjectsFromArray:[self createItemsPerArtistArray]];
    self.items = items;
}
/**
 *  Each loop round the set of artists appends another item per artist
 */
-(NSArray*)createItemsPerArtistArray{
    NSMutableArray * result = [NSMutableArray new];
    for (SongKickEvent*event in [self.events sortedResultsUsingProperty:@"distanceCache" ascending:YES]) {
        for (SongKickPerformance * performance in event.performance) {
            // unless artist has been disliked
            PlaylistItem * item = [PlaylistItem new];
            item.event = event;
            item.songKickArtist = performance.artist;
            if(item.songKickArtist.soundCloudUserId)
                item.soundCloudUser = [SoundCloudUser findById:item.songKickArtist.soundCloudUserId];
            [result addObject:item];
        }
    }
    return result;
}
-(NSInteger)indexOfItem:(PlaylistItem *)item{
    NSInteger result = [self.items indexOfObject:item];
    if(result == NSNotFound) return 0;
    return result;
}
-(void)fetchItemAfter:(PlaylistItem*)previousItem callback:(void (^)(PlaylistItem * item))callback{
    assert(callback);
    NSInteger indexOfNextItem = [self indexOfItemAfter:previousItem];
    if(indexOfNextItem >= self.items.count){
        [self.items addObjectsFromArray:[self createItemsPerArtistArray]];
        if(indexOfNextItem >= self.items.count) {
            dispatch_async(dispatch_get_main_queue(), ^{
                callback(nil);
            });
            return;
        }
    }
    
    __block PlaylistItem * item = self.items[indexOfNextItem];
    
    void (^whenTracksAvailable)() = ^{
        NSArray * addedTrackIds = [self soundCloudIdsForTracksAddedForArtist:item.songKickArtist.id];
        SoundCloudTrack * track = [item.soundCloudUser nextTrackAfter:addedTrackIds];
        if(track == nil){
            NSLog(@"No tracks for %@, skipping forward", item.songKickArtist.displayName);
            [self fetchItemAfter:item callback:callback];
        }else{
            item.track = track;
            dispatch_async(dispatch_get_main_queue(), ^{
                callback(item);
            });
        }
    };
    
    if(!item.soundCloudUser){
        [self.soundCloudSyncController fetchArtistNamed:item.songKickArtist.displayName completion:^(SoundCloudUser *soundCloudUser) {
            item.soundCloudUser = soundCloudUser;
            whenTracksAvailable();
        }];
    }else{
        whenTracksAvailable();
    }
}
-(NSArray*)soundCloudIdsForTracksAddedForArtist:(NSInteger)artistId{
    return [[self.items filter:^BOOL(PlaylistItem* item) {
        return item.songKickArtist.id == artistId;
    }] map:^id(PlaylistItem* item) {
        return @(item.track.id);
    }];
}
-(NSInteger)indexOfItemAfter:(PlaylistItem*)previousItem{
    if(previousItem == nil){
        return 0;
    }else{
        NSInteger indexOfPreviousItem = [self.items indexOfObject:previousItem];
        if(indexOfPreviousItem == NSNotFound){
            return 0;
        }else{
            return indexOfPreviousItem + 1;
        }
    }
}

-(PlaylistItem *)itemBefore:(PlaylistItem *)item{
    NSInteger indexOfItem = [self.items indexOfObject:item];
    if(indexOfItem == NSNotFound) return nil;
    if(indexOfItem == 0) return nil;
    PlaylistItem *result = self.items[indexOfItem - 1];
    if(result.track == nil){
        return [self itemBefore:result];
    }else{
        return result;
    }
}

-(void)saveCurrentlyPlayingItem:(PlaylistItem *)item{
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
//    [defaults set]
}

@end
