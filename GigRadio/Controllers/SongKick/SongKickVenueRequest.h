//
//  SongKickVenueRequest.h
//  GigRadio
//
//  Created by Michael Forrest on 17/08/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SongKickVenueRequest : NSURLRequest
+(instancetype)requestWithVenueId:(NSInteger)venueId;
@end
