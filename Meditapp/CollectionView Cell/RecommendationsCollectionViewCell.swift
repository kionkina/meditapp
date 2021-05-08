//
//  RecommendationsCollectionViewCell.swift
//  Meditapp
//
//  Created by Jackson Lu on 4/19/21.
//

import UIKit
import FirebaseStorage
import TaggerKit
class RecommendationsCollectionViewCell: UICollectionViewCell {
    static let identifier = "RecommendationsCollectionViewCell"
    
    static func nib() -> UINib{
        return UINib(nibName: "RecommendationsCollectionViewCell", bundle: nil)
    }
    
    var userPost:Post?
    var postUser:User?
    
    @IBOutlet weak var postTitle: UILabel!
    @IBOutlet weak var postDesc: UILabel!
    @IBOutlet weak var postImage: UIImageView!
    
    @IBOutlet weak var userName: UIButton!
    @IBOutlet weak var userImage: UIImageView!
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var tagView: UIView!
    
    //tags view also
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    public func configure(withPost userPost:Post, forUser postUser:User, forView view:TKCollectionView){
        postTitle.text = userPost.Name
        postDesc.text = userPost.Description
        
        let postImageRef = Storage.storage().reference().child("postphotos").child(userPost.PostImg)
        
        postImage.sd_setImage(with: postImageRef)
        
        userName.setTitle(postUser.username, for: .normal) 
        let userPfpRef = Storage.storage().reference().child("profilephotos").child(postUser.profilePic)
        
        userImage.sd_setImage(with: userPfpRef)
        
        tagView.addSubview(view.view)
    }

}
