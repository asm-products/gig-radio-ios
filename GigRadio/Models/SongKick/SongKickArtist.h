//
//  SongKickArtist.h
//  GigRadio
//
//  Created by Michael Forrest on 16/08/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import <Realm/Realm.h>

@interface SongKickArtist : RLMObject
@property (nonatomic) long id;
@property (nonatomic, strong) NSString * uri;
@property (nonatomic, strong) NSString * displayName;
@end

// This protocol enables typed collections. i.e.:
// RLMArray<SongKickArtist>
RLM_ARRAY_TYPE(SongKickArtist)
