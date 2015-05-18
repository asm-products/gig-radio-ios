//
//  CalendarHelper.m
//  GigRadio
//
//  Created by Michael Forrest on 16/08/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import "CalendarHelper.h"

@implementation CalendarHelper
+(NSDateComponents*)days:(NSInteger)count{
    NSDateComponents * result = [NSDateComponents new];
    result.day = count;
    return result;
}
+(NSDate *)startOfUTCDay:(NSDate *)date{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSCalendarUnit calendarUnits = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
    
    NSDateComponents *components = [calendar components:calendarUnits
                                                fromDate:date];
    return [calendar dateFromComponents:components];
}
@end
