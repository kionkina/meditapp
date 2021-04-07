//  postCellTableViewCell.swift
//  Meditapp
//
//  Created by Gabriella Alexis on 3/2/21.
//

import UIKit
import UserNotifications
import FirebaseStorage
import AVFoundation

class postCellTableViewCell: UITableViewCell, AVAudioPlayerDelegate  {
    
    @IBOutlet weak var postTitle: UILabel!
    @IBOutlet weak var postDescription: UILabel!
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var userImage: UIImageView!
    
    @IBOutlet weak var likesCount: UILabel?
    @IBOutlet weak var time: UILabel?
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    
    
    @IBOutlet weak var commentsCount: UILabel?
    @IBOutlet weak var username:UIButton!
    @IBOutlet weak var usernameLabel: UILabel?
    
    @IBOutlet weak var sepLine: UIImageView?
    
    
    func playDownloadedAudio(forPath path: URL){
        do{
            print("about to play audio")
            HomePageViewController.playingCell = self
            
            HomePageViewController.audioPlayer = try AVAudioPlayer(contentsOf: path)
            
            HomePageViewController.audioPlayer.delegate = self
            HomePageViewController.audioPlayer.play()
            playButton.setImage(UIImage(named: "stop.circle"), for: UIControl.State.normal)
        }
        catch{
            print("there was error playing audio", error.localizedDescription)
        }
    }
    
    func downloadThenPlay(){
        let downloadPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(post!.RecID)
        
        print(downloadPath, "path for file i gonna play")
        if !FileManager.default.fileExists(atPath: downloadPath.path){
            let audioRef = Storage.storage().reference().child("recordings").child(post!.RecID)
            
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
        if (!HomePageViewController.audioPlayer.isPlaying){
            HomePageViewController.playingCell = self
            downloadThenPlay()
        }
        else{
            if(HomePageViewController.playingCell != nil && HomePageViewController.playingCell == self){
                stopPlaying()
            }
            else if (HomePageViewController.playingCell != nil && HomePageViewController.playingCell != self){
                HomePageViewController.playingCell?.stopPlaying()
                downloadThenPlay()
            }
        }
    }
    
    func stopPlaying(){
        HomePageViewController.audioPlayer.stop()
        HomePageViewController.audioPlayer.delegate = nil
        playButton.setImage(UIImage(named: "play.circle"), for: UIControl.State.normal)
    }
    
    func audioPlayerDidFinishPlaying(_: AVAudioPlayer, successfully: Bool){
        print("finished playing")
        playButton.setImage(UIImage(named: "play.circle"), for: UIControl.State.normal)
        HomePageViewController.audioPlayer.delegate = nil
    }
    
    @IBAction func backwardsButton(_ sender: UIButton) {
    }
    
    @IBAction func forwardsButton(_ sender: UIButton) {
    }
    
    @IBAction func followButton(_ sender: UIButton) {
        
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
            DBViewController.createLike(for: post!.RecID){ numofLikes in
                //update user likepost then store it back in userdefault.
                User.current.likedPosts.updateValue(true, forKey: self.post!.RecID)
                self.setLiked(true, numofLikes)
                
                let updateDict = [
                    "updateRecID":self.post!.RecID,
                    "updateLikes":numofLikes
                ] as [String : Any]
                
                NotificationCenter.default.post(name: Notification.Name("UpdateLikes"), object: updateDict)
                
                let userLikedPosts:[String:Bool] =  User.current.likedPosts
                defaults.set(userLikedPosts, forKey: "UserLikedPosts")

            }
        }
        else{
            DBViewController.destroyLike(for: post!.RecID){ numofLikes in
                User.current.likedPosts.removeValue(forKey: self.post!.RecID)
                self.setLiked(false, numofLikes)

                let updateDict = [
                    "updateRecID":self.post!.RecID,
                    "updateLikes":numofLikes
                ] as [String : Any]
                
                NotificationCenter.default.post(name: Notification.Name("UpdateLikes"), object: updateDict)
                
                let userLikedPosts:[String:Bool] =  User.current.likedPosts
                defaults.set(userLikedPosts, forKey: "UserLikedPosts")

            }
        }
    }
    
    @IBAction func commentButton(_ sender: UIButton) {
    }
    
//    var uid: String = ""
    var postUser: User?
    var post: Post?
    var liked: Bool = false

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    //removed extra param: , user: User?
    func configure(with model: Post, for user: User?){
        self.commentsCount?.text = "\(model.numComments)"
        
        self.postTitle.text = model.Name
        self.postDescription.text = model.Description
        //retrieves image from postphotos in storage
        let profilePicRef = Storage.storage().reference().child("profilephotos").child(user!.profilePic)
//        print("setting     postimage with", model.PostImg)
        
        self.userImage.sd_setImage(with: Storage.storage().reference().child("profilephotos").child(user!.profilePic))
        
//        let downloadTask = profilePicRef.getData(maxSize: 600 * 400 * 12) { (data, error) in
//            if let error = error{
//                print("error, \(error.localizedDescription)")
//            }
//            if let data = data{
//                let image = UIImage(data: data)
//                self.userImage.image = image
//                self.userImage.layer.cornerRadius = self.userImage.frame.height/2
//                self.userImage.clipsToBounds = true
//            }
//            // print(error ?? "NONE")
//        }
        
        let imageRef = Storage.storage().reference().child("postphotos").child(model.PostImg)
        //sets the image from the path to the UIImageView
        self.postImage.sd_setImage(with: imageRef)
        
        //fix user image when implement profile picture
        self.username?.setTitle(user!.username, for: .normal)
        self.usernameLabel?.text = user!.username
        self.time?.text = DBViewController.convertTime(stamp: model.Timestamp)
        
        self.postUser = user
        self.post = model
    }

    

}
