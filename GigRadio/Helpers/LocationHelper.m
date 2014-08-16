//
//  LocationHelper.m
//  GigRadio
//
//  Created by Michael Forrest on 16/08/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import "LocationHelper.h"
#import <CLLocationManager+blocks.h>
@implementation LocationHelper
+(void)lookupWithError:(void (^)(NSError *))errorHandler completion:(void (^)(CLLocation*))completionHandler{
#if TARGET_IPHONE_SIMULATOR
    CLLocation * berlin = [[CLLocation alloc] initWithLatitude:52.48949722 longitude:13.42834774];
    completionHandler(berlin);
    return;
#endif
    static CLLocationManager * manager = nil;
    if(!manager) manager = [CLLocationManager new];
    [manager startUpdatingLocationWithUpdateBlock:^(CLLocationManager *manager, CLLocation *location, NSError *error, BOOL *stopUpdating) {
        if(error){
            errorHandler(error);
        }else{
            completionHandler(location);
        }
        //TODO: wait until accuracy is sufficient
        *stopUpdating = YES;
    }];
}
@end
