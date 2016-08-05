//
//  SplitViewController.swift
//  MyWallpaper
//
//  Created by Linsw on 16/2/5.
//  Copyright © 2016年 Linsw. All rights reserved.
//

import UIKit

class SplitViewController: UISplitViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = themeBlack.splitViewBackgroundColor
        maximumPrimaryColumnWidth = CGFloat(MAXFLOAT)
        let ratio:CGFloat = 180/(self.view.frame.width)
        preferredPrimaryColumnWidthFraction = ratio
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    override func prefersStatusBarHidden() -> Bool {
        return false
    }
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
}
