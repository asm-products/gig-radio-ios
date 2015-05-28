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

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    @IBAction func didPressDirectionsButton(sender: AnyObject) {
    }
    @IBAction func didPressSongKickButton(sender: AnyObject) {
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
