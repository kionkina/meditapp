//  postCellTableViewCell.swift
//  Meditapp
//
//  Created by Gabriella Alexis on 3/2/21.
//

import UIKit
import UserNotifications

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
    
    func setLiked(_ isLiked: Bool, _ numofLikes: Int){
        liked = isLiked
//        print("Am i in wtf?")
        if(liked){
            DispatchQueue.main.async{
                self.likeButton.isSelected = true
                self.likesCount.text = String(numofLikes)
            }
//            likeButton.setImage(UIImage(named: "heartfilled"), for: UIControl.State.selected)
        }
        else{
            DispatchQueue.main.async{
                self.likeButton.isSelected = false
                self.likesCount.text = String(numofLikes)
            }
//            likeButton.setImage(UIImage(named: "heart"), for: UIControl.State.normal)
        }
    }
    
    @IBAction func likeButton(_ sender: UIButton) {
        let like = !liked
        let defaults = UserDefaults.standard

        if(like){
            DBViewController.createLike(for: post!.RecID){ numofLikes in
                //update user likepost then store it back in userdefault.
                User.current.likedPosts.updateValue(true, forKey: self.post!.RecID)
                self.setLiked(true, numofLikes)
                
                let updateDict = [
                    "updateRecID":self.post!.RecID,
                    "updateLikes":numofLikes
                ] as [String : Any]
                
                NotificationCenter.default.post(name: Notification.Name("UpdateLikes"), object: updateDict)
                
                print(self.post!.numLikes, "ADDING IN PCT")
                print(User.current.likedPosts, "THIS IS AFTER LIKED")
                
                let userLikedPosts:[String:Bool] =  User.current.likedPosts
                defaults.set(userLikedPosts, forKey: "UserLikedPosts")

            }
        }
        else{
            DBViewController.destroyLike(for: post!.RecID){ numofLikes in
                User.current.likedPosts.removeValue(forKey: self.post!.RecID)
                self.setLiked(false, numofLikes)
                print(User.current.likedPosts, "THIS IS AFTER DISLIKED")

                let updateDict = [
                    "updateRecID":self.post!.RecID,
                    "updateLikes":numofLikes
                ] as [String : Any]
                
                NotificationCenter.default.post(name: Notification.Name("UpdateLikes"), object: updateDict)
                
                print(self.post!.numLikes, "SUBT IN PCT")
                
                let userLikedPosts:[String:Bool] =  User.current.likedPosts
                defaults.set(userLikedPosts, forKey: "UserLikedPosts")

            }
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
//        self.likesCount.text = "\(4)"
        self.dislikesCount.text = "\(3)"
        self.commentsCount.text = "\(5)"
        
        self.postTitle.text = model.Name
        self.postDescription.text = model.Description
        self.postImage.image = UIImage(named: "sunrise")
        self.userImage.image = UIImage(named:"profile_pic_1")
        self.username.setTitle(user!.username, for: .normal)
        
//        self.likesCount.text = String(model.numLikes)
        
        self.postUser = user
        self.post = model
    }

    

}
