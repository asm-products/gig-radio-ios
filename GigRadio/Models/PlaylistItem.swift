//
//  PlaylistItem.swift
//  GigRadio
//
//  Created by Michael Forrest on 17/05/2015.
//  Copyright (c) 2015 Good To Hear. All rights reserved.
//

import UIKit
import RealmSwift

class PlaylistItem: Object {
    dynamic var id = NSUUID().UUIDString
    dynamic var songKickEvent = SongKickEvent()
    dynamic var songKickArtist = SongKickArtist()
    
    dynamic var soundCloudUser = SoundCloudUser()
    dynamic var soundCloudTrack = SoundCloudTrack()
    
    dynamic var colorIndex = 0
    dynamic var createdAt = NSDate()
    
    
    dynamic var hasBeenPlayed = false
    
    override static func primaryKey()->String?{
        return "id"
    }
}
