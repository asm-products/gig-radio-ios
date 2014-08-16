//
//  SongKickEventSyncOperation.m
//  GigRadio
//
//  Created by Michael Forrest on 16/08/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import "SongKickEventSyncOperation.h"
#import "SongKickEvent.h"
#import "NSDictionary+RemovesNullValues.h"
@implementation SongKickEventSyncOperation

-(void)parseAndStore:(NSDictionary*)json{
//    [SongKickEvent createInRealm:[RLMRealm defaultRealm] withJSONArray:[json valueForKeyPath:@"resultsPage.results.event"]];
    
    RLMRealm * realm = [RLMRealm defaultRealm];
    for (NSDictionary * dict in [json valueForKeyPath:@"resultsPage.results.event"]) {
        if([SongKickEvent objectsInRealm:realm where:@"id == %@", dict[@"id"]].count > 0){
            NSLog(@"Skipping duplicated");
        }else{
            NSMutableDictionary * cleanDict = [dict dictionaryWithoutNullValues].mutableCopy;
            if(!cleanDict[@"end"])
                cleanDict[@"end"] = cleanDict[@"start"];
            cleanDict[@"start"] = [SongKickDateTime dictionaryConvertedFromJSON:cleanDict[@"start"]];
            cleanDict[@"end"] = [SongKickDateTime dictionaryConvertedFromJSON:cleanDict[@"end"]];
            
            NSLog(@"Will save event %@", cleanDict[@"displayName"]);
            [realm beginWriteTransaction];
            [SongKickEvent createInRealm:realm withObject:cleanDict];
            [realm commitWriteTransaction];
            NSLog(@"Saved event %@", cleanDict[@"displayName"]);
        }
    }
    if(self.jsonParseCompletionBlock) self.jsonParseCompletionBlock();
}
@end
