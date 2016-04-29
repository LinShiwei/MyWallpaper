//
//  Picture.swift
//  MyWallpaper
//
//  Created by Linsw on 16/4/29.
//  Copyright © 2016年 Linsw. All rights reserved.
//

import Foundation
import UIKit
class Picture {
    let name :String
    let url  :String
    let size :CGSize
    init(name:String,url:String,size:CGSize){
        self.name = name
        self.url = url
        self.size = size
    }
}