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
    
    var panGesture: UIPanGestureRecognizer!
    var panOrigin: CGPoint!
    var highQualityImageUrl: NSURL?
    
    var isAnimating = false
    var isLoaded = false
    
    let downloadButton = UIButton()
    let closeButton = UIButton()
    let windowBounds = UIScreen.mainScreen().bounds
    var scrollView = UIScrollView()
    var maskView = UIView()
    
    // MARK: - Lifecycle methods
    init(senderView: UIImageView,highQualityImageUrl: NSURL?, backgroundColor: UIColor) {
        self.senderView = senderView
        self.highQualityImageUrl = highQualityImageUrl
     
        rootViewController = UIApplication.sharedApplication().keyWindow!.rootViewController!
        maskView.backgroundColor = backgroundColor
        
        super.init(nibName: nil, bundle: nil)
        
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
        originalFrame.origin = CGPointMake(originalFrame.origin.x, originalFrame.origin.y)
        originalFrame.size = senderView.frame.size

        originalFrameRelativeToScreen = originalFrame
        
//        UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: UIStatusBarAnimation.Slide)
    }
    func initSenderView(currentIndexPathRow:Int){
        if !(self.senderView.superview is UIScrollView) {
            senderView.alpha = 1.0
            let cell = self.senderView.superview?.superview as! CollectionViewCell
            let collection = cell.superview as! UICollectionView
            let indexPath = NSIndexPath(forRow: currentIndexPathRow, inSection: 0)
            let senderCell = collection.cellForItemAtIndexPath(indexPath) as! CollectionViewCell
            senderView = senderCell.imageView
            senderView.alpha = 0
            collection.scrollToItemAtIndexPath(indexPath, atScrollPosition: .CenteredVertically, animated: false)
            configureView()
        }else{
            
        }
        
    }
    func getCurrentIndexPathRow()->Int{
        
        let cell = self.senderView.superview?.superview as! CollectionViewCell
        let collection = cell.superview as! UICollectionView
        let indexPath = collection.indexPathForCell(cell)
        return indexPath!.row
    }
    func nextIndexPathRow(currentIndexPathRow:Int)->Int{
        let cell = self.senderView.superview?.superview as! CollectionViewCell
        let collection = cell.superview as! UICollectionView
        let controller = collection.parentViewController as! DetailViewController
        if currentIndexPathRow == controller.picturesURL.count - 1 {
            return 0
        }else{
            return currentIndexPathRow + 1
        }
    }
    func previousIndexPathRow(currentIndexPathRow:Int)->Int{
        let cell = self.senderView.superview?.superview as! CollectionViewCell
        let collection = cell.superview as! UICollectionView
        let controller = collection.parentViewController as! DetailViewController
        if currentIndexPathRow == 0 {
            return controller.picturesURL.count - 1
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
        let cell = self.senderView.superview?.superview as! CollectionViewCell
        let collection = cell.superview as! UICollectionView
        let controller = collection.parentViewController as! DetailViewController
        return NSURL(string: controller.picturesURL[row])!

    }
    func getImageSizeAtIndexPathRowWithOffset(indexPathRow:Int,previousOrCurrentOrNext:Int)->CGSize{
        var row:Int
        switch previousOrCurrentOrNext{
        case -1: row = previousIndexPathRow(indexPathRow)
        case 1:  row = nextIndexPathRow(indexPathRow)
        default: row = indexPathRow
        }
        let cell = self.senderView.superview?.superview as! CollectionViewCell
        let collection = cell.superview as! UICollectionView
        let controller = collection.parentViewController as! DetailViewController
        
        return controller.cellImageSize[row]
    }
    
    func configureImageView() {
        let cache = Cache<UIImage>(name: "highQualityImageCache")

        currentIndexPathRow = getCurrentIndexPathRow()
        
        let previousImageSize = getImageSizeAtIndexPathRowWithOffset(currentIndexPathRow, previousOrCurrentOrNext: -1)
        previousImageView.frame = centerFrameFromImageSize(previousImageSize)
        previousImageView.contentMode = UIViewContentMode.ScaleAspectFit
        let previousURL = getImageURLAtIndexPathRowWithOffset(currentIndexPathRow, previousOrCurrentOrNext: -1)
        cache.fetch(URL: previousURL).onSuccess { image in
            self.previousImageView.image = image
        }
        
        let nextImageSize = getImageSizeAtIndexPathRowWithOffset(currentIndexPathRow, previousOrCurrentOrNext: 1)
        var nextFrame = centerFrameFromImageSize(nextImageSize)
        nextFrame.origin.x += scrollView.frame.width * 2
        nextImageView.frame = nextFrame
        nextImageView.contentMode = UIViewContentMode.ScaleAspectFit
        let nextURL = getImageURLAtIndexPathRowWithOffset(currentIndexPathRow, previousOrCurrentOrNext: 1)
        cache.fetch(URL: nextURL).onSuccess { image in
            self.nextImageView.image = image
        }
        
        senderView.alpha = 0.0
        
        imageView.frame = originalFrameRelativeToScreen
        imageView.userInteractionEnabled = true
        imageView.contentMode = UIViewContentMode.ScaleAspectFit
        
        if let highQualityImageUrl = highQualityImageUrl {
            cache.fetch(URL: highQualityImageUrl).onSuccess { image in
                self.imageView.image = image
                self.animateEntry()
            }
//            imageView.hnk_setImageFromURL(highQualityImageUrl, placeholder: senderView.image, format: nil, failure: nil, success: nil)
        } else {
            imageView.image = senderView.image
        }

        scrollView.addSubview(imageView)
        scrollView.addSubview(previousImageView)
        scrollView.addSubview(nextImageView)
//        animateEntry()
//        addPanGestureToView()
        addGestures()
        centerScrollViewContents()
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
    
    // MARK: - Gestures
//    func addPanGestureToView() {
//        panGesture = UIPanGestureRecognizer(target: self, action: "gestureRecognizerDidPan:")
//        panGesture.cancelsTouchesInView = false
//        panGesture.delegate = self
//        
//        imageView.addGestureRecognizer(panGesture)
//    }
    
    func addGestures() {
        let singleTapRecognizer = UITapGestureRecognizer(target: self, action: "didSingleTap:")
        singleTapRecognizer.numberOfTapsRequired = 1
        singleTapRecognizer.numberOfTouchesRequired = 1
        scrollView.addGestureRecognizer(singleTapRecognizer)
        
        let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: "didDoubleTap:")
        doubleTapRecognizer.numberOfTapsRequired = 2
        doubleTapRecognizer.numberOfTouchesRequired = 1
        scrollView.addGestureRecognizer(doubleTapRecognizer)
        
        singleTapRecognizer.requireGestureRecognizerToFail(doubleTapRecognizer)
    }
    
    func zoomInZoomOut(point: CGPoint) {
        let newZoomScale = scrollView.zoomScale > (scrollView.maximumZoomScale / 2) ? scrollView.minimumZoomScale : scrollView.maximumZoomScale
        
        let scrollViewSize = scrollView.bounds.size
        let w = scrollViewSize.width / newZoomScale
        let h = scrollViewSize.height / newZoomScale
        let x = point.x - (w / 2.0)
        let y = point.y - (h / 2.0)
        
        let rectToZoomTo = CGRectMake(x, y, w, h)
        scrollView.zoomToRect(rectToZoomTo, animated: true)
    }
    
    // MARK: - Animation
    func animateEntry() {
        self.imageView.frame.origin.x += scrollView.frame.width
        UIView.animateWithDuration(0.8, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.6, options: [UIViewAnimationOptions.BeginFromCurrentState, UIViewAnimationOptions.CurveEaseInOut], animations: {() -> Void in
            if let image = self.imageView.image {
                var frame = self.centerFrameFromImageSize(image.size)
                frame.origin.x += self.scrollView.frame.width
                self.imageView.frame = frame
//                self.imageView.frame.origin.x += self.scrollView.frame.width
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
            self.view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.1, 1.1)
            self.rootViewController.view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.95, 0.95)
            }, completion: nil)
    }
    
    func centerFrameFromImageSize(imageSize:CGSize) -> CGRect {
        var newImageSize = imageResizeBaseOnWidth(windowBounds.size.width, oldWidth: imageSize.width, oldHeight: imageSize.height)
        newImageSize.height = min(windowBounds.size.height, newImageSize.height)
//        return CGRectMake(0, windowBounds.size.height / 2 - newImageSize.height / 2, newImageSize.width, newImageSize.height)
        return CGRectMake(0, windowBounds.size.height / 2 - newImageSize.height / 2, newImageSize.width, newImageSize.height)
    }
    
    func imageResizeBaseOnWidth(newWidth: CGFloat, oldWidth: CGFloat, oldHeight: CGFloat) -> CGSize {
        let scaleFactor = newWidth / oldWidth
        let newHeight = oldHeight * scaleFactor
        return CGSizeMake(newWidth, newHeight)
    }
    
    // MARK: - Actions
    /// 以下这个函数完成的是拖移照片的手势响应函数
    /*
    func gestureRecognizerDidPan(recognizer: UIPanGestureRecognizer) {
        if scrollView.zoomScale != 1.0 || isAnimating {
            return
        }
        
        senderView.alpha = 0.0
        
        scrollView.bounces = false
        let windowSize = maskView.bounds.size
        let currentPoint = panGesture.translationInView(scrollView)
        let y = currentPoint.y + panOrigin.y
        
        imageView.frame.origin = CGPointMake(currentPoint.x + panOrigin.x, y)
        
        let yDiff = abs((y + imageView.frame.size.height / 2) - windowSize.height / 2)
        maskView.alpha = max(1 - yDiff / (windowSize.height / 0.95), kMinMaskViewAlpha)
        closeButton.alpha = max(1 - yDiff / (windowSize.height / 0.95), kMinMaskViewAlpha) / 4
        downloadButton.alpha = closeButton.alpha
        if (panGesture.state == UIGestureRecognizerState.Ended || panGesture.state == UIGestureRecognizerState.Cancelled) && scrollView.zoomScale == 1.0 {
            if maskView.alpha < 0.85 {
                dismissViewController()
            } else {
                rollbackViewController()
            }
        }
    }
    */
    func didSingleTap(recognizer: UITapGestureRecognizer) {
        if scrollView.zoomScale == 1.0 {
            dismissViewController()
        } else {
            scrollView.setZoomScale(1.0, animated: true)
        }
    }
    
    func didDoubleTap(recognizer: UITapGestureRecognizer) {
        let pointInView = recognizer.locationInView(imageView)
        zoomInZoomOut(pointInView)
    }
    
    func closeButtonTapped(sender: UIButton) {
        if scrollView.zoomScale != 1.0 {
            scrollView.setZoomScale(1.0, animated: true)
        }
        print("closeButtonTap")
        dismissViewController()
    }
    func downloadButtonTapped(sender: UIButton) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)){
            UIImageWriteToSavedPhotosAlbum(self.senderView.image!, self, "image:didFinishSavingWithError:contextInfo:", nil)
            }
        print("downloadButtonTap")
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
  /*
    func rollbackViewController() {
        isAnimating = true
        UIView.animateWithDuration(0.8, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.6, options: [UIViewAnimationOptions.BeginFromCurrentState, UIViewAnimationOptions.CurveEaseInOut], animations: {() in
            if let image = self.imageView.image {
                self.imageView.frame = self.centerFrameFromImage(image)
            } else {
                fatalError("Image within UIImageView needed.")
            }
            self.maskView.alpha = 1.0
            self.closeButton.alpha = 0.5
            self.downloadButton.alpha = self.closeButton.alpha
            }, completion: {(finished) in
                self.isAnimating = false
        })
    }
    */
    func dismissViewController() {
        isAnimating = true
        dispatch_async(dispatch_get_main_queue(), {
            self.imageView.clipsToBounds = true
            
            UIView.animateWithDuration(0.2, animations: {() in
                self.closeButton.alpha = 0.0
                self.downloadButton.alpha = self.closeButton.alpha

            })
            
            UIView.animateWithDuration(0.8, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.6, options: [UIViewAnimationOptions.BeginFromCurrentState, UIViewAnimationOptions.CurveEaseInOut], animations: {() in
                var frame = self.originalFrameRelativeToScreen
                frame.origin.x += self.scrollView.frame.width
                self.imageView.frame = frame
                self.rootViewController.view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0)
                self.view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0)
                self.maskView.alpha = 0.0
//                UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.None)
                }, completion: {(finished) in
                    self.willMoveToParentViewController(nil)
                    self.view.removeFromSuperview()
                    self.removeFromParentViewController()
                    self.senderView.alpha = 1.0
                    self.isAnimating = false
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

// MARK: - GestureRecognizer delegate
extension ImageViewer: UIGestureRecognizerDelegate {
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        panOrigin = imageView.frame.origin
        gestureRecognizer.enabled = true
        return !isAnimating
    }
}

// MARK: - ScrollView delegate
extension ImageViewer: UIScrollViewDelegate {
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(scrollView: UIScrollView) {
        isAnimating = true
        centerScrollViewContents()
    }
    
    func scrollViewDidEndZooming(scrollView: UIScrollView, withView view: UIView?, atScale scale: CGFloat) {
        isAnimating = false
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if scrollView.contentOffset.x > scrollView.frame.width {
            print("offset > width")
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
                print("offset <width")
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
