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

    var pictures = [Picture]()
    var currentIndex = 0
    var timer:NSTimer?

    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
    }
    func setUp(pictures pics:[Picture]){
        self.pictures = pics
        configureView()
        initTimer()
    }
    private func configureView(){
        pagingEnabled = true
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        backgroundColor = themeBlack.detailViewBackgroundColor  
        contentSize = CGSize(width: frame.width * CGFloat(pictures.count), height: frame.height)
        for index in 0...pictures.count-1 {
            let scrollImageView = initScrollImageView(index)
            let cache = Cache<UIImage>(name: "indexImageCache")
            let URL = NSURL(string: pictures[index].url)!
            
            cache.fetch(URL:URL).onSuccess{ [unowned self] image in
                scrollImageView.image = image
                scrollImageView.setupForImageViewer(URL, backgroundColor: self.backgroundColor!)
                self.addSubview(scrollImageView)
            }
        }
    }
    func initTimer(){
        guard timer == nil || timer?.valid == false else{ return}
        timer = NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: "moveToNextPage", userInfo: nil, repeats: true)
        
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
        assert(currentPage < pictures.count)
        assert(currentPage >= 0)
        print(currentPage)
        return currentPage
    }
    private func initScrollImageView(index:Int)->UIImageView {
        var frame = centerFrameFromImageSize(pictures[index].size)
        frame.origin.x += self.frame.width * CGFloat(index)
        let imageView = UIImageView()
        imageView.frame = frame
        return imageView
    }
    private func centerFrameFromImageSize(imageSize:CGSize) -> CGRect {
        return AVMakeRectWithAspectRatioInsideRect(imageSize, frame)
    }
}
