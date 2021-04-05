//
//  CommentTableViewCell.swift
//  Meditapp
//
//  Created by Karina Ionkina on 3/29/21.
//

import UIKit
import UserNotifications
import FirebaseStorage
import Firebase

class commentCellTableViewCell: UITableViewCell {
    

    @IBOutlet weak var content: UILabel!
    @IBOutlet weak var time: UILabel!

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var username:UIButton!
    
    
    var postUser: User?
    var comment: Comment?


    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    //removed extra param: , user: User?
    func configure(with model: Comment, for user: User?){

        self.content.text = model.Content
        //self.time.text = model.Timestamp
        //retrieves image from postphotos in storage
        //fix user image when implement profile picture
        let imageRef = Storage.storage().reference().child("profilephotos").child(user!.profilePic)
        //sets the image from the path to the UIImageView
        self.userImage.sd_setImage(with: imageRef)
        self.username.setTitle(user!.username, for: .normal)
        self.time.text = DBViewController.convertTime(stamp: model.Timestamp)
        
        self.postUser = user
        self.comment = model
    }

    

}
