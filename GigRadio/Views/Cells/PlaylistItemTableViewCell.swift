//
//  PlaylistItemTableViewCell.swift
//  GigRadio
//
//  Created by Michael Forrest on 28/05/2015.
//  Copyright (c) 2015 Good To Hear. All rights reserved.
//

import UIKit

class PlaylistItemTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    var track: PlaylistTrack!{
        didSet{
            titleLabel.attributedText = PlaylistHelper.attributedTrackInfoText(track, separator: " - ")
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = UIColor.clearColor()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
