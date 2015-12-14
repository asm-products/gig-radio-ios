//
//  TrackingHelper.swift
//  GigRadio
//
//  Created by Michael Forrest on 14/12/2015.
//  Copyright © 2015 Good To Hear. All rights reserved.
//

import UIKit
import Mixpanel
enum TrackedEvent: String{
    case TappedDateHeader = "Tapped Date Header"
    case ChangedDate = "Changed Date"
    case TrackPlayed = "Track Played"
    case SkippedForward = "Skipped Forward"
    case SkippedBackward = "Skipped Backward"
    case PlaybackPaused = "Playback Paused"
    case PlaybackResumed = "Playback Resumed"
    case ProblemButtonPressed = "Problem Button Pressed"
    case BlacklistedArtistAdded = "Artist Blacklisted"
    case BlacklistedArtistRemoved = "Artist Unblacklisted"
    case SoundCloudUsersListed = "SoundCloud Users Listed"
    case SoundCloudUserChanged = "SoundCloud User Changed"
    case SoundCloudUserViewed = "SoundCloud User Viewed"
    case FavouriteEventAdded = "Favourite Event Added"
    case FavouriteEventRemoved = "Favourite Event Removed"
    case EventDetailsViewed = "Event Details Viewed"
    case MapLinkViewed = "Map Link Viewed"
    case MappingPreferenceChanged = "Mapping Preference Changed"
    case SongKickEventViewed = "SongKick Event Viewed"
    case SongKickArtistViewed = "SongKick Artist Viewed"
    case PlaylistOrderChanged = "Playlist Order Changed"
    case TrackLengthFilterChanged = "Track Length Filter Changed"
    case PlaylistFollowActionChanged = "Playlist Follow Action Changed"
    case SpokenAnnouncementsChanged = "Spoken Announcements Changed"
    case InfoLinkFollowed = "Creator Link Followed"
}

class TrackingHelper: NSObject {

}
func trackEvent(event:TrackedEvent, properties:[String:AnyObject]){
    Mixpanel.sharedInstance().track(event.rawValue, properties: properties)
}
func timeEvent(event:TrackedEvent){
    Mixpanel.sharedInstance().timeEvent(event.rawValue)
}