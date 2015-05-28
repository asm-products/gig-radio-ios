//
//  SoundCloudClient.swift
//  GigRadio
//
//  Created by Michael Forrest on 17/05/2015.
//  Copyright (c) 2015 Good To Hear. All rights reserved.
//

import UIKit
import RealmSwift
import SwiftyJSON
import NSDictionary_TRVSUnderscoreCamelCaseAdditions

class SoundCloudClient: NSObject {
    static let sharedClient = SoundCloudClient()
    lazy var session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
    
    func findUser(name:String,completion:(user:SoundCloudUser?, error:NSError?)->Void){
        var params:[String:AnyObject] = [
            "q": name
        ]
        let url = urlWithParams(params, resource: "users")
        self.get(url) { json, error in
            println("fetched \(json.count) user(s) from SoundCloud via \(url)")
            if json.count > 0{
                var dict:NSDictionary = json[0].object.dictionaryWithoutNullValues()
                dict = dict.dictionaryWithCamelCaseKeys()
                let realm = Realm()
                realm.beginWrite()
                let user = realm.create(SoundCloudUser.self, value: dict, update: true)
                realm.commitWrite()
                completion(user:user, error:nil)
            }else{
                // FIXME: when no user found, create an appropriate error
                completion(user: nil, error: error)
            }
        }
    }
    func getTracks(user:SoundCloudUser, completion:(error:NSError?)->Void){
        let url = urlWithParams([:], resource: "users/\(user.id)/tracks")
        self.get(url) { json, error in
            println("fetched \(json.count) track(s) from SoundCloud via \(url) with erro \(error)")
            if error == nil{
                let realm = Realm()
                realm.write {
                    for item in json.object as! NSArray{
                        var item = item.dictionaryWithoutNullValues()
                        item = (item as NSDictionary).dictionaryWithCamelCaseKeys()
                        item["createdAt"] = DateFormats.soundCloudDateFormat().dateFromString(item["createdAt"] as! String)
                        let track = realm.create(SoundCloudTrack.self, value: item, update: true)
                        user.tracks.append(track)
                    }
                }
            }
            completion(error: error)
        }
    }
    func urlWithParams(params: [String:AnyObject], resource: String)->NSURL{
        var params = params
        params["client_id"] = SoundCloudConfiguration().clientId
        let uri = SoundCloudConfiguration().baseUri.stringByAppendingPathComponent("\(resource).json?\(params.querystring())")
        return NSURL(string: uri)!
    }
    func get(url:NSURL,completion:(json:JSON,error:NSError?)->Void){
        session.dataTaskWithURL(url, completionHandler: { data, response, error in
            let response = response as! NSHTTPURLResponse
            let json = JSON(data:data)
            Async.main {
                if response.statusCode != 200{
                    if error == nil{
                        let error = NSError(domain: "SoundCloud", code: response.statusCode, userInfo: json.object as! [NSObject : AnyObject])
                        completion(json: json,error: error)
                    }else{
                        completion(json: json,error: error)
                    }

                }else{
                    completion(json: json,error: nil)
                }
            }
        }).resume()
        return
        
    }
}
