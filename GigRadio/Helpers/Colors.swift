//
//  Colors.swift
//  GigRadio
//
//  Created by Michael Forrest on 20/11/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

import Foundation

class Colors : NSObject{
    class func colors()->[String]{
        return [
            "#E11587",
            "#7A58BA",
            "#1592A1",
            "#3CAD4E",
            "#BFC842",
            "#F7CA37",
            "#FC9526",
            "#F1453D"
        ]
    }
    class func color(index: Int)-> UIColor{
        let colors = self.colors()
        let hex = colors[index]
        return AVHexColor.colorWithHexString(hex)
    }
}