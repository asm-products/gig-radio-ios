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
    __weak IBOutlet UIButton *artistNameButton;
    __weak IBOutlet UIButton *venueButton;
    __weak IBOutlet UIButton *nowPlayingButton;
}
@property (nonatomic, strong) UIPageViewController * daySelector;
@property (nonatomic, strong) ArtistSelectionPresenter * artistsPresenter;

@property (nonatomic) NSInteger currentArtistIndex;

@property (nonatomic, strong) SongKickEvent * currentEvent;
@property (nonatomic, strong) SongKickArtist * currentSongKickArtist;
@property (nonatomic, strong) SoundCloudUser * currentSoundCloudUser;
@property (nonatomic, strong) SoundCloudTrack * currentSoundCloudTrack;
@end

@implementation NowPlayingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.date = [NSDate date];
    self.currentArtistIndex = 0;
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
    SongKickArtist * artist = self.artistsPresenter.artists[self.currentArtistIndex];
    if(!artist) {
        NSLog(@"NO artists!");
        return;
    }
    [self.artistsPresenter.soundCloudSyncController refreshWithArtistNamed:artist.displayName completion:^{
        SongKickEvent * event = [self.artistsPresenter eventWithArtist:artist];
        SoundCloudUser * soundCloudUser = [[SoundCloudUser objectsWhere:@"id == %i",artist.soundCloudUserId ] firstObject];
        RLMArray * tracks = [self.artistsPresenter artistTracks:soundCloudUser];
        
        SoundCloudTrack * track = tracks.firstObject;
        dispatch_async(dispatch_get_main_queue(), ^{
            [artistNameButton setTitle:artist.displayName forState:UIControlStateNormal];
            [venueButton setTitle:[NSString stringWithFormat:@"%@ (%1.0fm away)", event.venue.displayName, event.distanceCache] forState:UIControlStateNormal];
            
            [nowPlayingButton setTitle:[NSString stringWithFormat:@"Now playing: %@", track.title] forState:UIControlStateNormal];

        });
        
        
        self.currentEvent = event;
        self.currentSongKickArtist = artist;
        self.currentSoundCloudUser = soundCloudUser;
        self.currentSoundCloudTrack = track;
        
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
#pragma mark - button presses
-(void)open:(NSString*)uri{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:uri]];
}
- (IBAction)didPressArtistButton:(id)sender {
    // do a prompt
    // 1. open artist website
    // 2. songkick
    // 3. soundcloud
    // 4. search on Spotify
    // 5. search on iTunes
    [self open:self.currentSoundCloudUser.permalink_url];
}
- (IBAction)didPressVenueButton:(id)sender {
    // do a popup, prompt:
    // 1. songkick
    // 2. apple maps
    // 3. google maps
    // 4. citymapper citymapper://directions?endcoord=51.563612,-0.073299&endname=Abney%20Park%20Cemetery&endaddress=Stoke%20Newington%20High%20Street
    [self open:[NSString stringWithFormat:@"https://www.songkick.com/venues/%li", self.currentEvent.venue.id]];
}
- (IBAction)didPressNowPlayingButton:(id)sender {
    // 1. open in browser
    // 2. open in soundcloud app
    // 3. buy track
    [self open:self.currentSoundCloudTrack.permalink_url];
}
- (IBAction)didPressNext:(id)sender {
    self.currentArtistIndex ++;
    if(self.currentArtistIndex > self.artistsPresenter.artists.count - 1){
        self.currentArtistIndex = 0;
    }
    [self didPressRefresh:nil];
}

@end
