//
//  PhotoTakingHelper.swift
//  Makestagram
//
//  Created by Andy Wong on 6/28/16.
//  Copyright © 2016 Make School. All rights reserved.
//

import UIKit

typealias PhotoTakingHelperCallBack = UIImage? -> Void //What does this code do? Typealias adds a function signature with a name // Using this, anyone that wants a callback will need to use the exactly signatur

class PhotoTakingHelper: NSObject {
    //View Controller on which AlertViewController and UIImagePickerController are preseneted
    
    weak var viewController: UIViewController! //property 1: stores a weak reence to a UIViewController This is necessary because PhotoTakingHelper needs a UIViewController where i can present other view controllers. This is a weak reference because the PhotoTakingHelper does not own the refernced view controller
    var callback: PhotoTakingHelperCallBack //Property 2: callback function, and providing a protperty to store UIImagePickerCOntroller
    var imagePickerController: UIImagePickerController?
    
    init(viewController: UIViewController, callback: PhotoTakingHelperCallBack) { //recieves the view controller on which we will present other view contollers and the callback that we will call as soon as a user pick an image
        self.viewController = viewController
        self.callback = callback
        
        super.init()
        
        showPhotoSourceSelection()
    }
        func showPhotoSourceSelection(){ //allow user to choose between photo library and camera 
            let alertController = UIAlertController(title: nil, message: "Where do you want to get your picture from?", preferredStyle: .ActionSheet) //Sets up UIAleryController by providing it with a message and a preferredStyle. This can bee used to present different types of popups. Choosing the '.ActionSheet' option creates a popup that gets displayed from the bottom edge of the screen
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil) //Cancel Button
            alertController.addAction(cancelAction)
            
            let photoLibraryAction = UIAlertAction(title: "Photo from Library", style: .Default) { (action) in //button from pop('.ActionSheet') that will allow user to choose Photo Library as the option to post an image
                self.showImagePickerController(.PhotoLibrary)
            }
            alertController.addAction(photoLibraryAction)
    
            //Only show camera option if rear camera is available
            if (UIImagePickerController.isCameraDeviceAvailable(.Rear)) {
                let cameraAction = UIAlertAction(title: "Photo from Camera", style: .Default) { (action) in //If the if state is true, where the user does have a rear camera, the popup from user ('.ActionSheet') will give the user the option to capture a photo to post
                    self.showImagePickerController(.Camera)
                }
                alertController.addAction(cameraAction)
            }
//            let photoLibraryAction = UIAlertAction(title: "Photo from Library", style: .Default) { (action) in
//                self.showImagePickerController(.PhotoLibrary)
//            }
            viewController.presentViewController(alertController, animated: true, completion: nil) //This is used because only view controllers can be presented from other view controllers. This is used so taht we've stored in the viewController property and call the presentViewController method. This will now cause the pop to display whichever view controller is stored in the viewController property.

}
    func showImagePickerController(sourceType: UIImagePickerControllerSourceType){ //Implementing the actual photo taking code
        imagePickerController = UIImagePickerController() //This method creates a UIImagePickerController
        imagePickerController!.sourceType = sourceType //sets the sourceType of the Controller Depending on the sourceType of the UIImagePickerController, it will activate teh camera nad display a photo taking oerlag ~ or will show the user's photo librarby. //THe showImagePickerController method takes the sourceType as an argument and hands it on to the imagePickerController - THis alows the 'caller' of this method to specify wheter the camera or the photo library should be used as an image source
        imagePickerController!.delegate = self//signs up to become the 'delegate' of the UIImagePickerController
        
        self.viewController.presentViewController(imagePickerController!, animated: true, completion: nil) //Once the imagePickerController is initialized and configured, this will present it
    }
    
}

extension PhotoTakingHelper: UIImagePickerControllerDelegate, UINavigationControllerDelegate { //Before becoming the delegate, the image picker controller was automatically hidden but when we come the delegate, we are responsible for hiding the image picker controller and that is what "dismissViewControllerAnimated" does.
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject: AnyObject]!) { //Function will start when image is selected
        viewController.dismissViewControllerAnimated(false, completion: nil)
        
        callback(image)// hands hte image that has been sleected as an argument.
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) { //Function will start when cancel is tapped
        viewController.dismissViewControllerAnimated(true, completion:nil)
    }
    
}

