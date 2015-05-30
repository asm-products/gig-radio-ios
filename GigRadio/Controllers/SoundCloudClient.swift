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

class SoundCloudClient: ApiClientBase {
    static let sharedClient = SoundCloudClient()
    class func createSoundCloudUser(json:NSDictionary)->SoundCloudUser{
        var dict:NSDictionary = json.dictionaryWithoutNullValues()
        dict = dict.dictionaryWithCamelCaseKeys()
        let realm = Realm()
        realm.beginWrite()
        let user = realm.create(SoundCloudUser.self, value: dict, update: true)
        realm.commitWrite()
        return user
    }
    func findUser(name:String,completion:(user:SoundCloudUser?, error:NSError?)->Void){
        findUsers(name, completion: { (json, error) -> Void in
            if json.count > 0{
                let user = SoundCloudClient.createSoundCloudUser(json[0].object as! NSDictionary)
                completion(user:user, error:nil)
            }else{
                // FIXME: when no user found, create an appropriate error
                completion(user: nil, error: error)
            }
        })
    }
    func findUsers(name:String, completion:(json:JSON,error:NSError?)->Void){
        var params:[String:AnyObject] = [
            "q": name
        ]
        let url = urlWithParams(params, resource: "users")
        self.get(url) { json, error in
            println("fetched \(json.count) user(s) from SoundCloud via \(url)")
            completion(json: json, error: error)
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
}
