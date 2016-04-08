//
//  MyWallpaperTests.swift
//  MyWallpaperTests
//
//  Created by Linsw on 16/3/13.
//  Copyright © 2016年 Linsw. All rights reserved.
//

import XCTest
@testable import MyWallpaper
class MyWallpaperTests: XCTestCase {
    var splitViewController : UISplitViewController!
    var masterViewController: MasterViewController!
    var detailViewController: DetailViewController!
    override func setUp() {
        super.setUp()
        splitViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("SplitViewController") as! UISplitViewController
        masterViewController = splitViewController.viewControllers[0] as! MasterViewController
        detailViewController = splitViewController.viewControllers[1] as! DetailViewController
        let _ = masterViewController.view
        let _ = detailViewController.view
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
}
