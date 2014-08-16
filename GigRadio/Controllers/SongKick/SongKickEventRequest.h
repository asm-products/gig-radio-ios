//
//  SongKickEventRequest.h
//  GigRadio
//
//  Created by Michael Forrest on 16/08/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreLocation;
@interface SongKickEventRequest : NSURLRequest
+(instancetype)requestWithMinDate:(NSDate*)minDate maxDate:(NSDate*)maxDate perPage:(NSInteger)perPage location:(CLLocation*)location;
@end
