//
//  SoundCloudUser.m
//  GigRadio
//
//  Created by Michael Forrest on 16/08/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import "SoundCloudUser.h"

@implementation SoundCloudUser

// Specify default values for properties

+ (NSDictionary *)defaultPropertyValues
{
    return @{
            @"website":@"",
            @"website_title":@"",
            @"permalink":@"",
            @"description":@"",
            @"userDescription":@"",
            @"avatar_url":@"",
            @"city":@""
             };
}

// Specify properties to ignore (Realm won't persist these)

//+ (NSArray *)ignoredProperties
//{
//    return @[];
//}
+(SoundCloudUser *)findById:(NSInteger)identifier{
   return [[SoundCloudUser objectsWhere:@"id == %i",identifier ] firstObject];
}

-(void)loadImage:(void (^)(UIImage *))callback{
    NSURLSession * session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSString * url = [self.avatar_url stringByReplacingOccurrencesOfString:@"-large.jpg" withString:@"-t500x500.jpg"];
    [[session dataTaskWithURL:[NSURL URLWithString:url] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if(data){
            UIImage * image = [UIImage imageWithData:data];
            dispatch_async(dispatch_get_main_queue(), ^{
                callback(image);
            });
        }
    }] resume];

}

-(SoundCloudTrack *)nextTrackAfter:(NSArray *)trackIdsToSkip{
    for (SoundCloudTrack * track in self.tracks) {
        if([trackIdsToSkip indexOfObject:@(track.id)] == NSNotFound){
            return track;
        }
    }
    return nil;
}

@end
