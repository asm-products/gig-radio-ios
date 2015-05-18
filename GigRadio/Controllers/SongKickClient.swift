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
        getEvents(date, end: date, location: location, completion: completion)
    }
    // http://www.songkick.com/developer/event-search
    func getEvents(start: NSDate, end: NSDate, location: CLLocation?, completion:(error:NSError?)->Void){
        var params: [String:AnyObject] = [
            "min_date": DateFormats.querystringDateFormatter().stringFromDate(start),
            "max_date": DateFormats.querystringDateFormatter().stringFromDate(end)
        ]
        if let location = location{
            params["location"] = "geo:\(location.coordinate.latitude),\(location.coordinate.longitude)"
        }else{
            params["location"] = "clientip"
        }
        let url = urlWithParams(params, resource: "events")
        session.dataTaskWithURL(url, completionHandler: { (data, response, error) -> Void in
            if let response = response as? NSHTTPURLResponse{
                let json = JSON(data: data)
                if response.statusCode != 200{
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        if let message = json["resultsPage"]["error"]["message"].object as? String{
                            completion(error: NSError(domain: "SongKick", code: response.statusCode, userInfo: [NSLocalizedDescriptionKey: message]))
                        }else{
                            completion(error: error)
                        }
                    })
                }else{
                    let events = json["resultsPage"]["results"]["event"]
                    println("Fetched \(events.count) event(s) from SongKick")
                    if events.error == nil{
                        let realm = Realm()
                        realm.write {
                            for event in events.object as! NSArray{
                                if let event = event as? NSDictionary{
                                    let event = event.dictionaryWithoutNullValues()
                                    let model = realm.create(SongKickEvent.self, value: event, update: true)
                                    if let date = model.start.parsedDate(){
                                        model.date = date
                                    }
                                }
                            }
                        }
                    }
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        completion(error: events.error)
                    })
                    
                }
            }
        }).resume()
        
    }
    
    func urlWithParams(params: [String:AnyObject], resource: String)->NSURL{
        var params = params
        params["apikey"] = SongKickConfiguration().apiKey
        let uri = SongKickConfiguration().baseUrl.stringByAppendingPathComponent("\(resource).json?\(params.querystring())")
        return NSURL(string: uri)!
    }
    
}
