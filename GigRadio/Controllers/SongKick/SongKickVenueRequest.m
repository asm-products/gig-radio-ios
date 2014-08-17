//
//  SongKickVenueRequest.m
//  GigRadio
//
//  Created by Michael Forrest on 17/08/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import "SongKickVenueRequest.h"
#import <CMDQueryStringSerialization.h>
#import "SongKickConfiguration.h"

@implementation SongKickVenueRequest
+(instancetype)requestWithVenueId:(NSInteger)venueId{
    NSMutableDictionary * query = [NSMutableDictionary new];
    query[@"apikey"] = [SongKickConfiguration apiKey];
    
    
    NSMutableString * uri = [SongKickConfiguration baseUri].mutableCopy;
    [uri appendFormat:@"/venues/%i.json?%@",venueId,[CMDQueryStringSerialization queryStringWithDictionary:query]];
    return [self requestWithURL:[NSURL URLWithString:uri]];
    
}
@end
