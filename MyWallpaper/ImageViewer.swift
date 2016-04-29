//
//  ImageViewer.swift
//  ImageViewer
//
//  Created by Tan Nghia La on 30.04.15.
//  Copyright (c) 2015 Tan Nghia La. All rights reserved.
//

import UIKit
import Haneke

class ImageViewer: UIViewController {
    // MARK: - Properties
    var senderView: UIImageView!
    var originalFrameRelativeToScreen: CGRect!
    var rootViewController: UIViewController!
    
    let imageView = UIImageView()
    let nextImageView = UIImageView()
    let previousImageView = UIImageView()
    var currentIndexPathRow :Int = 0
    
    var highQualityImageUrl: NSURL?
    var pictures:[Picture]!
    
    let downloadButton = UIButton()
    let closeButton = UIButton()
    let windowBounds = UIScreen.mainScreen().bounds
    let scrollView = UIScrollView()
    let maskView = UIView()
    
    // MARK: - Lifecycle methods
    init(senderView: UIImageView,highQualityImageUrl: NSURL?,pictures:[Picture], backgroundColor: UIColor) {
        self.senderView = senderView
        self.pictures = pictures
        self.highQualityImageUrl = highQualityImageUrl
     
        rootViewController = UIApplication.sharedApplication().keyWindow!.rootViewController!
        maskView.backgroundColor = backgroundColor
        super.init(nibName: nil, bundle: nil)
        if let timer = self.getTimer() {
            timer.invalidate()
        }
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func loadView() {
        super.loadView()
        configureView()
        configureMaskView()
        configureScrollView()
        configureCloseButton()
        configureDownloadButton()
        configureImageView()
        configureConstraints()
    }
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    // MARK: - View configuration
    private func configureScrollView() {
        scrollView.frame = windowBounds
        scrollView.delegate = self
        scrollView.pagingEnabled = true
        scrollView.contentSize = CGSizeMake(scrollView.frame.width * 3, scrollView.frame.height)
        scrollView.setContentOffset(CGPoint(x: scrollView.frame.width, y: 0), animated: false)
        view.addSubview(scrollView)
    }
    private func configureMaskView() {
        maskView.frame = windowBounds
        maskView.alpha = 0.0
        view.insertSubview(maskView, atIndex: 0)
    }
    private func configureCloseButton() {
        configureButton(closeButton, withImageName: "ImageClose", andAction: "closeButtonTapped:")
    }
    private func configureDownloadButton() {
        configureButton(downloadButton, withImageName: "ImageDownload", andAction: "downloadButtonTapped:")
    }
    private func configureButton(button:UIButton,withImageName imageName:String, andAction action:Selector){
        let image = UIImage(named: imageName, inBundle: NSBundle(forClass: ImageViewer.self), compatibleWithTraitCollection: nil)
        button.alpha = 0
        button.setImage(image, forState: .Normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: action, forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(button)
        view.setNeedsUpdateConstraints()
    }
    private func configureView() {
        var originalFrame = senderView.convertRect(windowBounds, toView: nil)
        originalFrame.size = senderView.frame.size
        originalFrameRelativeToScreen = originalFrame
    }
    private func initSenderView(currentIndexPathRow:Int){
        if !(self.senderView.superview is UIScrollView) {
            senderView.alpha = 1.0
            let cell = self.senderView.superview?.superview as! ImageCollectionViewCell
            let collection = cell.superview as! UICollectionView
            let indexPath = NSIndexPath(forItem: currentIndexPathRow, inSection: 0)
            
            collection.scrollToItemAtIndexPath(indexPath, atScrollPosition: .CenteredVertically, animated: false)
            guard let senderCell = collection.cellForItemAtIndexPath(indexPath) as? ImageCollectionViewCell else{
                print(collection.cellForItemAtIndexPath(indexPath))
                return
            }
            senderView = senderCell.imageView
            senderView.alpha = 0
            configureView()
        }else{
            senderView.alpha = 1.0
            let scrollView = self.senderView.superview as! UIScrollView
            let views = scrollView.subviews
            let originX = scrollView.frame.width * CGFloat(currentIndexPathRow)
            for index in 1...views.count - 1 {
                if views[index].frame.origin.x == originX{
                    senderView = views[index] as! UIImageView
                }
            }
            senderView.alpha = 0
            scrollView.scrollRectToVisible(senderView.frame, animated: false)
                    print("init finish senderview frame\(senderView.frame)")
            configureView()
        }
    }
    func getTimer()->NSTimer?{
        guard senderView.superview is UIScrollView else{return nil}
        let controller = senderView.superview!.parentViewController as! DetailViewController
        return controller.timer
    }
    func initTimer(){
        guard senderView.superview is UIScrollView else{return}
        let controller = senderView.superview!.parentViewController as! DetailViewController
        controller.initTimer()
    }
    private func getCurrentIndexPathRow()->Int{
        if senderView.superview is UIScrollView{
            let scrollView = senderView.superview as! UIScrollView
            let index = Int(senderView.frame.origin.x / scrollView.frame.width)
            return index
        }else{
            let cell = senderView.superview?.superview as! ImageCollectionViewCell
            let collection = cell.superview as! UICollectionView
            let indexPath = collection.indexPathForCell(cell)
            return indexPath!.row
        }
    }
    private func nextIndexPathRow(currentIndexPathRow:Int)->Int{
        if currentIndexPathRow == pictures.count - 1 {
            return 0
        }else{
            return currentIndexPathRow + 1
        }
    }
    private func previousIndexPathRow(currentIndexPathRow:Int)->Int{
        if currentIndexPathRow == 0 {
            return pictures.count - 1
        }else{
            return currentIndexPathRow - 1
        }
    }
    private func getImageURLAtIndexPathRowWithOffset(indexPathRow:Int,previousOrCurrentOrNext:Int)->NSURL{
        var row:Int
        switch previousOrCurrentOrNext{
        case -1: row = previousIndexPathRow(indexPathRow)
        case 1:  row = nextIndexPathRow(indexPathRow)
        default: row = indexPathRow
        }
        return NSURL(string: pictures[row].url)!
    }
    private func getImageSizeAtIndexPathRowWithOffset(indexPathRow:Int,previousOrCurrentOrNext:Int)->CGSize{
        var row:Int
        switch previousOrCurrentOrNext{
        case -1: row = previousIndexPathRow(indexPathRow)
        case 1:  row = nextIndexPathRow(indexPathRow)
        default: row = indexPathRow
        }
        return pictures[row].size
    }
    private func configureImageView() {

        let cache = Cache<UIImage>(name: "highQualityImageCache")

        currentIndexPathRow = getCurrentIndexPathRow()
        
        let previousImageSize = getImageSizeAtIndexPathRowWithOffset(currentIndexPathRow, previousOrCurrentOrNext: -1)
        previousImageView.frame = centerFrameFromImageSize(previousImageSize)
        previousImageView.contentMode = UIViewContentMode.ScaleAspectFill
        let previousURL = getImageURLAtIndexPathRowWithOffset(currentIndexPathRow, previousOrCurrentOrNext: -1)
        cache.fetch(URL: previousURL).onSuccess {[weak self]image in
            self?.previousImageView.image = image
        }
        
        let nextImageSize = getImageSizeAtIndexPathRowWithOffset(currentIndexPathRow, previousOrCurrentOrNext: 1)
        var nextFrame = centerFrameFromImageSize(nextImageSize)
        nextFrame.origin.x += scrollView.frame.width * 2
        nextImageView.frame = nextFrame
        nextImageView.contentMode = UIViewContentMode.ScaleAspectFill
        let nextURL = getImageURLAtIndexPathRowWithOffset(currentIndexPathRow, previousOrCurrentOrNext: 1)
        cache.fetch(URL: nextURL).onSuccess {[weak self]image in
            self?.nextImageView.image = image
        }
        
        senderView.alpha = 0.0
        
        imageView.frame = originalFrameRelativeToScreen
        imageView.userInteractionEnabled = true
        imageView.contentMode = UIViewContentMode.ScaleAspectFill
        
        if let highQualityImageUrl = highQualityImageUrl {
            cache.fetch(URL: highQualityImageUrl).onSuccess {[weak self] image in
                self?.imageView.image = image
                self?.animateEntry()
            }
        } else {
            imageView.image = senderView.image
        }

        scrollView.addSubview(imageView)
        scrollView.addSubview(previousImageView)
        scrollView.addSubview(nextImageView)

    }
    private func configureConstraints() {
        var constraints: [NSLayoutConstraint] = []
        
        let views: [String: UIView] = [
            "closeButton"   : closeButton,
            "downloadButton":downloadButton
        ]
        constraints.append(NSLayoutConstraint(item: closeButton, attribute: .CenterX, relatedBy: .Equal, toItem: closeButton.superview, attribute: .CenterX, multiplier: 1.0, constant: 0))
        constraints.appendContentsOf(NSLayoutConstraint.constraintsWithVisualFormat("V:[closeButton(==64)]-40-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        constraints.appendContentsOf(NSLayoutConstraint.constraintsWithVisualFormat("H:[closeButton(==64)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        constraints.appendContentsOf(NSLayoutConstraint.constraintsWithVisualFormat("V:[downloadButton(==64)]-40-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        constraints.appendContentsOf(NSLayoutConstraint.constraintsWithVisualFormat("H:[downloadButton(==64)]-40-[closeButton]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        
        NSLayoutConstraint.activateConstraints(constraints)
    }
 
    // MARK: - Animation
    private func animateEntry() {
        self.imageView.frame.origin.x += scrollView.frame.width
        UIView.animateWithDuration(0.8, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.6, options: [UIViewAnimationOptions.BeginFromCurrentState, UIViewAnimationOptions.CurveEaseInOut], animations: {[unowned self]() -> Void in
            if let image = self.imageView.image {
                var frame = self.centerFrameFromImageSize(image.size)
                frame.origin.x += self.scrollView.frame.width
                self.imageView.frame = frame
            } else {
                fatalError("Image within UIImageView needed.")
            }
            }, completion: nil)
    
        UIView.animateWithDuration(0.4, delay: 0.03, options: [UIViewAnimationOptions.BeginFromCurrentState, UIViewAnimationOptions.CurveEaseInOut], animations: {[unowned self]() -> Void in
            self.closeButton.alpha = 0.5
            self.downloadButton.alpha = self.closeButton.alpha
            self.maskView.alpha = 1.0
            }, completion: nil)
        
        UIView.animateWithDuration(0.4, delay: 0.1, options: [UIViewAnimationOptions.BeginFromCurrentState, UIViewAnimationOptions.CurveEaseInOut], animations: {() -> Void in

            }, completion: nil)
    }
    
    private func centerFrameFromImageSize(imageSize:CGSize) -> CGRect {
        var newImageSize = imageResizeBaseOnWidth(windowBounds.size.width, oldWidth: imageSize.width, oldHeight: imageSize.height)
        newImageSize.height = min(windowBounds.size.height, newImageSize.height)
       
        return CGRectMake(0, windowBounds.size.height / 2 - newImageSize.height / 2, newImageSize.width, newImageSize.height)
    }
    
    private func imageResizeBaseOnWidth(newWidth: CGFloat, oldWidth: CGFloat, oldHeight: CGFloat) -> CGSize {
        let scaleFactor = newWidth / oldWidth
        let newHeight = oldHeight * scaleFactor
        return CGSizeMake(newWidth, newHeight)
    }
    func closeButtonTapped(sender: UIButton) {
        if scrollView.zoomScale != 1.0 {
            scrollView.setZoomScale(1.0, animated: true)
        }
        dismissViewController()
    }
    func downloadButtonTapped(sender: UIButton) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)){
            UIImageWriteToSavedPhotosAlbum(self.senderView.image!, self, "image:didFinishSavingWithError:contextInfo:", nil)
            }
    }
    func image(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo:UnsafePointer<Void>) {
        dispatch_async(dispatch_get_main_queue()) {[unowned self] in
            if error == nil {
                let icon = UIImage(named: "ImageDownloaded", inBundle: NSBundle(forClass: ImageViewer.self), compatibleWithTraitCollection: nil)
                self.downloadButton.setImage(icon, forState: .Normal)
            } else {
                
            }
        }
        
    }
    // MARK: - Misc.
    private func centerScrollViewContents() {
        let boundsSize = rootViewController.view.bounds.size
        var contentsFrame = imageView.frame
        
        if contentsFrame.size.width < boundsSize.width {
            contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0
        } else {
            contentsFrame.origin.x = 0.0
        }
        
        if contentsFrame.size.height < boundsSize.height {
            contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0
        } else {
            contentsFrame.origin.y = 0.0
        }
        
        imageView.frame = contentsFrame
    }
    private func dismissViewController() {
        initTimer()
        dispatch_async(dispatch_get_main_queue()){ [unowned self] in
            self.imageView.clipsToBounds = true
            
            UIView.animateWithDuration(0.2){[unowned self]() in
                self.closeButton.alpha = 0.0
                self.downloadButton.alpha = self.closeButton.alpha
            }
            
            var frame = self.originalFrameRelativeToScreen
            frame.origin.x += self.scrollView.frame.width

            UIView.animateWithDuration(0.8, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.6, options: [UIViewAnimationOptions.BeginFromCurrentState, UIViewAnimationOptions.CurveEaseInOut], animations: {[unowned self]() in
                
                self.imageView.frame = frame
                self.maskView.alpha = 0.0
                }, completion: {(finished) in
                    self.senderView.alpha = 1.0
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
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if scrollView.contentOffset.x > scrollView.frame.width {
            currentIndexPathRow = nextIndexPathRow(currentIndexPathRow)

            previousImageView.frame.size = imageView.frame.size
            previousImageView.frame.origin.y = imageView.frame.origin.y
            previousImageView.image = imageView.image
            
            imageView.frame.size = nextImageView.frame.size
            imageView.frame.origin.y = nextImageView.frame.origin.y
            imageView.image = nextImageView.image
            
            scrollView.setContentOffset(CGPoint(x: scrollView.frame.width, y: 0), animated: false)
            let nextImageSize = getImageSizeAtIndexPathRowWithOffset(currentIndexPathRow, previousOrCurrentOrNext: 1)
            var nextFrame = centerFrameFromImageSize(nextImageSize)
            nextFrame.origin.x += scrollView.frame.width * 2
            nextImageView.frame = nextFrame
            
            let nextURL = getImageURLAtIndexPathRowWithOffset(currentIndexPathRow, previousOrCurrentOrNext: 1)
            let cache = Cache<UIImage>(name: "highQualityImageCache")
            cache.fetch(URL: nextURL).onSuccess {[weak self]image in
                self?.nextImageView.image = image
                
            }
            initSenderView(currentIndexPathRow)
            
        }else{
            if scrollView.contentOffset.x < scrollView.frame.width {
                currentIndexPathRow = previousIndexPathRow(currentIndexPathRow)
                
                nextImageView.frame.size = imageView.frame.size
                nextImageView.frame.origin.y = imageView.frame.origin.y
                nextImageView.image = imageView.image
                
                imageView.frame.size = previousImageView.frame.size
                imageView.frame.origin.y = previousImageView.frame.origin.y
                imageView.image = previousImageView.image
                
                scrollView.setContentOffset(CGPoint(x: scrollView.frame.width, y: 0), animated: false)
                let previousImageSize = getImageSizeAtIndexPathRowWithOffset(currentIndexPathRow, previousOrCurrentOrNext: -1)
                var previousFrame = centerFrameFromImageSize(previousImageSize)
                previousFrame.origin.x += 0
                previousImageView.frame = previousFrame

                let previousURL = getImageURLAtIndexPathRowWithOffset(currentIndexPathRow, previousOrCurrentOrNext: -1)
                let cache = Cache<UIImage>(name: "highQualityImageCache")
                cache.fetch(URL: previousURL).onSuccess { [weak self]image in
                    self?.previousImageView.image = image
                }
                initSenderView(currentIndexPathRow)
            }else{
                print("offset = width")
            }
        }
    }
}
