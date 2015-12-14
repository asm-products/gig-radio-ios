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
    case TrackPlayed = "Track Played"
    case PlaybackPaused = "Playback Paused"
    case PlaybackResumed = "Playback Resumed"
}

class TrackingHelper: NSObject {

}
func trackEvent(event:TrackedEvent, properties:[String:AnyObject]){
    Mixpanel.sharedInstance().track(event.rawValue, properties: properties)
}
func timeEvent(event:TrackedEvent){
    Mixpanel.sharedInstance().timeEvent(event.rawValue)
}