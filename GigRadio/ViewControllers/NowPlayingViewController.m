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
#import "Playlist.h"
#import "PlaylistDebuggingTableViewController.h"
#import "AppDelegate.h"
#import "CompassView.h"
#import "EventDetailViewController.h"

@import MapKit;
@import MediaPlayer;

@import CoreLocation;
@interface NowPlayingViewController ()<UIPageViewControllerDataSource,UIPageViewControllerDelegate,NCMusicEngineDelegate>{
    __weak IBOutlet UIButton *artistNameButton;
    __weak IBOutlet UIButton *dateButton;
    __weak IBOutlet UIButton *venueButton;
    __weak IBOutlet UIButton *nowPlayingButton;
    __weak IBOutlet CompassView *compassView;
    __weak IBOutlet UILabel *distanceLabel;
}
@property (nonatomic, strong) UIPageViewController * daySelector;

@property (nonatomic, strong) MusicEngine * musicEngine;
@property (nonatomic, strong) Playlist * playlist;
@property (nonatomic, strong) PlaylistItem * currentPlaylistItem;

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
    
    [(AppDelegate*)[UIApplication sharedApplication].delegate setNowPlayingViewController:self]; // trying out a new pattern here...
    
    self.isPaused = YES;
    [self wireUpTransportControls];
    
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
    self.playlist = [Playlist currentPlaylist];
    
    [self.songKickSyncController refreshWithLocation:self.location date:date completion:^{
        self.playlist.startDate = date;
        self.playlist.endDate = date;
        [self.playlist rebuild];
        [self.playlist fetchItemAfter:self.currentPlaylistItem callback:^(PlaylistItem *item) {
            self.currentPlaylistItem = item;
            [self refreshCurrentArtist];
        }];
        
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
        ((PlaylistDebuggingTableViewController*) segue.destinationViewController).playlist = self.playlist;
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }else if([segue.identifier isEqualToString:@"Event"]){
        EventDetailViewController* controller = segue.destinationViewController;
        controller.event = self.currentPlaylistItem.event;
        controller.backgroundImage = self.artistImageView.image;
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
    if(self.currentPlaylistItem.songKickArtist == nil) {
        // do something
        [self showPlaylistItem:nil];
        return;
    }
    
    SongKickEvent * event = self.currentPlaylistItem.event;
    if([event.venue.street isEqualToString:@""]){
        [self.songKickSyncController refreshVenue:event.venue.id completion:^{
            // and now I know the map links work
        }];
    }
    [self showPlaylistItem:self.currentPlaylistItem];
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if(!self.isPaused){
            [self.musicEngine playUrl:self.currentPlaylistItem.track.playbackURL];
        }
        [nowPlayingButton setTitle:[NSString stringWithFormat:@"%@", self.currentPlaylistItem.track.title] forState:UIControlStateNormal];
    });
}
-(void)showPlaylistItem:(PlaylistItem*)item{
    [artistNameButton setTitle:item.songKickArtist ? item.songKickArtist.displayName : @"" forState:UIControlStateNormal];
    [dateButton setTitle:item.event ? [[DateFormats eventDateFormatter] stringFromDate:item.event.start.datetime] : @"" forState:UIControlStateNormal];
    
    [venueButton setTitle:[NSString stringWithFormat:@"%@\n%@", item.event.venue.displayName, item.event.venue.address] forState:UIControlStateNormal];
    MKDistanceFormatter *df = [[MKDistanceFormatter alloc]init];
    df.unitStyle = MKDistanceFormatterUnitStyleAbbreviated;
    
    compassView.destination = item.event.venue.location;
    
    distanceLabel.text =  item.event ? [[df stringFromDistance:item.event.distanceCache] stringByAppendingString:@"\naway"] : @"";
    
    [item.soundCloudUser loadImage:^(UIImage*image){
        UIColor * tintColor = [UIColor colorWithRed:0.843 green:0.000 blue:0.455 alpha:1];
        
        [[[image toCIImage] imageByApplyingFilters:@[
                                                     [CIFilter filterColorControlsSaturation:0 brightness:0.3 contrast:0.8]
                                                     ]] processToUIImageCompletion:^(UIImage *uiImage) {
            self.artistImageView.image = [uiImage rt_tintedImageWithColor:tintColor level:0.5];
            self.artistImageView.alpha = 0.7;
        }];
        
        
        
        NSMutableDictionary * info = @{
                                       MPMediaItemPropertyAlbumTitle:[NSString stringWithFormat:@"Upcoming gig: %@", item.event.displayName],
                                       MPMediaItemPropertyTitle: [NSString stringWithFormat:@"%@ - %@",item.track.title, item.songKickArtist.displayName]
                                       }.mutableCopy;
        if(image){
            info[MPMediaItemPropertyArtwork] = [[MPMediaItemArtwork alloc] initWithImage:image];
        }
        [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:info];
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

#pragma mark - transport
-(void)wireUpTransportControls{
    [self.fastforwardButton addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleFastforwardTapGesture:)]];
    [self.rewindButton addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleRewindTapGesture:)]];
}
- (IBAction)didPressPlayPause:(id)sender {
    [self togglePlayback];
}
-(void)togglePlayback{
    if(self.isPaused){
        if(self.musicEngine.playState == NCMusicEnginePlayStatePaused && self.musicEngine.currentlyPlayingTrack == self.currentPlaylistItem.track){
            [self.musicEngine resume];
        }else{
            [self.musicEngine playSoundCloudTrack:self.currentPlaylistItem.track];
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
    [self playPreviousOrBackToBeginning];
}
-(void)handleRewindLongPressGesture:(UILongPressGestureRecognizer*)press{
    
}
-(void)playNext{
    [self.playlist fetchItemAfter:self.currentPlaylistItem callback:^(PlaylistItem *item) {
        self.currentPlaylistItem = item;
        [self refreshCurrentArtist];
    }];
}
-(void)playPreviousOrBackToBeginning{
    if(self.playbackScrubSlider.value > 0.1){
        [self.musicEngine playSoundCloudTrack:self.currentPlaylistItem.track];
    }else{
        self.currentPlaylistItem = [self.playlist itemBefore:self.currentPlaylistItem];
        [self.musicEngine playSoundCloudTrack:self.currentPlaylistItem.track];
        [self refreshCurrentArtist];
    }
}

#pragma mark - other button presses
-(void)open:(NSString*)uri{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:uri]];
}
- (IBAction)didPressArtistButton:(id)sender {
    NSArray * links = @[self.currentPlaylistItem.soundCloudUser.website_title ? self.currentPlaylistItem.soundCloudUser.website_title : @"Artist website",
                          @"View on SongKick",
                          @"View on SoundCloud",
                          @"Search on Spotify",
                          @"Search on iTunes"];
    [UIActionSheet showInView:self.view withTitle:self.currentPlaylistItem.songKickArtist.displayName cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles: links tapBlock:^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
        if(buttonIndex == 0) [self open:self.currentPlaylistItem.soundCloudUser.website];
        if(buttonIndex == 1) [self open:self.currentPlaylistItem.songKickArtist.uri];
        if(buttonIndex == 2) [self open:self.currentPlaylistItem.soundCloudUser.permalink_url];
        
    } ];
}
- (IBAction)didPressNowPlayingButton:(id)sender {
    // 1. open in browser
    // 2. open in soundcloud app
    // 3. buy track
    
    [self open:self.currentPlaylistItem.track.permalink_url];
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
