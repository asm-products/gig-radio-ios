//
//  ArtistSelectionPresenter.h
//  GigRadio
//
//  Created by Michael Forrest on 16/08/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SongKickEvent.h"
#import "SongKickArtist.h"
#import "SongKickVenue.h"
#import "SoundCloudSyncController.h"
#import "SoundCloudUser.h"

@interface ArtistSelectionPresenter : NSObject
@property (nonatomic, strong) NSDate * date;
@property (nonatomic, strong) RLMResults * events;
@property (nonatomic, strong) NSArray * artists;
+(instancetype)presenterForDate:(NSDate*)date;
-(instancetype)initWithDate:(NSDate*)date;
-(void)refresh;
+(NSMutableDictionary*)presenters;
@property (nonatomic, strong) SoundCloudSyncController * soundCloudSyncController;
/**
 *  This breaks if an artist plays more than one gig in the given time frame
 */
-(SongKickEvent*)eventWithArtist:(SongKickArtist*)artist;
-(RLMResults*)artistTracks:(SoundCloudUser*)user;
@end
