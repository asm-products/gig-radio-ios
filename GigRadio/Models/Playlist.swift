//
//  Playlist.swift
//  GigRadio
//
//  Created by Michael Forrest on 20/05/2015.
//  Copyright (c) 2015 Good To Hear. All rights reserved.
//

import UIKit
import RealmSwift

enum PlaylistType: Int{
    case LocationTracking // needs a date
    case SpecificEvent
    case SpecificLocation // needs a date
}
class Playlist: Object {
    dynamic var id = NSUUID().UUIDString
    override static func primaryKey()->String?{
        return "id"
    }
    
    dynamic var type = PlaylistType.LocationTracking.rawValue
    
    dynamic var utcDate = CalendarHelper.startOfUTCDay(NSDate())
    
    dynamic var lat:Double = 0
    dynamic var lng:Double = 0
    
    var location:CLLocation{
        return CLLocation(latitude: lat, longitude: lng)
    }
    
    dynamic var specificEvent: SongKickEvent!
    
    let performances = List<PlaylistPerformance>()
    
    let tracks = List<PlaylistTrack>()
    
    var currentTrack: PlaylistTrack?
    override static func ignoredProperties() -> [String] {
        return ["nextTrackFinder"]
    }

    class func findOrCreateForUtcDate(utcDate:NSDate)->Playlist{
        let realm = try! Realm()
        let playlists = realm.objects(Playlist).filter("utcDate = %@", utcDate)
        if playlists.count == 0{
            realm.beginWrite()
            let playlist = realm.create(Playlist.self, value: ["utcDate":utcDate], update: true)
            try! realm.commitWrite()
            return playlist
        }else{
            return playlists.first!
        }
    }
    
    func setLocation(newValue:CLLocation){
        try! Realm().write{
            self.lat = newValue.coordinate.latitude
            self.lng = newValue.coordinate.longitude
        }
    }

    func fetchEvents(completion: ()->Void){
        SongKickClient.sharedClient.getEvents(utcDate, location: location, completion: { (eventIds, error) -> Void in
            if let ids = eventIds{
                self.addOrUpdateEventIds(ids)
            }
            SongKickVenue.updateDistanceCachesWithLocation(self.location)
            self.sortEvents()
            completion()
        })
    }
    func sortEvents(){
        //TODO: sort events by preference
//        switch Defaults.venueSortOrder{
//            case .Natural
//            case .NearestFirst
//        }
    }
    func addOrUpdateEventIds(ids:[Int]){
        let realm = try! Realm()
        let events = realm.objects(SongKickEvent).filter("id in %@", ids)
        try! realm.write {
            // temporary soundcloud stuff cos realm doesn't support nil values
            var soundCloudUser = realm.objectForPrimaryKey(SoundCloudUser.self, key: 0)
            if soundCloudUser == nil {
                soundCloudUser = SoundCloudUser()
            }
            
            for event in events{
                let eventMissingFromRun = self.performances.filter("songKickEvent == %@", event).count == 0
                let statusIsOkay = event.status == "ok"
                if eventMissingFromRun && statusIsOkay{
                    for performance in event.performance{
                        let item = PlaylistPerformance()
                        item.songKickEvent = event
                        item.songKickArtist = performance.artist
                        item.soundCloudUser = soundCloudUser!
                        self.performances.append(item)
                    }
                }
            }
            
            var gradientIndex = 0
            let incrementGradientIndex:()->Void = {
                gradientIndex += 1
                gradientIndex %= Colors.gradients().count
            }
            for item in self.performances{
                item.colorIndex = gradientIndex
                incrementGradientIndex()
            }
        }
    }
    var nextTrackFinder: NextTrackFinder?
    func determineTrackAfter(track:PlaylistTrack?, callback:(track:PlaylistTrack?)->Void){ // optional for edge case of totally running out of music to play
        if let track = track{
            // continue playlist
            if let index = tracks.indexOf(track){
                if index < tracks.count - 1{ // we've been re-playing tracks and are moving back through the playlist
                    callback(track: tracks[index + 1])
                }else{
                    self.nextTrackFinder = NextTrackFinder(performance:track.performance, callback: callback)
                }
            }
        }else{
            // set up playlist
            if let performance = performances.last{ // force it to loop round
                self.nextTrackFinder = NextTrackFinder(performance:performance, callback: callback)
            }else{
                callback(track: nil) // no performances available
            }
        }
    }
    func removeTracksForPerformance(performance:PlaylistPerformance){
        let tracks = self.tracks.filter("performance = %@", performance)
        let realm = try! Realm()
        try! realm.write {
            realm.delete(tracks)
        }
    }
    func removeTracksBySoundCloudUser(user: SoundCloudUser){
        let realm = try! Realm()
        var ids = [String]()
        for track in self.tracks{
            if track.performance.soundCloudUser == user{
                ids.append(track.id)
            }
        }
        let tracks = self.tracks.filter("id in %@", ids)
        try! realm.write {
            realm.delete(tracks)
        }
    }
}
