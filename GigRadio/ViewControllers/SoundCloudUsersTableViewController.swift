//
//  SoundCloudUsersTableViewController.swift
//  GigRadio
//
//  Created by Michael Forrest on 30/05/2015.
//  Copyright (c) 2015 Good To Hear. All rights reserved.
//

import UIKit
import SwiftyJSON

protocol SoundCloudUsersTableViewControllerDelegate{
    func soundCloudUsersTableDidSelectUser(user: SoundCloudUser)
}


class SoundCloudUsersTableViewController: UITableViewController {
    var songKickArtist: SongKickArtist!
    var selectedSoundCloudUser: SoundCloudUser!
    var users = [NSDictionary]()
    var delegate: SoundCloudUsersTableViewControllerDelegate!
    override func viewDidLoad() {
        super.viewDidLoad()
        SoundCloudClient.sharedClient.findUsers(songKickArtist.displayName) {json,error in
            if json.type == .Array{
                for (index:String, item) in json{
                    self.users.append(item.object as! NSDictionary)
                    self.tableView.reloadData()
                }
            }
        }
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    func userAtIndexPath(indexPath:NSIndexPath)->NSDictionary{
        return users[indexPath.row]
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! UITableViewCell
        let user = userAtIndexPath(indexPath)
        let id = user["id"] as! Int
        cell.textLabel?.text = user["username"] as? String
        let count = user["track_count"] as! Int
        cell.detailTextLabel?.text = "\(count)"
        let url = user["avatar_url"] as! String
        preload([url]) {
            cell.imageView?.image = cachedImage(url)
        }
        cell.accessoryType = selectedSoundCloudUser.id == id ? .Checkmark : .None
        
        return cell
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let user = SoundCloudClient.createSoundCloudUser(self.userAtIndexPath(indexPath))
        delegate.soundCloudUsersTableDidSelectUser(user)
        self.navigationController?.popViewControllerAnimated(true)
    }

}
