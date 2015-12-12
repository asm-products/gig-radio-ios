//
//  MappingApp.swift
//  GigRadio
//
//  Created by Michael Forrest on 30/05/2015.
//  Copyright (c) 2015 Good To Hear. All rights reserved.
//

import UIKit

class MapLink: NSObject {
    static let DefaultsKey = "MapLinkPreferenceKey"
    var displayName: String
    var appURL: NSURL
    init(displayName: String, appURL: NSURL){
        self.displayName = displayName
        self.appURL = appURL
    }
    class func allMapLinks(venue:SongKickVenue)->[MapLink]{
        var links = [MapLink]()
        let app = UIApplication.sharedApplication()
        
        for item:[String] in [
            ["CityMapper", citymapperUri(venue)],
            ["Google Maps", googleMapsUri(venue)],
            ["Apple Maps", appleMapsUri(venue)]
            ]
        {
            if let url = NSURL(string: item.last!){
                if app.canOpenURL(url){
                    links.append(MapLink(displayName: item.first!, appURL: url))
                }
            }
        }
        return links
    }
    class func preferredMapLink(venue:SongKickVenue)->MapLink?{
        let links = allMapLinks(venue)
        if let name = NSUserDefaults.standardUserDefaults().stringForKey(DefaultsKey){
            return  links.filter({$0.displayName == name}).first
        }else{
           return links.first
        }
    }
    class func saveMapLinkPreference(mapLink:MapLink){
        NSUserDefaults.standardUserDefaults().setObject(mapLink.displayName, forKey: DefaultsKey)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    class func appleMapsUri(venue:SongKickVenue)->String{
        return "http://maps.apple.com/?daddr=\(venue.address().stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)"
    }
    class func googleMapsUri(venue:SongKickVenue)->String{
        //comgooglemaps://?saddr=Google+Inc,+8th+Avenue,+New+York,+NY&daddr=John+F.+Kennedy+International+Airport,+Van+Wyck+Expressway,+Jamaica,+New+York&directionsmode=transit
        return "comgooglemaps://?daddr=\(venue.address().stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)"
    }
    class func citymapperUri(venue:SongKickVenue)->String{
        // citymapper://directions?endcoord=51.563612,-0.073299&endname=Abney%20Park%20Cemetery&endaddress=Stoke%20Newington%20High%20Street
        var params = [
            "endname": venue.displayName,
            "endaddress": venue.address()
            ].map { name, value -> NSURLQueryItem in
                return NSURLQueryItem(name: name, value: value)
        }
        if venue.lat != 0{
            params.append(NSURLQueryItem(name: "endcoord", value: "\(venue.lat),\(venue.lng)"))
        }
        let components = NSURLComponents(URL: NSURL(string: "citymapper://directions")!, resolvingAgainstBaseURL: false)
        components?.queryItems = params
        return components!.URL!.absoluteString
    }
}
