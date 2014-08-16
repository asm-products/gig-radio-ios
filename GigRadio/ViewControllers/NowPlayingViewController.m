//
//  NowPlayingViewController.m
//  GigRadio
//
//  Created by Michael Forrest on 16/08/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import "NowPlayingViewController.h"
#import "SelectedDayViewController.h"
#import "CalendarHelper.h"
#import "ArtistSelectionPresenter.h"
#import "SongKickArtist.h"
#import "SongKickEvent.h"
#import "SoundCloudUser.h"
#import "SoundCloudTrack.h"
#import "SoundCloudSyncController.h"
@interface NowPlayingViewController ()<UIPageViewControllerDataSource,UIPageViewControllerDelegate>{
    __weak IBOutlet UILabel *artistNameLabel;
    
    __weak IBOutlet UILabel *venueLabel;
    __weak IBOutlet UILabel *nowPlayingLabel;
}
@property (nonatomic, strong) UIPageViewController * daySelector;
@property (nonatomic, strong) ArtistSelectionPresenter * artistsPresenter;
@end

@implementation NowPlayingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.date = [NSDate date];
}
-(void)setDate:(NSDate *)date{
    _date = date;
    
    NSLog(@"*************** %@ *******", date);
    self.artistsPresenter = [ArtistSelectionPresenter presenterForDate:date];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"DaySelector"]){
        self.daySelector = segue.destinationViewController;
        self.daySelector.dataSource = self;
        self.daySelector.delegate = self;
        [self.daySelector setViewControllers:@[[self dayViewControllerForDate:self.date]] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    }
}
- (IBAction)didPressRefresh:(id)sender {
    SongKickArtist * artist = [self.artistsPresenter.artists firstObject];
    if(!artist) {
        NSLog(@"NO artists!");
        return;
    }
    [self.artistsPresenter.soundCloudSyncController refreshWithArtistNamed:artist.displayName completion:^{
        SongKickEvent * event = [self.artistsPresenter eventWithArtist:artist];
        SoundCloudUser * soundCloudUser = [[SoundCloudUser objectsWhere:@"id == %i",artist.soundCloudUserId ] firstObject];
        RLMArray * tracks = [self.artistsPresenter artistTracks:soundCloudUser];
        
        SoundCloudTrack * track = tracks.firstObject;
        
        artistNameLabel.text = artist.displayName;
        venueLabel.text = [NSString stringWithFormat:@"%@ (%1.0fm away)", event.venue.displayName, event.distanceCache];
        nowPlayingLabel.text = [NSString stringWithFormat:@"Now playing: %@", track.title];
        
    }];
}

#pragma mark - Day selector control
-(SelectedDayViewController*)dayViewControllerForDate:(NSDate*)date{
    SelectedDayViewController * controller = [self.storyboard instantiateViewControllerWithIdentifier:@"SelectedDay"];
    controller.date = self.date ? self.date : [NSDate date];
    return controller;
}
-(NSDate*)dateFrom:(UIViewController*)current dayCount:(NSInteger)dayCount{
    SelectedDayViewController * controller = (SelectedDayViewController *) current;
    NSDate * currentDate = controller.date;
    NSDate * result = [[NSCalendar currentCalendar] dateByAddingComponents:[CalendarHelper days:dayCount] toDate:currentDate options:0];
    return result;
    
}
-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController{
    
    self.date = [self dateFrom:viewController dayCount:-1];
    return [self dayViewControllerForDate:self.date];
}
-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController{
    self.date = [self dateFrom:viewController dayCount:1];
    return [self dayViewControllerForDate:self.date];
    
}
@end
