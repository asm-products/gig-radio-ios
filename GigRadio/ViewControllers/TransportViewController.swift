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
import Mixpanel
protocol TransportViewControllerDelegate{
    func playNextTrack()
    func playPreviousTrack()
    func getPlaylist()->Playlist
    func scrollToPerformance(performance:PlaylistPerformance)
    func problemButtonPressed(track:PlaylistTrack)
}
func soundURL(name:String)->NSURL{
    return NSBundle.mainBundle().URLForResource(name, withExtension: "aif")!
}

class TransportViewController: UIViewController,STKAudioPlayerDelegate,SpeechDelegate{
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
    
    var audioPlayer: STKAudioPlayer!
    var displayLink: CADisplayLink!
    let speech = SpeechController()
    
    var track: PlaylistTrack?
    
    let forwardSound = try? AVAudioPlayer(contentsOfURL: soundURL("forward"))
    let backwardSound = try? AVAudioPlayer(contentsOfURL: soundURL("backward"))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        speech.delegate = self
        
        forwardSound?.prepareToPlay()
        backwardSound?.prepareToPlay()
        
        displayLink = CADisplayLink(target: self, selector: "displayLinkCallback")
        displayLink.frameInterval = 60
        displayLink.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
        
        var options = STKAudioPlayerOptions()
        options.enableVolumeMixer = true
        audioPlayer = STKAudioPlayer(options: options)
        audioPlayer.delegate = self

        
        volumeView.setVolumeThumbImage(UIImage(named: "volume-thumb"), forState: .Normal)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleAVAudioSessionRouteChangeNotification:", name: AVAudioSessionRouteChangeNotification, object: nil)
        
    }
    func handleAVAudioSessionRouteChangeNotification(notification:NSNotification){
        guard let info = notification.userInfo as? [String:AnyObject],
            reasonRaw = info[AVAudioSessionRouteChangeReasonKey] as? UInt,
            reason = AVAudioSessionRouteChangeReason(rawValue: reasonRaw),
            oldRoute = info[AVAudioSessionRouteChangePreviousRouteKey]
            else {
                print("no reason found for \(notification.userInfo)")
                return
        }
        print("old route \(oldRoute)")
        if reason == .OldDeviceUnavailable && oldRoute.description.containsString("Headphones"){ // seems to work internationally
            setPlaying(false)
        }
    }
    func play(track:PlaylistTrack){
        trackEvent(.TrackPlayed, properties: ["SoundCloud ID": track.soundCloudTrack.id])
        setBufferingDisplay(true)
        speech.announceTrack(track)
        
        self.track = track
        trackInfoLabel.attributedText = PlaylistHelper.attributedTrackInfoText(track, separator: "\n")
        audioPlayer.play(track.soundCloudTrack.playbackUrl())
        
        MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo = [
            MPMediaItemPropertyAlbumTitle: "\(track.performance.songKickEvent.start.datetime) \(track.performance.songKickEvent.displayName)",
            MPMediaItemPropertyTitle: "\(track.soundCloudTrack.title) - \(track.performance.soundCloudUser.username)",
            MPMediaItemPropertyPlaybackDuration: track.soundCloudTrack.duration / 1000,
            MPNowPlayingInfoPropertyElapsedPlaybackTime: 0,
            MPNowPlayingInfoPropertyPlaybackRate: 1
        ]
        becomeActive()
    }
    func becomeActive(){
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch _ {
        }

        UIApplication.sharedApplication().beginReceivingRemoteControlEvents()
        self.becomeFirstResponder()
    }
    @IBAction func didPressPlayPause(sender: AnyObject) {
        if audioPlayer.state == STKAudioPlayerStatePlaying{
            setPlaying(false)
            trackEvent(.PlaybackPaused, properties: [:])
        }else{
            setPlaying(true)
            trackEvent(.PlaybackResumed, properties: [:])
        }
    }
    func setPlaying(playing:Bool){
        if playing{
            timeEvent(.PlaybackPaused)
            audioPlayer.resume()
            MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo?[MPNowPlayingInfoPropertyPlaybackRate] = 1
            becomeActive()
        }else{
            audioPlayer.pause()
            MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo?[MPNowPlayingInfoPropertyPlaybackRate] = 0
        }
    }
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    func displayLinkCallback(){
        let formatter = NSDateComponentsFormatter()
        formatter.unitsStyle = NSDateComponentsFormatterUnitsStyle.Positional
        formatter.zeroFormattingBehavior = .Pad
        formatter.allowedUnits = [.Minute, .Second]
        let value = audioPlayer.progress / audioPlayer.duration
        playbackSlider.setValue(Float(value), animated: false)
        playbackTimeView.text = formatter.stringFromTimeInterval(audioPlayer.progress)
        timeRemainingView.text = formatter.stringFromTimeInterval(audioPlayer.duration - audioPlayer.progress)
//        MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo = [
//            MPMediaV
//        ]
    }
    
    func setBufferingDisplay(buffering:Bool){
        if buffering{
            bufferingActivityIndicator.startAnimating()
            timeRemainingView.hidden = true
        }else{
            bufferingActivityIndicator.stopAnimating()
            timeRemainingView.hidden = false
            displayLinkCallback()
        }
    }
    func setPlayButtonDisplayState(playing:Bool){
        let name = playing ? "pause" : "play"
        playPauseButton.setImage(UIImage(named: name), forState: .Normal)
    }
    /// Raised when an item has started playing
    func audioPlayer(audioPlayer: STKAudioPlayer!, didStartPlayingQueueItemId queueItemId: NSObject!){
    }
    /// Raised when an item has finished buffering (may or may not be the currently playing item)
    /// This event may be raised multiple times for the same item if seek is invoked on the player
    func audioPlayer(audioPlayer: STKAudioPlayer!, didFinishBufferingSourceWithQueueItemId queueItemId: NSObject!){
        setBufferingDisplay(false)
    }
    /// Raised when the state of the player has changed
    func audioPlayer(audioPlayer: STKAudioPlayer!, stateChanged state: STKAudioPlayerState, previousState: STKAudioPlayerState){
        switch state.rawValue{
        case STKAudioPlayerStateBuffering.rawValue:
            setBufferingDisplay(true)
        case STKAudioPlayerStatePaused.rawValue,STKAudioPlayerStateStopped.rawValue:
            setPlayButtonDisplayState(false)
        case STKAudioPlayerStatePlaying.rawValue:
            setPlayButtonDisplayState(true)
            setBufferingDisplay(false)
        default:
            print("Ignored state \(state)")
        }
    }
    /// Raised when an item has finished playing
    func audioPlayer(audioPlayer: STKAudioPlayer!, didFinishPlayingQueueItemId queueItemId: NSObject!, withReason stopReason: STKAudioPlayerStopReason, andProgress progress: Double, andDuration duration: Double){
        switch stopReason.rawValue{
        case STKAudioPlayerStopReasonNone.rawValue:
            print("Stopped for no reason")
        case STKAudioPlayerStopReasonEof.rawValue:
            delegate.playNextTrack()
        default:
            print("Player stopped for STKAudioPlayerStopReason.\(stopReason.rawValue)")
        }
    }
    /// Raised when an unexpected and possibly unrecoverable error has occured (usually best to recreate the STKAudioPlauyer)
    func audioPlayer(audioPlayer: STKAudioPlayer!, unexpectedError errorCode: STKAudioPlayerErrorCode){
       
    }
    @IBAction func didPressForward(sender: AnyObject) {
//        audioPlayer.stop()
        setBufferingDisplay(true)
        forwardSound?.play()
        delegate.playNextTrack()
    }
    @IBAction func didPressRewind(sender: AnyObject) {
//        audioPlayer.stop()
        backwardSound?.play()
        delegate.playPreviousTrack()
    }
    @IBAction func didDragPlaybackTime(sender: UISlider) {
        audioPlayer.seekToTime( Double(sender.value) * audioPlayer.duration )
    }
    override func remoteControlReceivedWithEvent(event: UIEvent?) {
        guard let subtype = event?.subtype else { return }
        switch subtype{
        case .RemoteControlTogglePlayPause: didPressPlayPause(self)
        case .RemoteControlNextTrack: didPressForward(self)
        case .RemoteControlPreviousTrack: didPressRewind(self)
        case .RemoteControlPlay:
            audioPlayer.resume()
            do {
                try AVAudioSession.sharedInstance().setActive(true)
            } catch _ {
            }
        case .RemoteControlPause:
            audioPlayer.pause()
        default:
            print("ignored \(event)")
        }
    }
    @IBAction func didPressTrackInfo(sender: AnyObject) {
        delegate.scrollToPerformance(track!.performance)
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let dest = segue.destinationViewController as? PlaylistTableViewController{
            dest.playlist = delegate.getPlaylist()
        }
    }
    @IBAction func didPressProblemButton(sender: AnyObject) {
        if let track = self.track{
            delegate.problemButtonPressed(track)
        }
    }
    func duckMusic() {
        audioPlayer.volume = 0.5
    }
    func unduckMusic() {
        audioPlayer.volume = 1.0
    }
}
