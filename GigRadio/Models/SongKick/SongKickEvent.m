//
//  SongKickEvent.m
//  GigRadio
//
//  Created by Michael Forrest on 16/08/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import "SongKickEvent.h"

@implementation SongKickEvent
+(NSDictionary *)defaultPropertyValues{
    return @{
             @"distanceCache":@(100000000),
             @"description":@"",
             @"uri": @""
             };
}
@end
