//
//  TimelineViewController.swift
//  Makestagram
//
//  Created by Andy Wong on 6/28/16.
//  Copyright © 2016 Make School. All rights reserved.
//

import UIKit
import Parse
import ConvenienceKit

class TimelineViewController: UIViewController,TimelineComponentTarget {
    @IBOutlet weak var tableView: UITableView!

    var photoTakingHelper: PhotoTakingHelper?
    var timelineComponent: TimelineComponent<Post, TimelineViewController>!
    let defaultRange = 0...4 // have the time initially show the first five posts
    let additionalRangeSize = 5 //when the user reaches the end of the first five posts, load another 5 posts
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        timelineComponent = TimelineComponent(target: self)
        self.tabBarController?.delegate = self //sets this class as a delegate
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        timelineComponent.loadInitialIfRequired() //by calling loadInitialIFRequired wil amke an initial timeline request when time is first displayed
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
    func loadInRange(range: Range<Int>, completionBlock: ([Post]?) -> Void) {
        
        ParseHelper.timelineRequestForCurrentUser(range) { (result: [PFObject]?, error: NSError?) -> Void in //Passes the range from the pass arguemnt
            let posts = result as? [Post] ?? []// Cheecks whether or not we have a post
            // 3
            completionBlock(posts)//Passes the post back with completetion block to Timeline component
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
        
        return timelineComponent.content.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("PostCell") as! PostTableViewCell //casts a cell to our custom class PostTableViewCell, performing a cast is necessary to use PostTableViewCell instead of the old, UITableViewCell
        
        let post = timelineComponent.content[indexPath.row]
            //Right before a post will be displated we will start the image download
        post.downloadImage()
        //Instead of changing the image that is displyed in the cell from TimelineViewController, we assign the post that will be displayed to the Post object itself 
       
        post.fetchLikes()
        
        cell.post = post
//        cell.postImageView.image = posts[indexPath.row].image //decides which image should be displayed in the cell
        
        return cell
    }
    
}


extension TimelineViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        timelineComponent.targetWillDisplayEntry(indexPath.row)
    }
}





