//
//  PlaylistTableViewController.swift
//  GigRadio
//
//  Created by Michael Forrest on 28/05/2015.
//  Copyright (c) 2015 Good To Hear. All rights reserved.
//

import UIKit

class PlaylistTableViewController: UITableViewController {
    var playlist: Playlist!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playlist.tracks.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! PlaylistItemTableViewCell
        let items = playlist.tracks
        let item = items[ items.count - indexPath.row - 1]
        cell.track = item
        return cell
    }

}
