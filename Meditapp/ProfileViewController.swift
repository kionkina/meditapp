//
//  MainViewController.swift
//  Firebase-boilerplate
//
//  Created by Mariano Montori on 7/24/17.
// Edited by Gabriella Alexis on 3/29/21
//  Copyright © 2017 Mariano Montori. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import AVFoundation

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UploadPicDelegate {
    
    
    func UploadedPic(forController controller: UploadPicViewController, forImagePath updatedPic: UIImage) {
//        print("Delegate has been called")
//        print("image url", updatedPic)
        DispatchQueue.main.async {
            self.Pfp.image = updatedPic
            self.tableView.reloadData()
        }
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "uploadPFP"{
            let viewcontroller = segue.destination as! UploadPicViewController
            viewcontroller.delegate = self
        }
        else if (segue.identifier == "toComments") {
            let button = sender as! UIButton
            if let cell = button.superview?.superview as? postCellTableViewCell {
                    //print(cell.uid)
                let vc = segue.destination as! CommentViewController
                vc.postUser = User.current
                vc.recording = cell.post
            }
        }
        else if (segue.identifier == "toFollowers") {
                    let vc = segue.destination as! followersViewController
                    vc.followers = true
                    vc.userIds = User.current.followers
                    vc.numIds = User.current.numFollowers
            }
            else if (segue.identifier == "toFollowing") {
                    let vc = segue.destination as! followersViewController
                    vc.followers = false
                    vc.userIds = User.current.following
                    vc.numIds = User.current.numFollowing
            }
        }
    
    
    //VARIABLES
    var authHandle: AuthStateDidChangeListenerHandle?
     
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var Pfp: UIImageView!
    
    @IBOutlet weak var fullname: UILabel!
    @IBOutlet weak var userName: UILabel!
    
    @IBOutlet weak var numFollowers: UILabel!
    @IBOutlet weak var numFollowing: UILabel!
    
//    var firstTimeLoaded = false
    
    var audioReference: StorageReference{
        return Storage.storage().reference().child("recordings")
    }
    
//    var postUser: User?
    var recordings: [Post] = []
    let myRefreshControl = UIRefreshControl()

    
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recordings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isFetching{
            print("displaying loading cell")
            let cell = tableView.dequeueReusableCell(withIdentifier: "LoadingCell", for: indexPath)
            let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
            
            spinner.startAnimating()
            return cell
        }
        else{
            print("isfetching is false")
            let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as! postCellTableViewCell
            
            let recording = recordings[indexPath.row]
            cell.post = recording
            
            //set whether the post has already been liked when displaying cells.
            if User.current.likedPosts[recording.RecID] != nil{
                cell.setLiked(User.current.likedPosts[recording.RecID]!, recording.numLikes)
            }
            else{
                cell.setLiked(false, recording.numLikes)
            }
            
    //        cell.configure(with: recording, for: User.current, tagger: nil)
            cell.configure(with: recording, for: User.current)
            cell.selectionStyle = UITableViewCell.SelectionStyle.none

            cell.postUser = User.current
            
            return cell
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if HomePageViewController.audioPlayer.isPlaying{
            print("player needs to stop playing")
            HomePageViewController.playingCell?.stopPlaying()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
////        print(postUser!.profilePic, "updated pfp")
//        print(recordings.count, "recording count in viewwillappear")
//        print(User.current.recordings.count, "user recording count in viewwillappear")
//        if(recordings.count != 0 && User.current.recordings.count > recordings.count){
//            print("post mustve been added")
//            recordings.removeAll()
//            configure()
//        }
        if firstTime{
            firstTime.toggle()
        }
        else{
            loadRecordings()
        }
    }
    
    var firstTime = false
    override func viewDidLoad() {
        print("In profile vc")
        tableView.delegate = self
        tableView.dataSource = self
        configure()
        
        myRefreshControl.addTarget(self, action: #selector(refreshReload), for: .valueChanged)
        tableView.refreshControl = myRefreshControl
        
        super.viewDidLoad()
    
        firstTime = true
    }
    
    @objc func refreshReload(){
        recordings.removeAll()
        loadRecordings()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("view did appear")
        if (numFollowing.text != String(User.current.numFollowing)) {
            numFollowing.text = String(User.current.numFollowing)
        }
        if (numFollowers.text != String(User.current.numFollowers)) {
            numFollowers.text = String(User.current.numFollowers)
        }
    }
    
    func configure()
    {
        
        fullname.text = User.current.firstName + User.current.lastName
        userName.text = User.current.username
        numFollowers.text = String(User.current.numFollowers)
        numFollowing.text = String(User.current.numFollowing)
        
        authHandle = AuthService.authListener(viewController: self)
    
//        print(postUser!.recordings, "recordings in profile vc")
        loadRecordings()
        
        let profilePicRef = Storage.storage().reference().child("profilephotos").child(User.current.profilePic)
        
        self.Pfp.sd_setImage(with: profilePicRef)
    
    }
    
    var isFetching = true
    
    func loadRecordings(){
        print("load recordings called")
        DispatchQueue.main.async {
            self.myRefreshControl.endRefreshing()
            self.isFetching = true
            self.recordings.removeAll()
            self.tableView.reloadData()
        }
        
        let userRecs = User.current.recordings.map{ Array($0.values)[0] }

        DBViewController.getRecordings(for: userRecs) { (doc: DocumentSnapshot) in
            self.recordings.append(Post(snapshot: doc)!)
            self.recordings.sort(by: { $0.Timestamp.dateValue() > $1.Timestamp.dateValue() })
            print(self.recordings)
            DispatchQueue.main.async {
                self.isFetching = false
                self.tableView.reloadData()
            }
        }
    }
    
    @IBAction func logOut(_ sender: Any) {
        AuthService.presentLogOut(viewController: self)
    }
}
