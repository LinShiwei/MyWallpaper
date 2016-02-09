//
//  ViewController.swift
//  MyWallpaper
//
//  Created by Linsw on 16/2/4.
//  Copyright © 2016年 Linsw. All rights reserved.
//

import UIKit
import SwiftyJSON
class ViewController: UIViewController {

    @IBOutlet weak var image: UIImageView!
    var dataJSON = NSMutableData()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let stringURL:NSString = "http://api.tietuku.com/v2/api/getpiclist/key/a5rMlZpnZG6VnpNllmaUkpJon2NrlZVsmGdplGOXamxpmczKm2KVbMObmGSWYpY=/pid/13557"
        
//        "
        //building NSURL
        let url = NSURL(string: stringURL as String)
//        //building NSURLRequest
//        let request = NSURLRequest(URL: url!)
        //connection
        let session = NSURLSession.sharedSession()
        
        let dataTask = session.dataTaskWithURL(url!)  {
            data,response,error in
            
            
            dispatch_async(dispatch_get_main_queue()) {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            }
            if let error = error {
                print(error.localizedDescription)
            } else if let httpResponse = response as? NSHTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    
                    self.updateSearchResults(data)

                }
            }
            
        }
    
        dataTask.resume()

        
        
        
        
        
        
        
    }
    func updateSearchResults(data: NSData?) {
//        searchResults.removeAll()
//        var datat = NSData()
//        do {
//            if let data = data, response = try NSJSONSerialization.JSONObjectWithData(data, options:NSJSONReadingOptions(rawValue:2)) as? [String: AnyObject] {
//                
//                // Get the results array
//                print("\(response)")
//                if let array: AnyObject = response["linkurl"] {
//                    
////                    let str = array as! String
////                    print("\(str)")
////                    let url = NSURL(string: str)
////                    datat = NSData(contentsOfURL: url!)!
//                } else {
//                    print("id key not found in dictionary")
//                }
//            } else {
//                print("JSON Error")
//            }
//        } catch let error as NSError {
//            print("Error parsing results: \(error.localizedDescription)")
//        }
        var json:JSON?
        var datat = NSData()
        if let data = data {
            json = JSON(data:data)
            print("\(json)")
            let picUrl = json!["pic"][0]["linkurl"].string!
            let url = NSURL(string: picUrl)
            print("\(url)")
            datat = NSData(contentsOfURL: url!)!
        }
        
        dispatch_async(dispatch_get_main_queue()) {
            self.image.image = UIImage(data: datat)

        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    

}

