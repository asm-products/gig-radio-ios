//
//  FlyersCollectionViewController.swift
//  GigRadio
//
//  Created by Michael Forrest on 17/05/2015.
//  Copyright (c) 2015 Good To Hear. All rights reserved.
//

import UIKit
import RealmSwift

let reuseIdentifier = "Flyer"

protocol FlyersCollectionViewControllerDelegate: EditPlaylistItemViewControllerDelegate{
    func heightOfTransportArea()->CGFloat
}

class FlyersCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, FlyerCollectionViewCellDelegate {
    var playlist: Playlist?
    var delegate: FlyersCollectionViewControllerDelegate!
    override func viewDidLoad() {
        super.viewDidLoad()
        if let layout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout{
            layout.itemSize = CGSize(width: collectionView!.frame.width , height: collectionView!.frame.size.height)
        }
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleFavouriteCountChanged", name: FAVOURITE_COUNT_CHANGED, object: nil)
        reload(nil)
    }
    deinit{
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    func handleFavouriteCountChanged(){
        guard let cells = collectionView?.visibleCells() as? [FlyerCollectionViewCell] else {
            print("Bad cells!")
            return
        }
        for cell in cells{
            if let item = cell.performance{
                cell.updateFavouriteState(item)
            }
        }
    }
    func reload(callback:(()->Void)?){
        var urls = [String]()
        if let playlist = playlist{
            for item in playlist.performances{
                urls.append(item.songKickArtist.imageUrl())
            }
            preload(urls){
                self.collectionView?.reloadData()
                callback?()                    
            }
        }
    }

    // MARK: UICollectionViewDataSource
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return playlist == nil ? 0 : 1
    }
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return playlist!.performances.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! FlyerCollectionViewCell
    
        let performance = performanceAtIndexPath(indexPath)
        cell.performance = performance
        cell.delegate = self
        cell.baselineConstraint.constant = delegate.heightOfTransportArea()
        performance?.determineSoundCloudUser({ (user, error) -> Void in
            performance?.determineTracksAvailable({ (trackCount, error) -> Void in
                if cell.performance == performance{
                    cell.performance = performance // update if it's not been reused by now.
                }
            })
        })
        return cell
    }

    func performanceAtIndexPath(indexPath:NSIndexPath)->PlaylistPerformance?{
        return playlist!.performances[indexPath.row]
    }
    func flyerCellShowEventButtonPressed(event: SongKickEvent) {
        showEvent(event)
    }
    func flyerCellTrackCountButtonPressed(performance:PlaylistPerformance) {
        if let nav = storyboard?.instantiateViewControllerWithIdentifier("EditPlaylistItemNav") as? UINavigationController{
            if let root = nav.topViewController  as? EditPlaylistItemViewController{
                root.performance = performance
                root.delegate = delegate
                presentViewController(nav, animated: true, completion: nil)
            }
        }
    }
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        if let layout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout{
            layout.itemSize = size
        }
        collectionView?.reloadData()
    }
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if let performance = performanceAtIndexPath(indexPath){
            showEvent(performance.songKickEvent)
        }
    }
    func showEvent(event:SongKickEvent){
        if let controller = storyboard?.instantiateViewControllerWithIdentifier("GigPage") as? GigInfoTableViewController{
            controller.event = event
            navigationController?.pushViewController(controller, animated: true)
        }
    }
    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    
    }
    */

}
