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
    
    var pfpImage: UIImage?
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
        
        if indexPath.row == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "profileCell", for: indexPath) as! profileCell
            
            cell.firstNameLabel.text = postUser?.firstName
            cell.lastNameLabel.text = postUser?.lastName
            if let pfpImage = pfpImage{
                cell.profileImageView.image = pfpImage
                return cell
            }
            else{
                print("did not download image yet")
                return cell
            }
        }
        else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as! postCellTableViewCell
            let recording = recordings[indexPath.row - 1]
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
    }
    
    
    // MARK: - Table view data source

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1 + recordings.count
    }
    


//    var uid = String()
    var pfpReference: StorageReference{
        return Storage.storage().reference().child("profilephotos")
    }
    
    var postUser: User?
    var recordings: [Post] = [] 
    
    let myRefreshControl = UIRefreshControl()

    @IBOutlet weak var Pfp: UIImageView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        print("loading userprofile vc")
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        myRefreshControl.addTarget(self, action: #selector(refreshReload), for: .valueChanged)
        tableView.refreshControl = myRefreshControl
        
//        username.text = postUser?.firstName
        navigationItem.title = postUser?.username
//        firstName.text = postUser?.lastName
//        lastName.text = postUser?.username
        
//        print("in profile! uid: " + postUser!.uid)
//        loadPfp()
        
        //change eventually to user.profileimage
        loadPfp(forImageName: "default.jpeg")
        loadRecordings()
//        NotificationCenter.default.addObserver(self, selector: #selector(handleLikes), name: Notification.Name("UpdateLikes"), object: nil)
        
//        NotificationCenter.default.addObserver(self, selector: #selector(handleComment), name: Notification.Name("UpdateComment"), object: nil)
    }
    
    @objc func refreshReload(){
        print("i have refreshed")
        recordings.removeAll()
        tableView.reloadData()
        loadRecordings()
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
                self.myRefreshControl.endRefreshing()
            }
        }
    }
    
    //TODO : CHECK IF USER HAS IMAGE: BOOL.
    func loadPfp(forImageName imageName: String){
        let downloadImageRef = pfpReference.child("\(imageName)")
        
        let downloadTask = downloadImageRef.getData(maxSize: 1024 * 1024 * 12) { (data, error) in
            if let error = error{
                print("error, \(error.localizedDescription)")
            }
            if let data = data{
                print("i have image data")
                let image = UIImage(data: data)
                self.pfpImage = image
                self.tableView.reloadData()
            }
            // print(error ?? "NONE")
        }
        
        downloadTask.resume()
    }
    
}
