//
//  BlacklistedArtists.swift
//  GigRadio
//
//  Created by Michael Forrest on 30/05/2015.
//  Copyright (c) 2015 Good To Hear. All rights reserved.
//

import UIKit
import RealmSwift
class BlacklistedArtist: Object {
    dynamic var soundCloudUser = SoundCloudUser()
    
    
    
    class func includes(user:SoundCloudUser)->Bool{
        return itemsWithSoundCloudUser(user).count > 0
    }
    class func includesSoundCloudUserWithId(id:Int)->Bool?{ // true, false or unknown
        if id == 0 {
            return nil
        }
        if let user = Realm().objectForPrimaryKey(SoundCloudUser.self, key: id){
            return self.includes(user)
        }else{
            return nil
        }
    }
    class func itemsWithSoundCloudUser(user:SoundCloudUser)->Results<BlacklistedArtist>{
        return Realm().objects(BlacklistedArtist).filter("soundCloudUser = %@", user)
    }
    class func add(user:SoundCloudUser){
        let realm = Realm()
        realm.write {
           realm.create(BlacklistedArtist.self, value: ["soundCloudUser": user], update: false)
        }
    }
    class func remove(user:SoundCloudUser){
        let realm = Realm()
        realm.write {
            realm.delete(self.itemsWithSoundCloudUser(user))
        }
    }
}
