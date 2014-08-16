//
//  SyncOperationBase.m
//  GigRadio
//
//  Created by Michael Forrest on 16/08/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import "SyncOperationBase.h"

@implementation SyncOperationBase
-(instancetype)initWithRequest:(NSURLRequest*)request{
    if(self = [super init]){
        self.request = request;
    }
    return self;
}
-(void)main{
    @autoreleasepool{
        [self performRequest];
    }
}
-(void)performRequest{
    NSURLSession * session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSLog(@"Get %@", self.request.URL.absoluteString);
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    NSURLSessionDataTask * task = [session dataTaskWithRequest:self.request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        NSHTTPURLResponse * httpResponse = (NSHTTPURLResponse*) response;
        if(httpResponse && httpResponse.statusCode == 200){
            NSError * error;
            NSDictionary * json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
            if(error){
                NSLog(@"Error parsing json %@", error.localizedDescription);
            }else{
                [self parseAndStore: json];
            }
        }else{
            NSLog(@"There was an error with the request: %@", error);
        }
    }];
    [task resume];
}
-(void)parseAndStore:(NSDictionary *)json{
    @throw [NSException exceptionWithName:@"AbstractMethod" reason:@"should be overridden" userInfo:nil];
}
@end
