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
    
    @IBOutlet weak var musicByMichaelForrestCell: TableViewCell!
    @IBOutlet weak var jonArcherOnTwitterCell: TableViewCell!
    @IBOutlet weak var mikeKuechOnTwitterCell: TableViewCell!
    
    
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
    override func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        let firstLinkIndexPath = tableView.indexPathForCell(musicByMichaelForrestCell)!
        return indexPath.section >= firstLinkIndexPath.section
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        var link = ""
        if cell == musicByMichaelForrestCell{
            link = "http://michaelforrestmusic.com/about"
        }else if cell == jonArcherOnTwitterCell{
            link = "http://twitter.com/jonarcher"
        }else if cell == mikeKuechOnTwitterCell{ // urgh. misnamed now.
            link = "https://dribbble.com/MikeKuech"
        }
        if let url = NSURL(string: link){
            UIApplication.sharedApplication().openURL(url)
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
    }

}
