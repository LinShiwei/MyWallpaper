//
//  ImageViewerScrollView.swift
//  MyWallpaper
//
//  Created by Linsw on 16/4/29.
//  Copyright © 2016年 Linsw. All rights reserved.
//

import UIKit
import Haneke

class ImageViewerScrollView: UIScrollView {

    var currentIndex : Int
    let pictures :[Picture]
    var originFrameRelativeToScrollView : CGRect!
    var centerImage : UIImage{
        get{
            return centerImageViewInScrollView()!.image!
        }
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    init(originFrame:CGRect,currentIndex index:Int, pictures pics:[Picture]){
        currentIndex = index
        pictures = pics
        super.init(frame:windowBounds)
        pagingEnabled = true
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        contentSize = CGSize(width: self.frame.width * 3, height: self.frame.height)
        setContentOffset(CGPoint(x: self.frame.width, y: 0), animated: false)
        configureOriginFrameToScrollView(originFrame)
        configureImageViews()
    }
    private func configureImageViews(){
        addSubview(createImageView(0, imageURL: pictures[previousIndex(currentIndex)].url))
        addSubview(createImageView(frame.width, imageURL: pictures[currentIndex].url))
        addSubview(createImageView(frame.width*2, imageURL: pictures[nextIndex(currentIndex)].url))
        centerImageViewInScrollView()?.frame = originFrameRelativeToScrollView
    }
    private func previousIndex(index:Int)->Int{
        if index == 0 {
            return pictures.count - 1
        }else{
            return index - 1
        }
    }
    private func nextIndex(index:Int)->Int{
        if index == pictures.count - 1 {
            return 0
        }else{
            return index + 1
        }
    }
    private func createImageView(originX:CGFloat,imageURL:String)->UIImageView{
        let imageView = UIImageView(frame: CGRect(x: originX, y: 0, width: frame.width, height: frame.height))
        imageView.contentMode = .ScaleAspectFill
        let cache = Cache<UIImage>(name: "highQualityImageCache")
        cache.fetch(URL: NSURL(string: imageURL)!).onSuccess { image in
            imageView.image = image
        }
        return imageView
    }
    
    private func leftImageViewInScrollView()->UIImageView?{
        for imageView in subviews where imageView.frame.origin.x == 0 {
            return imageView as? UIImageView
        }
        return nil
    }
    private func centerImageViewInScrollView()->UIImageView?{
        for imageView in subviews where (imageView.frame.origin.x >= frame.width)&&(imageView.frame.origin.x < frame.width*2) {
            return imageView as? UIImageView
        }
        return nil
    }
    private func rightImageViewInScrollView()->UIImageView?{
        for imageView in subviews where imageView.frame.origin.x == frame.width*2 {
            return imageView as? UIImageView
        }
        return nil
    }
    func configureOriginFrameToScrollView(frame:CGRect){
        originFrameRelativeToScrollView = CGRect(origin: CGPoint(x: frame.origin.x + self.frame.width, y: frame.origin.y), size: frame.size)
    }
    func scrollViewSwipeRight(){
        currentIndex = previousIndex(currentIndex)
        let rightImageView = rightImageViewInScrollView()!
        centerImageViewInScrollView()!.frame.origin.x = frame.width*2
        leftImageViewInScrollView()!.frame.origin.x = frame.width
        rightImageView.frame.origin.x = 0
        let cache = Cache<UIImage>(name: "highQualityImageCache")
        cache.fetch(URL: NSURL(string: pictures[previousIndex(currentIndex)].url)!).onSuccess { image in
            rightImageView.image = image
        }
        setContentOffset(CGPoint(x: self.frame.width, y: 0), animated: false)
    }
    func scrollViewSwipeLeft(){
        assert(leftImageViewInScrollView() != nil)
        assert(rightImageViewInScrollView() != nil)
        assert(centerImageViewInScrollView() != nil)

        currentIndex = nextIndex(currentIndex)
        let leftImageView = leftImageViewInScrollView()!
        centerImageViewInScrollView()!.frame.origin.x = 0
        rightImageViewInScrollView()!.frame.origin.x = frame.width
        leftImageView.frame.origin.x = frame.width*2
        let cache = Cache<UIImage>(name: "highQualityImageCache")
        cache.fetch(URL: NSURL(string: pictures[nextIndex(currentIndex)].url)!).onSuccess { image in
            leftImageView.image = image
        }
        setContentOffset(CGPoint(x: self.frame.width, y: 0), animated: false)
    }
    func zoomIn(){
        guard let centerImageView = centerImageViewInScrollView() else { return }
        centerImageView.frame = CGRect(x: frame.width, y: 0, width: frame.width, height: frame.height)
    }
    func zoomOut(){
        guard let centerImageView = centerImageViewInScrollView() else { return }
        centerImageView.frame = self.originFrameRelativeToScrollView
    }
}
