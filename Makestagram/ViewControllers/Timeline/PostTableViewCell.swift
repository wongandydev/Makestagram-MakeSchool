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
    var post: Post? {
        didSet {
            //Whenever a new value is assigned to the post property, we use optional binding to check whether the new value is nil
            if let post = post {
                //If the value isn't nil, we will create a binding between the image property of the post and the image property of the postImageView using the .bindTo method
                //bind the image of hte post to the 'postImage' view
                post.image.bindTo(postImageView.bnd_image)
            }
        }
    }
}
