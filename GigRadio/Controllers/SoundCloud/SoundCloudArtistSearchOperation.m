//
//  SoundCloudArtistSearchOperation.m
//  GigRadio
//
//  Created by Michael Forrest on 16/08/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import "SoundCloudArtistSearchOperation.h"
#import "SoundCloudUser.h"
#import "NSDictionary+RemovesNullValues.h"
@implementation SoundCloudArtistSearchOperation
-(void)parseAndStore:(NSArray *)json{
   // store the first artist in the list (have faith in soundcloud's search results!)
    if([json count] == 0) {
        NSLog(@"No artist found for %@", self.request.URL.absoluteString);
    }else{
        NSDictionary * dict = json.firstObject;
        NSLog(@"Dealing with user %@", dict[@"full_name"]);
        RLMRealm * realm = [RLMRealm defaultRealm];
        RLMArray * foundUsers = [SoundCloudUser objectsWhere:@"id == %@", dict[@"id"]];
        if(foundUsers.count > 0){
            NSLog(@"already got user %@", dict[@"full_name"]);
            self.foundUserId = ((SoundCloudUser*)foundUsers.firstObject).id;
        }else{
            dict = [dict dictionaryWithoutNullValues];
            NSMutableDictionary * cleanDict = dict.mutableCopy;
            if(dict[@"description"])
                cleanDict[@"userDescription"] = dict[@"description"];
            [realm beginWriteTransaction];
            SoundCloudUser * user = [SoundCloudUser createInRealm:realm withObject:cleanDict];
            [realm commitWriteTransaction];
            self.foundUserId = user.id;
        }
        NSLog(@"User id for %@ is %@", dict[@"full_name"],  @(self.foundUserId));
    }
    if(self.jsonParseCompletionBlock) self.jsonParseCompletionBlock();
}
@end
