//
//  FavouritesTableViewController.swift
//  GigRadio
//
//  Created by Michael Forrest on 28/05/2015.
//  Copyright (c) 2015 Good To Hear. All rights reserved.
//

import UIKit

class FavouritesTableViewController: UITableViewController {
    enum Section:Int{
        case Upcoming
        case Past
        case Count
    }
    var upcoming = Favourite.futureEvents()
    var past = Favourite.pastEvents()
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return Section.Count.rawValue
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section(rawValue: section)!{
        case .Upcoming: return upcoming.count
        case .Past: return past.count
        default: return 0
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! FavouriteItemTableViewCell
        cell.favourite = favouriteAtIndexPath(indexPath)
        return cell
    }
    func favouriteAtIndexPath(indexPath:NSIndexPath)->Favourite?{
        switch Section(rawValue: indexPath.section)!{
        case .Upcoming: return upcoming[indexPath.row]
        case .Past: return past[indexPath.row]
        default:
            return nil
        }
    }
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch Section(rawValue: section)!{
        case .Upcoming: return t("Favourites.Upcoming")
        case .Past: return t("Favourites.Past")
        default: return nil
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let dest = segue.destinationViewController as? GigInfoViewController{
            if let indexPath = tableView.indexPathForSelectedRow{
                dest.event = favouriteAtIndexPath(indexPath)!.event
            }
        }
    }



    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let favourite = favouriteAtIndexPath(indexPath)!
            Favourite.remove(favourite)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            NSNotificationCenter.defaultCenter().postNotificationName(FAVOURITE_COUNT_CHANGED, object: nil)
        }
    }





}
