//
//  CommentTableViewCell.swift
//  Meditapp
//
//  Created by Karina Ionkina on 3/29/21.
//

import UIKit
import UserNotifications
import FirebaseStorage

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
        self.userImage.image = UIImage(named:"profile_pic_1")
        self.username.setTitle(user!.username, for: .normal)
        
        self.postUser = user
        self.comment = model
    }

    

}
