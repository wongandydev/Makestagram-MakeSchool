//
//  TimelineViewController.swift
//  Makestagram
//
//  Created by Andy Wong on 6/28/16.
//  Copyright © 2016 Make School. All rights reserved.
//

import UIKit

class TimelineViewController: UIViewController {

    var photoTakingHelper: PhotoTakingHelper?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.tabBarController?.delegate = self //sets this class as a delegate
    }


func takePhoto() {
    //instantiate photo taking class, provide callback for when photo is selected 
        photoTakingHelper = PhotoTakingHelper(viewController: self.tabBarController!) { (image: UIImage?) in //assigns the instance PhotoTakingHelper to photoTakingHelper property //There are two parameters: The view controller where hte popup will be presented and the callback that should run as soon as a photo has been selected // '{image: UIImage?) in ... }' is a closure
        print("recieved a callback")
        }
    }
}
//MARK: Tab Bar Delegate

    extension TimelineViewController: UITabBarControllerDelegate {
        func tabBarController(tabBarController: UITabBarController, shouldSelectViewController viewController: UIViewController) -> Bool { //This protocol method requires us to return a Bool if true it will continue the code following, if flase, the view controller will not be displayed 
            if (viewController is PhotoViewController) {
                takePhoto()
                return false
            }
            else{
                return true
            }
    
        }
    }

