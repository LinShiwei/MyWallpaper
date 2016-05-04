//
//  SearchPage.swift
//  MyWallpaper
//
//  Created by Linsw on 16/3/1.
//  Copyright © 2016年 Linsw. All rights reserved.
//

import UIKit
import Haneke
import SwiftyJSON
import GameplayKit
class SearchPage: UIViewController{
    
    let searchBar = UISearchBar()
    var rootViewController: UIViewController!
    var senderView : UISearchBar
    var originalFrameRelativeToScreen: CGRect!
    
    let maskView = UIView()
    var collectionView : UICollectionView?
    var guideView : UIView?
    var keyWordsView: KeyWordsView?
    
    var pictures = [Picture]()
    var filteredPictures = [Picture]()
    //MARK: View
    init(senderView : UISearchBar,backgroundColor:UIColor){
        self.senderView = senderView
        self.maskView.backgroundColor = backgroundColor
        rootViewController = UIApplication.sharedApplication().keyWindow!.rootViewController!
        originalFrameRelativeToScreen = CGRect(origin: senderView.convertPoint(CGPoint(x: 0, y: 0), toView: nil), size: senderView.frame.size)
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func presentFromRootViewController() {
        willMoveToParentViewController(rootViewController)
        rootViewController.view.addSubview(view)
        rootViewController.addChildViewController(self)
        didMoveToParentViewController(rootViewController)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        initPicturesData()
    }
    override func loadView() {
        super.loadView()
        configureMaskView()
        configureSearchBar()
        configureCollectionView()
        configureGuideView()
        animateEntry()
    }
    private func animateEntry(){
        senderView.alpha = 0
        UIView.animateWithDuration(0.8, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.6, options: [UIViewAnimationOptions.BeginFromCurrentState, UIViewAnimationOptions.CurveEaseInOut], animations: {[unowned self]() -> Void in
            self.searchBar.frame = self.setSearchBarFrame()
            }, completion: nil)
        configureKeysWordView()

        UIView.animateWithDuration(0.4, delay: 0.03, options: [UIViewAnimationOptions.BeginFromCurrentState, UIViewAnimationOptions.CurveEaseInOut], animations: {[unowned self]() -> Void in
            self.maskView.alpha = 1.0
            self.collectionView!.alpha = 1.0
            self.guideView!.alpha = 1.0
            self.keyWordsView!.alpha = 1.0
            }, completion: nil)
        
    }
    private func dismissViewController() {
        searchBar.text = nil
        searchBar.resignFirstResponder()

        dispatch_async(dispatch_get_main_queue(), {
            UIView.animateWithDuration(0.1){[unowned self]() in
                self.guideView!.alpha = 0.0
                }
            UIView.animateWithDuration(0.8, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.6, options: [UIViewAnimationOptions.BeginFromCurrentState, UIViewAnimationOptions.CurveEaseInOut], animations: {[unowned self]() in
                self.searchBar.frame = self.originalFrameRelativeToScreen
                self.collectionView!.alpha = 0.0
                self.maskView.alpha = 0.0
                self.keyWordsView!.alpha = 0.0
                }, completion: {(finished) in
                    self.willMoveToParentViewController(nil)
                    self.view.removeFromSuperview()
                    self.removeFromParentViewController()
                    self.senderView.alpha = 1.0
            })
        })
    }
    //MARK: Configure Views
    private func configureMaskView() {
        maskView.frame = windowBounds
        maskView.alpha = 0.0
        maskView.addGestureRecognizer(initSwipeGestureRecognizer())
        view.insertSubview(maskView, atIndex: 0)
    }
    private func configureSearchBar(){
        searchBar.barTintColor = UIColor.clearColor()
        searchBar.frame = originalFrameRelativeToScreen
        searchBar.delegate = self
        view.addSubview(searchBar)
    }
    private func configureCollectionView(){
        collectionView = getOriginCollectionView()
        collectionView!.delegate = self
        collectionView!.dataSource = self
        view.addSubview(collectionView!)
    }
    private func configureGuideView(){
        guideView = UIView(frame: CGRect(x: 0, y: collectionView!.frame.origin.y - 52, width: windowBounds.width, height: 44))
        if let guideView = guideView{
            let guideLabel = UILabel(frame: CGRect(x: guideView.frame.width/2-150, y: 0, width: 300, height: 44))
            guideLabel.text = "猜您喜欢"
            guideLabel.textAlignment = .Center
            guideLabel.font = UIFont(name: "AmericanTypewriter-Bold", size: 24)
            guideLabel.textColor = themeBlack.textColor
            
            let lineView = UIView(frame: CGRect(x: 0, y: 20, width: guideView.frame.width, height: 4))
            lineView.backgroundColor = themeBlack.lineColor
            guideLabel.backgroundColor = maskView.backgroundColor
            guideView.backgroundColor = UIColor.clearColor()

            guideView.addSubview(lineView)
            guideView.addSubview(guideLabel)
            guideView.alpha = 0
            view.addSubview(guideView)
        }
    }
    private func configureKeysWordView(){
        guard let viewFromNib = NSBundle.mainBundle().loadNibNamed("KeyWordsView", owner: self, options: nil).first as? KeyWordsView else{return}
        keyWordsView = viewFromNib
        keyWordsView!.attachTo(searchBar)
        keyWordsView!.alpha = 0
        view.addSubview(keyWordsView!)
    }
    private func setSearchBarFrame()->CGRect{
        let barWidth : CGFloat = windowBounds.width/2
        let barHeight: CGFloat = 44
        let origin = CGPoint(x: windowBounds.width/2 - barWidth/2, y: windowBounds.height/5)
        let size = CGSize(width: barWidth, height: barHeight)
        return CGRect(origin: origin, size: size)
    }
    private func initSwipeGestureRecognizer()->UISwipeGestureRecognizer{
        let recognizer = UISwipeGestureRecognizer(target: self, action: "didSwipeUp:")
        recognizer.direction = .Up
        return recognizer
    }
    func didSwipeUp(sender:UISwipeGestureRecognizer){
        dismissViewController()
    }
    private func initPicturesData(){
        let stringURL:String = urlGetPicList
        let cache = Shared.JSONCache
        cache.fetch(URL: NSURL(string: stringURL)!,failure:{ error in
            dispatch_async(dispatch_get_main_queue()) {
                print("fail to initPicturesData")
            }
        }).onSuccess{[weak self] jsonObject in
            if let pageCount = JSON(jsonObject.dictionary)["pages"].int {
                for page in 1...pageCount {
                    let string = stringURL + "/p/" + String(page)
                    let cache = Shared.JSONCache
                    cache.fetch(URL: NSURL(string: string)!).onSuccess{[weak self] object in
                        for  picJSON in JSON(object.dictionary)["pic"].array! {
                            if let url = picJSON["linkurl"].string,let width = picJSON["width"].string ,let height = picJSON["height"].string,let name = picJSON["name"].string {
                                let picture = Picture(name: name, url: url, size: CGSize(width: Int(width)!, height: Int(height)!))
                                self!.pictures.append(picture)
                            }
                        }
                        if page == pageCount,let pics = self?.pictures {
                            self!.filteredPictures = Array(GKRandomSource.sharedRandom().arrayByShufflingObjectsInArray(pics).suffix(15)) as! [Picture]
                            dispatch_async(dispatch_get_main_queue()) { [weak self] in
                                self!.collectionView!.reloadData()
                            }
                        }
                    }
                }
            }else{
                dispatch_async(dispatch_get_main_queue()) {
                    print("pages key no found")
                }
            }
        }
    }
    //MARK: Support Function
    private func getOriginCollectionView()->UICollectionView {
        let origin = CGPoint(x: 20, y: windowBounds.height*2/5)
        let size = CGSize(width: windowBounds.width - 20*2, height: windowBounds.height - origin.y - 20)
        let frame = CGRect(origin: origin, size: size)
        let collectionView = ImageCollectionView(frame: frame)
        (collectionView.collectionViewLayout as! CollectionViewWaterfallLayout).columnCount = 5
        collectionView.backgroundColor = UIColor.clearColor()
        collectionView.alpha = 0
        
        let loadingView = LoadingView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        loadingView.center = self.view.convertPoint(collectionView.center, toView: collectionView)
        collectionView.addSubview(loadingView)
        return collectionView
    }
}

//MARK: UICollectionView DataSource
extension SearchPage:UICollectionViewDataSource{
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return filteredPictures.count
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ImageCollectionViewCell", forIndexPath: indexPath) as! ImageCollectionViewCell
        for view in collectionView.subviews where view is LoadingView {
            view.hidden = true
        }
        cell.configureCell(filteredPictures[indexPath.row].url, backgroundColor: maskView.backgroundColor!)
        return cell
    }
}
// MARK: WaterfallLayoutDelegate
extension SearchPage:CollectionViewWaterfallLayoutDelegate{
    func collectionView(collectionView: UICollectionView, layout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return windowBounds.size
    }
}
//MARK: UISearchBarDelegate
extension SearchPage:UISearchBarDelegate{
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        filteredPictures = pictures.filter({(picture : Picture)->Bool in
            guard let text = searchBar.text where picture.name.containsString(text) else {
                return false
            }
            return true
        })
        collectionView!.reloadData()
        for view in guideView!.subviews where view is UILabel {
            UIView.animateWithDuration(0.5, delay: 0, options: .AllowAnimatedContent, animations: {[unowned self]() in
                (view as! UILabel).text = self.filteredPictures.count > 0 ? "为您搜索到以下图片":"未找到相关图片"
                }, completion: nil)
        }
    }
}

