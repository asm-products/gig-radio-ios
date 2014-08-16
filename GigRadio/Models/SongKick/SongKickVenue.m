//
//  SongKickVenue.m
//  GigRadio
//
//  Created by Michael Forrest on 16/08/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import "SongKickVenue.h"

@implementation SongKickVenue
+(NSDictionary *)defaultPropertyValues{
    return @{
             @"lat": @0,
             @"lng": @0,
             @"id": @0,
             @"distanceCache": @(DBL_MAX)
             };
}
+(void)updateDistanceCachesWithLocation:(CLLocation *)location{
    [[RLMRealm defaultRealm] beginWriteTransaction];
    for (SongKickVenue * venue in [self allObjects]) {
        venue.distanceCache = [venue.location distanceFromLocation:location];
    }
    [[RLMRealm defaultRealm] commitWriteTransaction];
}
-(CLLocation *)location{
    return [[CLLocation alloc] initWithLatitude:self.lat longitude:self.lng];
}
@end
