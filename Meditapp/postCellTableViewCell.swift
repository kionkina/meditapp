    //
//  postCellTableViewCell.swift
//  Meditapp
//
//  Created by Gabriella Alexis on 3/2/21.
//

import UIKit
import FirebaseStorage

class postCellTableViewCell: UITableViewCell {
    
    @IBOutlet weak var postTitle: UILabel!
    @IBOutlet weak var postDescription: UILabel!
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var userImage: UIImageView!
    
    @IBOutlet weak var likesCount: UILabel!
    @IBOutlet weak var dislikesCount: UILabel!
    @IBOutlet weak var commentsCount: UILabel!
    @IBOutlet weak var username:UIButton!
    
    
    
    @IBAction func playButton(_ sender: UIButton) {
        playAudio!()
    }
    
    @IBAction func backwardsButton(_ sender: UIButton) {
    }
    
    @IBAction func forwardsButton(_ sender: UIButton) {
    }
    
    @IBAction func followButton(_ sender: UIButton) {
    }
    
    @IBAction func likeButton(_ sender: UIButton) {
    }
    
    @IBAction func dislikeButton(_ sender: UIButton) {
    }
    
    @IBAction func commentButton(_ sender: UIButton) {
    }
    
//    var uid: String = ""
    var postUser: User?
    var playAudio: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    //removed extra param: , user: User?
    func configure(with model: Post, for user: User?){
        self.likesCount.text = "\(4)"
        self.dislikesCount.text = "\(3)"
        self.commentsCount.text = "\(5)"
        
        self.postTitle.text = model.Name
        self.postDescription.text = model.Description
        //retrieves image from postphotos in storage
        let imageRef = Storage.storage().reference().child("postphotos").child(model.PostImg)
        //sets the image from the path to the UIImageView
        self.postImage.sd_setImage(with: imageRef)
        //fix user image when implement profile picture
        self.userImage.image = UIImage(named:"profile_pic_1")
        self.username.setTitle(user!.username, for: .normal)
        self.postUser = user
        
//        let userid = user?.uid
//        print(userid ?? "")
    }

    

}
