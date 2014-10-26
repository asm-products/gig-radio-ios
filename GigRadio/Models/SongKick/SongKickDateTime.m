//
//  SongKickDateTime.m
//  GigRadio
//
//  Created by Michael Forrest on 16/08/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import "SongKickDateTime.h"
#import "DateFormats.h"
@implementation SongKickDateTime
+(NSDictionary *)defaultPropertyValues{
    return @{
             @"date": [NSDate dateWithTimeIntervalSince1970:0],
             @"datetime": [NSDate dateWithTimeIntervalSince1970:0],
             @"timeString": @""
             };
}
+(NSDictionary *)dictionaryConvertedFromJSON:(NSDictionary *)dict{
    NSMutableDictionary * result = dict.mutableCopy;
    if(dict[@"date"])
        result[@"date"] = [[DateFormats querystringDateFormatter] dateFromString:dict[@"date"]];
    
    if(dict[@"datetime"])
        result[@"datetime"] = [[DateFormats dateTimeFormat] dateFromString:dict[@"datetime"]];
//    else
//        result[@"datetime"] = [self createDateTimeFromDateAndTimeString];

    
    if(dict[@"time"])
        result[@"timeString"] = dict[@"time"];
    
    return result;
}
@end
