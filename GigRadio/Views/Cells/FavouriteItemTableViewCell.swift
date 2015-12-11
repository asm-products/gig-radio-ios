//
//  FavouriteItemTableViewCell.swift
//  GigRadio
//
//  Created by Michael Forrest on 28/05/2015.
//  Copyright (c) 2015 Good To Hear. All rights reserved.
//

import UIKit

class FavouriteItemTableViewCell: UITableViewCell {
    @IBOutlet weak var mainLabel: UILabel!
    @IBOutlet weak var tonightLabel: UILabel!
   
    var favourite:Favourite!{
        didSet{
            let text = NSMutableAttributedString(string: "")
            let br = NSAttributedString(string: "\n")
            let date = NSAttributedString(string: DateFormats.todayFormatter().stringFromDate(favourite.event.date), attributes: Typography.RobotoBold(16))
            let artists = NSAttributedString(string: favourite.event.artistNames().joinWithSeparator(", "), attributes: Typography.RobotoRegular(24))
            let timeAndDate = NSAttributedString(string: PlaylistHelper.dateAndVenueText(favourite.event), attributes: Typography.RobotoLight(16))
            text.appendAttributedString(date)
            text.appendAttributedString(br)
            text.appendAttributedString(artists)
            text.appendAttributedString(br)
            text.appendAttributedString(timeAndDate)
            mainLabel.attributedText = text
            if NSCalendar.currentCalendar().isDateInToday(favourite.event.date){
                tonightLabel.text = "Tonight!"
            }else{
                tonightLabel.text = ""
            }
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
