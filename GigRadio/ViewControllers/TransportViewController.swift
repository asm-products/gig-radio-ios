//
//  TransportViewController.swift
//  GigRadio
//
//  Created by Michael Forrest on 23/05/2015.
//  Copyright (c) 2015 Good To Hear. All rights reserved.
//

import UIKit
import MediaPlayer
import StreamingKit
import AVFoundation
protocol TransportViewControllerDelegate{
    func playNextTrack()
    func playPreviousTrack()
}

class TransportViewController: UIViewController,STKAudioPlayerDelegate{
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
    
    var audioPlayer = STKAudioPlayer()
    var displayLink: CADisplayLink!
    
    var playlistItem: PlaylistItem?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        displayLink = CADisplayLink(target: self, selector: "displayLinkCallback")
        displayLink.frameInterval = 60
        displayLink.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
        audioPlayer.delegate = self
        
        volumeView.setVolumeThumbImage(UIImage(named: "volume-thumb"), forState: .Normal)
    }
    func play(item:PlaylistItem, callback:(success:Bool)->Void){
        AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, error: nil)
        self.playlistItem = item
        item.markPlayed()
        trackInfoLabel.attributedText = PlaylistHelper.attributedTrackInfoText(playlistItem!, separator: "\n")
        audioPlayer.play(item.soundCloudTrack.playbackUrl())
        callback(success: true)
    }
    func displayLinkCallback(){
        let formatter = NSDateComponentsFormatter()
        formatter.unitsStyle = NSDateComponentsFormatterUnitsStyle.Positional
        formatter.zeroFormattingBehavior = .Pad
        formatter.allowedUnits = .CalendarUnitMinute | .CalendarUnitSecond
        let value = audioPlayer.progress / audioPlayer.duration
        playbackSlider.setValue(Float(value), animated: false)
        playbackTimeView.text = formatter.stringFromTimeInterval(audioPlayer.progress)
        timeRemainingView.text = formatter.stringFromTimeInterval(audioPlayer.duration - audioPlayer.progress)
    }
    
    func setBufferingDisplay(buffering:Bool){
        if buffering{
            bufferingActivityIndicator.startAnimating()
            timeRemainingView.hidden = true
        }else{
            bufferingActivityIndicator.stopAnimating()
            timeRemainingView.hidden = false
        }
    }
    func setPlayButtonDisplayState(playing:Bool){
        let name = playing ? "pause" : "play"
        playPauseButton.setImage(UIImage(named: name), forState: .Normal)
    }
    /// Raised when an item has started playing
    func audioPlayer(audioPlayer: STKAudioPlayer!, didStartPlayingQueueItemId queueItemId: NSObject!){
        bufferingActivityIndicator.stopAnimating()
        timeRemainingView.hidden = false
    }
    /// Raised when an item has finished buffering (may or may not be the currently playing item)
    /// This event may be raised multiple times for the same item if seek is invoked on the player
    func audioPlayer(audioPlayer: STKAudioPlayer!, didFinishBufferingSourceWithQueueItemId queueItemId: NSObject!){
    }
    /// Raised when the state of the player has changed
    func audioPlayer(audioPlayer: STKAudioPlayer!, stateChanged state: STKAudioPlayerState, previousState: STKAudioPlayerState){
        switch state.value{
        case STKAudioPlayerStateBuffering.value:
            setBufferingDisplay(true)
        case STKAudioPlayerStatePaused.value,STKAudioPlayerStateStopped.value:
            setPlayButtonDisplayState(false)
            setBufferingDisplay(false)
        case STKAudioPlayerStatePlaying.value:
            setPlayButtonDisplayState(true)
            setBufferingDisplay(false)
        default:
            println("Ignored state \(state)")
        }
    }
    /// Raised when an item has finished playing
    func audioPlayer(audioPlayer: STKAudioPlayer!, didFinishPlayingQueueItemId queueItemId: NSObject!, withReason stopReason: STKAudioPlayerStopReason, andProgress progress: Double, andDuration duration: Double){
        switch stopReason.value{
        case STKAudioPlayerStopReasonNone.value:
            println("Stopped for no reason")
        case STKAudioPlayerStopReasonEof.value:
            delegate.playNextTrack()
        default:
            println("Player stopped for STKAudioPlayerStopReason.\(stopReason.value)")
        }
    }
    /// Raised when an unexpected and possibly unrecoverable error has occured (usually best to recreate the STKAudioPlauyer)
    func audioPlayer(audioPlayer: STKAudioPlayer!, unexpectedError errorCode: STKAudioPlayerErrorCode){
       
    }
    @IBAction func didPressPlayPause(sender: AnyObject) {
        if audioPlayer.state.value == STKAudioPlayerStatePlaying.value{
            audioPlayer.pause()
        }else{
            audioPlayer.resume()
        }
    }
    @IBAction func didPressForward(sender: AnyObject) {
        delegate.playNextTrack()
    }
    @IBAction func didPressRewind(sender: AnyObject) {
        delegate.playPreviousTrack()
    }
    @IBAction func didDragPlaybackTime(sender: UISlider) {
        audioPlayer.seekToTime( Double(sender.value) * audioPlayer.duration )
    }
}
