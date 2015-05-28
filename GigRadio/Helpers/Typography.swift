//
//  Typography.swift
//  GigRadio
//
//  Created by Michael Forrest on 20/05/2015.
//  Copyright (c) 2015 Good To Hear. All rights reserved.
//

import UIKit

class Typography: NSObject {
    
    let FocusedArtistAttributes = [NSFontAttributeName: UIFont(name: "Roboto-Light", size: 36)!]
    let DefaultAttributes = [NSFontAttributeName: UIFont(name: "Roboto-Light", size: 24)!]
    
    class func RobotoBold(size:CGFloat)->[String:AnyObject]{
        return [NSFontAttributeName: UIFont(name: "Roboto-Bold", size: size)!]
    }
    class func RobotoRegular(size:CGFloat)->[String:AnyObject]{
        return [NSFontAttributeName: UIFont(name: "Roboto-Regular", size: size)!]
    }
    class func RobotoLight(size:CGFloat)->[String:AnyObject]{
        return [NSFontAttributeName: UIFont(name: "Roboto-Light", size: size)!]
    }
    
    class func HeaderLight(size:CGFloat)->[String:AnyObject]{
        return [
            NSFontAttributeName: UIFont(name: "HelveticaNeue-Light", size: size)!,
            NSForegroundColorAttributeName: UIColor.whiteColor()
        ]
    }
    class func HeaderRegular(size:CGFloat)->[String:AnyObject]{
        return [
            NSFontAttributeName: UIFont(name: "HelveticaNeue-Bold", size: size)!,
            NSForegroundColorAttributeName: UIColor.whiteColor()
        
        ]
    }
}
