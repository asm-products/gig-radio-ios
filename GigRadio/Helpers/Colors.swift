//
//  Colors.swift
//  GigRadio
//
//  Created by Michael Forrest on 20/11/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

import Foundation
import AVHexColor

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
    class func gradients()->[[String]]{
        return [
            ["#E8168B", "#832F68"],
            ["#7C59BE", "#462E9E"],
            ["#1697A6", "#3A4CA8"],
            ["#3EB14F", "#179B94"],
            ["#C0C842", "#4BA04B"],
            ["#F8CD38", "#FD9B28"],
            ["#FC9626", "#ED6C1F"]
        ]
    }
    class func gradient(index: Int)-> [UIColor]{
        let colors = self.gradients()
        let gradient = colors[index]
        return gradient.map{ AVHexColor.colorWithHexString($0) }
    }

}