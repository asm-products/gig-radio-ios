//
//  EditPlaylistItemViewController.swift
//  GigRadio
//
//  Created by Michael Forrest on 28/05/2015.
//  Copyright (c) 2015 Good To Hear. All rights reserved.
//

import UIKit

class EditPlaylistItemViewController: UITableViewController {
    var performance: PlaylistPerformance!

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var explanationLabel: UILabel!
    @IBOutlet weak var selectSoundCloudUserCell: UITableViewCell!
    @IBOutlet weak var pickDifferentTrackCell: UITableViewCell!
    @IBOutlet weak var playAllTracksCell: UITableViewCell!
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
    }

    @IBAction func didPressDone(sender: AnyObject) {
        navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        case selectSoundCloudUserCell: showSoundCloudUserList()
        case pickDifferentTrackCell: showTracksList()
        case playAllTracksCell: playAllTracks()
        case doNotPlayTracksCell: disableArtist()
        default:
            println("skip")
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    func showSoundCloudUserList(){
        
    }
    func showTracksList(){
        
    }
    func playAllTracks(){
        
    }
    func disableArtist(){
        
    }

}
