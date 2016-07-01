//
//  Post.swift
//  Makestagram
//
//  Created by Andy Wong on 6/29/16.
//  Copyright © 2016 Make School. All rights reserved.
//

import Foundation
import Parse
import Bond

class Post: PFObject, PFSubclassing{
    
    @NSManaged var imageFile: PFFile? //What is this code doing? //Property we want to hace access to Parse Class
    @NSManaged var user: PFUser? //What is this code doing? //Property we want to hace access to Parse Class
    var image: Observable<UIImage?> = Observable(nil)
    var photoUploadTask: UIBackgroundTaskIdentifier? //photo Upload Yast property
    var likes: Observable<[PFUser]?> = Observable(nil)//We made the property observable so we can listen to cahnges and updates. it is also a nil because before we download it it, the property will be a nil
    
    static func parseClassName() -> String { //Creates a connection between the Parse class and Swift class
        return "Post"
    }

//MARK: Override Class
    override class func initialize() { //What is this whole class function doing]]]
        3
        var onceToken: dispatch_once_t = 0;
        dispatch_once(&onceToken) {
            //inform Parse about this subclass
            self.registerSubclass()
        }
    }
    
    func uploadPost() {//When this is called, it will grab the photo that will be upoaded from the image property, and turn it into a PFFile called iamgeFil
        if let image = image.value {
            
            guard let imageData = UIImageJPEGRepresentation(image, 0.8) else {return}
            guard let imageFile = PFFile(name: "image.jpg", data: imageData) else {return}
            
            
            user = PFUser.currentUser()//Allows us to access the user that is logged in
            self.imageFile = imageFile //assigns image fil to self.imageFile
           
            photoUploadTask = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler { () -> Void in //Background tast that creates a unique ID and returns it. //Stores uiquie ID in the photoUploadTask property //API requires us to provide an expirationHander for closure //The closure runs when the extra time that iOS permitted has expired.
                //This should also delete any temporary resource that you created in case our photo upload don't have any resources.
                UIApplication.sharedApplication().endBackgroundTask(self.photoUploadTask!)//Incase the additional background time is not enough, we are required to cancel our task //This is used to prevent the app from terminating
            }
            
            saveInBackgroundWithBlock() { (success: Bool, error: NSError?) in //uploads the Post //This is nil right now because As of now, it is not necessary to know when upload is complete
                    UIApplication.sharedApplication().endBackgroundTask(self.photoUploadTask!)/// Developers are responsible for calling this due to Background API
            }
        }
    }
    
    func downloadImage() {
        //if image is not downloaded yet, get it 
        // check if image.value already has a stored value. Used to avoid downloading images multiple times
        if (image.value == nil) {
            //starts download, instead of using getData as we did previously, we are using getDataInBackgroundWithBlock so we are not blocking the main thread
            imageFile?.getDataInBackgroundWithBlock { (data: NSData?, error: NSError?) -> Void in
                if let data = data {
                    let image = UIImage(data: data, scale:1.0)!
                    //Once the download ocmpletesm we update the post.image //used te .value property because image is a observable
                    self.image.value = image
                }
            }
        }
    }
    
    func fetchLikes() {
        if (likes.value != nil) { //Checks if likes.value has a stored value or not if it does have a value, it will not perform the code below and just returns. If it's nil, then it will continue to perform the code
            return
        }
        
        ParseHelper.likesForPost(self, completionBlock: { (likes: [PFObject]?, error: NSError?) -> Void in //fetches the likes for the currentPost using the ParseHellper likesForPost method created earlier
    
            let validLikes = likes?.filter { like in like[ParseHelper.ParseLikeFromUser] != nil} // filter method that is used to make sure that all the likes that done be deleted users or users that no longer uses the app will be removed. Or end the statements below will cause the app to crash
            
            self.likes.value = validLikes?.map { like in //Map method is similar to filter but replaces the objects instead of deleting them
                let fromUser = like[ParseHelper.ParseLikeFromUser] as! PFUser
                
                return fromUser
                }
            })
        }
    func doesUserLikePost(user: PFUser) -> Bool {//Checks to see if a user liked a post
        if let likes = likes.value { //if the user did like the post then continue to the statement below, else, it wil return false
            return likes.contains(user) //returns the user that liked the post
        }
        else{
            return false
        }
    }
    func toggleLikePost(user: PFUser) {
        if (doesUserLikePost(user)) {
            //if post is Liked, unlike it now
            likes.value = likes.value?.filter { $0 != user } // removes the user from the local cahe stored in the likes property
            ParseHelper.unlikePost(user, post: self) //Syncs the change with Parse
        }
        else {
            //if this post is not liked yet, like it now 
            //2
            likes.value?.append(user) //Since the user hasn't liked the post yet, we will add the userinto the list of users who liked the post
            ParseHelper.likePost(user, post: self)//syncs with Parse
        }
    }
}