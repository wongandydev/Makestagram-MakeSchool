//
//  TimelineViewController.swift
//  Makestagram
//
//  Created by Andy Wong on 6/28/16.
//  Copyright © 2016 Make School. All rights reserved.
//

import UIKit
import Parse

class TimelineViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!

    var posts: [Post] = []
    var photoTakingHelper: PhotoTakingHelper?

    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.tabBarController?.delegate = self //sets this class as a delegate
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        ParseHelper.timelineRequestForCurrentUser { (result: [PFObject]?, error: NSError?) -> Void in
            self.posts = result as? [Post] ?? []
        
            self.tableView.reloadData()
        }
    }
func takePhoto() {
    //instantiate photo taking class, provide callback for when photo is selected 
        photoTakingHelper = PhotoTakingHelper(viewController: self.tabBarController!)
        { (image: UIImage?) in //assigns the instance PhotoTakingHelper to photoTakingHelper property //There are two parameters: The view controller where hte popup will be presented and the callback that should run as soon as a photo has been selected // '{image: UIImage?) in ... }' is a closure
        let post = Post()
        post.image.value = image!
        post.uploadPost()

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

extension TimelineViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return posts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("PostCell") as! PostTableViewCell //casts a cell to our custom class PostTableViewCell, performing a cast is necessary to use PostTableViewCell instead of the old, UITableViewCell
        
        let post = posts[indexPath.row]
        //Right before a post will be displated we will start the image download
        post.downloadImage()
        //Instead of changing the image that is displyed in the cell from TimelineViewController, we assign the post that will be displayed to the Post object itself 
       
        post.fetchLikes()
        
        cell.post = post
//        cell.postImageView.image = posts[indexPath.row].image //decides which image should be displayed in the cell
        
        return cell
    }
}





