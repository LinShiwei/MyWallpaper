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
    @IBOutlet weak var albumIndexScrollView: UIScrollView!
    @IBOutlet weak var switchController: UISwitch!
    
    @IBOutlet weak var imageCollectionView: UICollectionView!
    
//    let windowBounds = UIScreen.mainScreen().bounds
    var timer:NSTimer?
    var picturesURL = [String]()
    var cellImageSize = [CGSize]()
    
    var indexPicturesURL = [String]()
    var indexImageSize = [CGSize]()
    
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
        cell.imageView.hnk_setImageFromURL(url!)
        cell.imageView.setupForImageViewer(url, backgroundColor: UIColor.blackColor())
        return cell
    }
    
    // MARK: WaterfallLayoutDelegate
    
    func collectionView(collectionView: UICollectionView, layout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return cellImageSize[indexPath.row]
    }
    
    //MARK: Get image from URL
    func fetchDataWithAlbumID(){
        var stringURL:String = "http://api.tietuku.com/v2/api/getpiclist/key/a5rMlZpnZG6VnpNllmaUkpJon2NrlZVsmGdplGOXamxpmczKm2KVbMObmGSWYpY="
        //building NSURL
        picturesURL.removeAll()
        cellImageSize.removeAll()
        indexPicturesURL.removeAll()
        indexImageSize.removeAll()
        if let timer = timer {
            timer.invalidate()
        }
        timer = nil


        if albumID != albumIndex {
            imageCollectionView.alpha = 1
            switchController.alpha = 0
            albumIndexScrollView.alpha = 0
            pageControl.alpha = 0
            stringURL = stringURL + "/aid/" + albumID
            let cache = Shared.JSONCache
            let URL = NSURL(string: stringURL)!
            
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
//                print(" detail picURL \(self.cellImageSize)")
                dispatch_async(dispatch_get_main_queue()) {
                    self.imageCollectionView.reloadData()
                }
            }
        }else{
            imageCollectionView.alpha = 0
            switchController.alpha = 1
            albumIndexScrollView.alpha = 1
            pageControl.alpha = 1
            stringURL = stringURL + "/aid/" + albumID
            let cache = Shared.JSONCache
            let URL = NSURL(string: stringURL)!
            cache.fetch(URL: URL).onSuccess{ jsonObject in
                let json = JSON(jsonObject.dictionary)
                for  picJSON in json["pic"].array! {
                    if let url = picJSON["linkurl"].string {
                        self.indexPicturesURL.append(url)
                    }else {
                        print("linkurl key no found")
                    }
                    if let width = picJSON["width"].string ,let height = picJSON["height"].string {
                        self.indexImageSize.append(CGSize(width: Int(width)!, height: Int(height)!))
                    }else{
                        print("width and height key no found")
                    }
                }
                self.initScrollView()
            }

        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    func getLayout()->CollectionViewWaterfallLayout{
        let layout = CollectionViewWaterfallLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.headerInset = UIEdgeInsetsMake(0, 0, 0, 0)
        layout.headerHeight = 0
        layout.footerHeight = 0
        layout.columnCount = 3
        layout.minimumColumnSpacing = 0
        layout.minimumInteritemSpacing = 0
        return layout
    }
    func initPageControl(){
        pageControl.numberOfPages = indexPicturesURL.count - 1
        timer = NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: "moveToNextPage", userInfo: nil, repeats: true)
//        var constraints: [NSLayoutConstraint] = []
//        
//        let views: [String: UIView] = [
//            "pageControl"   : pageControl
//        ]
//        constraints.append(NSLayoutConstraint(item: pageControl, attribute: .CenterX, relatedBy: .Equal, toItem: albumIndexScrollView, attribute: .CenterX, multiplier: 1.0, constant: 0))
//        constraints.appendContentsOf(NSLayoutConstraint.constraintsWithVisualFormat("V:[pageControl]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
//        NSLayoutConstraint.activateConstraints(constraints)

    }
    func moveToNextPage (){
        
        // Move to next page
        let pageWidth:CGFloat = CGRectGetWidth(albumIndexScrollView.frame)
        let maxWidth:CGFloat = pageWidth * CGFloat(indexPicturesURL.count)
        let contentOffset:CGFloat = albumIndexScrollView.contentOffset.x
        
        var slideToX = contentOffset + pageWidth
        
        if  contentOffset + pageWidth == maxWidth{
            slideToX = 0
        }
        albumIndexScrollView.scrollRectToVisible(CGRectMake(slideToX, 0, pageWidth, CGRectGetHeight(albumIndexScrollView.frame)), animated: true)
    }
    func initScrollView(){
        albumIndexScrollView.delegate = self
        albumIndexScrollView.contentSize = CGSizeMake(albumIndexScrollView.frame.width * CGFloat(indexPicturesURL.count), albumIndexScrollView.frame.height)
        for index in 0...indexPicturesURL.count-1 {
            let scrollImageView = initScrollImageView(index)
            let cache = Cache<UIImage>(name: "highQualityImageCache")
            let URL = NSURL(string: indexPicturesURL[index])!
            cache.fetch(URL:URL).onSuccess{ image in
                scrollImageView.image = image
                self.albumIndexScrollView.addSubview(scrollImageView)
                if index == 0 {
                    print("frame")
                    print(self.albumIndexScrollView.frame)
                    print(scrollImageView.frame)
                }

            }
        }
        
        initPageControl()

    }
    func initScrollImageView(index:Int)->UIImageView {
        let indexFloat = CGFloat(index)
        let imageView = UIImageView()
        var frame = centerFrameFromImageSize(indexImageSize[index])
        frame.origin.x += albumIndexScrollView.frame.width * indexFloat
        imageView.frame = frame
        return imageView
    }
    func centerFrameFromImageSize(imageSize:CGSize) -> CGRect {
        var newImageSize = imageResizeBaseOnWidth(albumIndexScrollView.frame.size.width, oldWidth: imageSize.width, oldHeight: imageSize.height)
        newImageSize.height = min(albumIndexScrollView.frame.size.height, newImageSize.height)
        return CGRectMake(0,albumIndexScrollView.frame.size.height / 2 - newImageSize.height / 2, newImageSize.width, newImageSize.height)
    }
    
    func imageResizeBaseOnWidth(newWidth: CGFloat, oldWidth: CGFloat, oldHeight: CGFloat) -> CGSize {
        let scaleFactor = newWidth / oldWidth
        let newHeight = oldHeight * scaleFactor
        return CGSizeMake(newWidth, newHeight)
    }
    //MARK: ScrollView Delegate
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let pageWidth:CGFloat = CGRectGetWidth(scrollView.frame)
        let currentPage:CGFloat = floor((scrollView.contentOffset.x-pageWidth/2)/pageWidth)+1
        // Change the indicator
        pageControl.currentPage = Int(currentPage)
        

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
