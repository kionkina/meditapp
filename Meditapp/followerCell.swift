//
//  followerCell.swift
//  Meditapp
//
//  Created by Karina Ionkina on 4/19/21.
//
import UIKit
import UserNotifications
import FirebaseStorage
import Firebase

class followerCell: UITableViewCell {
    

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var username: UIButton!
    
    var postUser: User?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    //removed extra param: , user: User?
    func configure(for user: User?){

        //self.time.text = model.Timestamp
        //retrieves image from postphotos in storage
        //fix user image when implement profile picture
        let imageRef = Storage.storage().reference().child("profilephotos").child(user!.profilePic)
        //sets the image from the path to the UIImageView
        self.userImage.sd_setImage(with: imageRef)
        self.userImage.layer.cornerRadius = self.userImage.frame.height/2
        self.userImage.clipsToBounds = true
        
        self.username.setTitle(user!.username, for: .normal)
        
        self.postUser = user
    }

    

}
