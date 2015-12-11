//
//  Dictionary+Querystring.swift
//  GigRadio
//
//  Created by Michael Forrest on 17/05/2015.
//  Copyright (c) 2015 Good To Hear. All rights reserved.
//

import Foundation

extension Dictionary{
    func querystring()->String{
        var result = [String]()
        for (key, value) in self{
            let value = "\(value)"
            result.append("\(key)=\(value.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)")
        }
        return result.joinWithSeparator("&")
    }
}