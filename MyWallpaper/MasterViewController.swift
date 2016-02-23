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
    
    @IBOutlet weak var categoryTabelView: UITableView!
    
    var albumList = [[String]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.blackColor()
        categoryTabelView.backgroundView = UIView()
        categoryTabelView.backgroundView?.backgroundColor = UIColor.blackColor()
//         Do any additional setup after loading the view.
        initAlbumList()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    func initAlbumList() {
        let stringURL:String = "http://api.tietuku.com/v2/api/getalbum/key/a5rMlZpnZG6VnpNllmaUkpJon2NrlZVsmGdplGOXamxpmczKm2KVbMObmGSWYpY="
        
        let cache = Shared.JSONCache
        let URL = NSURL(string: stringURL)!
        cache.removeAll()
        cache.fetch(URL: URL).onSuccess { jsonObject in
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
            
            dispatch_async(dispatch_get_main_queue()) {
                self.categoryTabelView.reloadData()
            }
        }
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "categoryCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! TableViewCell
        
        cell.titleLabel.text = albumList[indexPath.row][0]
        cell.cellImageView.hnk_setImageFromURL(NSURL(string: albumList[indexPath.row][1])!)
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.1, alpha: 1)
        cell.selectedBackgroundView = view
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
    }
    
}
