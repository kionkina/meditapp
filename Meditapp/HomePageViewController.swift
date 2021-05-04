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
import TaggerKit

class HomePageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate{

    @IBOutlet var tableView: UITableView!
    
    var recordings = [Post]()
    var users = [String: User?]()
//    var audioPlayer = AVAudioPlayer()
    var queryLimit = 0
    let myRefreshControl = UIRefreshControl()
    var separator = 0
    
    var curr_index = -1
    var followings: [User] = []
    var userIds: [String:Bool] = [:]
    var numIds: Int = 0

    static var audioPlayer = AVAudioPlayer()
    static var playingCell: postCellTableViewCell?
    
    var tagTaggerKits = [TKCollectionView]()
    
    var isFetchingMore:Bool = false
    var canFetchMoreFollowing:Bool = true

    var audioReference: StorageReference{
        return Storage.storage().reference().child("recordings")

    }
    
    @objc func loadTenUsers(success: @escaping (Bool) -> Void) -> Void {
        followings.removeAll()
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
                        self.followings.append(newUser)
                        self.users[newUser.uid] = newUser
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
            print("loaded all da following", self.followings)
            loadRecordings(forLimit: 10)
        }
    }
    
    func getCurrentMillis()->Int64{
        return  Int64(NSDate().timeIntervalSince1970 * 1)
    }
    
    @objc func loadRecordings(forLimit limit:Int) {
        print("refreshing")
        print("I'm following")
        print(followings.map({ $0.firstName}))
        myRefreshControl.endRefreshing()
        queryLimit = limit
        var fetchPosts = [DocumentReference]()
        var recentPost:DocumentReference?
        var maxTimestamp = Timestamp(seconds: 0, nanoseconds:0)
//        print(minTimestamp, "timestamp")
        var numPosts = 0
        var followingRef:User?
        
        while(canFetchMoreFollowing && numPosts < queryLimit){
            let prevCount = recordings.count
            for following in followings{
                print("following loop", following.recordings)
                if following.recordings.count > 0{
                    print("line 100", following.recordings[0])
                    let userRecordings = following.recordings[following.recordings.count - 1]
                    let currTimestamp = DBViewController.stringToTime(time: Array(userRecordings.keys)[0] )
                    if currTimestamp.dateValue() > maxTimestamp.dateValue(){
                        print("found a more recent post")
                        maxTimestamp = currTimestamp
                        recentPost = userRecordings[DBViewController.timeToString(stamp: maxTimestamp)]
                        followingRef = following
                    }
                }
            }
            if recentPost != nil, followingRef != nil{
                fetchPosts.append(recentPost!)
                followingRef!.recordings.removeLast(1)
                numPosts += 1
                recentPost = nil
                followingRef = nil
                maxTimestamp = Timestamp(seconds: 0, nanoseconds:0)
            }
            else{
                print("one is nil")
                canFetchMoreFollowing = false
            }
        }
//        print(numPosts, "After while loop and the fetchedposts", fetchPosts)
        DBViewController.getRec(for: fetchPosts) { (snapshot) in
//            print(snapshot, "the snapshots array")
//            self.recordings.append(Post(snapshot: snapshot)!)
            print("fetching posts")
            let post = Post(snapshot: snapshot)!
                        self.recordings.insert(post, at: 0)
                        let tagsForPost = TKCollectionView()
                        tagsForPost.tags = post.Tags
            self.tagTaggerKits.append(tagsForPost)
//            print("After db call", self.recordings.count)
            self.recordings.sort(by: { $0.Timestamp.dateValue() > $1.Timestamp.dateValue() })
            if self.recordings.count == numPosts{
                print("about to reload table")
                self.tableView.reloadData()
            }
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
//        canFetchMore = true
        //because if we dont remove users, in the loadusers post, all our users already stored, so it wont get to point of reloading data, since if statement never checks in loaduser since we run the loop on recordings we already fetched where it checks if ownerid exists in dict we had prior before we removed. The table then tries to load the cell before table has been reloading so it tries to load the row from data model that is no longer dere.
        recordings.removeAll()
        users.removeAll()
        tagTaggerKits.removeAll()
        tableView.reloadData()
        self.userIds = User.current.following
        canFetchMoreFollowing = true
        loadTenUsers(success: doneLoadingUsers)
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
    

    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        if indexPath.row + 1 == recordings.count{
//            if !isFetchingMore && canFetchMore{
//                print("fetching more")
//                loadRecordings(forLimit: queryLimit + 10)
//            }
//        }
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
        
        print("I am following", User.current.following)
        tableView.estimatedRowHeight = 10000 // or your estimate

        myRefreshControl.addTarget(self, action: #selector(refreshReload), for: .valueChanged)
        tableView.refreshControl = myRefreshControl

        self.userIds = User.current.following
        loadTenUsers(success: doneLoadingUsers)
//        loadRecordings(forLimit: 10)
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
                cell.configure(with: recording, for: User.current, tagger: tagTaggerKits[indexPath.row])
                cell.postUser = User.current
            }
            else{
                cell.configure(with: recording, for: user, tagger: tagTaggerKits[indexPath.row] )
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

