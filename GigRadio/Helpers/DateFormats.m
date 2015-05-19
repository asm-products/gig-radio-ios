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
        NSLocale *enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]; \
        [formatter setLocale:enUSPOSIXLocale]; \
        formatter.dateFormat = format; \
    }); \
    return formatter;

@implementation DateFormats
+(NSDateFormatter *)dayOfTheWeekFormatter{
    formatter(@"EEEE")
}
+(NSDateFormatter *)dayOfTheWeekShortFormatter{
    formatter(@"EEE");
}
+(NSDateFormatter *)dayOfTheMonthFormatter{
    formatter(@"dd")
}
+(NSDateFormatter *)monthShortFormatter{
    formatter(@"MMM")
}
+(NSDateFormatter*)monthAndYearFormatter{
    formatter(@"MMMM yyyy")
}
+(NSDateFormatter *)querystringDateFormatter{
    formatter(@"yyyy-MM-dd");
}
+(NSDateFormatter *)dateTimeFormat{
    formatter(@"yyyy-MM-dd'T'HH:mm:ssZ"); // 2014-08-16T14:00:00+0200
}
+(NSDateFormatter*)soundCloudDateFormat{
    formatter(@"yyyy/MM/dd HH:mm:ss Z"); // 2014/04/25 20:50:44 +0000
}
+(NSDateFormatter*)eventDateFormatter{
    formatter(@"HH:mm EEEE MMM dd");
}
+(NSDateFormatter *)timeFormatter{
    static NSDateFormatter * formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [NSDateFormatter new];
        formatter.timeStyle = NSDateFormatterShortStyle;
        
        
    });
    return formatter;

}
@end
