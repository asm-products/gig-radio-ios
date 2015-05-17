//
//  SongKickPerformance.swift
//  GigRadio
//
//  Created by Michael Forrest on 17/05/2015.
//  Copyright (c) 2015 Good To Hear. All rights reserved.
//

import UIKit
import RealmSwift

class SongKickPerformance: Object {
    dynamic var id: Int = 0
    dynamic var displayName = ""
    dynamic var artist = SongKickArtist()
    
    override static func primaryKey()->String?{
        return "id"
    }
}
