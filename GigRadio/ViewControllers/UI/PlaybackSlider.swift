//
//  PlaybackSlider.swift
//  GigRadio
//
//  Created by Michael Forrest on 17/05/2015.
//  Copyright (c) 2015 Good To Hear. All rights reserved.
//

import UIKit

class PlaybackSlider: UISlider {

    override func awakeFromNib() {
        let track = UIImage(named: "playback-track")?.resizableImageWithCapInsets(UIEdgeInsets(top: 0, left: 11, bottom: 0, right: 11))
        setThumbImage(UIImage(named: "playback-thumb"), forState: .Normal)
        setMinimumTrackImage(track, forState: .Normal)
        setMaximumTrackImage(track, forState: .Normal)
    }

}
