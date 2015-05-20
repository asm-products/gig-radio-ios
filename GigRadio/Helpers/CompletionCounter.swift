//
//  CompletionCounter.swift
//  GigRadio
//
//  Created by Michael Forrest on 20/05/2015.
//  Copyright (c) 2015 Good To Hear. All rights reserved.
//

import UIKit

class CompletionCounter{
    var count = 0
    var total:Int
    var completion: ()->Void
    init(total:Int, completion:()->Void){
        self.total = total
        self.completion = completion
        if total == 0{
            completion()
        }
    }
    func click(){
        count += 1
        if count == total - 1{
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.completion()
            })
        }
    }
}

