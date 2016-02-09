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
class DetailViewController: UIViewController,UICollectionViewDataSource,CollectionViewWaterfallLayoutDelegate{

    
    @IBOutlet weak var imageCollectionView: UICollectionView!
    
    var picturesURL = [String]()
    var cellImageSize = [CGSize]()
    
    var albumID :String?{
        didSet{
            self.fetchDataWithAlbumID()
        }
    }
    //MARK: view init
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
        if let id = albumID {
            stringURL = stringURL + "/aid/" + id
            let cache = Shared.JSONCache
            let URL = NSURL(string: stringURL)!
            
            cache.fetch(URL: URL).onSuccess { jsonObject in
                let json = JSON(jsonObject.dictionary)
                self.picturesURL.removeAll()
                self.cellImageSize.removeAll()
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
}
extension DetailViewController: CategorySelectionDelegate {
    func categorySelected(albumID:String) {
        self.albumID = albumID
    }
}
// MARK: Swipe Gesture
extension ImageViewer {
    func addSwipeGestureRecognizer(){
        let swipeRightGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "didSwipeRight:")
        swipeRightGestureRecognizer.direction = UISwipeGestureRecognizerDirection.Right
        imageView.addGestureRecognizer(swipeRightGestureRecognizer)
    }
    
    func didSwipeRight(recognizer:UISwipeGestureRecognizer){
        print("didSwipeRight")
        
    }
    
}

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
