//
//  DetailViewController.swift
//  MyWallpaper
//
//  Created by Linsw on 16/2/5.
//  Copyright © 2016年 Linsw. All rights reserved.
//

import UIKit
import SwiftyJSON
class DetailViewController: UIViewController,UICollectionViewDataSource,CollectionViewWaterfallLayoutDelegate{

    
    @IBOutlet weak var imageCollectionView: UICollectionView!
    
    var picturesURL = [String]()
    var pictures = [UIImage]()
    
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
        return pictures.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("imageCollectionViewCell", forIndexPath: indexPath) as! CollectionViewCell
        cell.backgroundColor = UIColor.whiteColor()
        cell.imageView.image = pictures[indexPath.row]
        cell.imageView.setupForImageViewer(nil, backgroundColor: UIColor.blackColor())
        return cell
    }
    
    // MARK: WaterfallLayoutDelegate
    
    func collectionView(collectionView: UICollectionView, layout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return pictures[indexPath.row].size 
    }
    
    //MARK: Get image from URL
    func fetchDataWithAlbumID(){
        var stringURL:String = "http://api.tietuku.com/v2/api/getpiclist/key/a5rMlZpnZG6VnpNllmaUkpJon2NrlZVsmGdplGOXamxpmczKm2KVbMObmGSWYpY="
        //building NSURL
        if let id = albumID {
            stringURL = stringURL + "/aid/" + id
        
            let url = NSURL(string: stringURL)
           
            let session = NSURLSession.sharedSession()
            
            let dataTask = session.dataTaskWithURL(url!)  {
                data,response,error in
                dispatch_async(dispatch_get_main_queue()) {
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                }
                if let error = error {
                    print(error.localizedDescription)
                } else if let httpResponse = response as? NSHTTPURLResponse {
                    if httpResponse.statusCode == 200 {
                        self.initPicturesURL(data)
                        
                    }
                }
            }
            dataTask.resume()
        }
    }
    
    func initPicturesURL(data:NSData?){
        picturesURL.removeAll()
        pictures.removeAll()
        let json = JSON(data:data!)["pic"].array
        for  picJSON in json! {
            if let url = picJSON["linkurl"].string {
                picturesURL.append(url)
                pictures.append(getImageFromURL(url)!)
            }
        }
        
        print(" detail picURL \(picturesURL)")
        dispatch_async(dispatch_get_main_queue()) {
            self.imageCollectionView.reloadData()
        }
    }
    
    func getImageFromURL(url:String)->UIImage? {
        
        let data = NSData(contentsOfURL: NSURL(string: url)!)
        return UIImage(data: data!)
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
