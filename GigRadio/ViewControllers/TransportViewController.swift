//
//  TransportViewController.swift
//  GigRadio
//
//  Created by Michael Forrest on 23/05/2015.
//  Copyright (c) 2015 Good To Hear. All rights reserved.
//

import UIKit
import MediaPlayer

protocol TransportViewControllerDelegate{
    
}

class TransportViewController: UIViewController {
    var delegate: TransportViewControllerDelegate!
    @IBOutlet weak var volumeView: MPVolumeView!
    @IBOutlet weak var bufferingActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var playbackSlider: PlaybackSlider!
    @IBOutlet weak var trackInfoLabel: UILabel!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var rewindButton: UIButton!
    @IBOutlet weak var forwardButton: UIButton!
    @IBOutlet weak var playbackTimeView: UILabel!
    @IBOutlet weak var timeRemainingView: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        volumeView.setVolumeThumbImage(UIImage(named: "volume-thumb"), forState: .Normal)
    }


}
