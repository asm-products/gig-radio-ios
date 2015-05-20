//
//  CalendarHelper.h
//  GigRadio
//
//  Created by Michael Forrest on 16/08/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface CalendarHelper : NSObject
+(NSDateComponents*)days:(NSInteger)count;
+(NSDate*)startOfUTCDay:(NSDate*)date;
@end
