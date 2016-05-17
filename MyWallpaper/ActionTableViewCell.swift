//
//  ActionTableViewCell.swift
//  MyWallpaper
//
//  Created by Linsw on 16/5/8.
//  Copyright © 2016年 Linsw. All rights reserved.
//

import UIKit
import Haneke
class ActionTableViewCell: UITableViewCell {
    var prompt = SwiftPromptsView()

    @IBOutlet weak var clearCacheButton: UIButton!
    @IBAction func clearCache(sender: UIButton) {
        initPromptsView()
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        clearCacheButton.titleLabel!.textColor = themeBlack.lineColor
        backgroundColor = themeBlack.masterViewBackgroundColor
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    private func initPromptsView(){
        prompt = SwiftPromptsView(frame: windowBounds)
        prompt.delegate = self
        //Set the properties of the prompt
        prompt.setPromptHeader("Attention")
        prompt.setPromptContentText("Do you want to clear all cache?")
        prompt.setBlurringLevel(2.0)
        prompt.setPromptTopLineVisibility(true)
        prompt.setPromptBottomLineVisibility(false)
        prompt.setPromptBottomBarVisibility(true)

        prompt.setPromptHeaderTxtColor(UIColor(red: 255.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 1.0))
        prompt.setPromptOutlineColor(UIColor(red: 133.0/255.0, green: 133.0/255.0, blue: 133.0/255.0, alpha: 1.0))
        prompt.setPromptDismissIconColor(UIColor(red: 133.0/255.0, green: 133.0/255.0, blue: 133.0/255.0, alpha: 1.0))
        prompt.setPromptTopLineColor(UIColor(red: 151.0/255.0, green: 151.0/255.0, blue: 151.0/255.0, alpha: 1.0))
        prompt.setPromptBackgroundColor(UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 0.67))
        prompt.setPromptBottomBarColor(UIColor(red: 133.0/255.0, green: 133.0/255.0, blue: 133.0/255.0, alpha: 1.0))
        prompt.setMainButtonColor(UIColor.whiteColor())
        prompt.setMainButtonText("OK")
        UIApplication.sharedApplication().keyWindow!.addSubview(prompt)
    }
}
extension ActionTableViewCell:SwiftPromptsProtocol{
    func clickedOnTheMainButton() {
        print("Clicked on the main button")
        Shared.JSONCache.removeAll()
        Cache<UIImage>(name: "indexImageCache").removeAll()
        Cache<UIImage>(name: "highQualityImageCache").removeAll()
        prompt.dismissPrompt()
    }
    func clickedOnTheSecondButton() {
        print("Clicked on the second button")
        prompt.dismissPrompt()
    }
    func promptWasDismissed() {
        print("Dismissed the prompt")
    }
}
