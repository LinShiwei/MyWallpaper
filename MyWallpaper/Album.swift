//
//  Album.swift
//  MyWallpaper
//
//  Created by Linsw on 16/4/28.
//  Copyright © 2016年 Linsw. All rights reserved.
//

import Foundation

class Album {
    let name,url,id : String
    init(_ name:String, url:String, id:String){
        self.name = name
        self.url = url
        self.id = id
    }
}