//
//  Favourite.swift
//  GigRadio
//
//  Created by Michael Forrest on 28/05/2015.
//  Copyright (c) 2015 Good To Hear. All rights reserved.
//

import UIKit
import RealmSwift
let FAVOURITE_COUNT_CHANGED = "FAVOURITE_COUNT_CHANGED"
class Favourite: Object {
    dynamic var event: SongKickEvent!
    dynamic var id = NSUUID().UUIDString
    override static func primaryKey()->String?{
        return "id"
    }
    class func findByEvent(event:SongKickEvent)->Favourite?{
        let objects = try! Realm().objects(Favourite).filter("event = %@", event)
        return objects.first
    }
    class func remove(item:Favourite){
        for notification in UIApplication.sharedApplication().scheduledLocalNotifications!{
            if let userInfo = notification.userInfo as? [String:Int],
            let eventId = userInfo["songKickEventId"]{
                if eventId == item.event.id{
                    UIApplication.sharedApplication().cancelLocalNotification(notification)
                }
            }
        }
        try! Realm().write {
            try! Realm().delete(item)
        }
    }
    class func add(event:SongKickEvent){
        let notification = UILocalNotification()
        notification.userInfo = ["songKickEventId": event.id]
        notification.alertTitle = "Gig tonight"
        notification.alertBody = "\(event.displayName) \(event.venue.displayName) \(event.start.time)"
        if let dateTime = event.start.parsedDateTime(){
            notification.fireDate = dateTime.dateByAddingTimeInterval(2 * 60 * 60)
        }else{
            notification.fireDate = NSCalendar.currentCalendar().dateBySettingHour(12, minute: 00, second: 00, ofDate: event.date, options: [])
        }
        UIApplication.sharedApplication().scheduleLocalNotification(notification)

        try! Realm().write {
            let item = Favourite()
            item.event = event
            try! Realm().add(item, update: false)
        }
    }
    class func futureEvents()->Results<Favourite>{
        return try! Realm().objects(Favourite).filter("event.date >= %@", CalendarHelper.startOfUTCDay(NSDate()))
    }
    class func pastEvents()->Results<Favourite>{
        return try! Realm().objects(Favourite).filter("event.date < %@", CalendarHelper.startOfUTCDay(NSDate()))
    }
}
