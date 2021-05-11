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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "toFollowing") {
            let button = sender as! UIButton
            if let cell = button.superview?.superview as? profileCell {
                    //print(cell.uid)
                    let vc = segue.destination as! followersViewController
                    vc.followers = false
                    vc.userIds = postUser!.following
                    vc.numIds = postUser!.numFollowing
            }
        }
        else if (segue.identifier == "toFollowers") {
            let button = sender as! UIButton
            if let cell = button.superview?.superview as? profileCell {
                    //print(cell.uid)
                    let vc = segue.destination as! followersViewController
                    vc.followers = true
                    print("followers in segue")
                print(postUser!.followers)
                    vc.userIds = postUser!.followers
                    vc.numIds = postUser!.numFollowers
            }
        }
        else if (segue.identifier == "toComments") {
            let button = sender as! UIButton
            if let cell = button.superview?.superview as? postCellTableViewCell {
                    //print(cell.uid)
                    let vc = segue.destination as! CommentViewController
                    vc.postUser = self.postUser
                    vc.recording = cell.post
            }
        }
    }
    
    func addFollower() -> Void {
        postUser?.followers[User.current.uid] = true
        postUser?.numFollowers += 1
        tableView.reloadData()
        return
    }
    
    func removeFollower()-> Void {
        postUser?.followers.removeValue(forKey: User.current.uid)
        postUser?.numFollowers -= 1
        tableView.reloadData()
        return
    }
    
    var isFetching = true
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "profileCell", for: indexPath) as! profileCell
            
            cell.fullName.text = postUser!.firstName + " " + postUser!.lastName
            cell.username.text = postUser?.username
     
            cell.numFollowers.text = String(postUser!.numFollowers)
            cell.numFollowing.text = String(postUser!.numFollowing)
            cell.uid = postUser!.uid
            print(User.current.following)
            print("FOLLOWING")
            if (User.current.following[postUser!.uid] == true) {
                print("setting set follow to true")
                cell.setFollow(isFollowing: true)
            } else {
                cell.setFollow(isFollowing: false)
            }
            
            cell.followHandler =  addFollower
            cell.unfollowHandler = removeFollower
           
            
            cell.profileImageView.sd_setImage(with: Storage.storage().reference().child("profilephotos").child(postUser!.profilePic))
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            return cell
        }
        else{
            if isFetching{
                print("displaying loading cell")
                let cell = tableView.dequeueReusableCell(withIdentifier: "LoadingCell", for: indexPath)
                let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
                
                spinner.startAnimating()
                return cell
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
                    cell.configure(with: recording, for: user)
                    cell.postUser = user
                }
                
                cell.selectionStyle = UITableViewCell.SelectionStyle.none
                return cell
            }
        }
    }
    
    
    // MARK: - Table view data source

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if isFetching{
            return 1 + 1
        }
        else{
            return 1 + recordings.count
        }
    }
    


//    var uid = String()
    var pfpReference: StorageReference{
        return Storage.storage().reference().child("profilephotos")
    }
    
    var postUser: User?
    var recordings: [Post] = [] 
    
    let myRefreshControl = UIRefreshControl()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
//        print("loading userprofile vc")
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        myRefreshControl.addTarget(self, action: #selector(refreshReload), for: .valueChanged)
        tableView.refreshControl = myRefreshControl
        
        navigationItem.title = postUser?.username
        
//        print("in profile! uid: " + postUser!.uid, "and his recordings are", postUser!.recordings)
        
        //change eventually to user.profileimage
        loadRecordings()
        NotificationCenter.default.addObserver(self, selector: #selector(handleLikes), name: Notification.Name("UpdateLikes"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleComment), name: Notification.Name("UpdateComment"), object: nil)
    }
    
    @objc func refreshReload(){
        print("i have refreshed")
        recordings.removeAll()
        tableView.reloadData()
        loadRecordings()
    }
    
    deinit {
        print("destroying userprofile")
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
        myRefreshControl.endRefreshing()
        isFetching = true
        let userRecs = postUser!.recordings.map{ Array($0.values)[0] }
        print(userRecs, "userrecs vs", postUser!.recordings)
        DBViewController.getRecordings(for: userRecs) { (doc: DocumentSnapshot) in
            if (doc != nil) {
                self.recordings.append(Post(snapshot: doc)!)
                self.recordings.sort(by: { $0.Timestamp.dateValue() > $1.Timestamp.dateValue() })
                
                DispatchQueue.main.async {
                    self.isFetching = false
                    self.tableView.reloadData()
                }
            }
        }
    }
}
