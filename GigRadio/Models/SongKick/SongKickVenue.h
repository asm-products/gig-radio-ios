//
//  SongKickVenue.h
//  GigRadio
//
//  Created by Michael Forrest on 16/08/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import <Realm/Realm.h>
@import CoreLocation;
@interface SongKickVenue : RLMObject
@property (nonatomic) long id;
@property (nonatomic) double lat;
@property (nonatomic) double lng;
@property (nonatomic, strong) NSString * displayName;
@property (nonatomic, strong) NSString * street;
@property (nonatomic, strong) NSString * zip;
@property (nonatomic) NSInteger capacity;
@property (nonatomic, strong) NSString * venueDescription;

@property (nonatomic) double distanceCache;

-(NSString*)address;

-(CLLocation*)location;
+(void)updateDistanceCachesWithLocation:(CLLocation *)location;

-(NSString*)appleMapsUri;
-(NSString*)citymapperUri;

@end

// This protocol enables typed collections. i.e.:
// RLMArray<SongKickVenue>
RLM_ARRAY_TYPE(SongKickVenue)
