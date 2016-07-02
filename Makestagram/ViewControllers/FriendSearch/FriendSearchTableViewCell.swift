//
//  FriendSearchTableViewCell.swift
//  Makestagram
//
//  Created by Andy Wong on 7/1/16.
//  Copyright © 2016 Make School. All rights reserved.
//

import UIKit
import Parse

protocol  FriendSearchTableViewCellDelegate: class { //Used to have this become a delegate
    func cell(cell: FriendSearchTableViewCell, didSelectFollowUser user: PFUser)
    func cell(cell: FriendSearchTableViewCell, didSelectUnfollowUser user: PFUser)
    }
class FriendSearchTableViewCell: UITableViewCell {
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var followButton: UIButton!
    weak var delegate: FriendSearchTableViewCellDelegate? //Property for the delegate
    //Every tiem a new tableViewCell, the controller will set itself as the delegate by assining itself with the delegate property shown above
    var user: PFUser? {
        didSet {
            usernameLabel.text = user?.username
        }
    }
    
    var canFollow: Bool? = true {
        didSet {
            /*
             Change the state of the follow button based on whether or not
             it is possible to follow a user.
             */
            if let canFollow = canFollow { //if the user is already following the user, the selected of the followButton will be shown
                followButton.selected = !canFollow
            }
        }
    }
    
    @IBAction func followButtonTapped(sender: AnyObject) { //This is used to allow the user to tap and follow another user
        if let canFollow = canFollow where canFollow == true { //If the user is already following the user, you cannot tap it to follow again.
            delegate?.cell(self, didSelectFollowUser: user!)
            self.canFollow = false
        } else {//if user did follow the user, he can tap and follow the user.
            delegate?.cell(self, didSelectUnfollowUser: user!)
            self.canFollow = true
        }
    }
}