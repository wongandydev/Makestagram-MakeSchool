//
//  ParseHelper.swift
//  Makestagram
//
//  Created by Andy Wong on 6/30/16.
//  Copyright © 2016 Make School. All rights reserved.
//

import Foundation
import Parse

class ParseHelper { //Going to wrap all of our helper methods into a class called PatseHelper. this is done so all of the functions are bundled under the ParseHelper namespace. THis makes codes easier t oread.
    
    //Following Relation 
    static let ParseFollowClass = "Follow"
    static let ParseFollowFromUser = "fromUser"
    static let ParseFollowToUser = "toUser"
    
    //Like Relation 
    static let ParseLikeClass = "Like"
    static let ParseLikeToPost = "toPost"
    static let ParseLikeFromUser = "fromUser"
    
    //Post Relation 
    static let ParsePostUser = "user"
    static let ParsePostCreatedAt = "createdAt"
    
    //Flagged Content Relation
    static let ParseFlaggedContentClass = "FlaggedContent"
    static let ParseFlaggedContentFromUser = "fromUser"
    static let ParseFlaggedContentToPost = "toPost"
    
    //User Relation
    static let ParseUserUsername = "username"
    
    
    
    //marked static so tha twe can call it without having to createa an instance of ParseHelpeer.
    static func timelineRequestForCurrentUser(completionBlock: PFQueryArrayResultBlock) { //This is done so you can call this func with 'ParseHelper.timelimeRequestforUser instead of just timelineRequestforUser //So we will always find the function being called
        let followingQuery = PFQuery(className: ParseFollowClass)
        followingQuery.whereKey(ParseFollowFromUser, equalTo: PFUser.currentUser()!)
        
        let postsFromFollowedUsers = Post.query()
        postsFromFollowedUsers!.whereKey(ParsePostUser, matchesKey: ParseFollowToUser, inQuery: followingQuery)
        
        let postsFromThisUser = Post.query()
        postsFromThisUser!.whereKey(ParsePostUser, equalTo: PFUser.currentUser()!)
        
        let query = PFQuery.orQueryWithSubqueries([postsFromFollowedUsers!, postsFromThisUser!])
        query.includeKey(ParsePostUser)
        query.orderByDescending(ParsePostCreatedAt)
        
        
        //All of the code before this is exacctly the same as the query that was in TimeLine but this line below. This doesn't provide a closure and handling the results of the query but hands off the results of the closure that is then handed to the complationBlcok parameter. // This menas that anyone is able to handle the results returnted from query
        query.findObjectsInBackgroundWithBlock(completionBlock)
    }
//MARK: Like
    static func likePost(user: PFUser, post: Post) {
        let likeObject = PFObject(className: ParseLikeClass)
        likeObject[ParseLikeFromUser] = user
        likeObject[ParseLikeToPost] = post
        
        likeObject.saveInBackgroundWithBlock(nil)
    }
    static func unlikePost(user: PFUser, post:Post) {
        let query = PFQuery(className: ParseLikeClass)
        query.whereKey(ParseLikeFromUser, equalTo: user)
        query.whereKey(ParseLikeToPost, equalTo: post)
        
        query.findObjectsInBackgroundWithBlock { (results: [PFObject]?, error: NSError?) -> Void in
            // 2
            if let results = results {
                for like in results {
                    like.deleteInBackgroundWithBlock(nil)
                }
            }
        
        }
    }
    static func likesForPost(post: Post, completionBlock: PFQueryArrayResultBlock) {
        let query = PFQuery(className: ParseLikeClass)
        query.whereKey(ParseLikeToPost, equalTo: post)
        // 2
        query.includeKey(ParseLikeFromUser)//Tells parse t ofetch the PFUSer object for each of the likes // Without the .includeKey we would only be getting the reference and would need to write another piece of code to fetch the likes
        
        query.findObjectsInBackgroundWithBlock(completionBlock)
    }
}

extension PFObject { //This will allow swift to know to consider any two Parse objects equal if they ahve the same object ID 
    
    public override func isEqual(object: AnyObject?) -> Bool {
        if (object as? PFObject)?.objectId == self.objectId {
            return true
        }
        else {
            return super.isEqual(object)
        }
    }
}




