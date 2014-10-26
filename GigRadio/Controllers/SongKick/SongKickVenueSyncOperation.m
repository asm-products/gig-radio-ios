//
//  SongKickVenueSyncOperation.m
//  GigRadio
//
//  Created by Michael Forrest on 17/08/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import "SongKickVenueSyncOperation.h"
#import "SongKickVenue.h"
@implementation SongKickVenueSyncOperation
-(void)parseAndStore:(id)jsonContainer{
    NSDictionary * json = [jsonContainer valueForKeyPath:@"resultsPage.results.venue"];
    SongKickVenue * venue = [[SongKickVenue objectsWhere:@"id == %@", json[@"id"]] firstObject];
    [[RLMRealm defaultRealm] beginWriteTransaction];
    
    venue.venueDescription = json[@"description"];
    venue.street = json[@"street"];
    venue.zip = json[@"zip"];
    if(json[@"capacity"]!=[NSNull null])
        venue.capacity = [json[@"capacity"] integerValue];
    
    [[RLMRealm defaultRealm] commitWriteTransaction];
    
    if(self.jsonParseCompletionBlock) self.jsonParseCompletionBlock();
}
@end
