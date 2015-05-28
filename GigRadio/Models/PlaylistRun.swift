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
    class func allRunsInReverseOrder()->[PlaylistRun]{
        var result = [PlaylistRun]()
        for run in Realm().objects(PlaylistRun).sorted("createdAt", ascending: false){
            result.append(run)
        }
        return result
    }
    class func current()->PlaylistRun{
        if let run = Realm().objects(PlaylistRun).last{
            if run.isComplete(){
                return createNewRun()
            }else{
                return run
            }
        }else{
            return createNewRun()
        }
    }
    class func createNewRun()->PlaylistRun{
        let run = PlaylistRun()
        let realm = Realm()
        realm.write { realm.add(run, update: false) }
        return run
    }
    func indexOfLastUnplayedItem()->Int?{
        for (index,item) in enumerate(items){
            if item.hasBeenPlayed == false && ((item.userHasBeenChecked == false && item.soundCloudUser.id == 0) || item.soundCloudUser.couldHaveTracksAvailable){
                return index
            }
        }
        return nil
    }
    func isComplete()->Bool{
        return indexOfLastUnplayedItem() == nil
    }
    func globalIndex()->Int?{
        return Realm().objects(PlaylistRun).indexOf(self)
    }
}
