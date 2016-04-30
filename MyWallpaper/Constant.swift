//
//  Constant.swift
//  MyWallpaper
//
//  Created by Linsw on 16/3/11.
//  Copyright © 2016年 Linsw. All rights reserved.
//

import Foundation
import UIKit
//修改域名后，如果不能加载图片，可能是因为Apple Transport Security，在info.plist里添加白名单即可
let tieTuKuOpenkey = "/key/a5rMlZpnZG6VnpNllmaUkpJon2NrlZVsmGdplGOXamxpmczKm2KVbMObmGSWYpY="
let tieTuKuURL = "http://api.tietuku.cn/v2/api"

let urlGetAlbum   = tieTuKuURL + "/getalbum" + tieTuKuOpenkey
let urlGetPicList = tieTuKuURL + "/getpiclist" + tieTuKuOpenkey
//let urlGetRandomRecommandedPhotos = tieTuKuURL + "/getrandrec" + tieTuKuOpenkey

struct Theme {
    let splitViewBackgroundColor : UIColor
    let masterViewBackgroundColor: UIColor
    let detailViewBackgroundColor: UIColor
    let textColor                : UIColor
    let lineColor                : UIColor
    
}

let themeBlack = Theme(
    splitViewBackgroundColor : UIColor.blackColor(),
    masterViewBackgroundColor: UIColor.blackColor(),
    detailViewBackgroundColor: UIColor.blackColor(),
    textColor                : UIColor.whiteColor(),
    lineColor                : UIColor(white: 0.1, alpha: 1)
)

