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

protocol EditPlaylistItemViewControllerDelegate{
    func editSoundCloudUserDidChangeUserForPerformance(performance:PlaylistPerformance)
    func editSoundCloudUserDidBlacklistUser(user:SoundCloudUser)
}

class EditPlaylistItemViewController: UITableViewController,SoundCloudUsersTableViewControllerDelegate {
    var performance: PlaylistPerformance!
    var delegate: EditPlaylistItemViewControllerDelegate!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var explanationLabel: UILabel!
    @IBOutlet weak var selectSoundCloudUserCell: UITableViewCell!
    @IBOutlet weak var doNotPlayTracksCell: UITableViewCell!
    @IBOutlet weak var viewOnSoundCloudCell: UITableViewCell!
    
    var users: JSON?
    override func viewDidLoad() {
        super.viewDidLoad()
        populate()
    }
    func populate(){
        navigationItem.title = performance.songKickArtist.displayName
        if let image = cachedImage(performance.soundCloudUser.avatarUrlLarge){
            imageView.image = image
        }else{
            preload([performance.soundCloudUser.avatarUrlLarge]){
                self.imageView.image = cachedImage(self.performance.soundCloudUser.avatarUrlLarge)
            }
        }
        var unstreamableTracksCount = performance.soundCloudUser.tracks.filter("streamable = false").count
        explanationLabel.text = NSString(format: t("SoundCloudUser.Explanation"), performance.songKickArtist.displayName, performance.soundCloudUser.username, unstreamableTracksCount) as String
        
        SoundCloudClient.sharedClient.findUsers(performance.songKickArtist.displayName, completion: { (json, error) -> Void in
            self.users = json
            self.updateCountCell()
        })
        updateBlacklistingCell()
    }
    func updateCountCell(){
        if let users = users{
            let count = max(0,users.count - 1)
            self.selectSoundCloudUserCell.detailTextLabel?.text = template("SoundCloudUsers.CountOthersAvailable", values: [count])
            self.selectSoundCloudUserCell.detailTextLabel?.setNeedsDisplay()
        }
    }
    @IBAction func didPressDone(sender: AnyObject) {
        navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    func viewOnSoundCloud() {
        performance.soundCloudUser.showOnSoundCloud()
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        switch cell!{
        case viewOnSoundCloudCell: viewOnSoundCloud()
        case doNotPlayTracksCell: toggleArtist()
        default:
            print("skip")
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    func toggleArtist(){
        if BlacklistedArtist.includes(performance.soundCloudUser){
            BlacklistedArtist.remove(performance.soundCloudUser)
        }else{
            BlacklistedArtist.add(performance.soundCloudUser)
            delegate.editSoundCloudUserDidBlacklistUser(performance.soundCloudUser)
        }
        updateBlacklistingCell()
        dismissViewControllerAnimated(true, completion: nil)
    }
    func updateBlacklistingCell(){
        let text = BlacklistedArtist.includes(performance.soundCloudUser) ? t("Blacklisting.DoPlay") : t("Blacklisting.DoNotPlay")
        doNotPlayTracksCell.textLabel?.text = text
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let dest = segue.destinationViewController as? SoundCloudUsersTableViewController{
            dest.selectedSoundCloudUser = performance.soundCloudUser
            dest.songKickArtist = performance.songKickArtist
            if let users = users{
                dest.setUsers(users)
            }
            dest.delegate = self
        }
    }
    func soundCloudUsersTableDidSelectUser(user: SoundCloudUser) {
        try! Realm().write{
            self.performance.soundCloudUser = user
        }
        populate()
        delegate.editSoundCloudUserDidChangeUserForPerformance(self.performance)
    }
}
