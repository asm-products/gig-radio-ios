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
    func flyerCellTrackCountButtonPressed(item:PlaylistItem)
    func flyerCellPlayButtonPressed(item:PlaylistItem)
}

class FlyerCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var compass: CompassView!
    @IBOutlet weak var detailsButton: UIButton!
    @IBOutlet weak var lineupLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var baselineConstraint: NSLayoutConstraint!
    @IBOutlet weak var trackAvailabilityButton: UIButton!
    @IBOutlet weak var trackFetchingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var favouriteButton: UIButton!
    
    var delegate : FlyerCollectionViewCellDelegate!
    
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
                if let location = item.songKickEvent.venue.location(){
                   compass.destination =  location
                }
                
                detailsButton.setTitle(PlaylistHelper.dateAndVenueText(item.songKickEvent), forState: .Normal)
                updateTrackAvailabilityIcon(item.soundCloudUser.tracks.count)
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
    func updateTrackAvailabilityIcon(count:Int){
        trackAvailabilityButton.setTitle("\(count)", forState: .Normal)
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
    func updateFavouriteState(item:PlaylistItem){
        if Favourite.findByEvent(item.songKickEvent) != nil{
            favouriteButton.setImage(UIImage(named: "starred"), forState: .Normal)
        }else{
            favouriteButton.setImage(UIImage(named: "star"), forState: .Normal)
        }
    }
    @IBAction func didPressFavouriteButton(sender: AnyObject) {
        if let item = playlistItem{
            if let favourite = Favourite.findByEvent(item.songKickEvent){
                Favourite.remove(favourite)
            }else{
                Favourite.add(item.songKickEvent)
            }
            updateFavouriteState(item)
            NSNotificationCenter.defaultCenter().postNotificationName(FAVOURITE_COUNT_CHANGED, object: nil)
        }
    }
    @IBAction func didPressTracksIndicatorButton(sender: AnyObject) {
        delegate.flyerCellTrackCountButtonPressed(playlistItem!)
    }
    
    @IBAction func didPressEventLinkButton(sender: AnyObject) {
        delegate.flyerCellShowEventButtonPressed(playlistItem!.songKickEvent)
    }
}
