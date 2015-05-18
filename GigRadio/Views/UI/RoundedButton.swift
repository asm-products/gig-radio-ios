//
//  RoundedButton.swift
//  GigRadio
//
//  Created by Michael Forrest on 18/05/2015.
//  Copyright (c) 2015 Good To Hear. All rights reserved.
//

import UIKit

class RoundedButton: UIButton {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

    override func awakeFromNib() {
        layer.cornerRadius = frame.size.height * 0.5
    }
}
