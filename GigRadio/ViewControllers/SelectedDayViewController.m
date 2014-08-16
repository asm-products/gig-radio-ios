//
//  SelectedDayViewController.m
//  GigRadio
//
//  Created by Michael Forrest on 16/08/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import "SelectedDayViewController.h"
#import "DateFormats.h"
#import "ArtistSelectionPresenter.h"
@interface SelectedDayViewController (){
    
    __weak IBOutlet UILabel *dayOfTheWeekLabel;
    __weak IBOutlet UILabel *dayOfTheMonthLabel;
}

@end

@implementation SelectedDayViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    dayOfTheWeekLabel.text = [[DateFormats dayOfTheWeekFormatter] stringFromDate:self.date];
    dayOfTheMonthLabel.text = [[DateFormats dayOfTheMonthFormatter] stringFromDate:self.date];
}
- (IBAction)didPressRefresh:(id)sender {
    [[ArtistSelectionPresenter presenterForDate:self.date] refresh];
}
@end
