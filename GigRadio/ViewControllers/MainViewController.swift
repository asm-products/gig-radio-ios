//
//  MainViewController.swift
//  GigRadio
//
//  Created by Michael Forrest on 17/05/2015.
//  Copyright (c) 2015 Good To Hear. All rights reserved.
//

import UIKit
import MediaPlayer
import CoreLocation

class MainViewController: UIViewController, UICollectionViewDelegate, CLLocationManagerDelegate, DatePickerViewControllerDelegate {
    let DatePickerOffScreen:CGFloat = -80
    
    @IBOutlet weak var headerDateButton: UIButton!
    @IBOutlet weak var dateSelectorRevealConstraint: NSLayoutConstraint!
    @IBOutlet weak var volumeView: MPVolumeView!
    
    @IBOutlet weak var loadingView: UIView!
    var datePicker: DatePickerViewController?
    @IBOutlet weak var datePickerButtons: UIView!
    
    var playlist: Playlist?
    var location: CLLocation?
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return (loadingView != nil && loadingView.alpha < 1) ? .LightContent : .Default
    }
    override func prefersStatusBarHidden() -> Bool {
        return dateSelectorRevealConstraint == nil ||  dateSelectorRevealConstraint.constant == 0
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        view.bringSubviewToFront(loadingView) // for ease of authoring I put the loading view at the back of the storyboard once I laid it out
    }
    override func viewDidLoad() {
        super.viewDidLoad()
//        volumeView.setMinimumVolumeSliderImage(UIImage(named: "speaker-quiet"), forState: .Normal)
//        volumeView.setMaximumVolumeSliderImage(UIImage(named: "speaker-loud"), forState: .Normal)
        // deal with location stuff here because we might need to show UI
        LocationHelper.lookUp { (location, error) -> Void in
            self.location = location
            self.playlist = Playlist(accurateLocation: location != nil)
            self.playlist?.loadFirstItem({ (item, error) -> Void in
                self.hideLoadingView()
            })
        }
    }
    // MARK: Loading
    func hideLoadingView(){
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.loadingView.alpha = 0
            self.setNeedsStatusBarAppearanceUpdate()
        }) { (finished) -> Void in
            self.loadingView.hidden = true
        }
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let dest = segue.destinationViewController as? DatePickerViewController{
            self.datePicker = dest
            dest.delegate = self
            let swipe = UISwipeGestureRecognizer(target: self, action: "didSwipeUpDatePicker")
            swipe.direction = .Up
            dest.view.addGestureRecognizer(swipe)
        }
    }
    func datePickerDidChangeVisibleRange(startDate: NSDate, endDate: NSDate) {
//        datePicker?.activity.startAnimating()
        SongKickClient.sharedClient.getEvents(startDate, end: endDate, location: location) { (error) -> Void in
            if error != nil{
                println("SongKick error: \(error!.localizedDescription)")
            }
            self.datePicker?.refresh()
//            self.datePicker?.activity.stopAnimating()
        }
    }
    func datePickerDidSelectDate(startDate: NSDate) {
        
    }
    @IBAction func didPressTodayButton(sender: AnyObject) {
        datePicker?.scrollToToday(true)
    }
    @IBAction func didPressDismissButton(sender: AnyObject) {
        hideDatePickerAnimated(true)
    }
    func hideDatePickerAnimated(animated:Bool){
        setDatePickerHidden(true, animated: animated)
    }
    func showDatePickerAnimated(animated:Bool){
        setDatePickerHidden(false, animated: animated)
    }
    func didSwipeUpDatePicker(){
        hideDatePickerAnimated(true)
    }
    func setDatePickerHidden(hidden: Bool, animated: Bool){
        let y = hidden ? DatePickerOffScreen : 0
        dateSelectorRevealConstraint.constant = y
        view.setNeedsUpdateConstraints()
        
        let animations = { () -> Void in
            self.datePickerButtons.alpha = hidden ? 0 : 1
            self.view.layoutIfNeeded()
            self.setNeedsStatusBarAppearanceUpdate()
        }
        if animated{
            UIView.animateWithDuration(0.4, animations: animations)
        }else{
            animations()
        }
    }
    @IBAction func didPressDateHeader(sender: AnyObject) {
        showDatePickerAnimated(true)
    }
}
