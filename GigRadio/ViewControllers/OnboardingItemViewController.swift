//
//  OnboardingItemViewController.swift
//  GigRadio
//
//  Created by Michael Forrest on 11/12/2015.
//  Copyright © 2015 Good To Hear. All rights reserved.
//

import UIKit
import MediaPlayer

protocol OnboardingItemViewControllerDelegate:class{
    func onboardingItemViewControllerDidAppear(sender:OnboardingItemViewController)
}

class OnboardingItemViewController: UIViewController {
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var bodyLabel: UILabel!
    @IBOutlet weak var videoContainer: UIView!
    
    weak var delegate:OnboardingItemViewControllerDelegate?
    
    var item: OnboardingItem!
    var player:MPMoviePlayerController?
    var topSpace: CGFloat!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        topConstraint.constant = topSpace
        self.bodyLabel.text = NSLocalizedString(item!.bodyKey, comment: "translation")
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        loadVideo()
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        delegate?.onboardingItemViewControllerDidAppear(self)
    }
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        unloadVideo()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    func loadVideo(){
        let url = NSBundle.mainBundle().URLForResource("\(item.videoName)-Apple Devices HD (Best Quality)", withExtension: "m4v")
        let player = MPMoviePlayerController(contentURL: url)
        videoContainer.addSubview(player.view)
        player.view.autoPinEdgesToSuperviewEdges()
        player.repeatMode = .One
        player.controlStyle = .None
        player.prepareToPlay()
        player.play()
        self.player = player
    }
    func unloadVideo(){
        player?.stop()
        player?.view.removeFromSuperview()
        player = nil
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
