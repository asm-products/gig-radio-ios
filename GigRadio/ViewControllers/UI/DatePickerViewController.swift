//
//  DatePickerViewController.swift
//  GigRadio
//
//  Created by Michael Forrest on 12/02/2015.
//  Copyright (c) 2015 Good To Hear. All rights reserved.
//

import UIKit

protocol DatePickerViewControllerDelegate{
    func datePickerDidChangeVisibleRange(startDate: NSDate, endDate: NSDate)
    func datePickerDidSelectDate(startDate: NSDate)
}

extension Int{
    func daysAfter(date:NSDate)->NSDate{
        return NSCalendar.currentCalendar().dateByAddingComponents(CalendarHelper.days(self), toDate: date, options: nil)!
    }
}

class DatePickerViewController: UICollectionViewController, UIScrollViewDelegate, UICollectionViewDelegateFlowLayout {
    let DaysPerScreen = 10
    var day0: NSDate = (-4).daysAfter( CalendarHelper.startOfUTCDay(NSDate()) )
    var selectedDate: NSDate!
    var daysOffset = 0
    
    var centeredDateCache: NSDate?
    var backgroundView: UIView!
    var monthLabel: UILabel?
    
//    var activity: UIActivityIndicatorView!
    
    var delegate: DatePickerViewControllerDelegate!
    override func viewDidLoad() {
        super.viewDidLoad()
        selectedDate = 4.daysAfter(day0)

    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let view = UIView()
        let label = UILabel()
        label.font = UIFont.boldSystemFontOfSize(12)
        label.textColor = UIColor.whiteColor()
        label.textAlignment = .Center
        var frame = self.view.bounds
        frame.size.width = UIScreen.mainScreen().bounds.width // hack because the container width is coming in the wrong size
        view.frame = frame
        label.frame = CGRectMake(0, 0, view.bounds.width, 22)
        view.addSubview(label)
        
//        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.White)
//        activityIndicator.hidesWhenStopped = true
//        activityIndicator.frame = CGRectMake(100, 0, 20, 20)
//        view.addSubview(activityIndicator)
//        self.activity = activityIndicator
        
        collectionView!.backgroundView = view
        backgroundView = view
        monthLabel = label
        
        updateDateHeadingIfNeeded()
    }
    func scrollToToday(animated: Bool){
        let indexPath = NSIndexPath(forItem: 4, inSection: 0)
        collectionView?.scrollToItemAtIndexPath(indexPath, atScrollPosition: .CenteredHorizontally, animated: true)
        collectionView(collectionView!, didSelectItemAtIndexPath: indexPath)
    }
    func refresh(){
        collectionView?.reloadData()
    }
    // MARK: CollectionViewDataSource
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return DaysPerScreen * 4
     }
    func configureCell(cell:PickerDayCollectionViewCell, indexPath:NSIndexPath){
        let date = dateAtIndexPath(indexPath)
        cell.date = date
        cell.selectionIndicator.hidden = selectedDate != date
        
    }
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! PickerDayCollectionViewCell
        configureCell(cell, indexPath: indexPath)
        return cell
    }
    func dateAtIndexPath(indexPath:NSIndexPath)->NSDate{
        return (indexPath.row + daysOffset).daysAfter(day0)
    }
    override func scrollViewDidScroll(scrollView: UIScrollView) {
//        if scrollView.contentOffset.x > self.view.bounds.width{
//            daysOffset += DaysPerScreen
//            scrollView.contentOffset = CGPoint(x: 0, y:0)// cool, this preserves the momentum
//            collectionView?.reloadData()
//        }else if scrollView.contentOffset.x < 0{
//            daysOffset -= DaysPerScreen
//            scrollView.contentOffset = CGPoint(x:self.view.bounds.width, y: 0)
//            collectionView?.reloadData()
//        }
        updateDateHeadingIfNeeded()
    }
    override func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if decelerate == false{
            finishedChangingDateRange()
        }
    }
    override func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        finishedChangingDateRange()
    }
    func finishedChangingDateRange(){
        var cells = collectionView!.visibleCells() as! [PickerDayCollectionViewCell]
        cells.sort { (a, b) -> Bool in
            a.date.compare(b.date) == NSComparisonResult.OrderedAscending
        }
        if let first = cells.first,
            let last = cells.last{
                delegate.datePickerDidChangeVisibleRange(first.date, endDate: last.date)
        }
    }
    func updateDateHeadingIfNeeded(){
        let superview = collectionView!.superview!
        let localPoint = collectionView!.convertPoint(CGPoint(x: CGRectGetMidX(superview.frame), y: 50), fromCoordinateSpace:superview)
        if let indexPath = collectionView!.indexPathForItemAtPoint(localPoint) {
            let date = dateAtIndexPath(indexPath)
            if centeredDateCache != date{
                monthLabel?.text = DateFormats.monthAndYearFormatter().stringFromDate(date).uppercaseString
            }
            centeredDateCache = date
        }
    }
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let date = dateAtIndexPath(indexPath)
        selectedDate = date
        self.collectionView?.reloadData()
        
        delegate.datePickerDidSelectDate(date)
    }
    
    // MARK: Layout Delegate
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize{
        return CGSize(width: view.frame.width / CGFloat(DaysPerScreen), height: view.frame.size.height)
    }
}
