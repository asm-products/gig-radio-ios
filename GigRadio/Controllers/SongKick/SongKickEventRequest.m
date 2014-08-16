//
//  SongKickEventRequest.m
//  GigRadio
//
//  Created by Michael Forrest on 16/08/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import "SongKickEventRequest.h"
#import <CMDQueryStringSerialization.h>
#import "SongKickConfiguration.h"
#import "DateFormats.h"
@implementation SongKickEventRequest
+(instancetype)requestWithMinDate:(NSDate *)minDate maxDate:(NSDate *)maxDate perPage:(NSInteger)perPage location:(CLLocation*)location{
    NSMutableDictionary * query = [[NSMutableDictionary alloc] initWithCapacity:5];
    if(minDate) query[@"min_date"] = [[DateFormats querystringDateFormatter] stringFromDate:minDate];
    if(maxDate) query[@"max_date"] = [[DateFormats querystringDateFormatter] stringFromDate:maxDate];
    if(perPage) query[@"per_page"] = @(perPage);
    if(location) query[@"location"] = [NSString stringWithFormat:@"geo:%@,%@", @(location.coordinate.latitude), @(location.coordinate.longitude)];
    query[@"apikey"] = [SongKickConfiguration apiKey];
    
    NSMutableString * uri = [[SongKickConfiguration baseUri] mutableCopy];
    [uri appendFormat:@"/events.json?%@", [CMDQueryStringSerialization queryStringWithDictionary:query]];
    return [self requestWithURL:[NSURL URLWithString:uri]];
    
}
@end
