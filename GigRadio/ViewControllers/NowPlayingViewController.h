//
//  NowPlayingViewController.h
//  GigRadio
//
//  Created by Michael Forrest on 16/08/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GigRadio-Swift.h>

@interface NowPlayingViewController : UIViewController
@property (nonatomic, strong) NSDate * date;

-(void)playNext;
-(void)playPreviousOrBackToBeginning;
-(void)togglePlayback;

@end
