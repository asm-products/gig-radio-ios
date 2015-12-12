//
//  SongKickEvent.swift
//  GigRadio
//
//  Created by Michael Forrest on 17/05/2015.
//  Copyright (c) 2015 Good To Hear. All rights reserved.
//

import UIKit
import RealmSwift

class SongKickEvent: Object {
    dynamic var id: Int = 0
    dynamic var type = "concert"
    dynamic var displayName = ""
    dynamic var venue: SongKickVenue!
    let performance = List<SongKickPerformance>()
    dynamic var start: SongKickDateTime!
    dynamic var end: SongKickDateTime!
    dynamic var uri = ""
    dynamic var descriptionText = ""
    dynamic var popularity: Double = 0
    dynamic var series: SongKickDisplayName?
    dynamic var status = "ok"
    
    dynamic var distanceCache: Double = 0
    dynamic var date:NSDate = NSDate(timeIntervalSince1970: 0) // don't accidentally accumulate events for today; set this long in the past
    
    override static func primaryKey()->String?{
        return "id"
    }
    func artistNames()->[String]{
        var names = [String]()
        for p in performance{
           names.append(p.artist.displayName)
        }
        return names
    }
    
    class func eventCountOnDate(date:NSDate)->Int{
        return try! Realm().objects(SongKickEvent).filter("date = %@", date).count
    }
}
