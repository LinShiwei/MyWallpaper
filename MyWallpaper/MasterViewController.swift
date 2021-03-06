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
    func categorySelected(albumID _: String)
}

class MasterViewController: UIViewController{

    weak var delegate: CategorySelectionDelegate?
    
    @IBOutlet weak var categoryTableView: UITableView!

    var albumList = [Album]()
    //MARK: view
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = themeBlack.masterViewBackgroundColor
        categoryTableView.backgroundColor = view.backgroundColor
        initAlbumList()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    //MARK: init albumlist
    func initAlbumList() {
        let cache = Shared.JSONCache
        cache.removeAll()
        cache.fetch(URL: NSURL(string: urlGetAlbum)!,failure:{ _ in
                dispatch_async(dispatch_get_main_queue()) {
                    print("fail to fetch albumList")
                }
            }).onSuccess { [unowned self] jsonObject in
                let json = JSON(jsonObject.dictionary)
                if let albums = json["album"].array?.reverse() {
                    for albumJSON in albums{
                        if let albumName = albumJSON["albumname"].string,let picURL = albumJSON["pic"][0]["url"].string,let albumID = albumJSON["aid"].string {
                            self.albumList.append(Album(name: albumName, url: picURL, id: albumID))
                        }else{
                            print("album no found")
                        }
                    }
                }else{
                    print("album key no found")
                }
                dispatch_async(dispatch_get_main_queue()) { [unowned self] in
                    self.categoryTableView.reloadData()
            }
        }
    }
}
//MARK: TableView DataSource
extension MasterViewController: UITableViewDataSource{
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row != albumList.count{
            let cell = tableView.dequeueReusableCellWithIdentifier("CategoryCell", forIndexPath: indexPath) as! CategroyTableViewCell
            cell.titleLabel.text = albumList[indexPath.row].name
            cell.titleLabel.transform = CGAffineTransformMakeRotation(CGFloat(-M_PI / 2))
            cell.cellImageView.hnk_setImageFromURL(NSURL(string: albumList[indexPath.row].url)!)
            cell.setUpLayer()
            if indexPath.row == 0 {
                cell.titleLabel.alpha = 0
                for layer in cell.cellImageView.layer.sublayers! {
                    layer.opacity = 1
                }
                tableView.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: .None)
            }
            return cell
        }else{
            let cell = tableView.dequeueReusableCellWithIdentifier("ActionCell",forIndexPath: indexPath) as! ActionTableViewCell
            return cell
        }
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albumList.count + 1
    }
}
//MARK: TableView Delegate
extension MasterViewController: UITableViewDelegate{
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.delegate?.categorySelected(albumID: self.albumList[indexPath.row].id)
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! CategroyTableViewCell
        UIView.animateWithDuration(0.5, animations: {()-> Void in
            cell.titleLabel.alpha = 0
            }, completion: {(finish) in
                cell.imageViewFadeInAnimation()
        })
    }
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.userInteractionEnabled = false
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! CategroyTableViewCell
        cell.imageViewFadeOutAnimation()
        UIView.animateWithDuration(0.5, delay: 0.5, options: .TransitionNone, animations: {()-> Void in
            cell.titleLabel.alpha = 1
            }, completion: {(finish) in
                tableView.userInteractionEnabled = true
        })
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row != albumList.count {
            return 140
        }else{
            return 38
        }
    }
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if indexPath.row == albumList.count {
            return nil
        }
        return indexPath
    }
}
//MARK: UISearchBarDelegate
extension MasterViewController: UISearchBarDelegate{
    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
        let searchPage = SearchPage(senderView:searchBar,backgroundColor: view.backgroundColor!)
        searchPage.presentFromRootViewController()
        return false
    }
}
