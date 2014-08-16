//
//  SoundCloudUser.m
//  GigRadio
//
//  Created by Michael Forrest on 16/08/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import "SoundCloudUser.h"

@implementation SoundCloudUser

// Specify default values for properties

+ (NSDictionary *)defaultPropertyValues
{
    return @{
            @"website":@"",
            @"website_title":@"",
            @"permalink":@"",
            @"description":@"",
            @"city":@""
             };
}

// Specify properties to ignore (Realm won't persist these)

//+ (NSArray *)ignoredProperties
//{
//    return @[];
//}

@end
