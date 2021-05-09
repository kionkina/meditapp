//
//  RecommendationsCollectionViewCell.swift
//  Meditapp
//
//  Created by Jackson Lu on 4/19/21.
//

import UIKit
import FirebaseStorage
import TaggerKit
import AVFoundation
class RecommendationsCollectionViewCell: UICollectionViewCell, AVAudioPlayerDelegate {
    static let identifier = "RecommendationsCollectionViewCell"
    
    static func nib() -> UINib{
        return UINib(nibName: "RecommendationsCollectionViewCell", bundle: nil)
    }
    
    var userPost:Post?
    var postUser:User?
    
    @IBOutlet weak var postTitle: UILabel!
    @IBOutlet weak var postDescription: UILabel!
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var userImage: UIImageView!
    
    @IBOutlet weak var likesCount: UILabel?
    @IBOutlet weak var time: UILabel?
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    
    
    @IBOutlet weak var tags: UIView?
    
    @IBOutlet weak var commentsCount: UILabel?
    @IBOutlet weak var username:UIButton!
    @IBOutlet weak var usernameLabel: UILabel?
    
    var liked: Bool = false
    
    deinit {
        for view in tags!.subviews{
            view.removeFromSuperview()
        }
        print("cell deinited")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()

    }
    
    func playDownloadedAudio(forPath path: URL){
        do{
            print("about to play audio")
            ExplorePageViewController.playingCell = self
            
            ExplorePageViewController.audioPlayer = try AVAudioPlayer(contentsOf: path)
            
            ExplorePageViewController.audioPlayer.delegate = self
            ExplorePageViewController.audioPlayer.play()
            playButton.setImage(UIImage(named: "stop.circle"), for: UIControl.State.normal)
        }
        catch{
            print("there was error playing audio", error.localizedDescription)
        }
    }
    
    func downloadThenPlay(){
        let downloadPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(userPost!.RecID)
        
        print(downloadPath, "path for file i gonna play")
        if !FileManager.default.fileExists(atPath: downloadPath.path){
            let audioRef = Storage.storage().reference().child("recordings").child(userPost!.RecID)
            
            let downloadTask = audioRef.write(toFile: downloadPath){ url, error in
                if let error = error{
                    print("Error has occured: ", error.localizedDescription)
                }
                else{
                    print("i have to download")
                    self.playDownloadedAudio(forPath: downloadPath)
                }
            }
            downloadTask.resume()
        }
        else{
            print("already downloaded")
            playDownloadedAudio(forPath: downloadPath)
        }
    }
    @IBAction func playButton(_ sender: UIButton) {
        if (!ExplorePageViewController.audioPlayer.isPlaying){
            ExplorePageViewController.playingCell = self
            downloadThenPlay()
        }
        else{
            if(ExplorePageViewController.playingCell != nil && ExplorePageViewController.playingCell == self){
                stopPlaying()
            }
            else if (ExplorePageViewController.playingCell != nil && ExplorePageViewController.playingCell != self){
                ExplorePageViewController.playingCell?.stopPlaying()
                downloadThenPlay()
            }
        }
    }
    
    func stopPlaying(){
        print("stop playing in cell is called")
        ExplorePageViewController.audioPlayer.stop()
        ExplorePageViewController.audioPlayer.delegate = nil
        playButton.setImage(UIImage(named: "play.circle"), for: UIControl.State.normal)
    }
    
    func audioPlayerDidFinishPlaying(_: AVAudioPlayer, successfully: Bool){
        print("finished playing")
        playButton.setImage(UIImage(named: "play.circle"), for: UIControl.State.normal)
        ExplorePageViewController.audioPlayer.delegate = nil
    }

    func setLiked(_ isLiked: Bool, _ numofLikes: Int){
        liked = isLiked
        if(liked){
            DispatchQueue.main.async{
                self.likeButton.isSelected = true
                self.likesCount?.text = String(numofLikes)
            }
        }
        else{
            DispatchQueue.main.async{
                self.likeButton.isSelected = false
                self.likesCount?.text = String(numofLikes)
            }
        }
    }
    
    @IBAction func likeButton(_ sender: UIButton) {
        let like = !liked
        let defaults = UserDefaults.standard

        if(like){
            DBViewController.createLike(for: userPost!){ numofLikes in
                //update user likepost then store it back in userdefault.
                User.current.likedPosts.updateValue(true, forKey: self.userPost!.RecID)
                self.setLiked(true, numofLikes)
                
                for tag in self.userPost!.Tags{
                    if User.current.likedGenres[tag] != nil {
                        User.current.likedGenres[tag]! += 1
                    } else {
                        User.current.likedGenres[tag] = 1
                    }
                }
                let updateDict = [
                    "updateRecID":self.userPost!.RecID,
                    "updateLikes":numofLikes
                ] as [String : Any]
                
                NotificationCenter.default.post(name: Notification.Name("UpdateLikes"), object: updateDict)
                
                let userLikedPosts:[String:Bool] =  User.current.likedPosts
                defaults.set(userLikedPosts, forKey: "UserLikedPosts")
                

            }
        }
        else{
            DBViewController.destroyLike(for: userPost!){ numofLikes in
                User.current.likedPosts.removeValue(forKey: self.userPost!.RecID)
                self.setLiked(false, numofLikes)
                
                for tag in self.userPost!.Tags{
                    User.current.likedGenres[tag]! += 1
                }
                let updateDict = [
                    "updateRecID":self.userPost!.RecID,
                    "updateLikes":numofLikes
                ] as [String : Any]
                
                NotificationCenter.default.post(name: Notification.Name("UpdateLikes"), object: updateDict)
                
                let userLikedPosts:[String:Bool] =  User.current.likedPosts
                defaults.set(userLikedPosts, forKey: "UserLikedPosts")

            }
        }
    }
    
    var tagsCollection = TKCollectionView()

    override func awakeFromNib() {
        super.awakeFromNib()
        postImage.layer.cornerRadius = 10
        userImage.layer.cornerRadius = userImage.frame.size.height/2

        tags?.addSubview(tagsCollection.view)
    }

    func configure(with model: Post, for user: User?){
        self.commentsCount?.text = "\(model.numComments)"
        self.postTitle.text = model.Name
        self.postDescription.text = model.Description
       
//        if tagView != nil{
//            self.tags?.addSubview(tagView!.view)
//        }
//        print("post tags are \(model.Tags)")
        tagsCollection.tags = model.Tags
        tagsCollection.tagsCollectionView.reloadData()
        
        let imageRef = Storage.storage().reference().child("postphotos").child(model.PostImg)
        self.postImage.sd_setImage(with: imageRef)
        
        self.userPost = model
        
        //fix user image when implement profile picture
        self.username?.setTitle(user!.username, for: .normal)
        self.usernameLabel?.text = user!.username
        self.time?.text = DBViewController.convertTime(stamp: model.Timestamp)
        
        self.userImage.sd_setImage(with: Storage.storage().reference().child("profilephotos").child(user!.profilePic))
        
        self.postUser = user
    }
    
    @IBAction func profileClicked(_ sender: Any) {
        print("about to fire off notification")
        NotificationCenter.default.post(name: Notification.Name("profileClicked"), object: postUser!)
    }
    
    @IBAction func commentsClicked(_ sender: Any) {
        print("about to fire off notification")
        let dict = [
            "user": postUser,
            "post": userPost
        ]
        NotificationCenter.default.post(name: Notification.Name("commentsClicked"), object: dict)
    }
    
    
}


