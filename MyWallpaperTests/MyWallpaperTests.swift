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

    
    func testSearchPageGuideLabelTextDidChangeCorrectlyAfterSearch(){
        let searchPage = SearchPage(senderView: masterViewController.searchBar, backgroundColor: UIColor.blackColor())
        let _ = searchPage.view
        var guideLabel = UILabel()
        for view in searchPage.guideView!.subviews where view is UILabel{
            guideLabel = view as! UILabel
        }
        searchPage.searchBar.text = "风景"
        searchPage.searchBarSearchButtonClicked(searchPage.searchBar)
        print("fengjing")
        print(searchPage.filteredPictures)

        XCTAssertEqual(guideLabel.text, "为您搜索到以下图片")
        searchPage.searchBar.text = "图片没有这个名称"
        searchPage.searchBarSearchButtonClicked(searchPage.searchBar)
        print("wu")
        print(searchPage.filteredPictures)

        XCTAssertEqual(guideLabel.text, "未找到相关图片")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
}
