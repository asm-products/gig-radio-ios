//
//  GigInfoTableViewController.swift
//  GigRadio
//
//  Created by Michael Forrest on 12/12/2015.
//  Copyright © 2015 Good To Hear. All rights reserved.
//

import UIKit
import MapKit

private enum Section:Int{
    case Map
    case Directions
    case Artists
    case EventLinks
    static var count = 4
}

class GigInfoTableViewController: UITableViewController {
    
    @IBOutlet weak var favouriteButtonItem: UIBarButtonItem!
    
    var event: SongKickEvent!
    
    lazy var mapCell: MapCell = {
        self.createMapCell()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = 44
        navigationItem.title = t("EventInfo.Title")
        updateFavouriteButton()
    }
    func updateFavouriteButton(){
        if Favourite.findByEvent(event) != nil{
            favouriteButtonItem.image = UIImage(named: "starred")
        }else{
            favouriteButtonItem.image = UIImage(named: "star")
        }
    }
    @IBAction func didPressFavouriteButton(sender: AnyObject) {
        if let favourite = Favourite.findByEvent(event){
            Favourite.remove(favourite)
        }else{
            Favourite.add(event)
        }
        updateFavouriteButton()
        NSNotificationCenter.defaultCenter().postNotificationName(FAVOURITE_COUNT_CHANGED, object: nil)
    }
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return Section.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section(rawValue: section)!{
        case .Artists: return event.artistNames().count
        case .Map: return 1
        case .Directions: return 1 // "Show directions in CityMapper"
        case .EventLinks: return 1 // "Show in SongKick"
        }
    }
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch Section(rawValue: section)!{
        case .Artists: return t("EventInfo.ArtistsTitle")
        default: return nil
        }
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch Section(rawValue: indexPath.section)!{
        case .Artists:
            return artistCellForIndexPath(indexPath)
        case .Map:
            return mapCell
        case .Directions, .EventLinks:
            return linkCellForIndexPath(indexPath)
        }
    }
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch Section(rawValue: indexPath.section)!{
//        case .Map: 
        default: return UITableViewAutomaticDimension
        }
    }
    func createMapCell()->MapCell{
        let cell = tableView.dequeueReusableCellWithIdentifier("Map") as! MapCell
        let mapView = cell.mapView
        mapView.showsUserLocation = true
        if let location = event.venue.location(){
            let span = MKCoordinateSpanMake(0.01, 0.01)
            let region = MKCoordinateRegion(center:location.coordinate, span: span)
            let annotation = MKPointAnnotation()
            annotation.coordinate = location.coordinate
            mapView.setRegion(region, animated: false)
            mapView.addAnnotation(annotation)
        }
        cell.titleLabel.text = event.displayName
        return cell
    }
    func artistCellForIndexPath(indexPath:NSIndexPath)->ArtistCell{
        let cell = tableView.dequeueReusableCellWithIdentifier("Artist", forIndexPath: indexPath) as! ArtistCell
        let performance = event.performance[indexPath.row]
        cell.titleLabel.text = performance.artist.displayName
        return cell
    }
    func linkCellForIndexPath(indexPath:NSIndexPath)->UITableViewCell{
        let cell = tableView.dequeueReusableCellWithIdentifier("Link", forIndexPath: indexPath) as! LinkCell
        switch Section(rawValue: indexPath.section)!{
        case .Directions:
            if let link = MapLink.preferredMapLink(event.venue){
                cell.titleLabel.text = template("Directions.ButtonTitle", values: [link.displayName])
            }
            let button = UIButton(type: .Custom)
            let image = UIImage(named: "settings")
            button.frame.size = CGSize(width: 44, height: 44)
            button.setImage(image, forState: .Normal)
            button.addTarget(self, action: "didPressDirectionsSettings", forControlEvents: .TouchUpInside)
            cell.accessoryView = button
        case .EventLinks:
            cell.titleLabel.text = t("Link.ShowInSongKick")
        default:
            break
        }
        return cell
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
         switch Section(rawValue: indexPath.section)!{
         case .Directions: openMapLink()
         case .EventLinks: openSongKickLink()
         case .Artists: showArtistAtIndexPath(indexPath)
         default:
            break
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    func showArtistAtIndexPath(indexPath:NSIndexPath){
        if indexPath.section != Section.Artists.rawValue { return }
        let performance = event.performance[indexPath.row]
        UIApplication.sharedApplication().openURL(performance.artist.songKickURL())
        trackEvent(.SongKickArtistViewed, properties: ["SongKick Artist ID":performance.artist.id])
    }
    func didPressDirectionsSettings(){
        let sheet = UIAlertController(title: t("Directions.SettingsTitle"), message: nil, preferredStyle: .ActionSheet)
        for link in MapLink.allMapLinks(event.venue){
            sheet.addAction(UIAlertAction(title: link.displayName, style: .Default){ action in
                MapLink.saveMapLinkPreference(link)
                self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: Section.Directions.rawValue)], withRowAnimation: .Automatic)
            })
        }
        sheet.addAction(UIAlertAction(title: t("Cancel"), style: .Cancel) { action in
        })
        presentViewController(sheet, animated: true, completion: nil)
    }
    func openMapLink(){
        if let link = MapLink.preferredMapLink(event.venue){
            trackEvent(.MapLinkViewed, properties: [
                "URL": link.appURL.absoluteString,
                "Service": link.displayName
                ])
            UIApplication.sharedApplication().openURL(link.appURL)
        }
    }
    func openSongKickLink(){
        trackEvent(.SongKickEventViewed, properties: ["SongKick Event ID": event.id])
        let url = NSURL(string: "songkick://events/\(event.id)")!
        let app = UIApplication.sharedApplication()
        if app.canOpenURL(url){
            app.openURL(url)
        }else{
            let url = NSURL(string: "https://www.songkick.com/concerts/\(event.id)")!
            app.openURL(url)
        }
    }

}
class ArtistCell:UITableViewCell{
    @IBOutlet weak var titleLabel: UILabel!
}
class MapCell:UITableViewCell{
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var titleLabel: UILabel!
}
class LinkCell:UITableViewCell{
    @IBOutlet weak var titleLabel: UILabel!
    override func layoutSubviews() {
        super.layoutSubviews()
        if let accessoryView = accessoryView{
            accessoryView.frame.origin.x = frame.width - accessoryView.frame.width
        }
    }
}
