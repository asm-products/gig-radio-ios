//
//  PlaylistHelper.swift
//  GigRadio
//
//  Created by Michael Forrest on 28/05/2015.
//  Copyright (c) 2015 Good To Hear. All rights reserved.
//

import UIKit
import MapKit

let TrackTitleAttributes = [NSFontAttributeName: UIFont(name: "Roboto-Bold", size: 12)!]
let TrackArtistAttributes = [NSFontAttributeName: UIFont(name: "Roboto-Regular", size: 12)!]

class PlaylistHelper: NSObject {
   
    
    class func attributedTrackInfoText(item:PlaylistItem, separator:String)-> NSAttributedString{
        if item.soundCloudTrack.id == 0{
            return NSAttributedString(string: "")
        }
        var result = NSMutableAttributedString(string: "")
        let trackText = NSAttributedString(string: item.soundCloudTrack.title, attributes: TrackTitleAttributes)
        let artistText = NSAttributedString(string: item.soundCloudUser.displayName(), attributes: TrackArtistAttributes)
        result.appendAttributedString(trackText)
        result.appendAttributedString(NSAttributedString(string: separator))
        result.appendAttributedString(artistText)
        return result
    }
    class func dateAndVenueText(event:SongKickEvent)->String{
        let venue = event.venue.displayName
        let template = t("TimeVenueAndDistance.Title")
        var timeAndVenueText = venue
        if let startTime = event.start.parsedDateTime(){
            let time = DateFormats.timeFormatter().stringFromDate(startTime)
            timeAndVenueText = String(format: template, arguments: [time, venue])
        }
        var text = timeAndVenueText
        
        if event.venue.distanceCache > 0{
            let df = MKDistanceFormatter()
            df.unitStyle = .Abbreviated
            let distance = df.stringFromDistance(event.venue.distanceCache)
            let distanceText = String(format: t("TimeVenueAndDistance.Distance"), distance)
            text += distanceText
        }
        return text
    }
}
