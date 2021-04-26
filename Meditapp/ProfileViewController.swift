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
    }
    
    
    //VARIABLES
    var authHandle: AuthStateDidChangeListenerHandle?
     
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var Pfp: UIImageView!
    
    @IBOutlet weak var firstName: UILabel!
    @IBOutlet weak var lastName: UILabel!
    @IBOutlet weak var userName: UILabel!
    
    
    var audioPlayer = AVAudioPlayer()
    var firstTimeLoaded = false
    
    var audioReference: StorageReference{
        return Storage.storage().reference().child("recordings")
    }
    
//    var postUser: User?
    var recordings: [Post] = []
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recordings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
        
        cell.configure(with: recording, for: User.current, tagger: nil)
        cell.selectionStyle = UITableViewCell.SelectionStyle.none

        print("displaying cell numero: ", indexPath.row)
        cell.postUser = User.current
        
        return cell
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if HomePageViewController.audioPlayer.isPlaying{
            print("player needs to stop playing")
            HomePageViewController.playingCell?.stopPlaying()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        print(postUser!.profilePic, "updated pfp")
        print(recordings.count, "recording count in viewwillappear")
        print(User.current.recordings.count, "user recording count in viewwillappear")
        if(recordings.count != 0 && User.current.recordings.count > recordings.count){
            print("post mustve been added")
            recordings.removeAll()
            configure()
        }
    }
    
    override func viewDidLoad() {
        print("In profile vc")
        tableView.delegate = self
        tableView.dataSource = self
//        UserService.show(forUID: User.current.uid, completion: { (user) in
//            User.current = user
//            self.configure()
//        })
//        postUser = User.current
        configure()
        
        print("view did load for profile")

        super.viewDidLoad()
    
    }
    
    func configure()
    {
        
        firstName.text = User.current.firstName
        lastName.text = User.current.lastName
        userName.text = User.current.username
        
        authHandle = AuthService.authListener(viewController: self)
    
//        print(postUser!.recordings, "recordings in profile vc")
        loadRecordings()
        
        let profilePicRef = Storage.storage().reference().child("profilephotos").child(User.current.profilePic)
        
        self.Pfp.sd_setImage(with: profilePicRef)
        
//        let downloadTask = profilePicRef.getData(maxSize: 1024 * 1024 * 12) { (data, error) in
//            if let error = error{
//                print("error, (error.localizedDescription)")
//            }
//            if let data = data{
//                print("i have image data")
//                let image = UIImage(data: data)
//                self.Pfp.image = image
//                self.Pfp.layer.cornerRadius = self.Pfp.frame.height/2
//                self.Pfp.clipsToBounds = true
//            }
//            // print(error ?? "NONE")
//        }
    }
    
    func loadRecordings(){
        DBViewController.getRecordings(for: User.current.recordings) { (doc: DocumentSnapshot) in
            if(doc != nil){
                self.recordings.append(Post(snapshot: doc)!)
                self.recordings.sort(by: { $0.Timestamp.dateValue() > $1.Timestamp.dateValue() })
                print(self.recordings)
                self.tableView.reloadData()
            }
        }
    }
    
    @IBAction func logOut(_ sender: Any) {
        AuthService.presentLogOut(viewController: self)
    }
}
