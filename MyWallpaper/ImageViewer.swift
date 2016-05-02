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
    var senderView : UIImageView!{
        didSet{
            scrollView!.configureOriginFrameToScrollView(convertViewFrameToScreen(senderView))
        }
    }
    let currentIndex : Int!
    let pictures : [Picture]!
    let maskView = UIView()
    var scrollView : ImageViewerScrollView?
    var prompt = SwiftPromptsView()
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
        animateEntry()
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
    private func convertViewFrameToScreen(view:UIView)->CGRect{
        return CGRect(origin: view.convertPoint(CGPoint(x: 0, y: 0), toView: nil), size: view.frame.size)
    }
    private func configureView(){
        let swipeDownRecognizer = UISwipeGestureRecognizer(target: self, action: "didSwipeDown:")
        swipeDownRecognizer.direction = .Down
        view.addGestureRecognizer(swipeDownRecognizer)
        let swipeUpRecognizer = UISwipeGestureRecognizer(target: self, action: "didSwipeUp:")
        swipeUpRecognizer.direction = .Up
        view.addGestureRecognizer(swipeUpRecognizer)
    }
    private func configureMaskView(){
        maskView.frame = windowBounds
        maskView.alpha = 0
        view.insertSubview(maskView, atIndex: 0)
    }
    private func configureScrollView(){
        scrollView = ImageViewerScrollView(originFrame: convertViewFrameToScreen(senderView), currentIndex: currentIndex, pictures: pictures)
        scrollView!.delegate = self
        view.addSubview(scrollView!)
    }
    private func initSenderView(currentIndexPathRow:Int){
        if !(self.senderView.superview is UIScrollView) {
            senderView.alpha = 1.0
            let collection = (self.senderView.superview?.superview as! ImageCollectionViewCell).superview as! UICollectionView
            let indexPath = NSIndexPath(forItem: currentIndexPathRow, inSection: 0)
            
            collection.scrollToItemAtIndexPath(indexPath, atScrollPosition: .CenteredVertically, animated: false)
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.1 * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_main_queue()) {[unowned self] in
                guard let senderCell = collection.cellForItemAtIndexPath(indexPath) as? ImageCollectionViewCell else{
                    print("senderCell no found")
                    return
                }
                self.senderView = senderCell.imageView
                self.senderView.alpha = 0
            }
        }else{
            senderView.alpha = 1.0
            let scrollView = self.senderView.superview as! UIScrollView
            let originX = scrollView.frame.width * CGFloat(currentIndexPathRow)
            for view in scrollView.subviews where view.frame.origin.x == originX {
                scrollView.scrollRectToVisible(view.frame, animated: false)
                senderView = view as! UIImageView
            }

            senderView.alpha = 0
        }
    }
    private func initPromptsView(){
        prompt = SwiftPromptsView(frame: self.view.bounds)
        prompt.delegate = self
        prompt.enableLightEffectView()
        
        //Set the properties of the prompt
        prompt.setPromptHeader("Success")
        prompt.setPromptContentText("The photo was successfully saved to your photo album.")
        prompt.setPromptTopLineVisibility(true)
        prompt.setPromptBottomLineVisibility(false)
        prompt.setPromptBottomBarVisibility(true)
        prompt.setPromptTopLineColor(UIColor(red: 151.0/255.0, green: 151.0/255.0, blue: 151.0/255.0, alpha: 1.0))
        prompt.setPromptBackgroundColor(UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 0.67))
        prompt.setPromptBottomBarColor(UIColor(red: 34.0/255.0, green: 139.0/255.0, blue: 34.0/255.0, alpha: 0.67))
        prompt.setMainButtonColor(UIColor.whiteColor())
        prompt.setMainButtonText("OK")
        view.addSubview(prompt)
    }
    func didSwipeUp(sender:UISwipeGestureRecognizer){
        dismissViewController()
    }
    func didSwipeDown(sender:UISwipeGestureRecognizer){
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)){
            UIImageWriteToSavedPhotosAlbum(self.scrollView!.centerImage, self, "image:didFinishSavingWithError:contextInfo:", nil)
        }
    }
    func image(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo:UnsafePointer<Void>) {
        dispatch_async(dispatch_get_main_queue()) {[unowned self] in
            if error == nil {
                print("Download succeed")
                self.initPromptsView()
            } else {
                print("Download fail")
            }
        }
    }
    // MARK: - Animation
    private func animateEntry() {
        senderView.alpha = 0
        UIView.animateWithDuration(1.2, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.6, options: [UIViewAnimationOptions.BeginFromCurrentState, UIViewAnimationOptions.CurveEaseInOut], animations: {[unowned self]() -> Void in
            self.scrollView!.zoomIn()
            }, completion: nil)
        
        UIView.animateWithDuration(0.4, delay: 0.03, options: [UIViewAnimationOptions.BeginFromCurrentState, UIViewAnimationOptions.CurveEaseInOut], animations: {[unowned self]() -> Void in
            self.maskView.alpha = 1.0
            }, completion: nil)
    }
    private func dismissViewController() {
        UIView.animateWithDuration(1, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.6, options: [UIViewAnimationOptions.BeginFromCurrentState, UIViewAnimationOptions.CurveEaseInOut], animations: {[unowned self]() in
                self.scrollView!.zoomOut()
                self.maskView.alpha = 0
            }, completion: {(finished) in
                if self.senderView.superview is ImageScrollView {
                    (self.senderView.superview as! ImageScrollView).initTimer()
                }
                self.senderView.alpha = 1
                self.willMoveToParentViewController(nil)
                self.view.removeFromSuperview()
                self.removeFromParentViewController()
        })
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
        guard let view = scrollView as? ImageViewerScrollView else { return }
        if view.contentOffset.x > scrollView.frame.width {
            view.scrollViewSwipeLeft()
            initSenderView(view.currentIndex)
        }else{
            if view.contentOffset.x < view.frame.width {
                view.scrollViewSwipeRight()
                initSenderView(view.currentIndex)
            }else{
                print("offset = width")
            }
        }
        view.userInteractionEnabled = true
    }
}
extension ImageViewer: SwiftPromptsProtocol{
    func clickedOnTheMainButton() {
        print("Clicked on the main button")
        prompt.dismissPrompt()
    }
    func clickedOnTheSecondButton() {
        print("Clicked on the second button")
        prompt.dismissPrompt()
    }
    func promptWasDismissed() {
        print("Dismissed the prompt")
    }
}
