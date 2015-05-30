//
//  PlaylistItem.swift
//  GigRadio
//
//  Created by Michael Forrest on 17/05/2015.
//  Copyright (c) 2015 Good To Hear. All rights reserved.
//

import UIKit
import RealmSwift

class PlaylistPerformance: Object {
    dynamic var id = NSUUID().UUIDString
    override static func primaryKey()->String?{
        return "id"
    }
    
    dynamic var songKickEvent = SongKickEvent()
    dynamic var songKickArtist = SongKickArtist()
    dynamic var soundCloudUser = SoundCloudUser()
    
    dynamic var colorIndex = 0
    dynamic var createdAt = NSDate()
    
    dynamic var userHasBeenChecked = false
    
    
    var playlist: Playlist{
        return linkingObjects(Playlist.self, forProperty: "performances").first!
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
    func determineNextTrackToPlay(callback:(track:PlaylistTrack?)->Void){
        let realm = Realm()
        if BlacklistedArtist.includes(soundCloudUser){
            callback(track: nil)
            return
        }
        for track in soundCloudUser.tracks{
            if track.streamable && track.duration / 60000 <= 10{ // don't play tracks over 10 minutes (TODO: turn this into a setting)
                if playlist.tracks.filter("soundCloudTrack = %@", track).count == 0{
                    
                    realm.beginWrite()
                    let playlistTrack = PlaylistTrack()
                    playlistTrack.soundCloudTrack = track
                    playlistTrack.performance = self
                    playlist.tracks.append(playlistTrack)
                    realm.commitWrite()
                    
                    callback(track:playlistTrack)
                    return
                }
            }
        }
        callback(track:nil)
    }
}
