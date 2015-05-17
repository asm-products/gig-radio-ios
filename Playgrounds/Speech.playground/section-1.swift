// Playground - noun: a place where people can play

import UIKit
import AVFoundation

let synth = AVSpeechSynthesizer()
let utterance = AVSpeechUtterance(string: "That was Talk or Die by Michael Forrest. Michael Forrest is playing at Eschschloraque, 49 Rosenthaler Str, tonight after 20:00")
synth.speakUtterance(utterance)

