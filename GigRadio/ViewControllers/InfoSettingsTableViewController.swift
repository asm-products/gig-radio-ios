//
//  InfoSettingsTableViewController.swift
//  GigRadio
//
//  Created by Michael Forrest on 15/07/2015.
//  Copyright (c) 2015 Good To Hear. All rights reserved.
//

import UIKit

class InfoSettingsTableViewController: UITableViewController {

    @IBOutlet weak var sortOrderControl: UISegmentedControl!
    @IBOutlet weak var trackLengthFilterControl: UISegmentedControl!
    @IBOutlet weak var spokenAnnouncementsControl: UISegmentedControl!
    @IBOutlet weak var playlistFollowActionControl: UISegmentedControl!
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        let defaults = NSUserDefaults.standardUserDefaults()
        sortOrderControl.selectedSegmentIndex = defaults.integerForKey(VenueSortOrderKey)
        trackLengthFilterControl.selectedSegmentIndex = defaults.integerForKey(TrackLengthFilterKey)
        spokenAnnouncementsControl.selectedSegmentIndex = defaults.integerForKey(SpokenAnnouncementsKey)
        playlistFollowActionControl.selectedSegmentIndex = defaults.integerForKey(PlaylistFollowActionKey)
    }
    @IBAction func didChangePlaylistOrder(sender: AnyObject) {
        NSUserDefaults.standardUserDefaults().setInteger(sortOrderControl.selectedSegmentIndex, forKey: VenueSortOrderKey)
        NSNotificationCenter.defaultCenter().postNotificationName(DidChangeVenueSortOrderNotification, object: nil)
    }
    @IBAction func didChangeTrackLengthFilter(sender: AnyObject) {
        NSUserDefaults.standardUserDefaults().setInteger(trackLengthFilterControl.selectedSegmentIndex, forKey: TrackLengthFilterKey)
        NSNotificationCenter.defaultCenter().postNotificationName(DidChangeTrackLengthFilterNotification, object: nil)
    }
    @IBAction func didChangePlaylistFollowAction(sender: AnyObject) {
        NSUserDefaults.standardUserDefaults().setInteger(playlistFollowActionControl.selectedSegmentIndex
            , forKey: PlaylistFollowActionKey)
    }
    @IBAction func didChangeSpokenAnnouncements(sender: AnyObject) {
        NSUserDefaults.standardUserDefaults().setInteger(spokenAnnouncementsControl.selectedSegmentIndex, forKey: SpokenAnnouncementsKey)
    }
    
    @IBAction func didPressDone(sender: AnyObject) {
        navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    // MARK: - Table view data source

    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath) as! UITableViewCell

        // Configure the cell...

        return cell
    }
    */

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
