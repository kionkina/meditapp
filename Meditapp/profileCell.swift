//
//  profileCell.swift
//  Meditapp
//
//  Created by Jackson Lu on 4/2/21.
//

import UIKit

class profileCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!

    @IBOutlet var username: UILabel!
    @IBOutlet var fullName: UILabel!
    @IBOutlet var followBotton: UIButton!
    @IBOutlet var numFollowers: UILabel!
    @IBOutlet var numFollowing: UILabel!
    var isFollowing: Bool = true
    var uid: String = ""

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

    }
    
    func showFollowButton() {
        if isFollowing {
            self.followBotton.setTitle("Unfollow", for: .normal)
        }
        else {
            self.followBotton.setTitle("Follow", for: .normal)
        }
    }
    
    func setFollow(isFollowing: Bool){
        self.isFollowing = isFollowing
        showFollowButton()
    }
    
    var followHandler:(() -> Void)?
    var unfollowHandler:(() -> Void)?
    
    @IBAction func followButton(_ sender: UIButton) {
        //call appropriate db fxn
        //let upperView = self.superview?.superview as! UserProfilePageViewController
        if (isFollowing) {
            DBViewController.unfollow(for: self.uid) { (newNumFollowers) in
                DispatchQueue.main.async {
                    if (newNumFollowers != nil) {
                        self.isFollowing = false
                        //pulled from db instead of incrementing in case someone else followed too
                        User.current.numFollowing -= 1
                        User.current.following.removeValue(forKey: self.uid)
                        self.showFollowButton()
                        self.unfollowHandler!()
                    }
                }
            }
        } else {
            DBViewController.follow(for: self.uid) { (newNumFollowers) in
                DispatchQueue.main.async {
                    if (newNumFollowers != nil) {
                        print("newnumfolls")
                        print(newNumFollowers)
                        self.isFollowing = true
                        //pulled from db instead of incrementing in case someone else followed too
                        User.current.numFollowing += 1
                        User.current.following[self.uid] = true
                        self.showFollowButton()
                        self.followHandler!()
                        
            }
        }
    }
        }
    }
}
