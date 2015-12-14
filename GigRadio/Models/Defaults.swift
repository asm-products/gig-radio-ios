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
    case NearestFirst = 0
    case Natural = 1
    var description: String{
        switch self {
        case .NearestFirst: return "Nearest First"
        case .Natural: return "Natural"
        }
    }
}
enum TrackLengthFilter: Int{
    case Short = 0
    case All = 1
    case Long = 2
    var description: String {
        switch self {
        case .Short: return "< 10 Minutes"
        case .All: return "All"
        case .Long: return "> 10 Minutes"
        }
    }
}
enum SpokenAnnouncements:Int{
    case Off = 0
    case On = 1
    var description: String{
        switch self {
        case .Off: return "Off"
        case .On: return "On"
        }
    }
}
enum PlaylistFollowAction:Int{
    case LoopDay = 0
    case PlayNextDay = 1
    var description: String{
        switch self {
        case .LoopDay: return "Same Day"
        case .PlayNextDay: return "Continue To Next Day"
        }
    }
}

let DidChangeVenueSortOrderNotification = "DidChangeVenueSortOrderNotification"
let DidChangeTrackLengthFilterNotification = "DidChangeTrackLengthFilterNotification"
let DidChangeSpokenAnnouncementsNotification = "DidChangeSpokenAnnouncementsNotification"
let DidChangePlaylistFollowActionNotification = "DidChangePlaylistFollowActionNotification"

class Defaults: NSObject {
    class func register(){
        NSUserDefaults.standardUserDefaults().registerDefaults([
            VenueSortOrderKey: VenueSortOrder.NearestFirst.rawValue,
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
