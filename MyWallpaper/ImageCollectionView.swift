//
//  ImageCollectionView.swift
//  MyWallpaper
//
//  Created by Linsw on 16/4/29.
//  Copyright © 2016年 Linsw. All rights reserved.
//

import UIKit

class ImageCollectionView: UICollectionView {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setUp()
    }
    init(frame:CGRect){
        super.init(frame: frame, collectionViewLayout: UICollectionViewLayout())
        self.setUp()
    }
    private func getLayout()->CollectionViewWaterfallLayout{
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
    private func setUp(){
        collectionViewLayout = getLayout()
        registerNib(UINib(nibName: "ImageCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ImageCollectionViewCell")
    }
    
}
