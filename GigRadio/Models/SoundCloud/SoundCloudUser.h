//
//  SoundCloudUser.h
//  GigRadio
//
//  Created by Michael Forrest on 16/08/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import <Realm/Realm.h>
#import "SoundCloudTrack.h"
@import UIKit;

@interface SoundCloudUser : RLMObject
@property (nonatomic) NSInteger id;
@property (nonatomic, strong) NSString * kind;
@property (nonatomic, strong) NSString * permalink;
@property (nonatomic, strong) NSString * username;
@property (nonatomic, strong) NSString * uri;
@property (nonatomic, strong) NSString * permalink_url;
@property (nonatomic, strong) NSString * avatar_url;
@property (nonatomic, strong) NSString * full_name;
@property (nonatomic, strong) NSString * userDescription;
@property (nonatomic, strong) NSString * city;
@property (nonatomic, strong) NSString * website;
@property (nonatomic, strong) NSString * website_title;
@property (nonatomic) NSInteger track_count;
@property (nonatomic) NSInteger playlist_count;
@property (nonatomic) NSInteger followers_count;
@property (nonatomic) NSInteger followings_count;
+(SoundCloudUser*)findById:(NSInteger)identifier;
-(void)loadImage:(void(^)(UIImage*image))callback;

-(SoundCloudTrack*)nextTrackAfter:(NSArray*)trackIdsToSkip;

@property (nonatomic, strong) RLMArray<SoundCloudTrack> * tracks;

@end

// This protocol enables typed collections. i.e.:
// RLMArray<SoundCloudUser>
RLM_ARRAY_TYPE(SoundCloudUser)
