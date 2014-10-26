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
#import "MusicEngine.h"
#import "SongKickSyncController.h"
#import "LocationHelper.h"
#import <HTCoreImage.h>
#import <CIFilter+HTCICategoryColorAdjustment.h>
#import <UIImage+RTTint.h>
#import <UIView+SimpleMotionEffects.h>
#import "DateFormats.h"

@import MapKit;

@import CoreLocation;
@interface NowPlayingViewController ()<UIPageViewControllerDataSource,UIPageViewControllerDelegate,NCMusicEngineDelegate>{
    __weak IBOutlet UIButton *artistNameButton;
    __weak IBOutlet UIButton *dateButton;
    __weak IBOutlet UIButton *venueButton;
    __weak IBOutlet UIButton *nowPlayingButton;
    __weak IBOutlet UILabel *distanceLabel;
}
@property (nonatomic, strong) UIPageViewController * daySelector;
@property (nonatomic, strong) ArtistSelectionPresenter * artistsPresenter;

@property (nonatomic) NSInteger currentArtistIndex;

@property (nonatomic, strong) MusicEngine * musicEngine;

@property (nonatomic, strong) SongKickEvent * currentEvent;
@property (nonatomic, strong) SongKickArtist * currentSongKickArtist;
@property (nonatomic, strong) SoundCloudUser * currentSoundCloudUser;
@property (nonatomic, strong) SoundCloudTrack * currentSoundCloudTrack;

@property (nonatomic, strong) SongKickSyncController * songKickSyncController;
@property (nonatomic, strong) CLLocation * location;

@property (weak, nonatomic) IBOutlet UIButton *playPauseButton;
@property (weak, nonatomic) IBOutlet UIButton *rewindButton;
@property (weak, nonatomic) IBOutlet UIButton *fastforwardButton;
@property (weak, nonatomic) IBOutlet UIImageView *artistImageView;
@property (weak, nonatomic) IBOutlet UISlider *playbackScrubSlider;

@property (nonatomic) BOOL isPaused;

@end

@implementation NowPlayingViewController
-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}
-(BOOL)prefersStatusBarHidden{
    return YES;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.isPaused = YES;
    [self wireUpTransportControls];
    
    self.currentArtistIndex = 0;
    self.musicEngine = [MusicEngine new];
    self.musicEngine.delegate = self;
    
    self.songKickSyncController = [SongKickSyncController new]; 
    [LocationHelper lookupWithError:^(NSError *error) {
        NSLog(@"Error looking up location");
    } completion:^(CLLocation *location) {
        self.location = location;
        self.date = [NSDate date]; // triggers a sync...
    }];
    [self.artistImageView addMotionEffectWithMovement:CGPointMake(16, 16)];
}
/**
 *  This is messy right now - it triggers a sync which is not what you'd expect it to do!
 */
