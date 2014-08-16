//
//  ArtistSelectionPresenter.m
//  GigRadio
//
//  Created by Michael Forrest on 16/08/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import "ArtistSelectionPresenter.h"
#import <YLMoment.h>
#import "SoundCloudSyncController.h"

@interface ArtistSelectionPresenter()
@property (nonatomic, strong) SoundCloudSyncController * soundCloudSyncController;
@end

@implementation ArtistSelectionPresenter
/**
 *  Don't call this directly, use presenterForDate to get caching
 */
-(instancetype)initWithDate:(NSDate *)date{
    if(self = [super init]){
        self.date = date;
        self.soundCloudSyncController = [SoundCloudSyncController new];
        [self refresh];
    }
    return self;
}
-(void)refresh{
    self.events = [SongKickEvent objectsWhere:@"start.date == %@", self.date];
  
    RLMRealm * realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    for(SongKickEvent * event in self.events){
        event.distanceCache = event.venue.distanceCache;
    }
    [realm commitWriteTransaction];
    
    NSMutableArray * artists = [NSMutableArray new];
    for (SongKickEvent*event in [self.events arraySortedByProperty:@"distanceCache" ascending:YES]) {
        for (SongKickPerformance * performance in event.performance) {
            [artists addObject:performance.artist];
        }
    }
    self.artists = artists;
}
+(NSMutableDictionary*)presenters{
    static NSMutableDictionary * presenters = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        presenters = [NSMutableDictionary new];
    });
    return presenters;
}
+(instancetype)presenterForDate:(NSDate *)date{
    NSDate * normalizedDate = [[[YLMoment momentWithDate:date] startOf:@"day"] date];
    if(self.presenters[normalizedDate]){
        return self.presenters[normalizedDate];
    }else{
        ArtistSelectionPresenter * result = [[self alloc] initWithDate:normalizedDate];
        self.presenters[normalizedDate] = result;
        return result;
    }
}
@end
