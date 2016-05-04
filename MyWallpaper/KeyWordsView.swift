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
    private var searchBar : UISearchBar?
    func attachTo(searchBar:UISearchBar){
        self.searchBar = searchBar
        var origin = searchBar.frame.origin
        origin.y = origin.y + searchBar.frame.height + 8
        frame = CGRect(origin: origin, size: CGSize(width: searchBar.frame.size.width, height: 30))
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = UIColor.clearColor()
        configureButton()
    }
    private func configureButton(){
        let words = GKRandomSource.sharedRandom().arrayByShufflingObjectsInArray(keyWords) as! [String]
        if let stackView = self.subviews[0] as? UIStackView {
            for (index,view) in stackView.subviews.enumerate() where view is UIButton {
                let button = view as! UIButton
                button.addTarget(self, action: "buttonDidTap:", forControlEvents:.TouchUpInside)
                button.setTitle(words[index-1],forState:.Normal)
                button.backgroundColor = themeBlack.lineColor
                button.layer.cornerRadius = 10.0
            }
        }
    }
    func buttonDidTap(sender:UIButton){
        if let bar = searchBar, text = sender.titleLabel?.text {
            bar.text = text
            bar.delegate?.searchBarSearchButtonClicked!(bar)
        }
    }
}
