//
//  SongKickArtist.swift
//  GigRadio
//
//  Created by Michael Forrest on 17/05/2015.
//  Copyright (c) 2015 Good To Hear. All rights reserved.
//

import UIKit
import RealmSwift

class SongKickArtist: Object {
    dynamic var id: Int = 0
    dynamic var uri = ""
    dynamic var displayName = ""
    dynamic var soundCloudUserId: Int = 0

    override static func primaryKey()->String?{
        return "id"
    }
    func imageUrl()->String{
        return "http://images.sk-static.com/images/media/profile_images/artists/\(id)/huge_avatar"
    }
}
