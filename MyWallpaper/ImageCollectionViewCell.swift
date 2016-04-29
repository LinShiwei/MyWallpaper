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

}
