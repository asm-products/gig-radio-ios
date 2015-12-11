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
    
    dynamic var songKickEvent:SongKickEvent!
    dynamic var songKickArtist: SongKickArtist!
    dynamic var soundCloudUser: SoundCloudUser!
    
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
                try! Realm().write{
                    self.userHasBeenChecked = true
                    if user != nil{
                        self.soundCloudUser = user!
                        self.songKickArtist.soundCloudUserId = user!.id
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
                try! Realm().write{
                    self.soundCloudUser.tracksHaveBeenChecked = true
                }
                callback(trackCount: self.soundCloudUser.tracks.filter("streamable = %@", true).count, error:error)
            }
        }
    }
    func determineNextTrackToPlay(callback:(track:PlaylistTrack?)->Void){
        let realm = try! Realm()
        if BlacklistedArtist.includes(soundCloudUser){
            print("Skipping blacklisted user \(soundCloudUser.username)")
            callback(track: nil)
            return
        }
        for track in soundCloudUser.tracks{
            if track.streamable && shouldAllowTrack(track){
                if playlist.tracks.filter("soundCloudTrack = %@", track).count == 0{
                    
                    realm.beginWrite()
                    let playlistTrack = PlaylistTrack()
                    playlistTrack.soundCloudTrack = track
                    playlistTrack.performance = self
                    playlist.tracks.append(playlistTrack)
                    try! realm.commitWrite()
                    
                    callback(track:playlistTrack)
                    return
                }
            }
        }
        callback(track:nil)
    }
    func shouldAllowTrack(track:SoundCloudTrack)->Bool{
        switch Defaults.trackLengthFilter{
        case .Short: return track.duration / 60000 <= 10
        case .All: return true
        case .Long: return track.duration / 60000 > 10
        }

    }
}
