//
//  SongKickClient.swift
//  GigRadio
//
//  Created by Michael Forrest on 17/05/2015.
//  Copyright (c) 2015 Good To Hear. All rights reserved.
//

import UIKit
import RealmSwift
import SwiftyJSON

class SongKickClient: NSObject {
    static let sharedClient = SongKickClient()
    
    lazy var session: NSURLSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
    
    func getEvents(date: NSDate, location: CLLocation?, completion:(error:NSError?)->Void){
        var params: [String:AnyObject] = ["date": DateFormats.querystringDateFormatter().stringFromDate(date)]
        if let location = location{
            params["location"] = "geo:\(location.coordinate.latitude),\(location.coordinate.longitude)"
        }else{
            params["location"] = "clientip"
        }
        let url = urlWithParams(params, resource: "events")
        session.dataTaskWithURL(url, completionHandler: { (data, response, error) -> Void in
            let json = JSON(data: data)
            let events = json["resultsPage"]["results"]["event"]
            if events.error == nil{
                let realm = Realm()
                realm.write {
                    for event in events.object as! NSArray{
                        if let event = event as? NSDictionary{
                            let event = event.dictionaryWithoutNullValues()
                            realm.create(SongKickEvent.self, value: event, update: true)
                        }
                    }
                }
            }
            completion(error: events.error)
            
        }).resume()
        
    }
    
    func urlWithParams(params: [String:AnyObject], resource: String)->NSURL{
        var params = params
        params["apikey"] = SongKickConfiguration().apiKey
        let uri = SongKickConfiguration().baseUrl.stringByAppendingPathComponent("\(resource).json?\(params.querystring())")
        return NSURL(string: uri)!
    }
    
}
