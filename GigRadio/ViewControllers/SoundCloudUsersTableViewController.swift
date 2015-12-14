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
    var usersJSON: JSON?
    var users = [NSDictionary]()
    var delegate: SoundCloudUsersTableViewControllerDelegate!
    override func viewDidLoad() {
        super.viewDidLoad()
        trackEvent(.SoundCloudUsersListed, properties: ["Songkick Artist Name": songKickArtist.displayName])
        if usersJSON == nil{
            SoundCloudClient.sharedClient.findUsers(songKickArtist.displayName) {json,error in
                self.setUsers(json)
            }
        }
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        navigationItem.title = template("SoundCloudUsers.SearchTitle", values: [songKickArtist.displayName])
    }
    func setUsers(json:JSON){
        self.usersJSON = json
        if json.type == .Array{
            for (index, item): (String, JSON) in json{
                self.users.append(item.object as! NSDictionary)
            }
            self.tableView.reloadData()
        }
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
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! SoundCloudUserTableViewCell
        let dict = userAtIndexPath(indexPath).dictionaryWithCamelCaseKeys() as NSDictionary
        let user = SoundCloudUser(value: dict.dictionaryWithoutNullValues())
        cell.user = user
        cell.textLabel?.text = "\(user.displayName()) (\(user.city), \(user.country))"
        cell.detailTextLabel?.text = "\(user.trackCount) track(s), \(user.followersCount) follower(s)"
        preload([user.avatarUrl]) {
            cell.imageView?.image = cachedImage(user.avatarUrl)
        }
        cell.accessoryType = selectedSoundCloudUser.id == user.id ? .Checkmark : .DetailButton
//        cell.editingAccessoryType = UITableViewCellAccessoryType.DetailButton
        return cell
    }
    override func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! SoundCloudUserTableViewCell
        cell.user.showOnSoundCloud()
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let user = SoundCloudClient.createSoundCloudUser(self.userAtIndexPath(indexPath))
        delegate.soundCloudUsersTableDidSelectUser(user)
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        cell?.editingAccessoryType = .Checkmark
        self.navigationController?.popViewControllerAnimated(true)
    }

}
