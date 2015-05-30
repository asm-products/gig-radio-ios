//
//  PlaylistTrack.swift
//  GigRadio
//
//  Created by Michael Forrest on 30/05/2015.
//  Copyright (c) 2015 Good To Hear. All rights reserved.
//

import UIKit
import RealmSwift
class PlaylistTrack: Object {
    dynamic var id = NSUUID().UUIDString
    override static func primaryKey()->String?{
        return "id"
    }
    dynamic var soundCloudTrack = SoundCloudTrack()
    dynamic var performance = PlaylistPerformance()
}
