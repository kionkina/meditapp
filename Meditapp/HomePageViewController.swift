//
//  HomePageViewController.swift
//  Meditapp
//
//  Created by Jackson Lu on 3/20/21.
//
import AVFoundation
import UIKit
import FirebaseFirestore
import FirebaseStorage

class HomePageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var tableView: UITableView!

    var recordings = [Post]()
    var users = [String: User?]()
    var audioPlayer = AVAudioPlayer()
    
    var audioReference: StorageReference{
        return Storage.storage().reference().child("recordings")
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "toProfile") {
            let button = sender as! UIButton
            if let cell = button.superview?.superview as? postCellTableViewCell {
                //print(cell.uid)
                let vc = segue.destination as! UserProfilePageViewController
                vc.postUser = cell.postUser
            }
        }
    }
    
    func loadRecordings(success: @escaping(() -> Void)) {
        DBViewController.getPostsByTags(forTags: User.current.tags) { docs in
            for doc in docs{
                self.recordings.append(doc)
            }
            success()
        }
    }
    
    func loadUsers() -> Void {
        print("loadUsers")
        //check if ID is not already in users
        for recording in recordings {
            if !users.keys.contains(recording.OwnerID) {
                DBViewController.getUserById(forUID: recording.OwnerID) { (user) in
                    //instantiate user using snapshot, append to users dict
                    print("before let user")
                    if let user = user {
                        print("after let user")
                        self.users[user.uid] = user
                        print(self.users)
                        print("reloaded")
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(User.current.uid, "FOLLOWED BY THE TAGS", User.current.tags)
        loadRecordings(success: loadUsers)

    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as! postCellTableViewCell
        
        let recording = recordings[indexPath.row]
        //if user to current post found in dict
        //configure the cell
//        cell.configure(with: recording)
        if let user = users[recording.OwnerID]{
//            cell.configure(with: recording, user: user)
//            cell.configure(with: recording)
            //cell.uid = recordings[indexPath.row].OwnerID
            cell.configure(with: recording, for: user )
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
                            self.audioPlayer = try AVAudioPlayer(contentsOf: url!)
                            print("ABOUTTA PLAY AUDIO")
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
    
    

}

/* USE POST OBJECT instead
struct userPost {
    let postTitle: String
    let postDescription: String
    let postImage: String //will change later
    let userImage: String
    let numLikes: Int
    let numDislikes: Int
    let numComments: Int
    let OwnerID: String
}*/



