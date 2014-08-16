//
//  NSDictionary+RemovesNullValues.m
//  GigRadio
//
//  Created by Michael Forrest on 16/08/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import "NSDictionary+RemovesNullValues.h"

@implementation NSDictionary (RemovesNullValues)
-(NSDictionary *)dictionaryWithoutNullValues{
    NSMutableDictionary * result = self.mutableCopy;
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if([obj isEqual:[NSNull null]]){
            [result removeObjectsForKeys:@[key]]; // TODO: batch these?
        }
        if([[obj class] isSubclassOfClass:[NSDictionary class]]){
            result[key] = [obj dictionaryWithoutNullValues];
        }
    }];
    return result;
}
@end
