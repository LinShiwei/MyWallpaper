//
//  TableViewCell.swift
//  MyWallpaper
//
//  Created by Linsw on 16/2/5.
//  Copyright © 2016年 Linsw. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var cellImageView: UIImageView!
   
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        contentView.backgroundColor = themeBlack.masterViewBackgroundColor
    }
    func setUpLayer(){
        let layer = CALayer()
        let bounds = cellImageView.bounds
        layer.frame = bounds
        layer.opacity = 0
        layer.borderWidth = 5
        layer.borderColor = themeBlack.lineColor.CGColor
        layer.backgroundColor = themeBlack.masterViewBackgroundColor.CGColor
        
        let textLayer = CATextLayer()
        textLayer.frame = CGRect(x: 0, y: 0, width: bounds.width, height: 36.0)
        textLayer.position = CGPoint(x: bounds.width/2, y: bounds.height/2)
        textLayer.string = titleLabel.text
        textLayer.font = CTFontCreateWithName("Helvetica", 24, nil)
        textLayer.fontSize = 24.0
        textLayer.wrapped = true
        textLayer.alignmentMode = kCAAlignmentCenter
        layer.addSublayer(textLayer)
        cellImageView.layer.addSublayer(layer)
    }
    func imageViewFadeOutAnimation(){
        let fadeOutAnimation = CABasicAnimation(keyPath: "opacity")
        fadeOutAnimation.fromValue = 1.0
        fadeOutAnimation.toValue = 0
        fadeOutAnimation.duration = 0.5
        fadeOutAnimation.repeatCount = 0
        for layer in cellImageView.layer.sublayers!{
            layer.removeAllAnimations()
            layer.opacity = 0
            layer.addAnimation(fadeOutAnimation, forKey: "opacity")
        }
    }
    func imageViewFadeInAnimation(){
        let fadeInAnimation = CABasicAnimation(keyPath: "opacity")
        fadeInAnimation.fromValue = 0.0
        fadeInAnimation.toValue = 1.0
        fadeInAnimation.duration = 0.5
        fadeInAnimation.repeatCount = 0
        
        for layer in cellImageView.layer.sublayers!{
            layer.removeAllAnimations()
            layer.opacity = 1
            layer.addAnimation(fadeInAnimation, forKey: "opacity")
        }
    }
}
