//
//  MusicEngine.swift
//  GigRadio
//
//  Created by Michael Forrest on 17/05/2015.
//  Copyright (c) 2015 Good To Hear. All rights reserved.
//

import UIKit
class MusicEngine {
    var currentTrack: SoundCloudTrack?
    func playSoundCloudTrack(track: SoundCloudTrack){
//        playUrl(track.playbackURL)
        currentTrack = track
    }
}
