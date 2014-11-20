//
//  SoundCloudTrack.m
//  GigRadio
//
//  Created by Michael Forrest on 16/08/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import "SoundCloudTrack.h"
#import "SoundCloudConfiguration.h"
@implementation SoundCloudTrack
+(NSDictionary *)defaultPropertyValues{
    return @{
             @"kind":@"",
             @"id": @0,
             @"duration":@0,
             @"state":@"",
             @"sharing":@"",
             @"tag_list":@"",
             @"permalink":@"",
             @"streamable":@NO,
             @"downloadable":@NO,
             @"purchase_url":@"",
             @"label_id":@0,
             @"purchase_title":@"",
             @"genre":@"",
             @"title":@"",
             @"description":@"",
             @"trackDescription":@"",
             @"label_name":@"",
             @"track_type":@"",
             @"uri":@"",
             @"permalink_url":@"",
             @"artwork_url":@"",
             @"waveform_url":@"",
             @"stream_url":@"",
             @"playback_count":@0,
             @"download_count":@0,
             @"favoritings_count":@0,
             @"comment_count":@0
             };
}


-(NSURL *)playbackURL{
    return [NSURL URLWithString:[self.stream_url stringByAppendingFormat:@"?client_id=%@",[SoundCloudConfiguration clientId]]];
}
@end
