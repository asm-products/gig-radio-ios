//
//  LocationHelper.m
//  GigRadio
//
//  Created by Michael Forrest on 16/08/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import "LocationHelper.h"
#import "CLLocationManager+blocks.h"
@implementation LocationHelper
+(void)lookUp:(void (^)(CLLocation *, NSError *))completionHandler{
//+(void)lookupWithError:(void (^)(NSError *))errorHandler completion:(void (^)(CLLocation*))completionHandler{
    
#if TARGET_IPHONE_SIMULATOR
    CLLocation * berlin = [[CLLocation alloc] initWithLatitude:52.48949722 longitude:13.42834774];
    CLLocation * london = [[CLLocation alloc] initWithLatitude:51.5303125537017 longitude:-0.2051676474374754];
    completionHandler(berlin, nil);
    return;
#endif
    static CLLocationManager * manager = nil;
    if(!manager) manager = [CLLocationManager new];
    if([manager respondsToSelector:@selector(requestWhenInUseAuthorization)]){
        [manager performSelector:@selector(requestWhenInUseAuthorization)];
    }
    [manager startUpdatingLocationWithUpdateBlock:^(CLLocationManager *manager, CLLocation *location, NSError *error, BOOL *stopUpdating) {
        if(error){
            completionHandler(nil, error);
        }else{
            completionHandler(location, nil);
        }
        //TODO: wait until accuracy is sufficient
        *stopUpdating = YES;
    }];
}

@end
