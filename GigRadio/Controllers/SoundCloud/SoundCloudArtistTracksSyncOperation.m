//
//  SoundCloudArtistTracksSyncOperation.m
//  GigRadio
//
//  Created by Michael Forrest on 16/08/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import "SoundCloudArtistTracksSyncOperation.h"
#import "SoundCloudUser.h"
#import "SoundCloudTrack.h"
#import "DateFormats.h"
#import "NSDictionary+RemovesNullValues.h"
@implementation SoundCloudArtistTracksSyncOperation
-(void)parseAndStore:(NSArray *)json{
    RLMRealm * realm = [RLMRealm defaultRealm];
    for (NSDictionary * dict in json) {
        NSInteger trackId = [dict[@"id"] intValue];
        if([[SoundCloudTrack objectsWhere:@"id == %i", trackId] count] > 0){
            NSLog(@"Skip import %@", @(trackId));
        }else{
            
            NSMutableDictionary * cleanDict = dict.dictionaryWithoutNullValues.mutableCopy;
            cleanDict[@"created_at"] = [[DateFormats soundCloudDateFormat] dateFromString:dict[@"created_at"]];
            [realm beginWriteTransaction];
            SoundCloudTrack * track = [SoundCloudTrack createInRealm:realm withObject:cleanDict];
            [realm commitWriteTransaction];
            NSLog(@"Successfully saved track %@", track.title);
            
        }
    }
    if(self.jsonParseCompletionBlock){
        dispatch_async(dispatch_get_main_queue(), ^{
            self.jsonParseCompletionBlock();
        });

    }
}
@end
