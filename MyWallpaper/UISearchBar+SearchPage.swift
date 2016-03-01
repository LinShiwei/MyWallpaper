//
//  UISearchBar+SearchPage.swift
//  MyWallpaper
//
//  Created by Linsw on 16/3/1.
//  Copyright © 2016年 Linsw. All rights reserved.
//

import Foundation
import UIKit

public extension UISearchBar{
    public func setupForSearchPage(backgroundColor : UIColor = UIColor.whiteColor()){
        userInteractionEnabled = true
//        let gestureRecognizer = SearchPageTapGestureRecognizer(target: self, action: "didTap:", backgroundColor: backgroundColor)
//        addGestureRecognizer(gestureRecognizer)
    }
//    internal func didTap(recognizer: SearchPageTapGestureRecognizer){
//        let searchPage = SearchPage(backgroundColor: recognizer.backgroundColor)
//        searchPage.presentFromRootViewController()
//        print("didTap")
//    }
    
}

class SearchPageTapGestureRecognizer:UITapGestureRecognizer{
    var backgroundColor : UIColor!
    init(target: AnyObject, action: Selector, backgroundColor: UIColor) {
        self.backgroundColor = backgroundColor
        super.init(target: target, action: action)
    }
}