//
//  ImageCollectionViewCell.swift
//  MyWallpaper
//
//  Created by Linsw on 16/3/1.
//  Copyright © 2016年 Linsw. All rights reserved.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var loadingView: LoadingView!
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    func configureCell(url:String, backgroundColor:UIColor){
        loadingView.hidden = false
        imageView.hnk_setImageFromURL(NSURL(string: url)!, success: {
            [unowned self] image in
            self.imageView.image = image
            self.loadingView.hidden = true
        })
        imageView.setupForImageViewer(NSURL(string: url), backgroundColor: backgroundColor)
    }
}
