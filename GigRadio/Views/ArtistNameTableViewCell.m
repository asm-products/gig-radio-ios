//
//  ArtistNameTableViewCell.m
//  GigRadio
//
//  Created by Michael Forrest on 26/10/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import "ArtistNameTableViewCell.h"

@implementation ArtistNameTableViewCell{
    
    __weak IBOutlet UILabel *titleLabel;
}

- (void)awakeFromNib {
    // Initialization code
}
-(void)setSongKickArtist:(SongKickArtist *)songKickArtist{
    _songKickArtist = songKickArtist;
    titleLabel.text = songKickArtist.displayName;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
