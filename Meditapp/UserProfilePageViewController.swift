//
//  UserProfilePageViewController.swift
//  Meditapp
//
//  Created by Karina Ionkina on 3/18/21.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage
import AVFoundation

class UserProfilePageViewController:  UIViewController, UITableViewDelegate, UITableViewDataSource {
   
    @IBOutlet var tableView: UITableView!
    @IBOutlet var username: UILabel!
    @IBOutlet var firstName: UILabel!
    @IBOutlet var lastName: UILabel!
    @IBOutlet var followBotton: UIButton!
    
    var audioPlayer = AVAudioPlayer()
    
    var audioReference: StorageReference{
        return Storage.storage().reference().child("recordings")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if (segue.identifier == "toComments") {
            let button = sender as! UIButton
            if let cell = button.superview?.superview as? postCellTableViewCell {
                    //print(cell.uid)
                    let vc = segue.destination as! CommentViewController
                    vc.postUser = self.postUser
                    vc.recording = cell.post
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as! postCellTableViewCell
        let recording = recordings[indexPath.row]
        //if user to current post found in dict
        //configure the cell
//        cell.configure(with: recording)
        cell.post = recording
        

        if User.current.likedPosts[recording.RecID] != nil{
            cell.setLiked(User.current.likedPosts[recording.RecID]!, recording.numLikes)
        }
        else{
            cell.setLiked(false, recording.numLikes)
        }
        
        if let user = postUser{
//            cell.configure(with: recording, user: user)
//            cell.configure(with: recording)
            //cell.uid = recordings[indexPath.row].OwnerID
            cell.configure(with: recording, for: user )
            cell.playAudio = {
                let downloadPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(recording.RecID)
                
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
            //cell.postUser = user
        }
        
        return cell
    }
    
    
    // MARK: - Table view data source

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return recordings.count
    }
    


//    var uid = String()
    var pfpReference: StorageReference{
        return Storage.storage().reference().child("profilephotos")
    }
    
    var postUser: User?
    var recordings: [Post] = [] 
    

    @IBOutlet weak var Pfp: UIImageView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
//        print("removing observer")
//        NotificationCenter.default.removeObserver(self)
    }
    
    
    
    override func viewDidLoad() {
        print("loading userprofile vc")
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        username.text = postUser?.firstName
        firstName.text = postUser?.lastName
        lastName.text = postUser?.username
        
//        print("in profile! uid: " + postUser!.uid)
        loadPfp()
        loadRecordings()
        NotificationCenter.default.addObserver(self, selector: #selector(handleLikes), name: Notification.Name("UpdateLikes"), object: nil)
        print("loading recordings in userprofiles")
        
//        NotificationCenter.default.addObserver(self, selector: #selector(handleComment), name: Notification.Name("UpdateComment"), object: nil)
    }
    
    @objc func handleLikes(notification: NSNotification) {
        print("like fired off handler in userprofile")
        if let dict = notification.object as? [String:Any] {
            for post in recordings{
                if post.RecID == dict["updateRecID"] as! String{
                    post.numLikes = dict["updateLikes"] as! Int
                }
            }
        }
    }
    
    @objc func handleComment(notification: NSNotification) {
        print("like fired off comment handler in userprofile")
        if let dict = notification.object as? [String:Any] {
            for post in recordings{
                if post.RecID == dict["updateRecID"] as! String{
                    post.numComments = dict["updateComment"] as! Int
                }
            }
        }
    }
    
    func loadRecordings() {
        DBViewController.getRecordings(for: postUser!.recordings) { (doc: DocumentSnapshot) in
            if (doc != nil) {
                self.recordings.append(Post(snapshot: doc)!)
//                print(self.recordings)
                self.tableView.reloadData()
            }
        }
    }
    
    //TODO : CHECK IF USER HAS IMAGE: BOOL.
    func loadPfp(){
        let downloadImageRef = pfpReference.child("default.jpeg")
        
        let downloadTask = downloadImageRef.getData(maxSize: 1024 * 1024 * 12) { (data, error) in
            if let data = data{
                let image = UIImage(data: data)
                self.Pfp.image = image
            }
            // print(error ?? "NONE")
        }
        
        downloadTask.resume()
    }
    
}
