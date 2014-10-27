//
//  ArtistNameTableViewCell.h
//  GigRadio
//
//  Created by Michael Forrest on 26/10/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SongKickArtist.h"
#import "SoundCloudUser.h"
@interface ArtistNameTableViewCell : UITableViewCell
@property (nonatomic, strong) SongKickArtist * songKickArtist;
@property (nonatomic, strong) SoundCloudUser * soundCloudUser;
@end
