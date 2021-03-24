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
    @IBOutlet weak var likeButton: UIButton!
    
    
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
    
    func setLiked(_ isLiked: Bool){
        liked = isLiked
        if(liked){
            DispatchQueue.main.async{
                self.likeButton.isSelected = true
            }
//            likeButton.setImage(UIImage(named: "heartfilled"), for: UIControl.State.selected)
        }
        else{
            DispatchQueue.main.async{
                self.likeButton.isSelected = false
            }
//            likeButton.setImage(UIImage(named: "heart"), for: UIControl.State.normal)
        }
    }
    
    @IBAction func likeButton(_ sender: UIButton) {
        let like = !liked
        if(like){
            DBViewController.updateLikes(for: post!.RecID){
                User.current.likedPosts[self.post!.RecID] = true
                self.setLiked(true)
            }
        }
        else{
//            TwitterAPICaller.client?.destroyFavTweet(tweetID: tweetID, success: {
//                self.setFavorite(false)
//            }, failure: { (Error) in
//                print("Could not like")
//            })
        }
    }
    
    @IBAction func dislikeButton(_ sender: UIButton) {
    }
    
    @IBAction func commentButton(_ sender: UIButton) {
    }
    
//    var uid: String = ""
    var postUser: User?
    var post: Post?
    var liked: Bool = false
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
        self.postImage.image = UIImage(named: "sunrise")
        self.userImage.image = UIImage(named:"profile_pic_1")
        self.username.setTitle(user!.username, for: .normal)
        
        self.likesCount.text = String(model.numLikes)
        
        self.postUser = user
        self.post = model
    }

    

}
