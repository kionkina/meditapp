//  postCellTableViewCell.swift
//  Meditapp
//
//  Created by Gabriella Alexis on 3/2/21.
//

import UIKit
import TaggerKit
import UserNotifications
import FirebaseStorage
import AVFoundation

class postCellTableViewCell: UITableViewCell, AVAudioPlayerDelegate  {
    
    var tagsCollection = TKCollectionView()
    
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
    
    @IBOutlet weak var sepLine: UIImageView?
    
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
        print("stop playing in cell is called")
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
            DBViewController.createLike(for: post!){ numofLikes in
                //update user likepost then store it back in userdefault.
                User.current.likedPosts.updateValue(true, forKey: self.post!.RecID)
                self.setLiked(true, numofLikes)
                
                for tag in self.post!.Tags{
                    if User.current.likedGenres[tag] != nil {
                        User.current.likedGenres[tag]! += 1
                    } else {
                        User.current.likedGenres[tag] = 1
                    }
                }
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
            DBViewController.destroyLike(for: post!){ numofLikes in
                User.current.likedPosts.removeValue(forKey: self.post!.RecID)
                self.setLiked(false, numofLikes)
                
                for tag in self.post!.Tags{
                    User.current.likedGenres[tag]! += 1
                }
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
    
    var postUser: User?
    var post: Post?
    var liked: Bool = false
//    var tagCollection = TKCollectionView()

    override func awakeFromNib() {
        super.awakeFromNib()
        postImage.layer.cornerRadius = 10
        userImage.layer.cornerRadius = userImage.frame.size.height/2
        

        let meditappColor = UIColor(red: 252.0/255.0, green: 228.0/255.0, blue: 164.0/255, alpha: 0.2)
        tags?.addSubview(tagsCollection.view)
        //tags?.subviews[0].layer.backgroundColor = CGColor(red: 252.0/255.0, green: 228.0/255.0, blue: 164.0/255, alpha: 0.3)
        tags?.subviews[0].layer.backgroundColor = CGColor(red: 252.0/255.0, green: 228.0/255.0, blue: 164.0/255, alpha: 0.25)
        //self.backgroundColor = meditappColor
        self.applyGradient(isVertical: true, colorArray: [.white, meditappColor])
        
        self.layer.cornerRadius = 20
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
        tagsCollection.customFont = UIFont.systemFont(ofSize: 12)
        tagsCollection.customBackgroundColor = UIColor(red: 252.0/255.0, green: 228.0/255.0, blue: 164.0/255, alpha: 1)
        tagsCollection.tagsCollectionView.reloadData()
        
        
        
        
        let imageRef = Storage.storage().reference().child("postphotos").child(model.PostImg)
        self.postImage.sd_setImage(with: imageRef)
        
        self.post = model
        
        //fix user image when implement profile picture
        self.username?.setTitle(user!.username, for: .normal)
        self.usernameLabel?.text = user!.username
        self.username?.setTitleColor(UIColor.black, for: .normal)
        self.username?.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.bold)
        self.time?.text = DBViewController.convertTime(stamp: model.Timestamp)
        
        self.userImage.sd_setImage(with: Storage.storage().reference().child("profilephotos").child(user!.profilePic))
        
        self.postUser = user
    }

    
    

}

extension UIView {

    func applyGradient(isVertical: Bool, colorArray: [UIColor]) {
        layer.sublayers?.filter({ $0 is CAGradientLayer }).forEach({ $0.removeFromSuperlayer() })
         
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = colorArray.map({ $0.cgColor })
        if isVertical {
            //top to bottom
            gradientLayer.locations = [0.0, 1.0]
        } else {
            //left to right
            gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
            gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        }
        
        backgroundColor = .clear
        gradientLayer.frame = bounds
        layer.insertSublayer(gradientLayer, at: 0)
    }

}
