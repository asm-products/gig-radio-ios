//
//  SoundCloudArtistTracksRequest.m
//  GigRadio
//
//  Created by Michael Forrest on 16/08/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import "SoundCloudArtistTracksRequest.h"
#import "SoundCloudConfiguration.h"
#import <CMDQueryStringSerialization.h>
@implementation SoundCloudArtistTracksRequest
+(instancetype)requestWithUserId:(NSInteger)userId{
    NSMutableDictionary * query = [NSMutableDictionary new];
    query[@"client_id"] = [SoundCloudConfiguration clientId];
    
    NSMutableString * uri = [[SoundCloudConfiguration baseUri] mutableCopy];
    [uri appendFormat:@"/users/%@/tracks.json?%@", @(userId), [CMDQueryStringSerialization queryStringWithDictionary:query] ];
    return [self requestWithURL:[NSURL URLWithString:uri]];

}
@end
