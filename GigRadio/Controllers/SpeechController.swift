//
//  SpeechController.swift
//  GigRadio
//
//  Created by Michael Forrest on 21/07/2015.
//  Copyright (c) 2015 Good To Hear. All rights reserved.
//

import UIKit
import YLMoment
import AVFoundation


protocol SpeechDelegate{
    func duckMusic()
    func unduckMusic()
}
class SpeechController: NSObject, AVSpeechSynthesizerDelegate {
    var delegate: SpeechDelegate!
    let synthesizer = AVSpeechSynthesizer()
    override init() {
        super.init()
        synthesizer.delegate = self
        
    }
    func say(string:String){
        if Defaults.spokenAnnouncements == .Off {
            return
        }
        let utterance = AVSpeechUtterance(string: string)
        utterance.voice = AVSpeechSynthesisVoice(language: "de-DE")
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate * 0.10
        synthesizer.speakUtterance(utterance)
    }
    func announceEvent(event:SongKickEvent){
        let when = YLMoment(date:event.start.parsedDate()).fromNow()
        say("\(event.displayName)")
    }
    func announceTrack(track:PlaylistTrack){
        synthesizer.stopSpeakingAtBoundary(.Word)
        say("\(track.soundCloudTrack.title) by \(track.performance.soundCloudUser.username)")
    }
    func speechSynthesizer(synthesizer: AVSpeechSynthesizer!, didStartSpeechUtterance utterance: AVSpeechUtterance!) {
        delegate.duckMusic()
    }
    func speechSynthesizer(synthesizer: AVSpeechSynthesizer!, didFinishSpeechUtterance utterance: AVSpeechUtterance!) {
        delegate.unduckMusic()
    }
}
