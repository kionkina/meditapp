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

class CommentViewController:  UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var postUser: User?
    var recording: Post?
    var users: [String: User] = [:]
    var comments : [Comment] = []
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var commentTableView: UITableView!
    @IBOutlet weak var commentText: UITextField!
    @IBOutlet weak var postCommentButton: UIButton!

    
    var audioPlayer = AVAudioPlayer()
    
    var audioReference: StorageReference{
        return Storage.storage().reference().child("recordings")
    }
    
    func loadComments(success: @escaping(() -> Void)) {
        DBViewController.getCommentsById(forPost: (recording?.RecID)!) { (docs) in
            for doc in docs{
                self.comments.append(Comment(snapshot: doc)!)
            }
    
        }
    }
    
    func loadUsers() -> Void {
        print("loadUsers")
        //check if ID is not already in users
        for comment in comments {
            if !users.keys.contains(comment.OwnerID) {
                DBViewController.getUserById(forUID: comment.OwnerID) { (user) in
                    //instantiate user using snapshot, append to users dict
                    if let user = user {
                        self.users[user.uid] = user
                        self.commentTableView.reloadData()
                    }
                }
            }
        }
    }
    
    @IBAction func postComment(_ sender: Any) {
        //connect to firestore
        
        let OwnerID = User.current.uid
        let stamp = Timestamp(date: Date())
        let Content = commentText.text!
        let comment = Comment(Content: Content, OwnerID: OwnerID, Timestamp: stamp)
        
        print("inserting")
        print(comment)
        DBViewController.insertComment(postID: self.recording!.RecID, comment: comment) {
            self.loadComments {
                self.commentTableView.reloadData()
            }
        }

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (tableView === self.tableView) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as! postCellTableViewCell

            cell.post = recording
            
            //set whether the post has already been liked when displaying cells.
            if User.current.likedPosts[self.recording!.RecID] != nil{
                cell.setLiked(User.current.likedPosts[self.recording!.RecID]!, self.recording!.numLikes)
            }
            else{
                cell.setLiked(false, self.recording!.numLikes)
            }
            //if user to current post found in dict
            if let user = postUser{
                cell.configure(with: self.recording!, for: user )
                
                cell.playAudio = {
                    let downloadPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(self.recording!.RecID)
                    
                    print("DOWNLOAD TO URL", downloadPath)
                    let audioRef = self.audioReference.child(self.recording!.Name)
                    
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
        else if (tableView === self.commentTableView) {
            print("in comment table")
        let cell = tableView.dequeueReusableCell(withIdentifier: "sampleComment", for: indexPath) as!commentCellTableViewCell
            
            let comment = comments[indexPath.row]
            cell.comment = comment
            
            //if user to current post found in dict
            if let user = users[comment.OwnerID]{
                cell.configure(with: comment, for: user )
            }
            return cell
        }
        else {
            fatalError("Invalid table")
        }
    }
    
    
    // MARK: - Table view data source

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if (tableView === self.tableView){
            return 1
        }
        else {
            return comments.count
        }
    }
    


//    var uid = String()
    var pfpReference: StorageReference{
        return Storage.storage().reference().child("profilephotos")
    }
    
//
    override func viewDidLoad() {
        super.viewDidLoad()
        loadComments(success: loadUsers)
        commentTableView.delegate = self
        commentTableView.dataSource = self
        tableView.delegate = self
        tableView.dataSource = self

    
    }
}
