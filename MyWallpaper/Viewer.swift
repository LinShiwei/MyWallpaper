//
//  Viewer.swift
//  MyWallpaper
//
//  Created by Linsw on 16/4/29.
//  Copyright © 2016年 Linsw. All rights reserved.
//

import Foundation
import Haneke
import UIKit
class ImageViewer: UIViewController {
    // MARK: - Properties
    let rootViewController : UIViewController!
    let windowBounds = UIScreen.mainScreen().bounds
    let senderView : UIImageView!

    let currentIndex : Int!
    let pictures : [Picture]!
    let maskView = UIView()
    var scrollView : ImageViewerScrollView?

    // MARK: - Lifecycle methods
    init(senderView: UIImageView,currentIndex index:Int,pictures:[Picture], backgroundColor: UIColor) {
        self.senderView = senderView
        self.pictures = pictures
        self.currentIndex = index
        maskView.backgroundColor = backgroundColor

        rootViewController = UIApplication.sharedApplication().keyWindow!.rootViewController!
        super.init(nibName: nil, bundle: nil)
        
        configureView()
        configureMaskView()
        configureScrollView()

        view.backgroundColor = UIColor.greenColor()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func loadView() {
        super.loadView()
    }
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    private func configureView(){
        view.backgroundColor = UIColor.redColor()
        let swipeDownRecognizer = UISwipeGestureRecognizer(target: self, action: "didSwipeDown:")
        swipeDownRecognizer.direction = .Down
        view.addGestureRecognizer(swipeDownRecognizer)
        let swipeUpRecognizer = UISwipeGestureRecognizer(target: self, action: "didSwipeUp:")
        swipeUpRecognizer.direction = .Up
        view.addGestureRecognizer(swipeUpRecognizer)
    }
    private func configureMaskView(){
        maskView.frame = windowBounds
        view.insertSubview(maskView, atIndex: 0)
    }
    private func configureScrollView(){
        scrollView = ImageViewerScrollView(frame: windowBounds, currentIndex: currentIndex, pictures: pictures)
        scrollView!.delegate = self
        view.addSubview(scrollView!)
    }
    func didSwipeDown(sender:UISwipeGestureRecognizer){
        
    }
    func didSwipeUp(sender:UISwipeGestureRecognizer){
        dismissViewController()
    }
    // MARK: - Animation
    private func animateEntry() {
       
    }
    private func dismissViewController() {
        dispatch_async(dispatch_get_main_queue()){ [unowned self] in
            UIView.animateWithDuration(0.8, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.6, options: [UIViewAnimationOptions.BeginFromCurrentState, UIViewAnimationOptions.CurveEaseInOut], animations: {[unowned self]() in
                self.maskView.alpha = 0.0
                }, completion: {(finished) in
                    self.willMoveToParentViewController(nil)
                    self.view.removeFromSuperview()
                    self.removeFromParentViewController()
            })
        }
    }
    func presentFromRootViewController() {
        willMoveToParentViewController(rootViewController)
        rootViewController.view.addSubview(view)
        rootViewController.addChildViewController(self)
        didMoveToParentViewController(rootViewController)
    }
}
// MARK: - ScrollView delegate
extension ImageViewer: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        scrollView.userInteractionEnabled = false
    }
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if scrollView.contentOffset.x > scrollView.frame.width {
            (scrollView as! ImageViewerScrollView).scrollViewSwipeLeft()
        }else{
            if scrollView.contentOffset.x < scrollView.frame.width {
                (scrollView as! ImageViewerScrollView).scrollViewSwipeRight()
            }else{
                    print("offset = width")
            }
        }
        scrollView.userInteractionEnabled = true
    }
}
