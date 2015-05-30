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
    
    var playlist: Playlist!
    func getPlaylist()->Playlist{
        return playlist
    }
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return (loadingView != nil && loadingView.alpha < 1) ? .LightContent : .Default
    }
    override func prefersStatusBarHidden() -> Bool {
        return dateSelectorRevealConstraint == nil ||  dateSelectorRevealConstraint.constant == 0
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
        view.bringSubviewToFront(loadingView) // for ease of authoring I put the loading view at the back of the storyboard once I laid it out
        hideDatePickerAnimated(false)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        if playlist == nil{
            playlist = Playlist.findOrCreateForUtcDate( CalendarHelper.startOfUTCDay(NSDate()))
        }
        flyersController?.playlist = playlist
        playlist.currentTrack = playlist.tracks.last
        updateFavouritesCount()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateFavouritesCount", name: FAVOURITE_COUNT_CHANGED, object: nil)
        // deal with location stuff here because we might need to show UI
        LocationHelper.lookUp { (location, error) -> Void in
            self.playlist.setLocation(location)
            self.playlist.fetchEvents {
                self.setDateHeading(self.playlist.utcDate)
                self.flyersController?.reload{
                    self.playNextTrack() // maybe check whether it was playing on last launch? But I think I prefer straight up playback - launching the app is like turning on a radio.
                    self.hideLoadingView()
                }

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
    func changeDate(date:NSDate, callback:()->Void){
        let location = playlist.location
        self.playlist = Playlist.findOrCreateForUtcDate(CalendarHelper.startOfUTCDay(date)) // being cautious
        playlist.setLocation(location)
        flyersController?.playlist = playlist
        playlist.fetchEvents {
            self.flyersController?.reload {
                self.playNextTrack()
                callback()
            }
        }
    }
    func playNextTrack(){
        playlist.determineTrackAfter(playlist.currentTrack){ track in
            if let track = track{
                self.playlist.currentTrack = track
                self.displayAndPlayTrack(track)
            }
        }
    }
    func playPreviousTrack() {
        if var index = playlist.tracks.indexOf(playlist.currentTrack!){
            index -= 1
            if index > 0{
                let track = playlist.tracks[index]
                playlist.currentTrack = track
                displayAndPlayTrack(track)
            }
        }
    }
    func displayAndPlayTrack(track:PlaylistTrack){
        if let performanceIndex = playlist.performances.indexOf(track.performance){
            let indexPath = NSIndexPath(forItem: performanceIndex, inSection: 0)
            flyersController?.collectionView?.scrollToItemAtIndexPath(indexPath, atScrollPosition: .CenteredHorizontally, animated: true)
            if let cell = flyersController?.collectionView?.cellForItemAtIndexPath(indexPath) as? FlyerCollectionViewCell{
                cell.updateTrackAvailabilityIcon(track.performance.soundCloudUser.tracks.count)
                cell.trackFetchingIndicator.stopAnimating()
            }
            self.transportController.play(track)
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
    func datePickerDidChangeVisibleDates(utcDates:[NSDate]) {
        let counter = CompletionCounter(total: utcDates.count) {
            self.datePicker?.refresh()
        }
        for date in utcDates{
            let playlist = Playlist.findOrCreateForUtcDate(date)
            playlist.setLocation(self.playlist.location) // TODO: figure out if this is right when we've picked a specific city
            playlist.fetchEvents{
                counter.click()
            }
        }
    }
    func datePickerDidSelectDate(startDate: NSDate) {
        let status = DateFormats.todayFormatter().stringFromDate(startDate)
        SVProgressHUD.showWithStatus(status, maskType: .Black)
        setDateHeading(startDate)
        self.changeDate(startDate){
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
