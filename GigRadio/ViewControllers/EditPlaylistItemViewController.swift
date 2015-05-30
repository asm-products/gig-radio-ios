//
//  EditPlaylistItemViewController.swift
//  GigRadio
//
//  Created by Michael Forrest on 28/05/2015.
//  Copyright (c) 2015 Good To Hear. All rights reserved.
//

import UIKit
import RealmSwift
import SwiftyJSON
class EditPlaylistItemViewController: UITableViewController,SoundCloudUsersTableViewControllerDelegate {
    var performance: PlaylistPerformance!

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var explanationLabel: UILabel!
    @IBOutlet weak var selectSoundCloudUserCell: UITableViewCell!
    @IBOutlet weak var doNotPlayTracksCell: UITableViewCell!
    @IBOutlet weak var viewOnSoundCloudCell: UITableViewCell!
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = performance.songKickArtist.displayName
        if let image = cachedImage(performance.soundCloudUser.avatarUrl){
            imageView.image = image
        }else{
            preload([performance.soundCloudUser.avatarUrl]){
                self.imageView.image = cachedImage(self.performance.soundCloudUser.avatarUrl)
            }
        }
        explanationLabel.text = NSString(format: t("SoundCloudUser.Explanation"), performance.songKickArtist.displayName, performance.soundCloudUser.username) as String
        
        SoundCloudClient.sharedClient.findUsers(performance.songKickArtist.displayName, completion: { (json, error) -> Void in
            let count = json.count - 1
            self.selectSoundCloudUserCell.detailTextLabel?.text = template("SoundCloudUsers.CountOthersAvailable", [count])
        })
    }
    @IBAction func didPressDone(sender: AnyObject) {
        navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    func viewOnSoundCloud() {
        let url = NSURL(string:"soundcloud://users:\(performance.soundCloudUser.id)")!
        let app = UIApplication.sharedApplication()
        if app.canOpenURL(url){
            app.openURL(url)
        }else{
            let url = NSURL(string: "https://soundcloud.com/\(performance.soundCloudUser.permalink)")!
            app.openURL(url)
        }
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        switch cell!{
        case viewOnSoundCloudCell: viewOnSoundCloud()
        case doNotPlayTracksCell: disableArtist()
        default:
            println("skip")
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    func disableArtist(){
        
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let dest = segue.destinationViewController as? SoundCloudUsersTableViewController{
            dest.selectedSoundCloudUser = performance.soundCloudUser
            dest.songKickArtist = performance.songKickArtist
            dest.delegate = self
        }
    }
    func soundCloudUsersTableDidSelectUser(user: SoundCloudUser) {
        Realm().write{
            self.performance.soundCloudUser = user
        }
    }
}
