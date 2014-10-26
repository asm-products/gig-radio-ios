//
//  PlaylistDebuggingTableViewController.m
//  GigRadio
//
//  Created by Michael Forrest on 26/10/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import "PlaylistDebuggingTableViewController.h"

@interface Playlist()
-(NSArray*)items;
@end

@interface PlaylistDebuggingTableViewController ()

@end

@implementation PlaylistDebuggingTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.playlist.items.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Track" forIndexPath:indexPath];
    PlaylistItem * item = self.playlist.items[indexPath.section];
    cell.textLabel.text = item.track.title;
    return cell;
}
-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    PlaylistItem * item = self.playlist.items[section];
    return [NSString stringWithFormat:@"%@ (%@?)", item.songKickArtist.displayName, item.soundCloudUser.username];
}
-(NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section{
    PlaylistItem * item = self.playlist.items[section];
    return [NSString stringWithFormat:@"%@ start: %@ end: %@", item.event.displayName, item.event.start.datetime, item.event.end.datetime];
}
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
