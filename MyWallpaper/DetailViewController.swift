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
import AVFoundation
let albumIndex = "1196824"

class DetailViewController: UIViewController{

    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var albumHomeScrollView: ImageScrollView!
    @IBOutlet weak var loadingView: LoadingView!
    @IBOutlet weak var imageCollectionView: ImageCollectionView!
    
    var pictures = [Picture]()
    var albumID :String = albumIndex{
        didSet{
            self.fetchDataWithAlbumID()
        }
    }
    //MARK: view
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchDataWithAlbumID()
        view.backgroundColor = themeBlack.detailViewBackgroundColor
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    //MARK: Get image from URL
    private func fetchDataWithAlbumID(){
        var stringURL:String = urlGetPicList
        pictures.removeAll()

        if albumID != albumIndex {
            albumHomeScrollView.alpha = 0
            albumHomeScrollView.timer?.invalidate()
            pageControl.alpha = 0
            imageCollectionView.alpha = 1
            loadingView.alpha = 1
            stringURL = stringURL + "/aid/" + albumID
        }else{
            imageCollectionView.alpha = 0
            self.albumHomeScrollView.alpha = 1
            loadingView.alpha = 1
            stringURL = stringURL + "/aid/" + albumID
        }
        let cache = Shared.JSONCache
        cache.fetch(URL: NSURL(string: stringURL)!,failure:{ error in
            dispatch_async(dispatch_get_main_queue()) {
                print("fail to fetch pic")
            }
        }).onSuccess{ [unowned self] jsonObject in
            let json = JSON(jsonObject.dictionary)
            for  picJSON in json["pic"].array! {
                if let url = picJSON["linkurl"].string,let width = picJSON["width"].string ,let height = picJSON["height"].string,let name = picJSON["name"].string {
                    let picture = Picture(name: name, url: url, size: CGSize(width: Int(width)!, height: Int(height)!))
                    self.pictures.append(picture)
                }else {
                    print("picture no found")
                }
            }
            if self.albumID != albumIndex {
                dispatch_async(dispatch_get_main_queue()) { [unowned self] in
                    self.imageCollectionView.reloadData()
                }
            }else{
                self.initScrollView()
                self.loadingView.alpha = 0
                self.pageControl.alpha = 1
            }
        }
    }
    //MARK: Home Page (Scroll view)
    func initScrollView(){
        albumHomeScrollView.delegate = self
        albumHomeScrollView.setUp(pictures: pictures)
        initPageControl()
    }
    func initPageControl(){
        pageControl.numberOfPages = pictures.count
    }
}
//MARK: ScrollView Delegate
extension DetailViewController: UIScrollViewDelegate{
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        guard let view = scrollView as? ImageScrollView else {return}
        view.initTimer()
    }
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        guard let view = scrollView as? ImageScrollView else {return}
        view.prepareForDragging()
    }
    func scrollViewDidScroll(scrollView: UIScrollView) {
        guard let view = scrollView as? ImageScrollView else {return}
        pageControl.currentPage = view.updateCurrentPage()
    }
}
//MARK: CollectionView data source
extension DetailViewController: UICollectionViewDataSource{
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pictures.count
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ImageCollectionViewCell", forIndexPath: indexPath) as! ImageCollectionViewCell
        
        let url = NSURL(string: pictures[indexPath.row].url)
        loadingView.hidden = true
        cell.loadingView.hidden = false
        cell.imageView.hnk_setImageFromURL(url!, success: {
            image in
            cell.imageView.image = image
            cell.loadingView.hidden = true
        })
        cell.imageView.setupForImageViewer(url, backgroundColor: view.backgroundColor!)
        return cell
    }
}
// MARK: WaterfallLayoutDelegate
extension DetailViewController: CollectionViewWaterfallLayoutDelegate{
    func collectionView(collectionView: UICollectionView, layout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return pictures[indexPath.row].size
    }
}
//MARK: CategorySelectionDelegate
extension DetailViewController: CategorySelectionDelegate {
    func categorySelected(albumID albumID:String) {
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
