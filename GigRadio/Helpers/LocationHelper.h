//
//  LocationHelper.h
//  GigRadio
//
//  Created by Michael Forrest on 16/08/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import <Foundation/Foundation.h>

@import CoreLocation;
@interface LocationHelper : NSObject
+(void)track:(void(^)(CLLocation*__nullable location, NSError*__nullable error))completionHandler;
@end
