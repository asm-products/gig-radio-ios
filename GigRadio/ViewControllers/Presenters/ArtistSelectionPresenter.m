//
//  ArtistSelectionPresenter.m
//  GigRadio
//
//  Created by Michael Forrest on 16/08/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import "ArtistSelectionPresenter.h"
#import <YLMoment.h>
@implementation ArtistSelectionPresenter
-(instancetype)initWithDate:(NSDate *)date{
    if(self = [super init]){
        self.date = [[[YLMoment momentWithDate:date] startOf:@"day"] date];
        [self refresh];
    }
    return self;
}
-(void)refresh{
    self.events = [SongKickEvent objectsWhere:@"start.date == %@", self.date];
    
    NSMutableArray * artists = [NSMutableArray new];
    for (SongKickEvent*event in self.events) {
        for (SongKickPerformance * performance in event.performance) {
            [artists addObject:performance.artist];
        }
    }
    self.artists = artists;
}
+(instancetype)presenterForDate:(NSDate *)date{
    ArtistSelectionPresenter * result = [[self alloc] initWithDate:date];
    return result;
}
@end
