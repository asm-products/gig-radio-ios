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
extension UIImage{
    func isFullyTransparent()->Bool{
        let onePixel = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContextWithOptions(onePixel.size, false, 0)
        drawInRect(onePixel)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
        return image.getPixelAlpha(onePixel.origin) == 0
    }
    func getPixelAlpha(pos: CGPoint) -> CGFloat {
        var pixelData = CGDataProviderCopyData(CGImageGetDataProvider(self.CGImage))
        var data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        var pixelInfo: Int = ((Int(self.size.width) * Int(pos.y)) + Int(pos.x)) * 4
        var a = CGFloat(data[pixelInfo+3]) / CGFloat(255.0)
        return a
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
    let downloads = TWRDownloadManager.sharedManager()
    for url in urls{
        let name = url.md5()
        if downloads.fileExistsWithName(name) || downloads.isFileDownloadingForUrl(url, withProgressBlock: { (progress) -> Void in
        }){
            counter.click()
        }else{
            // download manager uses 'lastpathcomponent' to differentiate downloads but this doesn't work on songKick artist image urls
            // where the id is in the middle and last component is always the same
            downloads.downloadFileForURL(url, withName: name, inDirectoryNamed: nil, progressBlock: { (progress) -> Void in
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
        if let result = UIImage(contentsOfFile: path){
        // naughty SongKick CDN returns an empty transparent image instead of a 404 so we have to hack to check for a clear image
            if (result.isFullyTransparent()){
                return nil
            }else{
                return result
            }
        }else{
            return nil
        }
    }else{
        return nil
    }
}