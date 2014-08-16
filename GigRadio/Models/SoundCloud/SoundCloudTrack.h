//
//  SoundCloudTrack.h
//  GigRadio
//
//  Created by Michael Forrest on 16/08/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import <Realm/Realm.h>

@interface SoundCloudTrack : RLMObject
@property (nonatomic, strong) NSString * kind;
@property (nonatomic) NSInteger id;
@property (nonatomic, strong) NSDate * created_at;
@property (nonatomic) NSInteger user_id;
@property (nonatomic) NSInteger duration;
@property (nonatomic, strong) NSString * state;
@property (nonatomic, strong) NSString * sharing;
@property (nonatomic, strong) NSString * tag_list;
@property (nonatomic, strong) NSString * permalink;
@property (nonatomic) BOOL streamable;
@property (nonatomic) BOOL downloadable;
@property (nonatomic, strong) NSString * purchase_url;
@property (nonatomic) NSInteger label_id;
@property (nonatomic, strong) NSString * purchase_title;
@property (nonatomic, strong) NSString * genre;
@property (nonatomic, strong) NSString * title;
@property (nonatomic, strong) NSString * description;
@property (nonatomic, strong) NSString * label_name;
@property (nonatomic, strong) NSString * track_type;
@property (nonatomic, strong) NSString * uri;
@property (nonatomic, strong) NSString * permalink_url;
@property (nonatomic, strong) NSString * artwork_url;
@property (nonatomic, strong) NSString * waveform_url;
@property (nonatomic, strong) NSString * stream_url;
@property (nonatomic) NSInteger playback_count;
@property (nonatomic) NSInteger download_count;
@property (nonatomic) NSInteger favoritings_count;
@property (nonatomic) NSInteger comment_count;
@end

RLM_ARRAY_TYPE(SoundCloudTrack)
