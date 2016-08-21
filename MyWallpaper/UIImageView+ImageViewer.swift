//
//  UIImageView+ImageViewer.swift
//  ImageViewer
//
//  Created by Tan Nghia La on 03.05.15.
//  Copyright (c) 2015 Tan Nghia La. All rights reserved.
//

import Foundation
import UIKit

public extension UIImageView {
    public func setupForImageViewer(highQualityImageUrl: NSURL? = nil, backgroundColor: UIColor = themeBlack.splitViewBackgroundColor) {
        userInteractionEnabled = true
        addGestureRecognizer(ImageViewerTapGestureRecognizer(target: self, action: #selector(UIImageView.didTap(_:)), highQualityImageUrl: highQualityImageUrl, backgroundColor: backgroundColor))
    }
    internal func didTap(recognizer: ImageViewerTapGestureRecognizer) {
        var pictures=[Picture]()
        var currentIndex : Int
        if self.superview is ImageScrollView {
            let scrollView = self.superview as! ImageScrollView
            scrollView.timer?.invalidate()
            pictures = scrollView.pictures
            currentIndex = scrollView.currentIndex
        }else{
            let cell = self.superview?.superview as! ImageCollectionViewCell
            let collectionView = cell.superview as! UICollectionView
            currentIndex = collectionView.indexPathForCell(cell)!.row
            let controller = collectionView.parentViewController
            if controller is DetailViewController {
                pictures = (controller as! DetailViewController).pictures
            }else{
                pictures = (controller as! SearchPage).filteredPictures
            }
        }
        ImageViewer(senderView: self, currentIndex:currentIndex, pictures:pictures, backgroundColor: recognizer.backgroundColor).presentFromRootViewController()
    }
}

class ImageViewerTapGestureRecognizer: UITapGestureRecognizer {
    var highQualityImageUrl: NSURL?
    var backgroundColor: UIColor!
    init(target: AnyObject, action: Selector, highQualityImageUrl: NSURL?, backgroundColor: UIColor) {
        self.highQualityImageUrl = highQualityImageUrl
        self.backgroundColor = backgroundColor
        super.init(target: target, action: action)
    }
}