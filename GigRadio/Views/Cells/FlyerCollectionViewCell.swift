//
//  FlyerCollectionViewCell.swift
//  GigRadio
//
//  Created by Michael Forrest on 17/05/2015.
//  Copyright (c) 2015 Good To Hear. All rights reserved.
//

import UIKit
import MapKit

class FlyerCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var compass: CompassView!
    @IBOutlet weak var detailsButton: UIButton!
    @IBOutlet weak var lineupLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    var playlistItem: PlaylistItem?{
        didSet{
            if let lineupLabel = lineupLabel{
                lineupLabel.attributedText = attributedLineupText
                imageView.image = UIImage(named: "foo.jpg")
            }
            compass.destination = playlistItem?.songKickEvent.venue.location()
            let startTime = playlistItem!.songKickEvent.start.parsedDateTime()
            let time = startTime == nil ? "" : DateFormats.timeFormatter().stringFromDate(startTime!)
            let venue = playlistItem!.songKickEvent.venue.displayName
            let df = MKDistanceFormatter()
            df.unitStyle = .Abbreviated
            let distance = df.stringFromDistance(playlistItem!.songKickEvent.distanceCache)
            let template = t("TimeVenueAndDistance.Title")
            let text = String(format: template, arguments: [time, venue, distance])
            detailsButton.setTitle(text, forState: .Normal)
        }
    }
    let FocusedArtistAttributes = [NSFontAttributeName: UIFont(name: "Roboto-Light", size: 36)!]
    let DefaultAttributes = [NSFontAttributeName: UIFont(name: "Roboto-Light", size: 24)!]
    
    var attributedLineupText: NSAttributedString{
        if let item = playlistItem{
            let focusedArtist = item.songKickArtist
            let result = NSMutableAttributedString(string: "")
            for performance in item.songKickEvent.performance{
                let attributes: [NSObject:AnyObject] = ( (performance.artist.id == focusedArtist.id) ? FocusedArtistAttributes : DefaultAttributes)
                let string = NSAttributedString(string: performance.artist.displayName, attributes: attributes)
                
                result.appendAttributedString(string)
            }
            return result
        }else{
            return NSAttributedString(string: "Error")
        }
    }
}
