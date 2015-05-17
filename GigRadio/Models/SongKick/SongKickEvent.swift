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
    dynamic var venue = SongKickVenue()
    dynamic var performance = List<SongKickPerformance>()
    dynamic var start = SongKickDateTime()
    dynamic var end = SongKickDateTime()
    dynamic var uri = ""
    dynamic var descriptionText = ""
    dynamic var popularity: Double = 0
    dynamic var series = SongKickDisplayName()
    
    dynamic var distanceCache: Double = 0
    
    override static func primaryKey()->String?{
        return "id"
    }
}
