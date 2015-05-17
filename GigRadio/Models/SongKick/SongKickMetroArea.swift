//
//  SongKickMetroArea.swift
//  GigRadio
//
//  Created by Michael Forrest on 17/05/2015.
//  Copyright (c) 2015 Good To Hear. All rights reserved.
//

import UIKit
import RealmSwift

class SongKickMetroArea: Object {
    dynamic var id = 0
    dynamic var displayName = ""
    dynamic var country = SongKickDisplayName()
    dynamic var lat:Double = 0
    dynamic var lng:Double = 0
    
}
