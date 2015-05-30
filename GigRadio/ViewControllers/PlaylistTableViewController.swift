//
//  PlaylistTableViewController.swift
//  GigRadio
//
//  Created by Michael Forrest on 28/05/2015.
//  Copyright (c) 2015 Good To Hear. All rights reserved.
//

import UIKit

class PlaylistTableViewController: UITableViewController {
    var runs: [PlaylistRun]!
    override func viewDidLoad() {
        super.viewDidLoad()
        runs = PlaylistRun.allRunsInReverseOrder()
    }
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return runs.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let run = runs[section]
        return run.items.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! PlaylistItemTableViewCell
        let items = runs[indexPath.section].items
        let item = items[ items.count - indexPath.row - 1]
        cell.playlistItem = item
        return cell
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return DateFormats.dateTimeFormat().stringFromDate(runs[section].createdAt)
    }

}
