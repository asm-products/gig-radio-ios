//
//  EventDetailViewController.h
//  GigRadio
//
//  Created by Michael Forrest on 26/10/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SongKickEvent.h"
@interface EventDetailViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, strong) SongKickEvent * event;
@property (nonatomic, strong) UIImage * backgroundImage;
@end