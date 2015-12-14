//
//  AvatarView.swift
//  GigRadio
//
//  Created by Michael Forrest on 14/12/2015.
//  Copyright © 2015 Good To Hear. All rights reserved.
//

import UIKit

class AvatarView: UIImageView {

    override func awakeFromNib() {
        layer.cornerRadius = frame.height / 2
    }
}
