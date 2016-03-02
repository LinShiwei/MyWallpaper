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
    let kMinMaskViewAlpha: CGFloat = 0.3
    let kMaxImageScale: CGFloat = 2.5
    let kMinImageScale: CGFloat = 1.0
    
    var senderView: UIImageView!
    var originalFrameRelativeToScreen: CGRect!
    var rootViewController: UIViewController!
    
    var imageView = UIImageView()
    var nextImageView = UIImageView()
    var previousImageView = UIImageView()
    var currentIndexPathRow :Int = 0
    
    var highQualityImageUrl: NSURL?
    var pictures:[Picture]!
    
    let downloadButton = UIButton()
    let closeButton = UIButton()
    let windowBounds = UIScreen.mainScreen().bounds
    var scrollView = UIScrollView()
    var maskView = UIView()
    
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
   
    func configureScrollView() {
        scrollView.frame = windowBounds
        scrollView.delegate = self
        scrollView.minimumZoomScale = kMinImageScale
        scrollView.maximumZoomScale = kMaxImageScale
        scrollView.zoomScale = 1
        
        //我添加的代码
        scrollView.contentSize = CGSizeMake(scrollView.frame.width * 3, scrollView.frame.height)
        scrollView.pagingEnabled = true
        scrollView.setContentOffset(CGPoint(x: scrollView.frame.width, y: 0), animated: false)
        
        view.addSubview(scrollView)
    }
    
    func configureMaskView() {
        maskView.frame = windowBounds
        maskView.alpha = 0.0
        
        view.insertSubview(maskView, atIndex: 0)
    }
    
    func configureCloseButton() {
        closeButton.alpha = 0.0
        
        let image = UIImage(named: "ImageClose", inBundle: NSBundle(forClass: ImageViewer.self), compatibleWithTraitCollection: nil)
        
        closeButton.setImage(image, forState: .Normal)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.addTarget(self, action: "closeButtonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(closeButton)
        
        view.setNeedsUpdateConstraints()
    }
    func configureDownloadButton() {
        downloadButton.alpha = 0.0
        let image = UIImage(named: "ImageDownload", inBundle: NSBundle(forClass: ImageViewer.self), compatibleWithTraitCollection: nil)
        
        downloadButton.setImage(image, forState: .Normal)
        downloadButton.translatesAutoresizingMaskIntoConstraints = false
        downloadButton.addTarget(self, action: "downloadButtonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(downloadButton)
        
        view.setNeedsUpdateConstraints()
    }
    
    func configureView() {
        var originalFrame = senderView.convertRect(windowBounds, toView: nil)
        originalFrame.size = senderView.frame.size
        
        originalFrameRelativeToScreen = originalFrame
    
    }
    func initSenderView(currentIndexPathRow:Int){

        if !(self.senderView.superview is UIScrollView) {
            senderView.alpha = 1.0
            let cell = self.senderView.superview?.superview as! ImageCollectionViewCell
            let collection = cell.superview as! UICollectionView
            let indexPath = NSIndexPath(forRow: currentIndexPathRow, inSection: 0)
            collection.scrollToItemAtIndexPath(indexPath, atScrollPosition: .CenteredVertically, animated: false)
            let senderCell = collection.cellForItemAtIndexPath(indexPath) as! ImageCollectionViewCell

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
        if senderView.superview is UIScrollView {
            let controller = senderView.superview!.parentViewController as! DetailViewController
            return controller.timer
        }else{
            return nil
        }
    }
    func initTimer(){
        if senderView.superview is UIScrollView {
            let controller = senderView.superview!.parentViewController as! DetailViewController
            controller.initTimer()
        }else{
        }
    }
    func getCurrentIndexPathRow()->Int{
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
    func nextIndexPathRow(currentIndexPathRow:Int)->Int{
        if currentIndexPathRow == pictures.count - 1 {
            return 0
        }else{
            return currentIndexPathRow + 1
        }
    }
    func previousIndexPathRow(currentIndexPathRow:Int)->Int{
        if currentIndexPathRow == 0 {
            return pictures.count - 1
        }else{
            return currentIndexPathRow - 1
        }
    }
    func getImageURLAtIndexPathRowWithOffset(indexPathRow:Int,previousOrCurrentOrNext:Int)->NSURL{
        var row:Int
        switch previousOrCurrentOrNext{
        case -1: row = previousIndexPathRow(indexPathRow)
        case 1:  row = nextIndexPathRow(indexPathRow)
        default: row = indexPathRow
        }

        return NSURL(string: pictures[row].url)!
    }
    func getImageSizeAtIndexPathRowWithOffset(indexPathRow:Int,previousOrCurrentOrNext:Int)->CGSize{
        var row:Int
        switch previousOrCurrentOrNext{
        case -1: row = previousIndexPathRow(indexPathRow)
        case 1:  row = nextIndexPathRow(indexPathRow)
        default: row = indexPathRow
        }
        return pictures[row].size
    }
    
    func configureImageView() {

        let cache = Cache<UIImage>(name: "highQualityImageCache")

        currentIndexPathRow = getCurrentIndexPathRow()
        
        let previousImageSize = getImageSizeAtIndexPathRowWithOffset(currentIndexPathRow, previousOrCurrentOrNext: -1)
        previousImageView.frame = centerFrameFromImageSize(previousImageSize)
        previousImageView.contentMode = UIViewContentMode.ScaleAspectFill
        let previousURL = getImageURLAtIndexPathRowWithOffset(currentIndexPathRow, previousOrCurrentOrNext: -1)
        cache.fetch(URL: previousURL).onSuccess { image in
            self.previousImageView.image = image
        }
        
        let nextImageSize = getImageSizeAtIndexPathRowWithOffset(currentIndexPathRow, previousOrCurrentOrNext: 1)
        var nextFrame = centerFrameFromImageSize(nextImageSize)
        nextFrame.origin.x += scrollView.frame.width * 2
        nextImageView.frame = nextFrame
        nextImageView.contentMode = UIViewContentMode.ScaleAspectFill
        let nextURL = getImageURLAtIndexPathRowWithOffset(currentIndexPathRow, previousOrCurrentOrNext: 1)
        cache.fetch(URL: nextURL).onSuccess { image in
            self.nextImageView.image = image
        }
        
        senderView.alpha = 0.0
        
        imageView.frame = originalFrameRelativeToScreen
        imageView.userInteractionEnabled = true
        imageView.contentMode = UIViewContentMode.ScaleAspectFill
        
        if let highQualityImageUrl = highQualityImageUrl {
            cache.fetch(URL: highQualityImageUrl).onSuccess { image in
                self.imageView.image = image
                self.animateEntry()
            }
        } else {
            imageView.image = senderView.image
        }

        scrollView.addSubview(imageView)
        scrollView.addSubview(previousImageView)
        scrollView.addSubview(nextImageView)

    }
    
    func configureConstraints() {
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
    func animateEntry() {
        self.imageView.frame.origin.x += scrollView.frame.width
        UIView.animateWithDuration(0.8, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.6, options: [UIViewAnimationOptions.BeginFromCurrentState, UIViewAnimationOptions.CurveEaseInOut], animations: {() -> Void in
            if let image = self.imageView.image {
                var frame = self.centerFrameFromImageSize(image.size)
                frame.origin.x += self.scrollView.frame.width
                self.imageView.frame = frame
            } else {
                fatalError("Image within UIImageView needed.")
            }
            }, completion: nil)
    
        UIView.animateWithDuration(0.4, delay: 0.03, options: [UIViewAnimationOptions.BeginFromCurrentState, UIViewAnimationOptions.CurveEaseInOut], animations: {() -> Void in
            self.closeButton.alpha = 0.5
            self.downloadButton.alpha = self.closeButton.alpha
            self.maskView.alpha = 1.0
            }, completion: nil)
        
        UIView.animateWithDuration(0.4, delay: 0.1, options: [UIViewAnimationOptions.BeginFromCurrentState, UIViewAnimationOptions.CurveEaseInOut], animations: {() -> Void in

            }, completion: nil)
    }
    
    func centerFrameFromImageSize(imageSize:CGSize) -> CGRect {
        var newImageSize = imageResizeBaseOnWidth(windowBounds.size.width, oldWidth: imageSize.width, oldHeight: imageSize.height)
        newImageSize.height = min(windowBounds.size.height, newImageSize.height)
       
        return CGRectMake(0, windowBounds.size.height / 2 - newImageSize.height / 2, newImageSize.width, newImageSize.height)
    }
    
    func imageResizeBaseOnWidth(newWidth: CGFloat, oldWidth: CGFloat, oldHeight: CGFloat) -> CGSize {
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
        if error == nil {
            let icon = UIImage(named: "ImageDownloaded", inBundle: NSBundle(forClass: ImageViewer.self), compatibleWithTraitCollection: nil)
            downloadButton.setImage(icon, forState: .Normal)
//            downloadButton.enabled = false
        } else {
            
        }
    }
    // MARK: - Misc.
    func centerScrollViewContents() {
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
    func dismissViewController() {
        initTimer()
        dispatch_async(dispatch_get_main_queue(), {
            self.imageView.clipsToBounds = true
            
            UIView.animateWithDuration(0.2, animations: {() in
                self.closeButton.alpha = 0.0
                self.downloadButton.alpha = self.closeButton.alpha
            })
            
            var frame = self.originalFrameRelativeToScreen
            frame.origin.x += self.scrollView.frame.width

            UIView.animateWithDuration(0.8, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.6, options: [UIViewAnimationOptions.BeginFromCurrentState, UIViewAnimationOptions.CurveEaseInOut], animations: {() in
                
                self.imageView.frame = frame
                self.maskView.alpha = 0.0
                }, completion: {(finished) in
                    self.willMoveToParentViewController(nil)
                    self.view.removeFromSuperview()
                    self.removeFromParentViewController()
                    self.senderView.alpha = 1.0
            })
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
            cache.fetch(URL: nextURL).onSuccess { image in
                self.nextImageView.image = image
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
                cache.fetch(URL: previousURL).onSuccess { image in
                    self.previousImageView.image = image
                }
                initSenderView(currentIndexPathRow)
            }else{
                print("offset = width")
            }
        }
    }
}
