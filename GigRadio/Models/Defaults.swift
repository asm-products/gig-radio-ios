//
//  Defaults.swift
//  GigRadio
//
//  Created by Michael Forrest on 22/07/2015.
//  Copyright (c) 2015 Good To Hear. All rights reserved.
//

import UIKit

let VenueSortOrderKey = "VenueSortOrder"
let TrackLengthFilterKey = "TrackLengthFilter"
let SpokenAnnouncementsKey = "SpokenAnnouncementsActive"
let PlaylistFollowActionKey = "PlaylistFollowAction"

enum VenueSortOrder: Int{
    case Natural = 0
    case NearestFirst = 1
}
enum TrackLengthFilter: Int{
    case Short = 0
    case All = 1
    case Long = 2
}
enum SpokenAnnouncements:Int{
    case Off = 0
    case On = 1
}
enum PlaylistFollowAction:Int{
    case LoopDay = 0
    case PlayNextDay = 1
}
class Defaults: NSObject {
    class func register(){
        NSUserDefaults.standardUserDefaults().registerDefaults([
            VenueSortOrderKey: VenueSortOrder.Natural.rawValue,
            TrackLengthFilterKey: TrackLengthFilter.Short.rawValue,
            SpokenAnnouncementsKey: SpokenAnnouncements.Off.rawValue,
            PlaylistFollowActionKey: PlaylistFollowAction.LoopDay.rawValue
            ])
    }
    class var venueSortOrder: VenueSortOrder{
        return VenueSortOrder(rawValue: intFor(VenueSortOrderKey))!
    }
    class var trackLengthFilter: TrackLengthFilter{
        return TrackLengthFilter(rawValue: intFor(TrackLengthFilterKey))!
    }
    class var spokenAnnouncements: SpokenAnnouncements{
        return SpokenAnnouncements(rawValue: intFor(SpokenAnnouncementsKey))!
    }
    class var playlistFollowAction: PlaylistFollowAction{
        return PlaylistFollowAction(rawValue: intFor(PlaylistFollowActionKey))!
    }
    class func intFor(key:String)->Int{
        return NSUserDefaults.standardUserDefaults().integerForKey(key)
    }
   
}
