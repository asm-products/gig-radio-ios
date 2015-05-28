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
    var timeout: NSTimeInterval = 4
    var completion: ()->Void
    var timer: Async!
    init(total:Int, completion:()->Void){
        self.total = total
        self.completion = completion
        self.timer = Async.main(after: timeout) {
            self.complete()
        }
        if total == 0{
            self.complete()
        }
        
    }
    func complete(){
        timer.cancel(   )
        completion()
    }
    func click(){
        count += 1
        if count == total{
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.complete()
            })
        }
    }
}

