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
import StreamingKit

class HomePageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate{

    @IBOutlet var tableView: UITableView!
    
    var recordings = [Post]()
    var users = [String: User?]()
    var audioPlayer = AVAudioPlayer()
    var queryLimit = 0
    let myRefreshControl = UIRefreshControl()
    var separator = 0
    
    var curr_index = -1
    var following: [User] = []
    var userIds: [String:Bool] = [:]
    var numIds: Int = 0

    static var audioPlayer = AVAudioPlayer()
    static var playingCell: postCellTableViewCell?
    
    
    
    var isFetchingMore:Bool = false
    var canFetchMore:Bool = true

    var audioReference: StorageReference{
        return Storage.storage().reference().child("recordings")

    }
    
    @objc func loadTenUsers(success: @escaping (Bool) -> Void) -> Void {
        if (userIds != nil) {
            //takes 10 user ids from current index
            let keys = userIds.keys
            var idArr = [String](userIds.keys)

            var updateIndex: Bool = false
            // there are less than 10 more users to pull
            if (keys.count > 0) {
                if (keys.count - (curr_index + 1) > 10) {
                    updateIndex = true
                    idArr = [String](idArr[curr_index + 1...curr_index + 10])
                } else {
                    idArr = [String](idArr[(curr_index + 1)...(keys.count - 1)])
                }

                DBViewController.loadTenUsers(for: idArr) { (users: [User]) in
                    for newUser in users {
                        self.following.append(newUser)
                        print(users)
                    }
                    success(updateIndex)
                }
            }
        }
    }

    func doneLoadingUsers(updateIndex: Bool){
        print("in done loading users")
        tableView.reloadData()
        if (updateIndex) {
            curr_index += 10
            loadTenUsers(success: doneLoadingUsers)
        }
        else {
            print("loaded all da following")
            print(self.following)
            return
        }

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
        if (segue.identifier == "toComments") {
            let button = sender as! UIButton
            if let cell = button.superview?.superview as? postCellTableViewCell {
                    //print(cell.uid)
                    let vc = segue.destination as! CommentViewController
                    vc.postUser = cell.postUser
                    vc.recording = cell.post
            }
        }
    }
    
    @objc func refreshReload(){
        print("i have refreshed")
        canFetchMore = true
        //because if we dont remove users, in the loadusers post, all our users already stored, so it wont get to point of reloading data, since if statement never checks in loaduser since we run the loop on recordings we already fetched where it checks if ownerid exists in dict we had prior before we removed. The table then tries to load the cell before table has been reloading so it tries to load the row from data model that is no longer dere.
        recordings.removeAll()
        users.removeAll()
        tableView.reloadData()
        loadRecordings(success: loadUsers)
    }
    
    @objc func loadUsers() -> Void {
        print("loadUsers")
        //check if ID is not already in users
        for recording in recordings {
            if !users.keys.contains(recording.OwnerID) {
                DBViewController.getUserById(forUID: recording.OwnerID) { (user) in
                    if let user = user {
                        self.users[user.uid] = user
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
    
    @objc func loadRecordings(success: @escaping(() -> Void)) {
        print("i'm in loadrecordings")
        queryLimit = 8
        print("about to make call to get posts")
        DBViewController.getPostsByTags(forLimit: queryLimit, forTags: User.current.tags) { (docs, numFetched) in
            self.recordings.removeAll()
            for doc in docs{
                self.recordings.append(doc)
            }
//            print(self.recordings.count, "after first load")
            print("successfully appended to datamodel")
//            self.tableView.reloadData()
            self.separator = numFetched
            self.myRefreshControl.endRefreshing()
            success()
        }
    }
    
    func loadMoreRecordings(success: @escaping(() -> Void)) {
        print("load more recordings being called")
        queryLimit += 8
        DBViewController.getPostsByTags(forLimit: queryLimit, forTags: User.current.tags) { (docs, numFetched) in
            let prevNumPosts = self.recordings.count
            self.recordings.removeAll()
            for doc in docs{
                self.recordings.append(doc)
            }
            //check is prev num post is equal to new amount of post. if so, cant fetch anymore
            if prevNumPosts == self.recordings.count{
                self.canFetchMore = false
            }
            //in case we already have all users in our users dict, if statement wont check and it wont reload.
            self.separator = numFetched
            self.tableView.reloadData()
            self.isFetchingMore = false
            success()
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row + 1 == recordings.count{
            if !isFetchingMore && canFetchMore{
                print("fetching more")
                loadMoreRecordings(success: loadUsers)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if HomePageViewController.audioPlayer.isPlaying{
            print("player needs to stop playing")
            HomePageViewController.playingCell?.stopPlaying()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = 10000 // or your estimate

        myRefreshControl.addTarget(self, action: #selector(refreshReload), for: .valueChanged)
        tableView.refreshControl = myRefreshControl

        loadRecordings(success: loadUsers)
        self.userIds = User.current.following
        loadTenUsers(success: doneLoadingUsers)

        print(User.current.uid, "i am the current user")
        print(User.current.tags, "my current tags")
        print(User.current.recordings , "my recordings")
        print(User.current.profilePic, "current profile in homepage")
        NotificationCenter.default.addObserver(self, selector: #selector(handleLikes), name: Notification.Name("UpdateLikes"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleComment), name: Notification.Name("UpdateComment"), object: nil)
    }

    @objc func handleLikes(notification: NSNotification) {
//        print("like fired off handler in homepage")
        if let dict = notification.object as? [String:Any] {
            for post in recordings{
                if post.RecID == dict["updateRecID"] as! String{
                    post.numLikes = dict["updateLikes"] as! Int
                }
            }
        }
    }
    @objc func handleComment(notification: NSNotification) {
//        print("like fired off comment handler in homepage")
        if let dict = notification.object as? [String:Any] {
            for post in recordings{
                if post.RecID == dict["updateRecID"] as! String{
                    post.numComments = dict["updateComment"] as! Int
                }
            }
        }
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
                if let user = users[recording.OwnerID]{
                    if user?.uid == User.current.uid{
                        cell.configure(with: recording, for: User.current )
                        cell.postUser = User.current
                    }
                    else{
                        cell.configure(with: recording, for: user )
                        cell.postUser = user
                    }
                }
        
        // add separator
        cell.sepLine?.isHidden = (Int(indexPath.row) != self.separator - 1)
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        return cell
    }
    
    
    // MARK: - Table view data source

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return recordings.count
    }
    
    

}

