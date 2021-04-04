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
                vc.postUser = cell.postUser
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
//        print("recording from firebase is ", audioReference.child(recording.Name))
        //if user to current post found in dict
        
        cell.configure(with: recording, for: User.current)
        
        cell.playAudio = {
            let downloadPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(recording.RecID)

            print("DOWNLOAD TO URL", downloadPath)
            let audioRef = self.audioReference.child(recording.Name)

            let downloadTask = audioRef.write(toFile: downloadPath){ url, error in
                if let error = error{
                    print("Error has occured")
                }
                else{
                    do {
                        self.audioPlayer.stop()
                        self.audioPlayer = try AVAudioPlayer(contentsOf: url!)
                        self.audioPlayer.play()
                    } catch {
                        print(error)
                    }
                }
            }
            downloadTask.resume()
        }
        cell.postUser = User.current
        
        return cell
    }
    
    override func viewDidLoad() {
        tableView.delegate = self
        tableView.dataSource = self
        
        firstName.text = User.current.firstName
        lastName.text = User.current.lastName
        userName.text = User.current.username
        
        authHandle = AuthService.authListener(viewController: self)
    
        loadRecordings()
        configure()

        super.viewDidLoad()
    
    }
    
    func configure()
    {
        let profilePicRef = Storage.storage().reference().child("profilephotos").child(User.current.profilePic)
        
        self.Pfp.sd_setImage(with: profilePicRef)
        
    }
    
    func loadRecordings(){
        DBViewController.getRecordings(for: User.current.recordings) { (doc: DocumentSnapshot) in
            if(doc != nil){
                self.recordings.append(Post(snapshot: doc)!)
                print(self.recordings)
                self.tableView.reloadData()
            }
        }
    }
    
    @IBAction func logOut(_ sender: Any) {
        AuthService.presentLogOut(viewController: self)
    }
}
