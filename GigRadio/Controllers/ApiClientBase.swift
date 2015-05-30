//
//  ApiClientBase.swift
//  GigRadio
//
//  Created by Michael Forrest on 31/05/2015.
//  Copyright (c) 2015 Good To Hear. All rights reserved.
//

import UIKit
import SwiftyJSON

class ApiClientBase: NSObject {
    lazy var session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
    var errorDomain = "ApiClient"
   
    func get(url:NSURL,completion:(json:JSON,error:NSError?)->Void){
        session.dataTaskWithURL(url, completionHandler: { data, response, error in
            let response = response as! NSHTTPURLResponse
            let json = JSON(data:data)
            Async.main {
                if response.statusCode != 200{
                    if error == nil{
                        let error = NSError(domain: self.errorDomain, code: response.statusCode, userInfo: json.object as? [NSObject : AnyObject])
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
