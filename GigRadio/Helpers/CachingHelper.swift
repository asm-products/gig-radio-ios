//
//  CachingHelper.swift
//  GigRadio
//
//  Created by Michael Forrest on 20/05/2015.
//  Copyright (c) 2015 Good To Hear. All rights reserved.
//

import UIKit
import TWRDownloadManager
import CryptoSwift

class CachingHelper: NSObject {
    override init(){

    }
}


func preloadImage(url: String){
    TWRDownloadManager.sharedManager().downloadFileForURL(url, progressBlock: { (progress) -> Void in
    }, completionBlock: { (success) -> Void in
    }, enableBackgroundMode: false)
    return
}
func preload(urls:[String], callback: ()->Void){
    let counter = CompletionCounter(total: urls.count, completion: callback)
    for url in urls{
        let name = url.md5()
        if TWRDownloadManager.sharedManager().fileExistsWithName(name){
            counter.click()
        }else{
            // download manager uses 'lastpathcomponent' to differentiate downloads but this doesn't work on songKick artist image urls
            // where the id is in the middle and last component is always the same
            TWRDownloadManager.sharedManager().downloadFileForURL(url, withName: name, inDirectoryNamed: nil, progressBlock: { (progress) -> Void in
            }, completionBlock: { (success) -> Void in
                counter.click()
            }, enableBackgroundMode: false)
        }
    }
}

func cachedImage(url:String)->UIImage?{
    let name = url.md5()
    if TWRDownloadManager.sharedManager().fileExistsWithName(name){
        let path = TWRDownloadManager.sharedManager().localPathForFile(name)
        return UIImage(contentsOfFile: path)
    }else{
        return nil
    }
}