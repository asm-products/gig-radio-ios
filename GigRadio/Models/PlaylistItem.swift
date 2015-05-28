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
    
    dynamic var date: NSDate = CalendarHelper.startOfUTCDay(NSDate()) // should be UTC-start-of-day
    dynamic var songKickEvent = SongKickEvent()
    dynamic var songKickArtist = SongKickArtist()
    
    dynamic var soundCloudUser = SoundCloudUser()
    dynamic var soundCloudTrack = SoundCloudTrack()
    
    dynamic var colorIndex = 0
    dynamic var createdAt = NSDate()
    
    dynamic var userHasBeenChecked = false
    dynamic var hasBeenPlayed = false
    
    override static func primaryKey()->String?{
        return "id"
    }
    
    
    func determineSoundCloudUser(callback:(user:SoundCloudUser?,error:NSError?)->Void){
        if soundCloudUser.id != 0{
            callback(user: self.soundCloudUser, error:nil)
        }else{
            SoundCloudClient.sharedClient.findUser(songKickArtist.displayName) { (user,error) -> Void in
                Realm().write{
                    self.userHasBeenChecked = true
                    if user != nil{
                        self.soundCloudUser = user!
                    }
                }
                callback(user: user, error:error)
            }
        }
    }
    func determineTracksAvailable(callback:(trackCount:Int?,error:NSError?)->Void){
        if soundCloudUser.tracksHaveBeenChecked{
            callback(trackCount: self.soundCloudUser.tracks.filter("streamable = %@", true).count, error:nil)
        }else{
            SoundCloudClient.sharedClient.getTracks(soundCloudUser){ error in
                Realm().write{
                    self.soundCloudUser.tracksHaveBeenChecked = true
                }
                callback(trackCount: self.soundCloudUser.tracks.filter("streamable = %@", true).count, error:error)
            }
        }
    }
    func determineNextTrackToPlay(callback:(SoundCloudTrack?)->Void){
        // find all the playlist items that include this user
        // reject any tracks that have been included in a playlist already
        // return the next track. We should filter on the date. probably just the date
        let realm = Realm()
        let allPlaylistItems = realm.objects(PlaylistItem).filter("date = %@", self.date)
        for track in soundCloudUser.tracks{
            if track.streamable{
                if allPlaylistItems.filter("soundCloudTrack = %@", track).count == 0{
                    realm.write {
                        self.soundCloudTrack = track
                    }
                    callback(track)
                    return
                }
            }
        }
        callback(nil)
    }
    func markPlayed(){
        Realm().write {
            self.hasBeenPlayed = true
        }
    }
}
