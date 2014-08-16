//
//  SongKickPerformance.h
//  GigRadio
//
//  Created by Michael Forrest on 16/08/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import <Realm/Realm.h>
#import "SongKickArtist.h"

@interface SongKickPerformance : RLMObject
@property (nonatomic) long id;
@property (nonatomic, strong) NSString * displayName;
@property (nonatomic, strong) SongKickArtist * artist;
@end

RLM_ARRAY_TYPE(SongKickPerformance)
