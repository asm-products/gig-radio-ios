//
//  MainViewController.swift
//  GigRadio
//
//  Created by Michael Forrest on 17/05/2015.
//  Copyright (c) 2015 Good To Hear. All rights reserved.
//

import UIKit
import CoreLocation
import SVProgressHUD

class MainViewController: UIViewController, UICollectionViewDelegate, CLLocationManagerDelegate, DatePickerViewControllerDelegate {
    let DatePickerOffScreen:CGFloat = -80
    
    @IBOutlet weak var headerDateButton: UIButton!
    @IBOutlet weak var dateSelectorRevealConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var datePickerButtons: UIView!

    var datePicker: DatePickerViewController?
    var flyersController: FlyersCollectionViewController?
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
        hideDatePickerAnimated(false)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // deal with location stuff here because we might need to show UI
        
        LocationHelper.lookUp { (location, error) -> Void in
            self.location = location
            self.fetchEventsForDate(NSDate()){
                self.setDateHeading(NSDate())
                self.hideLoadingView()
            }
        }
    }
    func fetchEventsForDate(date:NSDate, callback:()->Void){
        SongKickClient.sharedClient.getEvents(date, location: location, completion: { (eventIds, error) -> Void in
            if let ids = eventIds{
                Playlist.sharedPlaylist.updateLatestRunWithEventIds(ids)
            }
            self.flyersController?.reload {
                callback()
            }
        })
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
        }else if let dest = segue.destinationViewController as? FlyersCollectionViewController{
            self.flyersController = dest
        }
    }
    // MARK: MediaPlayer
    
    // MARK: DatePicker
    func datePickerDidChangeVisibleRange(startDate: NSDate, endDate: NSDate) {
        SongKickClient.sharedClient.getEvents(startDate, end: endDate, location: location) { (results,error) -> Void in
            if error != nil{
                println("SongKick error: \(error!.localizedDescription)")
            }
            self.datePicker?.refresh()
        }
    }
    func datePickerDidSelectDate(startDate: NSDate) {
        let status = DateFormats.todayFormatter().stringFromDate(startDate)
        SVProgressHUD.showWithStatus(status, maskType: .Black)
        hideDatePickerAnimated(true)
        setDateHeading(startDate)
        self.fetchEventsForDate(startDate){
            SVProgressHUD.dismiss()
        }
    }
    func setDateHeading(date:NSDate){
        var title = NSMutableAttributedString()
        title.appendAttributedString(NSAttributedString(string: "GIG RADIO\n", attributes: Typography.HeaderRegular(13)))
        // WARN: Potentially broken in the US!
        let dateString = DateFormats.todayFormatter().stringFromDate(date)
        title.appendAttributedString(NSAttributedString(string: dateString, attributes: Typography.HeaderLight(13)))
        
        let style = NSMutableParagraphStyle()
        style.alignment = .Center
        title.addAttribute(NSParagraphStyleAttributeName, value: style, range: NSMakeRange(0, title.length))
        headerDateButton.setAttributedTitle(title, forState: .Normal)
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
