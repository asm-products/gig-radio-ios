//
//  SoundCloudArtistSearchRequest.m
//  GigRadio
//
//  Created by Michael Forrest on 16/08/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import "SoundCloudArtistSearchRequest.h"
#import "SoundCloudConfiguration.h"
#import <CMDQueryStringSerialization.h>
@implementation SoundCloudArtistSearchRequest
+(instancetype)requestWithArtistName:(NSString *)name{
    NSMutableDictionary * query = [NSMutableDictionary new];
    query[@"q"] = name;
    query[@"client_id"] = [SoundCloudConfiguration clientId];
    
    NSMutableString * uri = [[SoundCloudConfiguration baseUri] mutableCopy];
    [uri appendFormat:@"/users.json?%@", [CMDQueryStringSerialization queryStringWithDictionary:query] ];
    return [self requestWithURL:[NSURL URLWithString:uri]];
    
}
@end
