//
//  SoundCloudConfiguration.swift
//  GigRadio
//
//  Created by Michael Forrest on 17/05/2015.
//  Copyright (c) 2015 Good To Hear. All rights reserved.
//

import UIKit

struct SoundCloudConfiguration {
    var clientId = Secrets.SoundCloudClientId
    var baseUri = NSProcessInfo().environment["SOUNDCLOUD_BASE_URL"] ?? "https://api.soundcloud.com"
}
