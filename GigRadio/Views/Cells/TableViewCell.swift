//
//  TableViewCell.swift
//  GigRadio
//
//  Created by Michael Forrest on 12/12/2015.
//  Copyright © 2015 Good To Hear. All rights reserved.
//
// Because on iPad we were getting white backgrounds.


import UIKit

class TableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = UIColor.clearColor()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
