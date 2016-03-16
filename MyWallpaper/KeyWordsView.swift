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

    @IBOutlet weak var keyWordsLabel: UILabel!
    @IBOutlet weak var keyWord1: UIButton!
    @IBOutlet weak var keyWord2: UIButton!
    @IBOutlet weak var keyWord3: UIButton!
    @IBOutlet weak var keyWord4: UIButton!
    let keyWords = ["风景","汽车","人物","动漫"]
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//        
//
//    }
    func configureKeyWords(){
        let words = GKRandomSource.sharedRandom().arrayByShufflingObjectsInArray(keyWords) as! [String]
        var index = 0
        if let stackView = self.subviews[0] as? UIStackView {
            for view in stackView.subviews where view is UIButton {
                let button = view as! UIButton
                button.setTitle(words[index],forState:.Normal)
                index += 1
                button.backgroundColor = UIColor(white: 0.05, alpha: 1)
                let layer = button.layer
                layer.cornerRadius = 10.0
//                layer.borderWidth = 1.0
//                layer.borderColor = themeBlack.lineColor.CGColor
            }
        }
        
    }
    
    
}
