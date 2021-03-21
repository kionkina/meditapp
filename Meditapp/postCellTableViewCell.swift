    //
//  postCellTableViewCell.swift
//  Meditapp
//
//  Created by Gabriella Alexis on 3/2/21.
//

import UIKit

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

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    //removed extra param: , user: User?
    func configure(with model: userPost, for user: User?){
        self.likesCount.text = "\(model.numLikes)"
        self.dislikesCount.text = "\(model.numDislikes)"
        self.commentsCount.text = "\(model.numComments)"
        
        self.postTitle.text = model.postTitle
        self.postDescription.text = model.postDescription
        self.postImage.image = UIImage(named: model.postImage)
        self.userImage.image = UIImage(named: model.userImage)
        self.username.setTitle(user!.username, for: .normal)
        
//        let userid = user?.uid
//        print(userid ?? "")
    }

}
