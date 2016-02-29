//
//  DetailViewController.swift
//  MyWallpaper
//
//  Created by Linsw on 16/2/5.
//  Copyright © 2016年 Linsw. All rights reserved.
//

import UIKit
import SwiftyJSON
import Haneke
let albumIndex = "1196824"

class DetailViewController: UIViewController,UICollectionViewDataSource,UIScrollViewDelegate,CollectionViewWaterfallLayoutDelegate{

    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var albumHomeScrollView: UIScrollView!
    @IBOutlet weak var loadingView: LoadingView!
    
    @IBOutlet weak var imageCollectionView: UICollectionView!
    
    var timer:NSTimer?
    var picturesURL = [String]()
    var cellImageSize = [CGSize]()
    var albumID :String = albumIndex{
        didSet{
            self.fetchDataWithAlbumID()
        }
    }
    //MARK: view
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchDataWithAlbumID()
        self.imageCollectionView!.collectionViewLayout = getLayout()
        
        view.backgroundColor = UIColor.blackColor() 
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: CollectionView data source
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return picturesURL.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("imageCollectionViewCell", forIndexPath: indexPath) as! CollectionViewCell
        cell.backgroundColor = UIColor.whiteColor()
        let url = NSURL(string: picturesURL[indexPath.row])
        cell.loadingView.hidden = false
        cell.imageView.hnk_setImageFromURL(url!, success: {
        image in
            cell.imageView.image = image
            cell.loadingView.hidden = true
        })
        cell.imageView.setupForImageViewer(url, backgroundColor: UIColor.blackColor())
        cell.backgroundColor = UIColor.clearColor()
        return cell
    }
    
    // MARK: WaterfallLayoutDelegate
    
    func collectionView(collectionView: UICollectionView, layout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return cellImageSize[indexPath.row]
    }
    func getLayout()->CollectionViewWaterfallLayout{
        let layout = CollectionViewWaterfallLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.headerInset = UIEdgeInsetsMake(0, 0, 0, 0)
        layout.headerHeight = 0
        layout.footerHeight = 0
        layout.columnCount = 3
        layout.minimumColumnSpacing = 10
        layout.minimumInteritemSpacing = 10
        return layout
    }
    //MARK: Get image from URL
    func fetchDataWithAlbumID(){
        var stringURL:String = "http://api.tietuku.com/v2/api/getpiclist/key/a5rMlZpnZG6VnpNllmaUkpJon2NrlZVsmGdplGOXamxpmczKm2KVbMObmGSWYpY="
        picturesURL.removeAll()
        cellImageSize.removeAll()
        if let timer = timer {
            timer.invalidate()
        }
        timer = nil
        
        if albumID != albumIndex {
            albumHomeScrollView.alpha = 0
            pageControl.alpha = 0
            imageCollectionView.alpha = 1
            
            stringURL = stringURL + "/aid/" + albumID
            let cache = Shared.JSONCache
            let URL = NSURL(string: stringURL)!
            cache.removeAll()
            cache.fetch(URL: URL).onSuccess { jsonObject in

                let json = JSON(jsonObject.dictionary)
                for  picJSON in json["pic"].array! {
                    if let url = picJSON["linkurl"].string {
                        self.picturesURL.append(url)
                    }else {
                        print("linkurl key no found")
                    }
                    if let width = picJSON["width"].string ,let height = picJSON["height"].string {
                        self.cellImageSize.append(CGSize(width: Int(width)!, height: Int(height)!))
                    }else{
                        print("width and height key no found")
                    }
                }
                dispatch_async(dispatch_get_main_queue()) {
                    self.imageCollectionView.reloadData()
                }
            }
        }else{
            imageCollectionView.alpha = 0
            self.albumHomeScrollView.alpha = 1

            stringURL = stringURL + "/aid/" + albumID
            let cache = Shared.JSONCache
            let URL = NSURL(string: stringURL)!
            cache.removeAll()
            cache.fetch(URL: URL,failure:{ error in
                print("fail to fetch")
            }).onSuccess{ jsonObject in
                self.loadingView.alpha = 0
                self.pageControl.alpha = 1
                let json = JSON(jsonObject.dictionary)
                for  picJSON in json["pic"].array! {
                    if let url = picJSON["linkurl"].string {
                        self.picturesURL.append(url)
                    }else {
                        print("linkurl key no found")
                    }
                    if let width = picJSON["width"].string ,let height = picJSON["height"].string {
                        self.cellImageSize.append(CGSize(width: Int(width)!, height: Int(height)!))
                    }else{
                        print("width and height key no found")
                    }
                }
                self.initScrollView()
            }
        }
    }
    //MARK: Home Page (Scroll view)
    func initScrollView(){
        albumHomeScrollView.delegate = self
        albumHomeScrollView.contentSize = CGSizeMake(albumHomeScrollView.frame.width * CGFloat(picturesURL.count), albumHomeScrollView.frame.height)
        for index in 0...picturesURL.count-1 {
            let scrollImageView = initScrollImageView(index)
            let cache = Cache<UIImage>(name: "indexImageCache")
            let URL = NSURL(string: picturesURL[index])!
            cache.fetch(URL:URL).onSuccess{ image in
                scrollImageView.image = image
                scrollImageView.setupForImageViewer(URL, backgroundColor: UIColor.blackColor())
                self.albumHomeScrollView.addSubview(scrollImageView)
                
            }
        }
        initPageControl()
    }
    func initScrollImageView(index:Int)->UIImageView {
        let indexFloat = CGFloat(index)
        let imageView = UIImageView()
        var frame = centerFrameFromImageSize(cellImageSize[index])
        frame.origin.x += albumHomeScrollView.frame.width * indexFloat
        imageView.frame = frame
        return imageView
    }
    func initPageControl(){
        pageControl.numberOfPages = picturesURL.count
        initTimer()
    }
    func initTimer(){
        timer = NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: "moveToNextPage", userInfo: nil, repeats: true)
    }
    func moveToNextPage (){
        // Move to next page
        albumHomeScrollView.userInteractionEnabled = false
        for view in albumHomeScrollView.subviews {
            view.userInteractionEnabled = false
        }
        let pageWidth:CGFloat = CGRectGetWidth(albumHomeScrollView.frame)
        let maxWidth:CGFloat = pageWidth * CGFloat(picturesURL.count)
        let contentOffset:CGFloat = albumHomeScrollView.contentOffset.x
        
        var slideToX = contentOffset + pageWidth
        
        if  contentOffset + pageWidth == maxWidth{
            slideToX = 0
        }
        
        albumHomeScrollView.scrollRectToVisible(CGRectMake(slideToX, 0, pageWidth, CGRectGetHeight(albumHomeScrollView.frame)), animated: true)
    }

    func centerFrameFromImageSize(imageSize:CGSize) -> CGRect {
        var newImageSize = imageResizeBaseOnWidth(albumHomeScrollView.frame.size.width, oldWidth: imageSize.width, oldHeight: imageSize.height)
        newImageSize.height = min(albumHomeScrollView.frame.size.height, newImageSize.height)
        return CGRectMake(0,albumHomeScrollView.frame.size.height / 2 - newImageSize.height / 2, newImageSize.width, newImageSize.height)
    }
    
    func imageResizeBaseOnWidth(newWidth: CGFloat, oldWidth: CGFloat, oldHeight: CGFloat) -> CGSize {
        let scaleFactor = newWidth / oldWidth
        let newHeight = oldHeight * scaleFactor
        return CGSizeMake(newWidth, newHeight)
    }
    //MARK: ScrollView Delegate
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let pageWidth:CGFloat = CGRectGetWidth(scrollView.frame)
        let currentPage:CGFloat = floor((scrollView.contentOffset.x-pageWidth/2)/pageWidth)+1
        // Change the indicator
        pageControl.currentPage = Int(currentPage)
        scrollView.userInteractionEnabled = true
        for view in scrollView.subviews {
            view.userInteractionEnabled = true
        }
        initTimer()
    }
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        scrollView.userInteractionEnabled = false
        for view in scrollView.subviews {
            view.userInteractionEnabled = false
        }
        if let timer = timer {
            timer.invalidate()
        }
    }
    func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        let pageWidth:CGFloat = CGRectGetWidth(scrollView.frame)
        let currentPage:CGFloat = floor((scrollView.contentOffset.x-pageWidth/2)/pageWidth)+1
        // Change the indicator
        pageControl.currentPage = Int(currentPage)
        scrollView.userInteractionEnabled = true
        for view in scrollView.subviews {
            view.userInteractionEnabled = true
        }
    }
}
//MARK: CategorySelectionDelegate
extension DetailViewController: CategorySelectionDelegate {
    func categorySelected(albumID:String) {
        self.albumID = albumID
    }
}


//MARK: UIView extension
extension UIView {
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.nextResponder()
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}
