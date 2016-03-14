//
//  MasterViewController.swift
//  MyWallpaper
//
//  Created by Linsw on 16/2/5.
//  Copyright © 2016年 Linsw. All rights reserved.
//

import UIKit
import SwiftyJSON
import Haneke

protocol CategorySelectionDelegate: class {
    func categorySelected(albumID: String)
}

class MasterViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    weak var delegate: CategorySelectionDelegate?
    
    @IBOutlet weak var categoryTableView: UITableView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var albumList = [[String]]()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = themeBlack.masterViewBackgroundColor
        categoryTableView.backgroundView = UIView()
        categoryTableView.backgroundView?.backgroundColor = view.backgroundColor
        initAlbumList()
        searchBar.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    func initAlbumList() {
        let stringURL:String = urlGetAlbum
        let cache = Shared.JSONCache
        let URL = NSURL(string: stringURL)!
        cache.removeAll()
        cache.fetch(URL: URL,failure:{ error in
            dispatch_async(dispatch_get_main_queue()) {
                print("fail to fetch albumList")
            }
            }).onSuccess { [unowned self] jsonObject in
            let json = JSON(jsonObject.dictionary)
            if let albums = json["album"].array?.reverse() {
                for albumJSON in albums{
                    var listCell = [String]()
                    if let albumName = albumJSON["albumname"].string {
                        listCell.append(albumName)
                    }else{
                        print(" albumname key no found")
                    }
                    if let picURL = albumJSON["pic"][0]["url"].string {
                        listCell.append(picURL)
                    }else{
                        print("pic/url key no found")
                    }
                    if let albumID = albumJSON["aid"].string {
                        listCell.append(albumID)
                    }else{
                        print("ID key no found")
                    }
                    self.albumList.append(listCell)
                }
            }else{
                print("album key no found")
            }
            
            dispatch_async(dispatch_get_main_queue()) { [unowned self] in
                self.categoryTableView.reloadData()
            }
        }
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "categoryCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! TableViewCell
        
        cell.titleLabel.text = albumList[indexPath.row][0]
        cell.titleLabel.transform = CGAffineTransformMakeRotation(CGFloat(-M_PI / 2))
        cell.cellImageView.hnk_setImageFromURL(NSURL(string: albumList[indexPath.row][1])!)
        let view = UIView()
        view.backgroundColor = self.view.backgroundColor
        cell.selectedBackgroundView = view
        cell.contentView.backgroundColor = view.backgroundColor
        setTableViewCellImageLayer(cell)
        
        if indexPath.row == 0 {
            cell.titleLabel.alpha = 0
            for layer in cell.cellImageView.layer.sublayers! {
                layer.opacity = 1
            }
            tableView.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: .None)
        }
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albumList.count
        
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedCategory = self.albumList[indexPath.row]
        self.delegate?.categorySelected(selectedCategory[2])
        
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! TableViewCell
        let duration = CFTimeInterval(0.5)

        let fadeInAnimation = CABasicAnimation(keyPath: "opacity")
        fadeInAnimation.fromValue = 0.0
        fadeInAnimation.toValue = 1.0
        fadeInAnimation.duration = duration
        fadeInAnimation.repeatCount = 0

        UIView.animateWithDuration(duration, animations: {()-> Void in
            cell.titleLabel.alpha = 0
            }, completion: {(finish) in
                for layer in cell.cellImageView.layer.sublayers!{
                    layer.removeAllAnimations()
                    layer.opacity = 1
                    layer.addAnimation(fadeInAnimation, forKey: "opacity")
                }
        })
        
    }
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.userInteractionEnabled = false
        
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! TableViewCell
        let duration = CFTimeInterval(0.5)
        
        let fadeOutAnimation = CABasicAnimation(keyPath: "opacity")
        fadeOutAnimation.fromValue = 1.0
        fadeOutAnimation.toValue = 0
        fadeOutAnimation.duration = duration
        fadeOutAnimation.repeatCount = 0
        for layer in cell.cellImageView.layer.sublayers!{
            layer.removeAllAnimations()
            layer.opacity = 0
            layer.addAnimation(fadeOutAnimation, forKey: "opacity")
        }

        UIView.animateWithDuration(duration, delay: duration, options: .TransitionNone, animations: {()-> Void in
            cell.titleLabel.alpha = 1
            }, completion: {(finish) in
                tableView.userInteractionEnabled = true
        })
    }

    //MARK: Cell Layer
    func setTableViewCellImageLayer(cell:TableViewCell){
        let layer = CALayer()
        let bounds = cell.cellImageView.bounds
        let boarderWidth = CGFloat(5)
        layer.frame = bounds
        layer.backgroundColor = view.backgroundColor!.CGColor
        layer.hidden = false
        layer.masksToBounds = false
        layer.cornerRadius = 0
        layer.borderWidth = boarderWidth
        layer.borderColor = themeBlack.lineColor.CGColor
        layer.opacity = 0
        
        let textLayer = CATextLayer()
        let baseFontSize: CGFloat = 24.0
        let textframe = CGRect(x: 0, y: 0, width: bounds.width, height: 36.0)
        textLayer.frame = textframe
        textLayer.position = CGPoint(x: bounds.width/2, y: bounds.height/2)
        textLayer.string = cell.titleLabel.text
        textLayer.font = CTFontCreateWithName("Helvetica", baseFontSize, nil)
        textLayer.fontSize = 24.0
        textLayer.wrapped = true
        textLayer.alignmentMode = kCAAlignmentCenter
        layer.addSublayer(textLayer)
        cell.cellImageView.layer.addSublayer(layer)
    }
    
}

extension MasterViewController: UISearchBarDelegate{

    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
        let searchPage = SearchPage(senderView:searchBar,backgroundColor: view.backgroundColor!)
        searchPage.presentFromRootViewController()

        return false
    }
    
}
