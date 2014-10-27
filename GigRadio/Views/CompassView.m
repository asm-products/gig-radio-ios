//
//  CompassView.m
//  GigRadio
//
//  Created by Michael Forrest on 26/10/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import "CompassView.h"
#import "LocationHelper.h"

@implementation CompassView{
    UIImageView * needle;
    CLLocationManager * locationManager;
    CLLocation * currentLocation;
    CLHeading * currentHeading;
}

-(void)awakeFromNib{
    self.backgroundColor = [UIColor clearColor];
    CGPoint center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    UIImageView * background = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"compass_background"]];
    background.center = center;
    [self addSubview:background];
    
    needle = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"compass_needle"]];
    [self addSubview:needle];
    needle.center = center;
    
    locationManager = [CLLocationManager new];
    locationManager.delegate = self;
    [locationManager startUpdatingHeading];
    [locationManager startUpdatingLocation];
}
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    currentLocation = locations.lastObject;
    [self updateNeedle];
}
-(void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading{
    currentHeading = newHeading;
    [self updateNeedle];
}
-(void)updateNeedle{
    if(self.destination && currentHeading && currentLocation){
        CLLocation *northPoint = [[CLLocation alloc] initWithLatitude:(currentLocation.coordinate.latitude)+.01 longitude:self.destination.coordinate.longitude];
        float magA = [northPoint distanceFromLocation:currentLocation];
        float magB = [self.destination distanceFromLocation:currentLocation];
        CLLocation *startLat = [[CLLocation alloc] initWithLatitude:currentLocation.coordinate.latitude longitude:0];
        CLLocation *endLat = [[CLLocation alloc] initWithLatitude:self.destination.coordinate.latitude longitude:0];
        float aDotB = magA*[endLat distanceFromLocation:startLat];
        float bearing = acosf(aDotB/(magA*magB));
        float heading = M_PI * 2 * currentHeading.trueHeading / 360.0;
        needle.transform = CGAffineTransformMakeRotation( bearing - heading );
    }else{
        needle.transform = CGAffineTransformIdentity;
    }
}
@end
