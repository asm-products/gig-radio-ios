//
//  ImageProcessingHelper.swift
//  GigRadio
//
//  Created by Michael Forrest on 20/05/2015.
//  Copyright (c) 2015 Good To Hear. All rights reserved.
//

import UIKit
import CoreImage
import HTCoreImage
import TMCache

class ImageProcessingHelper: NSObject {
   
}

func desaturate(image: UIImage, completion: (image:UIImage)->Void){
    image.toCIImage().imageByApplyingFilter(
        CIFilter(colorControlsSaturation: 0, brightness: 0.3, contrast: 0.8)
    ).processToUIImageCompletion { (image) -> Void in
        completion(image: image)
    }
}
// this stuff is named a bit generally - will fall down if we start to process different sorts of images
func preprocessImages(urls:[String], callback:()->Void){
    let counter = CompletionCounter(total: urls.count, completion: callback)
    for url in urls{
        var image = cachedImage(url)
        if image == nil {
            image = UIImage(named: "flyer-placeholder.jpg")
        }
        if image == nil{
            println("balls")
        }
        desaturate(image!, { (image) -> Void in
            TMCache.sharedCache().setObject(image, forKey: url)
            counter.click()
        })
    }
}
func desaturatedImage(url:String)->UIImage?{
    if let image = TMCache.sharedCache().objectForKey(url) as? UIImage{
        return image
    }else{
        return nil
    }
}