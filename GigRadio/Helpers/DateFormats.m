//
//  DateFormats.m
//  GigRadio
//
//  Created by Michael Forrest on 16/08/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import "DateFormats.h"

#define formatter(format)\
    static NSDateFormatter * formatter = nil; \
    static dispatch_once_t onceToken; \
    dispatch_once(&onceToken, ^{ \
        formatter = [NSDateFormatter new]; \
        formatter.dateFormat = format; \
    }); \
    return formatter;

@implementation DateFormats
+(NSDateFormatter *)dayOfTheWeekFormatter{
    formatter(@"EEEE")
}
+(NSDateFormatter *)dayOfTheMonthFormatter{
    formatter(@"dd")
}
+(NSDateFormatter *)querystringDateFormatter{
    formatter(@"yyyy-MM-dd");
}
+(NSDateFormatter *)dateTimeFormat{
    formatter(@"yyyy-MM-dd'T'HH:mm:ssZZZZZ"); // 2014-08-16T14:00:00+0200
}
@end
