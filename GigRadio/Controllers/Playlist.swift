//
//  Playlist.swift
//  GigRadio
//
//  Created by Michael Forrest on 20/05/2015.
//  Copyright (c) 2015 Good To Hear. All rights reserved.
//

import UIKit
import RealmSwift

class Playlist: NSObject {
    static let sharedPlaylist = Playlist()
    
//    var currentItemIndexPath
    
    func updateLatestRunWithEventIds(ids:[Int], date: NSDate){
        var run = PlaylistRun.current()
        
        let realm = Realm()
        let events = realm.objects(SongKickEvent).filter("id in %@", ids)
        var itemsToRemove = [PlaylistItem]()
        
        for item in run.items{
            if item.hasBeenPlayed == false{
                // remove it if it's not in the new set
                let itemEventIsMissing = events.filter("id = %i", item.songKickEvent.id).count == 0
                if itemEventIsMissing{
                    itemsToRemove.append(item)
                }
                // TODO: update existing event?
            }
        }
        realm.write {
            for item in itemsToRemove{
                if let index = run.items.indexOf(item){
                    run.items.removeAtIndex(index)
                }
            }
            // temporary soundcloud stuff cos realm doesn't support nil values
            var soundCloudUser = realm.objectForPrimaryKey(SoundCloudUser.self, key: 0)
            var soundCloudTrack = realm.objectForPrimaryKey(SoundCloudTrack.self, key: 0)
            if soundCloudUser == nil {
                soundCloudUser = SoundCloudUser()
            }
            if soundCloudTrack == nil{
                soundCloudTrack = SoundCloudTrack()
            }
            
            for event in events{
                let eventMissingFromRun = run.items.filter("songKickEvent == %@", event).count == 0
                if eventMissingFromRun{
                    for performance in event.performance{
                        let item = PlaylistItem()
                        item.date = date
                        item.songKickEvent = event
                        item.songKickArtist = performance.artist
                        item.soundCloudUser = soundCloudUser!
                        item.soundCloudTrack = soundCloudTrack!
                        run.items.append(item)
                    }
                }
            }
            
            var gradientIndex = 0
            let incrementGradientIndex:()->Void = {
                gradientIndex += 1
                gradientIndex %= Colors.gradients().count
            }
            for item in run.items{
                item.colorIndex = gradientIndex
                incrementGradientIndex()
            }
        }

        
    }
    
}
