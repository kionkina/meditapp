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
import MessageInputBar

class CommentViewController:  UIViewController, UITableViewDelegate, UITableViewDataSource, MessageInputBarDelegate {
    
    var postUser: User?
    var recording: Post?
    var users: [String: User] = [:]
    var comments : [Comment] = []
    
    let commentBar = MessageInputBar()
    
//    @IBOutlet weak var commentTableView: UITableView!
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
                vc.postUser = self.postUser
            }
        }
    }
    
    
    func loadComments(success: @escaping(() -> Void)) {
        DBViewController.getCommentsById(forPost: (recording?.RecID)!){ (docs) in
            self.comments.removeAll()
            for doc in docs{
                self.comments.append(Comment(snapshot: doc)!)
            }
            print(self.comments.count, "how much comments after fetched")
            success()
//            self.tableView.reloadData()
        }
    }
    
    func loadUsers() -> Void {
        //check if ID is not already in users
        for comment in self.comments {
//            print(comment.Content, "is the comment")
            if !users.keys.contains(comment.OwnerID) {
                DBViewController.getUserById(forUID: comment.OwnerID) { (user) in
                    if let user = user {
                        if (user.uid == "MDjDMIj87odBpiHi2eihvDuMdj02") {
                            print("ITS DISLIKE!")
                            print("pfp2: ")
                            print(user.profilePic)
                        }

                        self.users[user.uid] = user
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
    
    func addComment(comment: Comment, success: @escaping(() -> Void)) {
        self.comments.insert(comment, at: 0)
            success()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.row == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as! postCellTableViewCell

            cell.post = recording
            
            //set whether the post has already been liked when displaying cells.
//            if User.current.likedPosts[self.recording!.RecID] != nil{
//                cell.setLiked(User.current.likedPosts[self.recording!.RecID]!, self.recording!.numLikes)
//            }
//            else{
//                cell.setLiked(false, self.recording!.numLikes)
//            }
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
        else if (comments.count > 0) {
//            print("dequing comments")
            let cell = tableView.dequeueReusableCell(withIdentifier: "sampleComment", for: indexPath) as! commentCellTableViewCell
            
            let comment = comments[indexPath.row - 1]
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
        return 1 + comments.count
    }
    


//    var uid = String()
    var pfpReference: StorageReference{
        return Storage.storage().reference().child("profilephotos")
    }
    
//
    
    override func viewWillAppear(_ animated: Bool) {
        print("commentviewcontroller appearing")
        super.viewWillAppear(animated)
        comments.removeAll()
        users.removeAll()
        loadComments(success: loadUsers)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set up the comment bar
        commentBar.inputTextView.placeholder = "Add a comment..."
        commentBar.sendButton.title = "Post"
        commentBar.delegate = self
        
        //when you pull down on tableview enough, it dismisses keyboard
        tableView.keyboardDismissMode = .interactive

        print(User.current.profilePic, "current profile pic")
        loadComments(success: loadUsers)
    }
    
    //these two functions will make the commentbar appear?
    override var inputAccessoryView: UIView?{
        return commentBar
    }
    //make commentbar always show at bottom.
    override var canBecomeFirstResponder: Bool{
        return true
    }

    //delegate method for when the post button on commentbar gets pressed
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        
        let OwnerID = User.current.uid
        let stamp = Timestamp(date: Date())
        let Content = text
        let comment = Comment(Content: Content, OwnerID: OwnerID, Timestamp: stamp)
        
        DBViewController.insertComment(postID: self.recording!.RecID, comment: comment, oldNumComments: recording!.numComments) { (updatedNumComments) in
            // update comment and comment table
            self.addComment(comment: comment, success: {
                if (!self.users.keys.contains(User.current.uid)) {
                    self.users[User.current.uid] = User.current
                }
//                self.commentTableView.reloadData()
            })
            // update numComments in post table
            self.recording?.numComments = updatedNumComments
            self.tableView.reloadData()
            //TODO: add signal to prev pages
            
            //removes the keyboard
            self.commentBar.inputTextView.text = nil
            self.commentBar.inputTextView.resignFirstResponder()
            
            let updateDict = [
                "updateRecID":self.recording!.RecID,
                "updateComment": updatedNumComments
            ] as [String : Any]
            
            NotificationCenter.default.post(name: Notification.Name("UpdateComment"), object: updateDict)
        }
    }
}
