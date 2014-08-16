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
@interface SongKickSyncController(Private)
@end

@implementation SongKickSyncController
-(NSOperationQueue *)syncOperations{
    if(!_syncOperations){
        _syncOperations = [NSOperationQueue new];
    }
    return _syncOperations;
}
-(void)refreshWithLocation:(CLLocation*)location{
    SongKickEventRequest * request = [SongKickEventRequest requestWithMinDate:nil maxDate:nil perPage:50 location:location]; // 100 is a bit slow
    NSLog(@"Requesting %@", request.URL.absoluteString);
    SongKickEventSyncOperation * operation = [[SongKickEventSyncOperation alloc] initWithRequest:request];
    [operation setCompletionBlock:^{
        [SongKickVenue updateDistanceCachesWithLocation:location];
    }];
    [self.syncOperations addOperation:operation];
}
@end
