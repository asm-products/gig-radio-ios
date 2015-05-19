//
//  ButtonWithRightAlignedImage.swift
//  GigRadio
//
//  Created by Michael Forrest on 18/05/2015.
//  Copyright (c) 2015 Good To Hear. All rights reserved.
//

import UIKit

class ButtonWithRightAlignedImage: UIButton {

    override func layoutSubviews() {
        super.layoutSubviews()
        titleEdgeInsets = UIEdgeInsetsMake(0, -imageView!.frame.size.width, 0, imageView!.frame.size.width);
        imageEdgeInsets = UIEdgeInsetsMake(0, titleLabel!.frame.size.width + 5, 0, -titleLabel!.frame.size.width - 20);
    }

}
