//
//  OnboardingViewController.swift
//  GigRadio
//
//  Created by Michael Forrest on 11/12/2015.
//  Copyright © 2015 Good To Hear. All rights reserved.
//

import UIKit
import PureLayout
struct OnboardingItem{
    let bodyKey: String
    let videoName: String
}
class OnboardingViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate, OnboardingItemViewControllerDelegate {
    var pageViewController: UIPageViewController?
    let items:[OnboardingItem] = [
        OnboardingItem(bodyKey: "onboarding-1", videoName: "songkick-browse"),
        OnboardingItem(bodyKey: "onboarding-2", videoName: "soundcloud"),
        OnboardingItem(bodyKey: "onboarding-3", videoName: "gig-radio-playback"),
        OnboardingItem(bodyKey: "onboarding-4", videoName: "fixing-errors")
    ]
    
    let ItemSpacing:CGFloat = 10
    
    @IBOutlet weak var transitionView: UIView!
    
    @IBOutlet weak var nextButton: UIButton!
    
    @IBOutlet weak var logoView: UIImageView!
    
    @IBOutlet weak var logoCenterConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.bringSubviewToFront(transitionView)
        if Onboarding.hasSeen(.IntroductionSeen) {
            self.performSegueWithIdentifier("exit", sender: nil)
        }else{
            build()
            Onboarding.markSeen(.IntroductionSeen)
        }
    }
    func build(){
        addPageViewController()
    }
    func addPageViewController(){
        let controller = UIPageViewController(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: nil)
        controller.delegate = self
        controller.dataSource = self
        controller.willMoveToParentViewController(self)
        view.insertSubview(controller.view, atIndex: 0)
        controller.view.autoPinEdgesToSuperviewEdges()
        addChildViewController(controller)
        controller.didMoveToParentViewController(self)
        pageViewController = controller
        
        controller.setViewControllers([viewControllerAtIndex(0)], direction: .Forward, animated: false, completion: nil)
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animateKeyframesWithDuration(1.5, delay: 0, options: [], animations: { () -> Void in
            UIView.addKeyframeWithRelativeStartTime(0, relativeDuration: 0.5) {
                self.makeAdjustmentsToReveal()
            }
            UIView.addKeyframeWithRelativeStartTime(0.5, relativeDuration: 0.5) {
                self.transitionView.backgroundColor = UIColor.clearColor()
            }
            }) { _ in
                
        }
    }
    func makeAdjustmentsToReveal(){
        logoView.transform = CGAffineTransformMakeScale(0.5, 0.5)
        let l = -(view.frame.midY - titleLabel.frame.minY) - logoView.frame.height * 0.5 - ItemSpacing
        logoCenterConstraint.constant = l
        view.layoutIfNeeded()
    }
    func viewControllerAtIndex(index:Int)->UIViewController{
        let result = storyboard!.instantiateViewControllerWithIdentifier("OnboardingItem") as! OnboardingItemViewController
        result.item = items[index]
        result.topSpace = titleLabel.frame.maxY + ItemSpacing
        result.delegate = self
        return result
    }
    
    // MARK: - Actions
    @IBAction func didPressNext(sender: AnyObject) {
        if let pageViewController = pageViewController, first = pageViewController.viewControllers?.first, next = viewControllerOffsetFrom(first, by: 1) {
            pageViewController.setViewControllers([next], direction: .Forward, animated:
            true, completion: nil)
        }else{
            exitWithAnimation()
        }
    }
    func exitWithAnimation(){
        UIView.animateKeyframesWithDuration(1.0, delay: 0, options: [], animations: {
            UIView.addKeyframeWithRelativeStartTime(0, relativeDuration: 0.5) {
                self.transitionView.backgroundColor = UIColor.whiteColor()
            }
            UIView.addKeyframeWithRelativeStartTime(0.5, relativeDuration: 0.5) {
                self.logoCenterConstraint.constant = 0
                self.logoView.transform = CGAffineTransformIdentity
                self.view.layoutIfNeeded()
            }
            }) { _ in
                self.performSegueWithIdentifier("exit", sender: nil)
        }
    }
    
    // MARK: - OnboardingItemViewControllerDelegate
    func onboardingItemViewControllerDidAppear(sender: OnboardingItemViewController) {
        let key =  indexOfItemController(sender) == items.count - 1 ? "onboarding-dismiss" : "onboarding-next"
        nextButton.setTitle(NSLocalizedString(key, comment: "next or exit"), forState: .Normal)
    }
    
    // MARK: - UIPageViewControllerDataSource
    // BEFORE
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        return viewControllerOffsetFrom(viewController, by: -1)
    }
    // AFTER
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        return viewControllerOffsetFrom(viewController, by: 1)
    }
    func indexOfItemController(viewController:UIViewController)->Int{
        let viewController = viewController as! OnboardingItemViewController
        return items.indexOf({ viewController.item?.bodyKey == $0.bodyKey })!
    }
    func viewControllerOffsetFrom(viewController:UIViewController, by: Int)->UIViewController?{
        let index = indexOfItemController(viewController) + by
        if index < 0 || index > items.count - 1 {
            return nil
        }else{
            return viewControllerAtIndex(index)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

}
