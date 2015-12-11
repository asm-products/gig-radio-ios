//
//  Onboarding.swift
//  GigRadio
//
//  Created by Michael Forrest on 11/12/2015.
//  Copyright © 2015 Good To Hear. All rights reserved.
//

import UIKit
enum OnboardingKey:String{
    case IntroductionSeen = "IntroductionSeen"
    static let allValues = [
        IntroductionSeen
    ]
}
class Onboarding: NSObject {
    static func markSeen(key:OnboardingKey){
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: key.rawValue)
    }
    static func hasSeen(key:OnboardingKey)->Bool{
        return !shouldShow(key)
    }
    static func shouldShow(key:OnboardingKey)->Bool{
        let defaults = NSUserDefaults.standardUserDefaults()
        let key = key.rawValue
        defaults.registerDefaults([key: false])
        return defaults.boolForKey(key) == false
    }
    static func hasSeenEnoughTimes(key:OnboardingKey, timesToShow:Int)->Bool{
        let timesSeenCount = NSUserDefaults.standardUserDefaults().integerForKey(key.rawValue)
        return timesSeenCount >= timesToShow
    }
    static func incrementSeen(key:OnboardingKey){
        var timesSeenCount = NSUserDefaults.standardUserDefaults().integerForKey(key.rawValue)
        timesSeenCount += 1
        NSUserDefaults.standardUserDefaults().setInteger(timesSeenCount, forKey: key.rawValue)
    }
    
}
