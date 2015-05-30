//
//  I18nHelper.swift
//  GigRadio
//
//  Created by Michael Forrest on 17/05/2015.
//  Copyright (c) 2015 Good To Hear. All rights reserved.
//

import UIKit

func t(key:String)->String{
    return NSLocalizedString(key, tableName: nil, bundle: NSBundle.mainBundle(), value: "", comment: "")
}
func template(key:String, values:[CVarArgType])->String{
    return String(format: t(key), arguments: values)
}