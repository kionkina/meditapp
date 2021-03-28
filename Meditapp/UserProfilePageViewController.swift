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
    
//
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        tableView.reloadData()
//    }
//
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        username.text = postUser?.firstName
        firstName.text = postUser?.lastName
        lastName.text = postUser?.username
        
//        print("in profile! uid: " + postUser!.uid)
        loadPfp()
        loadRecordings()
        print("loading recordings in userprofiles")
        // Do any additional setup after loading the view.
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
