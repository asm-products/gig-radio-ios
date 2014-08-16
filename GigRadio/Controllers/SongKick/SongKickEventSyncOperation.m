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
-(instancetype)initWithRequest:(SongKickEventRequest *)request{
    if(self = [super init]){
        self.request = request;
    }
    return self;
}
-(void)main{
    @autoreleasepool{
        [self performRequest];
    }
}
-(void)performRequest{
    NSURLSession * session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [[session dataTaskWithRequest:self.request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        NSHTTPURLResponse * httpResponse = (NSHTTPURLResponse*) response;
        if(httpResponse && httpResponse.statusCode == 200){
            NSError * error;
            NSDictionary * json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
            if(error){
                NSLog(@"Error parsing json %@", error.localizedDescription);
            }else{
                [self parseAndStore: json];
            }
        }
        
    }] resume];
}
-(void)parseAndStore:(NSDictionary*)json{
//    [SongKickEvent createInRealm:[RLMRealm defaultRealm] withJSONArray:[json valueForKeyPath:@"resultsPage.results.event"]];
    
    RLMRealm * realm = [RLMRealm defaultRealm];
    for (NSDictionary * dict in [json valueForKeyPath:@"resultsPage.results.event"]) {
        if([SongKickEvent objectsInRealm:realm where:@"id == %@", dict[@"id"]].count > 0){
            NSLog(@"Skipping duplicated");
        }else{
            NSDictionary * cleanDict = [dict dictionaryWithoutNullValues];
            NSLog(@"Will save event %@", cleanDict[@"displayName"]);
            [realm beginWriteTransaction];
            [SongKickEvent createInRealm:realm withObject:cleanDict];
            [realm commitWriteTransaction];
            NSLog(@"Saved event %@", cleanDict[@"displayName"]);
        }
    }
}
@end
