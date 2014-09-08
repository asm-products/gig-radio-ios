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
#import <UIActionSheet+Blocks.h>
#import "SoundCloudSyncController.h"
#import <NCMusicEngine.h>
#import "SongKickSyncController.h"
#import "LocationHelper.h"
@import CoreLocation;
@interface NowPlayingViewController ()<UIPageViewControllerDataSource,UIPageViewControllerDelegate,NCMusicEngineDelegate>{
    __weak IBOutlet UIButton *artistNameButton;
    __weak IBOutlet UIButton *venueButton;
    __weak IBOutlet UIButton *nowPlayingButton;
}
@property (nonatomic, strong) UIPageViewController * daySelector;
@property (nonatomic, strong) ArtistSelectionPresenter * artistsPresenter;

@property (nonatomic) NSInteger currentArtistIndex;

@property (nonatomic, strong) NCMusicEngine * musicEngine;

@property (nonatomic, strong) SongKickEvent * currentEvent;
@property (nonatomic, strong) SongKickArtist * currentSongKickArtist;
@property (nonatomic, strong) SoundCloudUser * currentSoundCloudUser;
@property (nonatomic, strong) SoundCloudTrack * currentSoundCloudTrack;

@property (nonatomic, strong) SongKickSyncController * songKickSyncController;
@property (nonatomic, strong) CLLocation * location;
@end

@implementation NowPlayingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.currentArtistIndex = 0;
    self.musicEngine = [NCMusicEngine new];
    self.musicEngine.delegate = self;
    
    self.songKickSyncController = [SongKickSyncController new]; 
    [LocationHelper lookupWithError:^(NSError *error) {
        NSLog(@"Error looking up location");
    } completion:^(CLLocation *location) {
        self.location = location;
        self.date = [NSDate date]; // triggers a sync...
    }];
}
/**
 *  This is messy right now - it triggers a sync which is not what you'd expect it to do!
 */
-(void)setDate:(NSDate *)date{
    _date = date;
    
    NSLog(@"*************** %@ *******", date);
    self.artistsPresenter = [ArtistSelectionPresenter presenterForDate:date];
    [self.songKickSyncController refreshWithLocation:self.location date:date completion:^{
        [self didPressRefresh:nil]; // also bad tight coupling with IBActions throughout this class. It's all gonna be different when I have the design though.
    }];
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
    if(!self.artistsPresenter.artists || self.artistsPresenter.artists.count == 0) return;
    SongKickArtist * artist = self.artistsPresenter.artists[self.currentArtistIndex];
    if(!artist) {
        NSLog(@"NO artists!");
        return;
    }
    SongKickEvent * event = [self.artistsPresenter eventWithArtist:artist];
    if([event.venue.street isEqualToString:@""]){
        [self.songKickSyncController refreshVenue:event.venue.id completion:^{
           // and now I know the map links work
        }];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
            [artistNameButton setTitle:artist.displayName forState:UIControlStateNormal];
            [venueButton setTitle:[NSString stringWithFormat:@"%@, %@ (%1.0fm away)",event.start.timeString, event.venue.displayName, event.distanceCache] forState:UIControlStateNormal];
        
    });
    [self.artistsPresenter.soundCloudSyncController refreshWithArtistNamed:artist.displayName completion:^{
        SoundCloudUser * soundCloudUser = [[SoundCloudUser objectsWhere:@"id == %i",artist.soundCloudUserId ] firstObject];
        RLMArray * tracks = [self.artistsPresenter artistTracks:soundCloudUser];
        
        SoundCloudTrack * track = tracks.firstObject;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.musicEngine playUrl:track.playbackURL];
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
    // 0. open artist website
    // 1. songkick
    // 2. soundcloud
    // 3. search on Spotify
    // 4. search on iTunes
    [UIActionSheet showInView:self.view withTitle:self.currentSongKickArtist.displayName cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@[self.currentSoundCloudUser.website_title ? self.currentSoundCloudUser.website_title : @"Artist website", @"View on SongKick", @"View on SoundCloud", @"Search on Spotify", @"Search on iTunes"] tapBlock:^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
        if(buttonIndex == 0) [self open:self.currentSoundCloudUser.website];
        if(buttonIndex == 1) [self open:self.currentSongKickArtist.uri];
        if(buttonIndex == 2) [self open:self.currentSoundCloudUser.permalink_url];
        
    } ];
}
- (IBAction)didPressVenueButton:(id)sender {
    // do a popup, prompt:
    // 0. songkick
    // 1. apple maps
    // 2. google maps
    // 3. citymapper
    
    [UIActionSheet showInView:self.view withTitle:nil cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@[@"Open in SongKick", @"Directions on Apple Maps",@"Directions on Google Maps",@"Directions on Citymapper"] tapBlock:^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
        if(buttonIndex == 0) [self open:self.currentEvent.uri];
        if(buttonIndex == 1) [self open:self.currentEvent.venue.appleMapsUri];
        if(buttonIndex == 3) [self open:self.currentEvent.venue.citymapperUri];

    }];

//    [self open:[NSString stringWithFormat:@"https://www.songkick.com/venues/%li", self.currentEvent.venue.id]];
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

#pragma mark - Player delegate
-(void)engine:(NCMusicEngine *)engine didChangeDownloadState:(NCMusicEngineDownloadState)downloadState{
    
}
-(void)engine:(NCMusicEngine *)engine didChangePlayState:(NCMusicEnginePlayState)playState{
    
}
-(void)engine:(NCMusicEngine *)engine downloadProgress:(CGFloat)progress{
    
}
-(void)engine:(NCMusicEngine *)engine playProgress:(CGFloat)progress{
    if(progress > 0.9999){
        [self didPressNext:nil];
    }
}
@end
