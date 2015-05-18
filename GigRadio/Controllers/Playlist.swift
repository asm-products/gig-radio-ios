//
//  Playlist.swift
//  GigRadio
//
//  Created by Michael Forrest on 17/05/2015.
//  Copyright (c) 2015 Good To Hear. All rights reserved.
//

import UIKit
import CoreLocation
import RealmSwift

class Playlist: NSObject, CLLocationManagerDelegate {
    var locationManager: CLLocationManager?
    let CrashTimeoutInterval: NSTimeInterval = 10 * 60 * 60
    
    var currentItem: PlaylistItem?
    var currentDate = NSDate()
    
    init(accurateLocation: Bool){
        super.init()
        if accurateLocation {
            locationManager = CLLocationManager()
            locationManager?.delegate = self
            locationManager?.startUpdatingLocation()
        }
    }
    
    func loadFirstItem(callback:(item:PlaylistItem?, error: NSError?)->Void){
        // see if we were halfway through playing one just now
        let realm = Realm()
        let items = realm.objects(PlaylistItem).filter("mightHaveCrashed = true AND createdAt < %@", NSDate().dateByAddingTimeInterval(-CrashTimeoutInterval))
        if items.count > 0{
            currentItem  = items.last
        }
        let songKick = SongKickClient.sharedClient
        songKick.getEvents(currentDate, location: locationManager?.location) { (error) -> Void in
            self.figureOutWhatToPlayNext()
        }
        callback(item: currentItem, error: nil)
    }
    func figureOutWhatToPlayNext(){
        let realm = Realm()
        if let event = realm.objects(SongKickEvent).first{
            let item = PlaylistItem()
            item.id = "0"
            item.songKickEvent = event
                realm.write {
                    realm.add(item, update: true)
            }
            
        }
    }
    
}
