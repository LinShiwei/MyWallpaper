//
//  ImageScrollView.swift
//  MyWallpaper
//
//  Created by Linsw on 16/4/30.
//  Copyright © 2016年 Linsw. All rights reserved.
//

import UIKit
import AVFoundation
import Haneke
class ImageScrollView: UIScrollView {

    var pictures = [Picture](){
        didSet{
            guard pictures.count != 0 else {return}
            for view in self.subviews where view is UIImageView {
                view.removeFromSuperview()
            }
            contentSize = CGSize(width: frame.width * CGFloat(pictures.count), height: frame.height)
            for index in 0...pictures.count-1 {
                let scrollImageView = createScrollImageView(index)
                let cache = Cache<UIImage>(name: "indexImageCache")
                let URL = NSURL(string: pictures[index].url)!
                
                cache.fetch(URL:URL).onSuccess{ [unowned self] image in
                    scrollImageView.image = image
                    scrollImageView.setupForImageViewer(URL, backgroundColor: self.backgroundColor!)
                    self.addSubview(scrollImageView)
                }
            }
            initTimer()
        }
    }
    var currentIndex = 0
    var timer:NSTimer?

    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
        pagingEnabled = true
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        backgroundColor = themeBlack.detailViewBackgroundColor
    }

    func initTimer(){
        guard timer == nil || timer?.valid == false else{ return}
        timer = NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: #selector(ImageScrollView.moveToNextPage), userInfo: nil, repeats: true)
    }
    
    func moveToNextPage (){
        userInteractionEnabled = false
        for view in subviews {
            view.userInteractionEnabled = false
        }
        let pageWidth:CGFloat = frame.width
        let maxWidth:CGFloat = pageWidth * CGFloat(pictures.count)
        let contentOffset:CGFloat = self.contentOffset.x
        
        var slideToX = contentOffset + pageWidth
        
        if  contentOffset + pageWidth == maxWidth{
            slideToX = 0
        }
        scrollRectToVisible(CGRect(x: slideToX, y: 0, width: pageWidth, height: frame.height), animated: true)
    }
    
    func prepareForDragging() {
        userInteractionEnabled = false
        for view in subviews {
            view.userInteractionEnabled = false
        }
        if let timer = timer {
            timer.invalidate()
        }
    }
    
    func updateCurrentPage()->Int{
        userInteractionEnabled = true
        for view in subviews {
            view.userInteractionEnabled = true
        }
        let pageWidth:CGFloat = frame.width
        let currentPage:Int = Int(floor((self.contentOffset.x-pageWidth/2)/pageWidth)+1)
        currentIndex = currentPage
        assert(0..<pictures.count ~= currentPage)
        return currentPage
    }
    
    private func createScrollImageView(index:Int)->UIImageView {
        var frame = centerFrameFromImageSize(pictures[index].size)
        frame.origin.x += self.frame.width * CGFloat(index)
       
        return UIImageView(frame: frame)
    }
    
    private func centerFrameFromImageSize(imageSize:CGSize) -> CGRect {
        return AVMakeRectWithAspectRatioInsideRect(imageSize, CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height))
    }
}
