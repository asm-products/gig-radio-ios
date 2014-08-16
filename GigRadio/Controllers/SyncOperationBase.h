//
//  SyncOperationBase.h
//  GigRadio
//
//  Created by Michael Forrest on 16/08/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void (^JSONParseCompletionBlock)();
@interface SyncOperationBase : NSOperation
@property (nonatomic, strong) NSURLRequest * request;
@property (nonatomic, strong) JSONParseCompletionBlock jsonParseCompletionBlock;
-(instancetype)initWithRequest:(NSURLRequest*)request;
-(void)parseAndStore:(id)json;

@end
