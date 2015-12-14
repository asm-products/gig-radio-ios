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
    
    @IBOutlet weak var faqCell: TableViewCell!
    @IBOutlet weak var appStoreCell: TableViewCell!
    @IBOutlet weak var facebookCell: TableViewCell!
    @IBOutlet weak var twitterCell: TableViewCell!
    
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
        let selection = VenueSortOrder(rawValue: sortOrderControl.selectedSegmentIndex)!
        NSUserDefaults.standardUserDefaults().setInteger(selection.rawValue, forKey: VenueSortOrderKey)
        NSNotificationCenter.defaultCenter().postNotificationName(DidChangeVenueSortOrderNotification, object: nil)
        trackEvent(.PlaylistOrderChanged, properties: ["Value": selection.description])
    }
    @IBAction func didChangeTrackLengthFilter(sender: AnyObject) {
        let selection = TrackLengthFilter(rawValue: trackLengthFilterControl.selectedSegmentIndex)!
        NSUserDefaults.standardUserDefaults().setInteger(selection.rawValue, forKey: TrackLengthFilterKey)
        NSNotificationCenter.defaultCenter().postNotificationName(DidChangeTrackLengthFilterNotification, object: nil)
        trackEvent(.TrackLengthFilterChanged, properties: ["Value": selection.description])
    }
    @IBAction func didChangePlaylistFollowAction(sender: AnyObject) {
        let selection = PlaylistFollowAction(rawValue: playlistFollowActionControl.selectedSegmentIndex)!
        NSUserDefaults.standardUserDefaults().setInteger(selection.rawValue
            , forKey: PlaylistFollowActionKey)
        trackEvent(.PlaylistFollowActionChanged, properties: ["Value": selection.description])
    }
    @IBAction func didChangeSpokenAnnouncements(sender: AnyObject) {
        let selection = SpokenAnnouncements(rawValue: spokenAnnouncementsControl.selectedSegmentIndex)!
        NSUserDefaults.standardUserDefaults().setInteger(selection.rawValue, forKey: SpokenAnnouncementsKey)
        trackEvent(.SpokenAnnouncementsChanged, properties: ["Value": selection.description])
    }
    
    @IBAction func didPressDone(sender: AnyObject) {
        navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    override func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        let firstLinkIndexPath = tableView.indexPathForCell(faqCell) ?? NSIndexPath(forRow: 0, inSection: 3)
        return indexPath.section >= firstLinkIndexPath.section
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)!
        
        let links:[UITableViewCell:String] = [
            musicByMichaelForrestCell: "http://michaelforrestmusic.com/about",
            jonArcherOnTwitterCell: "http://twitter.com/jonarcher",
            mikeKuechOnTwitterCell: "https://dribbble.com/MikeKuech",
            faqCell: "http://getgigradio.com/faq",
            appStoreCell: "itms-apps://itunes.apple.com/app/933577240",
            facebookCell: "https://facebook.com/GigRadio",
            twitterCell: "https://twitter.com/getgigradio"
        ]
        if let link = links[cell]{
            trackEvent(.InfoLinkFollowed, properties: ["URL": link])
            if let url = NSURL(string: link){
                UIApplication.sharedApplication().openURL(url)
            }
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }

}
