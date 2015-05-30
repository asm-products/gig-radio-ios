//
//  GigInfoViewController.swift
//  GigRadio
//
//  Created by Michael Forrest on 28/05/2015.
//  Copyright (c) 2015 Good To Hear. All rights reserved.
//

import UIKit
import MapKit

class GigInfoViewController: UIViewController {

    @IBOutlet weak var mainLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var directionsButton: UIButton!
    @IBOutlet weak var songKickButton: UIButton!
    @IBOutlet weak var favouriteButton: UIBarButtonItem!
    @IBOutlet weak var directionsSettingButton: UIButton!
    
    var mapLink: MapLink!
    
    var event:SongKickEvent!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let date = NSAttributedString(string: DateFormats.eventDateFormatter().stringFromDate(event.date), attributes: Typography.RobotoBold(13))
        let artists = NSAttributedString(string: join("\n",event.artistNames()), attributes: Typography.RobotoLight(24))
        let location = NSAttributedString(string: "\(event.venue.displayName)\n\(event.venue.address())", attributes: Typography.RobotoRegular(13))
        
        let text = NSMutableAttributedString(string: "")
        let br = NSAttributedString(string: "\n")
        text.appendAttributedString(date)
        text.appendAttributedString(br)
        text.appendAttributedString(artists)
        text.appendAttributedString(br)
        text.appendAttributedString(location)
        mainLabel.attributedText = text
        
        updateDirectionsButton()
        updateFavouriteButton()
        
        mapView.showsUserLocation = true
        if let location = event.venue.location(){
            let span = MKCoordinateSpanMake(0.01, 0.01)
            let region = MKCoordinateRegion(center:location.coordinate, span: span)
            let annotation = MKPointAnnotation()
            annotation.coordinate = location.coordinate
            mapView.setRegion(region, animated: false)
            mapView.addAnnotation(annotation)
        }
        
    }
    func updateFavouriteButton(){
        if Favourite.findByEvent(self.event) != nil{
            favouriteButton.image = UIImage(named: "starred")
        }else{
            favouriteButton.image = UIImage(named: "star")
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
    @IBAction func didPressDirectionsButton(sender: AnyObject) {
        if let link = mapLink{
            UIApplication.sharedApplication().openURL(link.appURL)
        }
    }
    @IBAction func didPressSongKickButton(sender: AnyObject) {
        let url = NSURL(string: "songkick://events/\(event.id)")!
        let app = UIApplication.sharedApplication()
        if app.canOpenURL(url){
            app.openURL(url)
        }else{
            let url = NSURL(string: "https://www.songkick.com/concerts/\(event.id)")!
            app.openURL(url)
        }
    }
    
    func updateDirectionsButton(){
        if let link = MapLink.preferredMapLink(event.venue){
            directionsButton.enabled = true
            let title = template("Directions.ButtonTitle", [link.displayName])
            directionsButton.setTitle(title, forState: .Normal)
            mapLink = link
        }else{
            directionsButton.enabled = false
        }
    }
    @IBAction func didPressDirectionsSettings(sender: AnyObject) {
        let sheet = UIAlertController(title: t("Directions.SettingsTitle"), message: nil, preferredStyle: .ActionSheet)
        for link in MapLink.allMapLinks(event.venue){
            sheet.addAction(UIAlertAction(title: t("Directions.ButtonTitle"), style: .Default){ action in
                MapLink.saveMapLinkPreference(link)
                self.updateDirectionsButton()
            })
        }
        sheet.addAction(UIAlertAction(title: t("Cancel"), style: .Cancel) { action in
        })
        presentViewController(sheet, animated: true, completion: nil)
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
