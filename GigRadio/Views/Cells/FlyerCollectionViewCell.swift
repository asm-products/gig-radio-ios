//
//  FlyerCollectionViewCell.swift
//  GigRadio
//
//  Created by Michael Forrest on 17/05/2015.
//  Copyright (c) 2015 Good To Hear. All rights reserved.
//

import UIKit

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
        }
    }
    
    
    var attributedLineupText: NSAttributedString{
        if let item = playlistItem{
            let highlightedArtist = item.songKickArtist
            let result = NSMutableAttributedString(string: "")
            for performance in item.songKickEvent.performance{
                result.appendAttributedString(NSAttributedString(string: performance.artist.displayName))
            }
            return result
        }else{
            return NSAttributedString(string: "Error")
        }
    }
}