-(void)setDate:(NSDate *)date{
    _date = date;
    
    NSLog(@"*************** %@ *******", date);
    self.artistsPresenter = [ArtistSelectionPresenter presenterForDate:date];
    [self.songKickSyncController refreshWithLocation:self.location date:date completion:^{
        [self.artistsPresenter refresh];
        [self refreshCurrentArtist];
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"DaySelector"]){
        self.daySelector = segue.destinationViewController;
        self.daySelector.dataSource = self;
        self.daySelector.delegate = self;
        [self.daySelector setViewControllers:@[[self dayViewControllerForDate:self.date]] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    }else if ([segue.identifier isEqualToString:@"Debug"]){
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }else if([segue.identifier isEqualToString:@"Event"]){
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
}
-(void)viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [super viewWillAppear:animated];
}
- (IBAction)didPressRefresh:(id)sender {
    [self refreshCurrentArtist];
}
-(void)refreshCurrentArtist{
    SongKickArtist * artist = [self currentArtist];
    if(!artist) {
        // do something
        return;
    }
    
    SongKickEvent * event = [self.artistsPresenter eventWithArtist:artist];
    if([event.venue.street isEqualToString:@""]){
        [self.songKickSyncController refreshVenue:event.venue.id completion:^{
            // and now I know the map links work
        }];
    }
    [self showArtist:artist event:event];
    [self.artistsPresenter.soundCloudSyncController fetchArtistNamed:artist.displayName completion:^(SoundCloudUser *soundCloudUser) {
        
        RLMArray * tracks = [self.artistsPresenter artistTracks:soundCloudUser];
        
        [soundCloudUser loadImage:^(UIImage*image){
            UIColor * tintColor = [UIColor colorWithRed:0.843 green:0.000 blue:0.455 alpha:1];

            [[[image toCIImage] imageByApplyingFilters:@[
                                                         [CIFilter filterColorControlsSaturation:0 brightness:0.3 contrast:0.5]
                                                         ]] processToUIImageCompletion:^(UIImage *uiImage) {
                self.artistImageView.image = [uiImage rt_tintedImageWithColor:tintColor level:0.5];
                self.artistImageView.alpha = 0.7;
            }];
        }];
        
        SoundCloudTrack * track = tracks.firstObject;
        dispatch_async(dispatch_get_main_queue(), ^{
            if(!self.isPaused){
                [self.musicEngine playUrl:track.playbackURL];
            }
            [nowPlayingButton setTitle:[NSString stringWithFormat:@"%@", track.title] forState:UIControlStateNormal];
        });
        self.currentEvent = event;
        self.currentSongKickArtist = artist;
        self.currentSoundCloudUser = soundCloudUser;
        self.currentSoundCloudTrack = track;
    }];
}
-(void)showArtist:(SongKickArtist*)artist event:(SongKickEvent*)event{
    [artistNameButton setTitle:artist.displayName forState:UIControlStateNormal];
    
    [dateButton setTitle:[[DateFormats eventDateFormatter] stringFromDate:event.start.datetime] forState:UIControlStateNormal];
    
    [venueButton setTitle:[NSString stringWithFormat:@"%@\n%@", event.venue.displayName, event.venue.address] forState:UIControlStateNormal];
    MKDistanceFormatter *df = [[MKDistanceFormatter alloc]init];
    df.unitStyle = MKDistanceFormatterUnitStyleAbbreviated;
    distanceLabel.text = [[df stringFromDistance:event.distanceCache] stringByAppendingString:@"\naway"];
    
}
-(SongKickArtist*)currentArtist{
    if(!self.artistsPresenter.artists || self.artistsPresenter.artists.count == 0) return nil;
    SongKickArtist * artist = self.artistsPresenter.artists[self.currentArtistIndex];
    return artist;
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

#pragma mark - transport
-(void)wireUpTransportControls{
    [self.fastforwardButton addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleFastforwardTapGesture:)]];
    [self.rewindButton addGestureRecognizer:[[UIGestureRecognizer alloc] initWithTarget:self action:@selector(handleRewindTapGesture:)]];
}
- (IBAction)didPressPlayPause:(id)sender {
    if(self.isPaused){
        if(self.musicEngine.playState == NCMusicEnginePlayStatePaused && self.musicEngine.currentlyPlayingTrack == self.currentSoundCloudTrack){
            [self.musicEngine resume];
        }else{
            [self.musicEngine playSoundCloudTrack:self.currentSoundCloudTrack];
        }
    }else{
        [self.musicEngine pause];
    }
    self.isPaused = !self.isPaused;
    [self updatePlayPauseButton];
}
-(void)updatePlayPauseButton{
    [self.playPauseButton setImage: [UIImage imageNamed:self.isPaused ? @"play_large" : @"pause_large" ]  forState:UIControlStateNormal];
}
-(void)handleFastforwardTapGesture:(UITapGestureRecognizer*)tap{
    [self playNext];
}
-(void)handleFastforwardLongPressGesture:(UILongPressGestureRecognizer*)press{
    
}
-(void)handleRewindTapGesture:(UITapGestureRecognizer*)tap{
    
}
-(void)handleRewindLongPressGesture:(UILongPressGestureRecognizer*)press{
    
}
-(void)playNext{
    self.currentArtistIndex ++;
    if(self.currentArtistIndex > self.artistsPresenter.artists.count - 1){
        self.currentArtistIndex = 0;
    }
    [self refreshCurrentArtist];
}

#pragma mark - other button presses
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
#pragma mark - Player delegate
-(void)engine:(NCMusicEngine *)engine didChangeDownloadState:(NCMusicEngineDownloadState)downloadState{
    
}
-(void)engine:(NCMusicEngine *)engine didChangePlayState:(NCMusicEnginePlayState)playState{
    
}
-(void)engine:(NCMusicEngine *)engine downloadProgress:(CGFloat)progress{
    
}
-(void)engine:(NCMusicEngine *)engine playProgress:(CGFloat)progress{
    [self.playbackScrubSlider setValue:progress animated:NO];
    if(progress > 0.9999){
        [self playNext];
    }
}
@end
