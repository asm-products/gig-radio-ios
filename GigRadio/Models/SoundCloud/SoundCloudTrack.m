//
//  SoundCloudTrack.m
//  GigRadio
//
//  Created by Michael Forrest on 16/08/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import "SoundCloudTrack.h"

@implementation SoundCloudTrack
+(NSDictionary *)defaultPropertyValues{
    return @{
             @"artwork_url":@"",
             @"label_name":@"",
             @"purchase_title":@"",
             @"purchase_url":@"",
             @"track_type":@"",
             @"kind":@"",
             @"state":@"",
             @"sharing":@"",
             @"tag_list":@"",
             @"permalink":@"",
             @"streamable":@NO,
             @"genre":@"",
             @"waveform_url":@"",
             @"stream_url":@"",
             @"label_id":@0
             };
}
@end
