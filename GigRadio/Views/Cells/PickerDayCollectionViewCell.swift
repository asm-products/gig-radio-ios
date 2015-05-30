//
//  PickerDayCollectionViewCell.swift
//  GigRadio
//
//  Created by Michael Forrest on 12/02/2015.
//  Copyright (c) 2015 Good To Hear. All rights reserved.
//

import UIKit

class PickerDayCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var dayOfTheWeekLabel: UILabel!
    @IBOutlet weak var dayOfTheMonthLabel: UILabel!
    @IBOutlet weak var signalStrengthIndicator: SignalStrengthIndicator!
    @IBOutlet weak var selectionIndicator: UIImageView!
    var date: NSDate!{
        didSet{
            dayOfTheMonthLabel.text = DateFormats.dayOfTheMonthFormatter().stringFromDate(date)
            dayOfTheWeekLabel.text = DateFormats.dayOfTheWeekShortFormatter().stringFromDate(date)
            let playlist = Playlist.findOrCreateForUtcDate(date)
            let eventsCount = playlist.performances.count
            signalStrengthIndicator.strength = Float(eventsCount) / 10.0
            
        }
    }
}
