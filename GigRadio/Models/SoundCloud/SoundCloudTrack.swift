//
//  SoundCloudTrack.swift
//  GigRadio
//
//  Created by Michael Forrest on 17/05/2015.
//  Copyright (c) 2015 Good To Hear. All rights reserved.
//

import UIKit
import RealmSwift

class SoundCloudTrack: Object {
    dynamic var id = 0
    dynamic var kind = ""
    dynamic var createdAt = NSDate()
    dynamic var userId  = 0
    dynamic var duration = 0
    dynamic var state = ""
    dynamic var sharing = ""
    dynamic var tagList = ""
    dynamic var permalink = ""
    dynamic var streamable = false
    dynamic var downloadable = false
    dynamic var purchaseUrl = ""
    dynamic var labelId = 0
    dynamic var purchaseTitle = ""
    dynamic var genre = ""
    dynamic var title = ""
    dynamic var descriptionText = ""
    dynamic var labelName = ""
    dynamic var trackType = ""
    dynamic var uri = ""
    dynamic var permalinkUrl = ""
    dynamic var artworkUrl = ""
    dynamic var waveformUrl = ""
    dynamic var streamUrl = ""
    dynamic var playbackCount = 0
    dynamic var downloadCount = 0
    dynamic var favoritingsCount = 0
    dynamic var commentCount = 0
    
    func playbackURL()->NSURL{
        return NSURL(string: "\(self.streamUrl)?client_id=\(SoundCloudConfiguration().clientId)")!
    }

}
