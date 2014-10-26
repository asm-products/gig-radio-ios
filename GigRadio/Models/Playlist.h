//
//  Playlist.h
//  GigRadio
//
//  Created by Michael Forrest on 26/10/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CWLSynthesizeSingleton.h>
#import "PlaylistItem.h"

@interface Playlist : NSObject
CWL_DECLARE_SINGLETON_FOR_CLASS_WITH_ACCESSOR(Playlist, currentPlaylist);

@property (nonatomic, strong) NSDate * startDate;
@property (nonatomic, strong) NSDate * endDate;

/**
 *  This is asynchronous because we need to hit SoundCloud to fetch each sound cloud user's tracks
 *  Relative to a given item in case the contents of the playlist changes.
 *
 *  @param previousItem first item is returned if this is nil
 *  @param callback on the main thread
 */
-(void)fetchItemAfter:(PlaylistItem*)previousItem callback:(void (^)(PlaylistItem * item))callback;

/**
 *  Synchronous because the playlist is always built in a forward direction, even if when it's short it might eventually loop around
 */
-(PlaylistItem*)itemBefore:(PlaylistItem*)item;

-(void)rebuild;

@end
