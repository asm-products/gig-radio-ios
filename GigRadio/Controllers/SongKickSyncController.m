//
//  SongKickSyncController.m
//  GigRadio
//
//  Created by Michael Forrest on 16/08/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import "SongKickSyncController.h"
#import "SongKickEventSyncOperation.h"
#import "SongKickEventRequest.h"
#import "SongKickEvent.h"
#import "SongKickVenueRequest.h"
#import "SongKickVenueSyncOperation.h"
@interface SongKickSyncController(Private)
@end

@implementation SongKickSyncController
-(NSOperationQueue *)syncOperations{
    if(!_syncOperations){
        _syncOperations = [NSOperationQueue new];
    }
    return _syncOperations;
}
-(void)refreshWithLocation:(CLLocation*)location completion:(void (^)())completionBlock{
    SongKickEventRequest * request = [SongKickEventRequest requestWithMinDate:nil maxDate:nil perPage:50 location:location]; // 100 is a bit slow
    NSLog(@"Requesting %@", request.URL.absoluteString);
    SongKickEventSyncOperation * operation = [[SongKickEventSyncOperation alloc] initWithRequest:request];
    [operation setJsonParseCompletionBlock:^{
        [SongKickVenue updateDistanceCachesWithLocation:location];
        if(completionBlock) completionBlock();
    }];
    [self.syncOperations addOperation:operation];
}
-(void)refreshVenue:(NSInteger)venueId completion:(void (^)())completionBlock{
    SongKickVenueRequest * request = [SongKickVenueRequest requestWithVenueId:venueId];
    SongKickVenueSyncOperation * operation = [[SongKickVenueSyncOperation alloc] initWithRequest:request];
    
    operation.jsonParseCompletionBlock = ^{
        if(completionBlock) completionBlock();
    };
    [self.syncOperations addOperation:operation];
}
@end
