//
//  SignalStrengthIndicator.swift
//  GigRadio
//
//  Created by Michael Forrest on 18/05/2015.
//  Copyright (c) 2015 Good To Hear. All rights reserved.
//

import UIKit

class SignalStrengthIndicator: UIView {
    var strength:Float = 0{
        didSet{
            setNeedsDisplay()
        }
    }
    override func awakeFromNib() {
        backgroundColor = UIColor.clearColor()
    }
    override func drawRect(rect: CGRect) {
        let Spacing:CGFloat = 2.0
        let ItemWidth = (rect.size.width - 2 * Spacing) / 3.0
        UIColor.whiteColor().setFill()
        let off = UIColor(white: 1.0, alpha: 0.3)
        if strength < 0.25{
            off.setFill()
        }
        UIBezierPath(rect: CGRect(x: 0, y: 0, width: ItemWidth, height: rect.height)).fill()
        if strength < 0.5{
            off.setFill()
        }
        UIBezierPath(rect: CGRect(x: ItemWidth + Spacing, y: 0, width: ItemWidth, height: rect.height)).fill()
        if strength < 0.75{
            off.setFill()
        }
        UIBezierPath(rect: CGRect(x: 2 * (ItemWidth + Spacing), y: 0, width: ItemWidth, height: rect.height)).fill()
    }

}
