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

class MainViewController: UIViewController, UICollectionViewDelegate, CLLocationManagerDelegate, DatePickerViewControllerDelegate,FlyersCollectionViewControllerDelegate,TransportViewControllerDelegate {
    let DatePickerOffScreen:CGFloat = -80
    
    @IBOutlet weak var headerDateButton: UIButton!
    @IBOutlet weak var dateSelectorRevealConstraint: NSLayoutConstraint!
    @IBOutlet weak var transportContainer: UIView!
    
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var datePickerButtons: UIView!
    @IBOutlet weak var favouritesCountLabel: UILabel! 

    var datePicker: DatePickerViewController?
    var flyersController: FlyersCollectionViewController?
    var transportController: TransportViewController!
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
        updateFavouritesCount()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateFavouritesCount", name: FAVOURITE_COUNT_CHANGED, object: nil)
        // deal with location stuff here because we might need to show UI
        LocationHelper.lookUp { (location, error) -> Void in
            self.location = location
            self.fetchEventsForDate(NSDate()){
                self.setDateHeading(NSDate())
                self.hideLoadingView()
            }
        }
    }
    func updateFavouritesCount(){
        favouritesCountLabel.layer.cornerRadius = 8
        let count = Favourite.futureEvents().count
        if count > 0{
            favouritesCountLabel.hidden = false
            favouritesCountLabel.text = "\(count)"
        }else{
            favouritesCountLabel.hidden = true
        }
    }
    func fetchEventsForDate(date:NSDate, callback:()->Void){
        SongKickClient.sharedClient.getEvents(date, location: location, completion: { (eventIds, error) -> Void in
            if let ids = eventIds{
                Playlist.sharedPlaylist.updateLatestRunWithEventIds(ids, date: date)
            }
            SongKickVenue.updateDistanceCachesWithLocation(self.location)
            self.flyersController?.reload {
                self.playNextTrack()
                callback()
            }
        })
    }
    func playNextTrack(){
        var run = PlaylistRun.current()
        self.setCurrentItemIndex(run.indexOfLastUnplayedItem(), run:run){ success in
            if success == false{
                self.playNextTrack()
            }
        }
    }
    func playPreviousTrack() {
        
    }
    func setCurrentItemIndex(itemIndex: Int?,run:PlaylistRun,  callback:(success:Bool)->Void){
        if itemIndex == nil{
            callback(success: false)
            return
        }
        // scroll to right performance
        let indexPath = NSIndexPath(forItem: itemIndex!, inSection: run.globalIndex()!)
        flyersController?.collectionView?.scrollToItemAtIndexPath(indexPath, atScrollPosition: .CenteredHorizontally, animated: true)
        let cell = flyersController?.collectionView?.cellForItemAtIndexPath(indexPath) as! FlyerCollectionViewCell?
        let item = run.items[itemIndex!]
        cell?.trackFetchingIndicator.startAnimating()
        cell?.trackAvailabilityButton.hidden = true
        item.determineSoundCloudUser(){ user,error in
            cell?.trackFetchingIndicator.hidden = true
            if user == nil{
                cell?.trackAvailabilityButton.setImage(UIImage(named:"tracks-avail-0"), forState: .Normal)
                callback(success: false)
            }else{
                item.determineTracksAvailable(){ trackCount,error in
                    if trackCount == nil{
                        cell?.updateTrackAvailabilityIcon(0)
                        item.markPlayed()
                        callback(success: false)
                    }else{
                        cell?.updateTrackAvailabilityIcon(trackCount!)
                        item.determineNextTrackToPlay(){ track in
                            if track == nil{
                                item.markPlayed()
                                callback(success:false)
                            }else{
                                self.transportController.setBufferingDisplay(true)
                                self.transportController.play(item){ success in
                                    callback(success:success)
                                }
                            }
                        }
                    }
                }
            }
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
        }else if let dest = segue.destinationViewController as? FlyersCollectionViewController{
            self.flyersController = dest
            flyersController?.delegate = self
        }else if let dest = segue.destinationViewController as? TransportViewController{
            self.transportController = dest
            dest.delegate = self
        }
    }
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
        setDateHeading(startDate)
        self.fetchEventsForDate(startDate){
            self.hideDatePickerAnimated(true)
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
    func heightOfTransportArea() -> CGFloat {
        return transportContainer.frame.size.height
    }
}
