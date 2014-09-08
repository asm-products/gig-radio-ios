//
//  SongKickEvent.h
//  GigRadio
//
//  Created by Michael Forrest on 16/08/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import <Realm/Realm.h>
#import "SongKickPerformance.h"
#import "SongKickDateTime.h"
#import "SongKickArtist.h"
#import "SongKickVenue.h"
#import <RLMObject+JSON.h>
@import CoreLocation;

@interface SongKickEvent : RLMObject
@property (nonatomic) long id;
@property (nonatomic, strong) NSString* type;
@property (nonatomic, strong) NSString * displayName;
@property (nonatomic, strong) SongKickVenue * venue;
@property (nonatomic, strong) RLMArray<SongKickPerformance>*performance;
@property (nonatomic, strong) SongKickDateTime * start;
@property (nonatomic, strong) SongKickDateTime * end;
@property (nonatomic, strong) NSString * uri;
@property (nonatomic, strong) NSString * description;


@property (nonatomic) double distanceCache;

@end

RLM_ARRAY_TYPE(SongKickEvent)
