//
//  SongKickConfiguration.swift
//  GigRadio
//
//  Created by Michael Forrest on 17/05/2015.
//  Copyright (c) 2015 Good To Hear. All rights reserved.
//

import UIKit

struct SongKickConfiguration{
    var apiKey = Secrets.SongKickApiKey
    var baseUrl = NSProcessInfo().environment["SONGKICK_BASE_URL"] ?? "https://api.songkick.com/api/3.0"
}