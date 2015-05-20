//
//  DateFormats.h
//  GigRadio
//
//  Created by Michael Forrest on 16/08/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface DateFormats : NSObject
+(NSDateFormatter*)dayOfTheWeekFormatter;
+(NSDateFormatter*)dayOfTheWeekShortFormatter;
+(NSDateFormatter*)dayOfTheMonthFormatter;
+(NSDateFormatter*)monthShortFormatter;
+(NSDateFormatter*)querystringDateFormatter;
+(NSDateFormatter*)dateTimeFormat;
+(NSDateFormatter*)soundCloudDateFormat;
+(NSDateFormatter*)eventDateFormatter;
+(NSDateFormatter*)monthAndYearFormatter;
+(NSDateFormatter*)timeFormatter;
+(NSDateFormatter*)todayFormatter;
@end
