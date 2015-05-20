//
//  PlaylistRun.swift
//  GigRadio
//
//  Created by Michael Forrest on 20/05/2015.
//  Copyright (c) 2015 Good To Hear. All rights reserved.
//

import UIKit
import RealmSwift

class PlaylistRun: Object {
    dynamic var items = List<PlaylistItem>()
    dynamic var createdAt = NSDate()
    
    class func current()->PlaylistRun{
        let realm = Realm()
        if let run = realm.objects(PlaylistRun).last{
            return run
        }else{
            let run = PlaylistRun()
            realm.write { realm.add(run, update: false) }
            return run
        }
    }
}
