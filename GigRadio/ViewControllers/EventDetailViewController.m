//
//  EventDetailViewController.m
//  GigRadio
//
//  Created by Michael Forrest on 26/10/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import "EventDetailViewController.h"
#import "EventTitleTableViewCell.h"
#import "ArtistNameTableViewCell.h"
#import "SpacetimeTableViewCell.h"
#import "EventLinkTableViewCell.h"
#import <UIView+SimpleMotionEffects.h>

typedef enum {
    EventDetailSectionTitle,
    EventDetailSectionArtists,
    EventDetailSectionSpacetime,
    EventDetailSectionLinks,
    EventDetailSectionCount
} EventDetailSection;


@interface EventDetailViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) EventTitleTableViewCell * eventTitleCell;
@property (nonatomic, strong) SpacetimeTableViewCell * spacetimeCell;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@end

@implementation EventDetailViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.backgroundImageView addMotionEffectWithMovement:CGPointMake(16, 16)];
    self.backgroundImageView.image = self.backgroundImage;
    self.tableView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
    self.eventTitleCell = [self.tableView dequeueReusableCellWithIdentifier:@"Title"];
    self.eventTitleCell.event = self.event;
    self.spacetimeCell = [self.tableView dequeueReusableCellWithIdentifier:@"Spacetime"];
    self.spacetimeCell.event = self.event;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return EventDetailSectionCount;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    switch (section) {
        case EventDetailSectionTitle: return 1;
        case EventDetailSectionArtists: return self.event.performance.count;
        case EventDetailSectionSpacetime: return 1;
        case EventDetailSectionLinks: return 4;
    }
    return 0;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.section) {
        case EventDetailSectionTitle:
        case EventDetailSectionLinks:
        case EventDetailSectionArtists: return 44;
        case EventDetailSectionSpacetime: return 180;
    }
    return 0;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.section) {
        case EventDetailSectionTitle: return self.eventTitleCell;
        case EventDetailSectionArtists: return [self artistCellForIndexPath:indexPath];
        case EventDetailSectionSpacetime: return self.spacetimeCell;
        case EventDetailSectionLinks: return [self linkCellForIndexPath:indexPath];
    }
    return nil;
}
-(ArtistNameTableViewCell*)artistCellForIndexPath:(NSIndexPath*)indexPath{
    ArtistNameTableViewCell * cell = [self.tableView dequeueReusableCellWithIdentifier:@"Artist" forIndexPath:indexPath];
    SongKickPerformance * performance = self.event.performance[indexPath.row];
    cell.songKickArtist = performance.artist;
    cell.soundCloudUser = [SoundCloudUser findById:cell.songKickArtist.soundCloudUserId];
    return cell;
}
-(BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    return indexPath.section == EventDetailSectionLinks;
}
-(EventLinkTableViewCell*)linkCellForIndexPath:(NSIndexPath*)indexPath{
    EventLinkTableViewCell * cell = [self.tableView dequeueReusableCellWithIdentifier:@"Link" forIndexPath:indexPath];
    cell.titleLabel.text = @[
                             @"OPEN IN SONGKICK",
                             @"DIRECTIONS ON APPLE MAPS",
                             @"DIRECTIONS ON GOOGLE MAPS",
                             @"DIRECTIONS ON CITYMAPPER"
                             ][indexPath.row];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == EventDetailSectionLinks){
        if(indexPath.row == 0) [self open:self.event.uri];
        if(indexPath.row == 1) [self open:self.event.venue.appleMapsUri];
        if(indexPath.row == 3) [self open:self.event.venue.citymapperUri];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
-(void)open:(NSString*)uri{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:uri]];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
