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

class SongKickClient: ApiClientBase {
    static let sharedClient = SongKickClient()
    
    func getEvents(date: NSDate, location: CLLocation?, completion:(results:[Int]?,error:NSError?)->Void){
        getEvents(date, end: date, location: location, completion: completion)
    }
    // http://www.songkick.com/developer/event-search
    func getEvents(start: NSDate, end: NSDate, location: CLLocation?, completion:(results:[Int]?,error:NSError?)->Void){
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
        self.get(url, completion: { json, error in
            if error == nil{
                let events = json["resultsPage"]["results"]["event"]
                print("Fetched \(events.count) event(s) from SongKick via \(url)")
                var ids = [Int]()
                if events.error == nil{
                    let realm = try! Realm()
                    try! realm.write {
                        for event in events.object as! NSArray{
                            if let event = event as? NSDictionary{
                                let event = event.dictionaryWithoutNullValues()
                                let model = realm.create(SongKickEvent.self, value: event, update: true)
                                if let start = model.start, date = start.parsedDate(){
                                    model.date = date
                                }
                                ids.append(model.id)
                            }
                        }
                    }
                }
                Async.main {
                    completion(results:ids, error: events.error)
                }
            }else{
                Async.main {
                    completion(results: nil, error: error)
                }
            }
        })
        
    }
    func getVenueDetails(venue:SongKickVenue, completion:()->Void){
        if venue.street != ""{
            completion()
            return
        }
        let url = urlWithParams([:], resource: "venues/\(venue.id)")
        self.get(url) { json, error in
            if error == nil{
                var object:NSDictionary = json["resultsPage"]["results"]["venue"].object as! NSDictionary
                object = object.dictionaryWithoutNullValues()
                let realm = try! Realm()
                try! realm.write{
                    realm.create(SongKickVenue.self, value: object, update: true)
                }
                completion()
            }
        }
    }
    
    func urlWithParams(params: [String:AnyObject], resource: String)->NSURL{
        var params = params
        params["apikey"] = SongKickConfiguration().apiKey
        let uri = (SongKickConfiguration().baseUrl as NSString).stringByAppendingPathComponent("\(resource).json?\(params.querystring())")
        return NSURL(string: uri)!
    }
    
}
