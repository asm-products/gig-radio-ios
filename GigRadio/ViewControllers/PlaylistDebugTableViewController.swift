//
//  PlaylistDebugTableViewController.swift
//  GigRadio
//
//  Created by Michael Forrest on 25/10/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

import UIKit

@objc(PlaylistDebugTableViewController) class PlaylistDebugTableViewController: UITableViewController {
    var artistSelectionPresenter: ArtistSelectionPresenter?
   

    
    override func viewDidLoad() {
        super.viewDidLoad()
        artistSelectionPresenter = ArtistSelectionPresenter(forDate: NSDate())
        self.tableView.reloadData()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return artistSelectionPresenter!.artists.count
    }
    func artistForSection(section: Int) -> SongKickArtist{
        return artistSelectionPresenter!.artists[section] as SongKickArtist
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let soundCloudUserId = artistForSection(section).soundCloudUserId
        
        var soundCloudUser = SoundCloudUser.findById(soundCloudUserId)
        if let user = soundCloudUser{
            let count = artistSelectionPresenter!.artistTracks(user).count
            return Int(count)
        }else{
            return 0
        }
    
    }

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let songKickArtist = artistForSection(section)
        return songKickArtist.displayName
    }
    override func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        let songKickArtist = artistForSection(section)
        let event = artistSelectionPresenter!.eventWithArtist(songKickArtist)
        return event.displayName
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let songKickArtist = artistForSection(indexPath.section)
        var soundCloudUser = SoundCloudUser.findById(songKickArtist.soundCloudUserId)
        let event = artistSelectionPresenter!.eventWithArtist(songKickArtist)
        let cell = tableView.dequeueReusableCellWithIdentifier("Track", forIndexPath: indexPath) as UITableViewCell
        let track = artistSelectionPresenter!.artistTracks(soundCloudUser!)[UInt(indexPath.row)] as SoundCloudTrack
        cell.textLabel.text = track.title
        return cell
    }
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 48
    }
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
