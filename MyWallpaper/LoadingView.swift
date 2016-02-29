//
//  LoadingView.swift
//  MyWallpaper
//
//  Created by Linsw on 16/2/27.
//  Copyright © 2016年 Linsw. All rights reserved.
//

import UIKit

class LoadingView: UIView {

    let lengthMultiplier: CGFloat = 3.0
    let replicatorLayer = CAReplicatorLayer()
    let instanceLayer = CALayer()
    let fadeAnimation = CABasicAnimation(keyPath: "opacity")
    let whiteColor = UIColor.whiteColor().CGColor
    
    
    func setUpReplicatorLayer() {
        replicatorLayer.frame = self.bounds
        let count :Float = 12.0
        replicatorLayer.instanceCount = Int(count)
        replicatorLayer.instanceDelay = CFTimeInterval(1/count)
        replicatorLayer.preservesDepth = false
        replicatorLayer.instanceColor = whiteColor
        replicatorLayer.instanceRedOffset = 0
        replicatorLayer.instanceGreenOffset = 0
        replicatorLayer.instanceBlueOffset = 0
        replicatorLayer.instanceAlphaOffset = 0
        let angle = Float(M_PI * 2.0) / count
        replicatorLayer.instanceTransform = CATransform3DMakeRotation(CGFloat(angle), 0.0, 0.0, 1.0)
    }
    
    func setUpInstanceLayer() {
        let layerWidth = CGFloat(self.bounds.width/20)
        let midX = CGRectGetMidX(self.bounds) - layerWidth / 2.0
        instanceLayer.frame = CGRect(x: midX, y: 0.0, width: layerWidth, height: layerWidth * lengthMultiplier)
        instanceLayer.backgroundColor = whiteColor
        instanceLayer.opacity = 0.0
        instanceLayer.addAnimation(fadeAnimation, forKey: "FadeAnimation")
    }
    
    func setUpLayerFadeAnimation() {
        fadeAnimation.fromValue = 1.0
        fadeAnimation.toValue = 0.0
        fadeAnimation.duration = 1.0
        fadeAnimation.repeatCount = Float(Int.max)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUpLayerFadeAnimation()
        setUpReplicatorLayer()
        self.layer.addSublayer(replicatorLayer)
        setUpInstanceLayer()
        replicatorLayer.addSublayer(instanceLayer)
        
    }
    
    
}
