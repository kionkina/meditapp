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
    
    @IBOutlet weak var commentTableView: UITableView!
    @IBOutlet var tableView: UITableView!

    @IBOutlet weak var commentText: UITextField!
    @IBOutlet weak var postCommentButton: UIButton!

    
    var audioPlayer = AVAudioPlayer()
    
    var audioReference: StorageReference{
        return Storage.storage().reference().child("recordings")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("IN PREPARE")
        if (segue.identifier == "toProfile1") {
            let button = sender as! UIButton
            if let cell = button.superview?.superview as? commentCellTableViewCell {
                //print(cell.uid)
                print("about to pass")
                print(cell.postUser)
                let vc = segue.destination as! UserProfilePageViewController
                vc.postUser = cell.postUser
            }
        }
        else if (segue.identifier == "toProfile2") {
            print("in segue2")
            let button = sender as! UIButton
            if let cell = button.superview?.superview as? postCellTableViewCell {
                //print(cell.uid)
                print(cell.postUser)
                let vc = segue.destination as! UserProfilePageViewController
                vc.postUser = self.postUser            }
    }
}
    
    
    func loadComments(success: @escaping(() -> Void)) {
        self.comments.removeAll()
        DBViewController.getCommentsById(forPost: (recording?.RecID)!) { (docs) in
            for doc in docs{
                print("adding ")
                print(doc.data())
                print("to comment coleciton")
                self.comments.append(Comment(snapshot: doc)!)
            }
            success()
        }
    }
    
    func loadUsers() -> Void {
        print("loadUsers")
        print("comments: ")
        print(self.comments)
        //check if ID is not already in users
        for comment in self.comments {
            print("ownerid ")
            print(comment.OwnerID)
            if !users.keys.contains(comment.OwnerID) {
                DBViewController.getUserById(forUID: comment.OwnerID) { (user) in
                    //instantiate user using snapshot, append to users dict
                    print("got user")
                    print(user!)
                    if let user = user {
                        self.users[user.uid] = user
                        print("reloading comment table view data")
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
        DBViewController.insertComment(postID: self.recording!.RecID, comment: comment, oldNumComments: self.recording!.numComments) { (updatedNumComments) in
            // update comment and comment table
            self.addComment(comment: comment, success: {
                if (!self.users.keys.contains(User.current.uid)) {
                    self.users[User.current.uid] = User.current
                }
                self.commentTableView.reloadData()
            })
            // update numComments in post table
            self.recording?.numComments = updatedNumComments
            self.tableView.reloadData()
            //TODO: add signal to prev pages
        }
    }
    
    func addComment(comment: Comment, success: @escaping(() -> Void)) {
        self.comments.insert(comment, at: 0)
            success()
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
            let cell = tableView.dequeueReusableCell(withIdentifier: "sampleComment", for: indexPath) as! commentCellTableViewCell
            
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
        print("tv1")
        print(tableView)
        // #warning Incomplete implementation, return the number of rows
        if (tableView === self.tableView){
            return 1
        }
        else {
            print("IN ELSE STATEMENT")
            print(self.comments.count)
            return self.comments.count
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
        //register your tableview cell
        //self.commentTableView.register(UITableViewCell.self, forCellReuseIdentifier: "sampleComment")
        //tableView.delegate = self
        //tableView.dataSource = self

    
    }
}
