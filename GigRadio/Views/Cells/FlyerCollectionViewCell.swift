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
    
    override class func layerClass()->AnyClass{
        return CAGradientLayer.self
    }
    
    var playlistItem: PlaylistItem?{
        didSet{
            if let lineupLabel = lineupLabel{
                lineupLabel.attributedText = attributedLineupText
            }
            imageView.image = nil
            if let item = playlistItem{
                updateGradient(item.colorIndex)
                if let image = cachedImage(item.songKickArtist.imageUrl()){
                    imageView.image = image
                }else{
                    imageView.image = UIImage(named: "flyer-placeholder")
                }
                compass.destination = item.songKickEvent.venue.location()
                let startTime = item.songKickEvent.start.parsedDateTime()
                let time = startTime == nil ? "" : DateFormats.timeFormatter().stringFromDate(startTime!)
                let venue = item.songKickEvent.venue.displayName
                let df = MKDistanceFormatter()
                df.unitStyle = .Abbreviated
                let distance = df.stringFromDistance(item.songKickEvent.distanceCache)
                let template = t("TimeVenueAndDistance.Title")
                let text = String(format: template, arguments: [time, venue, distance])
                detailsButton.setTitle(text, forState: .Normal)
                
            }
            
        }
    }
    func updateGradient(index:Int){
        let layer = self.layer as! CAGradientLayer
        layer.colors = Colors.gradient(index).map({$0.CGColor})
        layer.startPoint = CGPoint(x: 0, y: 0)
        layer.endPoint = CGPoint(x: 0, y: 1)
    }
    
    
    let FocusedArtistAttributes = [NSFontAttributeName: UIFont(name: "Roboto-Light", size: 40)!]
    let DefaultAttributes = [NSFontAttributeName: UIFont(name: "Roboto-Light", size: 24)!]
    
    var attributedLineupText: NSAttributedString{
        if let item = playlistItem{
            let focusedArtist = item.songKickArtist
            let result = NSMutableAttributedString(string: "")
            let acts = item.songKickEvent.performance
            for (index, performance) in enumerate(acts){
                let attributes: [NSObject:AnyObject] = ( (performance.artist.id == focusedArtist.id) ? FocusedArtistAttributes : DefaultAttributes)
                let string = NSAttributedString(string: performance.artist.displayName + (index < acts.count - 1 ? "\n" : ""), attributes: attributes)
                
                result.appendAttributedString(string)
            }
            return result
        }else{
            return NSAttributedString(string: "Error")
        }
    }
}
