//
//  GradientOverlayView.swift
//  GigRadio
//
//  Created by Michael Forrest on 18/05/2015.
//  Copyright (c) 2015 Good To Hear. All rights reserved.
//

import UIKit

class GradientOverlayView: UIView {

    override func awakeFromNib() {
        backgroundColor = UIColor.clearColor()
        let layer = self.layer as! CAGradientLayer
        let c = UIColor(white: 0.17, alpha: 1)
        layer.colors = [c.CGColor, c.colorWithAlphaComponent(0).CGColor, c.CGColor]
        layer.startPoint = CGPoint(x: 0, y: 0)
        layer.endPoint = CGPoint(x: 1, y: 0)
        userInteractionEnabled = false
        
    }
    override class func layerClass()->AnyClass{
        return CAGradientLayer.self
    }

}
