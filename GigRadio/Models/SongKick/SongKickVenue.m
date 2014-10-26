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
             @"distanceCache": @(DBL_MAX),
             @"street": @"",
             @"zip":@"",
             @"capacity":@0,
             @"venueDescription":@""
             
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

-(NSString*)address{
    return [NSString stringWithFormat:@"%@ %@", self.street, self.zip];
}
-(NSString *)appleMapsUri{
    return [NSString stringWithFormat:@"http://maps.apple.com/?daddr=%@",[self.address stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
}
-(NSString *)citymapperUri{
    // citymapper://directions?endcoord=51.563612,-0.073299&endname=Abney%20Park%20Cemetery&endaddress=Stoke%20Newington%20High%20Street
    return [NSString stringWithFormat:@"citymapper://directions?endcoord=%f,%f&endname=%@&endaddress=%@", self.lat,self.lng,[self.displayName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[self.address stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
}
@end
