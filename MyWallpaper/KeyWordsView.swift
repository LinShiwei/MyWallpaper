//
//  KeyWordsView.swift
//  MyWallpaper
//
//  Created by Linsw on 16/3/15.
//  Copyright © 2016年 Linsw. All rights reserved.
//

import UIKit
import GameplayKit
class KeyWordsView: UIView {

    @IBOutlet weak var keyWord1: UIButton!
    @IBOutlet weak var keyWord2: UIButton!
    @IBOutlet weak var keyWord3: UIButton!
    @IBOutlet weak var keyWord4: UIButton!
    @IBOutlet weak var keyWordsLabel: UILabel!

    private let keyWords = ["风景","汽车","人物","动漫"]
    
    func configureKeyWordsWith(target target :AnyObject, action:Selector,forControlEvents controlEvent:UIControlEvents? = .TouchUpInside){
        let words = GKRandomSource.sharedRandom().arrayByShufflingObjectsInArray(keyWords) as! [String]
        if let stackView = self.subviews[0] as? UIStackView {
            print(stackView.subviews)
            for (index,view) in stackView.subviews.enumerate() where view is UIButton {
                let button = view as! UIButton
                button.addTarget(target, action: action, forControlEvents: controlEvent!)
                button.setTitle(words[index-1],forState:.Normal)
                button.backgroundColor = themeBlack.lineColor
                button.layer.cornerRadius = 10.0
            }
        }
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = UIColor.clearColor()
    }
    
}
