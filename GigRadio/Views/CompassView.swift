//
//  CompassView.swift
//  GigRadio
//
//  Created by Michael Forrest on 17/05/2015.
//  Copyright (c) 2015 Good To Hear. All rights reserved.
//

import UIKit
import CoreLocation

class CompassView: UIView, CLLocationManagerDelegate {
    var needle: UIImageView!
    var locationManager: CLLocationManager!
    var currentLocation: CLLocation?
    var currentHeading: CLHeading?
    var destination: CLLocation?
    
    override func awakeFromNib() {
        self.backgroundColor = UIColor.clearColor()
        let center = CGPoint(x: CGRectGetMidX(self.bounds), y: CGRectGetMidY(self.bounds))
        let background = UIImageView(image: UIImage(named: "compass_background"))
        background.center = center
        addSubview(background)
        
        needle = UIImageView(image: UIImage(named: "compass_needle"))
        addSubview(needle)
        needle.center = center
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.startUpdatingHeading()
        locationManager.startUpdatingLocation()
    }
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.last
        updateNeedle()
    }
    func locationManager(manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        currentHeading = newHeading
        updateNeedle()
    }
    func updateNeedle(){
        if let destination = self.destination, currentLocation = self.currentLocation, currentHeading = self.currentHeading{
            let northPoint = CLLocation(latitude: currentLocation.coordinate.latitude + 0.1, longitude:destination.coordinate.longitude )
            
            let magA = northPoint.distanceFromLocation(currentLocation)
            let magB = destination.distanceFromLocation(currentLocation)
            let startLat = CLLocation(latitude: currentLocation.coordinate.latitude, longitude: 0)
            let endLat = CLLocation(latitude: destination.coordinate.latitude, longitude: 0)
            let aDotB = magA * endLat.distanceFromLocation(startLat)
            let bearing: CGFloat = CGFloat(acos(aDotB / (magA * magB)))
            let heading = CGFloat(M_PI * 2 * currentHeading.trueHeading / 360.0)
            needle.transform = CGAffineTransformMakeRotation(bearing - heading)
            
        }else{
            needle.transform = CGAffineTransformIdentity
        }
    }
}
