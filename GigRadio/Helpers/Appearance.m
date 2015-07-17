//
//  AppearanceHelper.m
//  GigRadio
//
//  Created by Michael Forrest on 17/07/2015.
//  Copyright (c) 2015 Good To Hear. All rights reserved.
//

#import "Appearance.h"

@implementation Appearance
+(void)apply{
    [[UILabel appearanceWhenContainedIn:[UITableViewHeaderFooterView class], nil] setTextColor:[UIColor lightGrayColor]];
}
@end
