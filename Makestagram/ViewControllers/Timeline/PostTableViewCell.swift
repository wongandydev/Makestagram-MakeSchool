//
//  PostTableViewCell.swift
//  Makestagram
//
//  Created by Andy Wong on 6/29/16.
//  Copyright © 2016 Make School. All rights reserved.
//

import UIKit
import Bond
import Parse


class PostTableViewCell: UITableViewCell {
    
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var likesIconImageView: UIImageView!
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var moreButton: UIButton!
    

    @IBAction func moreButtonTapped(sender: AnyObject) {
    }

    @IBAction func likeButtonTapped(sender: AnyObject) {
        post?.toggleLikePost(PFUser.currentUser()!)
    }
    var postDisposable: DisposableType?
    var likeDisposable: DisposableType?
    
    var post: Post? {
        didSet {
            postDisposable?.dispose()//Used the disposable to destroy any old bindings that may exist
            likeDisposable?.dispose()
            //Whenever a new value is assigned to the post property, we use optional binding to check whether the new value is nil
            if let post = post {
                postDisposable = post.image.bindTo(postImageView.bnd_image) ////assigned the disposables to properties so we can destory the binding later
                likeDisposable = post.likes.observe { (value: [PFUser]?) -> () in
                    if let value = value {//Becausepost.likes containt a optional array, we need to make sure the value is not nil
                        self.likesLabel.text = self.stringFromUserList(value)//update likes label to display the list of usernames of all users that have like the post userss the utility method stringFromUserList to generate the llist
                        self.likeButton.selected = value.contains(PFUser.currentUser()!) //if the current user is in the lists of users who have liked the post, the heart will be the selected heart
                        self.likesIconImageView.hidden = (value.count == 0)//if no one ever liked the post, value.count ==0, the small heart icon will not appear
                    }else { //if the post.likes is nil, which happens when we are waiting for a reponse from Parse, we will see all the UI elements to the default
                        self.likesLabel.text = ""
                        self.likeButton.selected = false
                        self.likesIconImageView.hidden = true
                    }
                }
            }
        }
    }
    func stringFromUserList(userList: [PFUser]) -> String {

        let usernameList = userList.map {user in user.username! }//replace objects in a collection with other ojects
        //2
        let commaSeparatedUserList = usernameList.joinWithSeparator(", ")//using the joinWithSeperator method, we can use an array of strings to create one joint string 
        
        return commaSeparatedUserList
    }
}
