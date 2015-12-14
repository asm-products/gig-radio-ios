//
//  FlyerCollectionViewCell.swift
//  GigRadio
//
//  Created by Michael Forrest on 17/05/2015.
//  Copyright (c) 2015 Good To Hear. All rights reserved.
//

import UIKit
import MapKit

protocol FlyerCollectionViewCellDelegate{
    func flyerCellShowEventButtonPressed(event:SongKickEvent)
    func flyerCellTrackCountButtonPressed(performance:PlaylistPerformance)
}

class FlyerCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var compass: CompassView!
    @IBOutlet weak var detailsButton: UIButton!
    @IBOutlet weak var lineupLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var baselineConstraint: NSLayoutConstraint!
    @IBOutlet weak var favouriteButton: UIButton!
    
    var delegate : FlyerCollectionViewCellDelegate!
    
    override class func layerClass()->AnyClass{
        return CAGradientLayer.self
    }
    
    var performance: PlaylistPerformance?{
        didSet{
            if let lineupLabel = lineupLabel{
                lineupLabel.attributedText = attributedLineupText
            }
            imageView.image = nil
            if let item = performance{
                updateGradient(item.colorIndex)
                if let image = cachedImage(item.songKickArtist.imageUrl()){
                    imageView.image = image
                }else{
                    imageView.image = UIImage(named: "flyer-placeholder")
                }
                if let location = item.songKickEvent.venue.location(){
                   compass.destination =  location
                }
                
                detailsButton.setTitle(PlaylistHelper.dateAndVenueText(item.songKickEvent), forState: .Normal)
                updateFavouriteState(item)
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
        if let item = performance{
            let focusedArtist = item.songKickArtist
            let result = NSMutableAttributedString(string: "")
            let acts = item.songKickEvent.performance
            for (index, performance) in acts.enumerate(){
                var attributes: [String:AnyObject] = ( (performance.artist.id == focusedArtist.id) ? FocusedArtistAttributes : DefaultAttributes)
                if BlacklistedArtist.includesSoundCloudUserWithId(performance.artist.soundCloudUserId) == true{
                    attributes[NSStrikethroughStyleAttributeName] = NSUnderlineStyle.StyleSingle.rawValue
                }else{
                    attributes[NSStrikethroughStyleAttributeName] = 0
                }
                let string = NSAttributedString(string: performance.artist.displayName + (index < acts.count - 1 ? "\n" : ""), attributes: attributes)
                
                result.appendAttributedString(string)
            }
            return result
        }else{
            return NSAttributedString(string: "Error")
        }
    }
    func updateFavouriteState(item:PlaylistPerformance){
        if Favourite.findByEvent(item.songKickEvent) != nil{
            favouriteButton.setImage(UIImage(named: "starred"), forState: .Normal)
        }else{
            favouriteButton.setImage(UIImage(named: "star"), forState: .Normal)
        }
    }
    @IBAction func didPressFavouriteButton(sender: AnyObject) {
        if let item = performance{
            if let favourite = Favourite.findByEvent(item.songKickEvent){
                Favourite.remove(favourite)
            }else{
                Favourite.add(item.songKickEvent)
            }
            NSNotificationCenter.defaultCenter().postNotificationName(FAVOURITE_COUNT_CHANGED, object: nil)
        }
    }
    @IBAction func didPressTracksIndicatorButton(sender: AnyObject) {
        delegate.flyerCellTrackCountButtonPressed(performance!)
    }
    
    @IBAction func didPressEventLinkButton(sender: AnyObject) {
        delegate.flyerCellShowEventButtonPressed(performance!.songKickEvent)
    }
}
