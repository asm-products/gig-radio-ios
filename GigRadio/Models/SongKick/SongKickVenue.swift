//
//  SongKickVenue.swift
//  GigRadio
//
//  Created by Michael Forrest on 17/05/2015.
//  Copyright (c) 2015 Good To Hear. All rights reserved.
//

import UIKit
import CoreLocation
import RealmSwift

class SongKickVenue: Object {
    dynamic var id = 0
    dynamic var lat: Double = 0
    dynamic var lng: Double = 0
    dynamic var displayName = ""
    dynamic var street = ""
    dynamic var zip = ""
    dynamic var capacity: Int = 0
    dynamic var descriptionText = ""
    dynamic var metroArea = SongKickMetroArea()
    
    dynamic var distanceCache: Double = 0
    
    
//    override static func primaryKey()->String?{
//        return "id"
//    }
    class func updateDistanceCachesWithLocation(location: CLLocation?){
        if let location = location{
            let realm = Realm()
            realm.write { () -> Void in
                for venue in realm.objects(SongKickVenue){
                    if let dest = venue.location(){
                        venue.distanceCache = location.distanceFromLocation(dest)
                    }else{
                        venue.distanceCache = 0 // not necessary unless upgrading dev version of app
                    }
                }
            }
        }
    }
    func location()->CLLocation?{
        if lat == 0 || lng == 0{
            return nil
        }else{
            return CLLocation(latitude: self.lat, longitude: self.lng)
        }
    }
    
    func address()->String{
        return "\(street) \(zip)"
    }
    func appleMapsUri()->String{
        return "http://maps.apple.com/?daddr=\(address().stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding))"
    }
    func citymapperUri()->String{
        // citymapper://directions?endcoord=51.563612,-0.073299&endname=Abney%20Park%20Cemetery&endaddress=Stoke%20Newington%20High%20Street
        return "citymapper://directions?endcoord=\(lat),\(lng)&endname=\(displayName.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding))&endaddress=\(address().stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding))"
    }
    
}
