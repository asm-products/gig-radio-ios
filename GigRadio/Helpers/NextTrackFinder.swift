//
//  NextTrackFinder.swift
//  GigRadio
//
//  Created by Michael Forrest on 30/05/2015.
//  Copyright (c) 2015 Good To Hear. All rights reserved.
//

import UIKit

class NextTrackFinder: NSObject {
    var count = 0
    var performance: PlaylistPerformance
    var callback:(track:PlaylistTrack?)->Void
    init(performance:PlaylistPerformance, callback:(track:PlaylistTrack?)->Void){
        self.performance = performance
        self.callback = callback
        super.init()
        doNext()
    }
    func doNext(){
        self.count += 1
        if self.count < performance.playlist.performances.count{
            if let next = performanceAfter(performance){
                self.performance = next
                determineNextTrackInPerformance(performance, callback: { (track) -> Void in
                    if track == nil{
                        self.doNext()
                    }else{
                        self.callback(track: track)
                    }
                })
            }
        }else{
            print("Warning, no more tracks found to play")
            self.callback(track: nil)
        }
    }
    func performanceAfter(performance:PlaylistPerformance)->PlaylistPerformance?{
        let performances = performance.playlist.performances
        if var index = performances.indexOf(performance){
            index += 1
            if index >= performances.count && Defaults.playlistFollowAction == .LoopDay{
                index %= performances.count
            }
            // otherwise we'll get a handy exception.
            return performances[index]

        }else{
            return nil
        }
    }
    func determineNextTrackInPerformance(performance:PlaylistPerformance,callback: (track:PlaylistTrack?)->Void){
        performance.determineSoundCloudUser { user, error in
            if let error = error{
                print("We have an error \(error)")
            }
            performance.determineTracksAvailable{ trackCount, error in
                if let error = error{
                    print("We have an error \(error)")
                }
                performance.determineNextTrackToPlay(callback)
            }
        }
    }
}
