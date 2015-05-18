//
//  SongKickDateTime.swift
//  GigRadio
//
//  Created by Michael Forrest on 17/05/2015.
//  Copyright (c) 2015 Good To Hear. All rights reserved.
//

import UIKit
import RealmSwift

class SongKickDateTime: Object {
    dynamic var datetime = ""
    dynamic var date = ""
    dynamic var time = "";
    class func dictionaryConvertedFromJSON(dict:NSDictionary)->NSDictionary{
        let result: NSMutableDictionary = dict.mutableCopy() as! NSMutableDictionary
        
        if let date = dict["date"] as? String{
           result["date"] = DateFormats.querystringDateFormatter().dateFromString(date)
        }
        if let datetime = dict["datetime"] as? String{
            result["datetime"] = DateFormats.dateTimeFormat().dateFromString(datetime)
        }
        if let time = dict["time"] as? String{
            result["timeString"] = dict["time"]
        }
        return result
    }
    
    func parsedDate()->NSDate?{
        if let result = DateFormats.querystringDateFormatter().dateFromString(date){
            return result
        }else if let result = DateFormats.dateTimeFormat().dateFromString(datetime){
            return result
        }else{
            return nil
        }
    }
}
