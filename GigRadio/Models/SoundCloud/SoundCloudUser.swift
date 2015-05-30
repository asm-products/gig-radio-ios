//
//  SoundCloudUser.swift
//  GigRadio
//
//  Created by Michael Forrest on 17/05/2015.
//  Copyright (c) 2015 Good To Hear. All rights reserved.
//

import UIKit
import RealmSwift

class SoundCloudUser: Object {
    dynamic var id: Int = 0
    dynamic var kind = ""
    dynamic var permalink = ""
    dynamic var username = ""
    dynamic var uri = ""
    dynamic var permalinkUrl = ""
    dynamic var avatarUrl = ""
    dynamic var fullName = ""
    dynamic var descriptionText  = ""
    dynamic var city = ""
    dynamic var country = ""
    dynamic var website = ""
    dynamic var websiteTitle = ""
    dynamic var trackCount: Int = 0
    dynamic var playlistCount: Int = 0
    dynamic var followersCount: Int = 0
    dynamic var followingsCount: Int = 0

    dynamic var tracks = List<SoundCloudTrack>()
    dynamic var tracksHaveBeenChecked = false
    
    override static func primaryKey()->String?{
        return "id"
    }
    var couldHaveTracksAvailable:Bool{
        return tracksHaveBeenChecked == false || tracks.count > 0
    }
    func displayName()->String{
       var result = fullName
        if result == ""{
            result = username
        }
        return result
    }
    func showOnSoundCloud(){
        let url = NSURL(string:"soundcloud://users:\(id)")!
        let app = UIApplication.sharedApplication()
        if app.canOpenURL(url){
            app.openURL(url)
        }else{
            let url = NSURL(string: "https://soundcloud.com/\(permalink)")!
            app.openURL(url)
        }
    }
}
