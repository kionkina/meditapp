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
    
    var topPosts = [Post]()
    
    var curr_index = -1
    var followings: [User] = []
    var userIds: [String:Bool] = [:]
    var numIds: Int = 0

    static var audioPlayer = AVAudioPlayer()
    static var playingCell: postCellTableViewCell?

    
//    var tagTaggerKits = [TKCollectionView]()
    
    var isFetching = true
    var showExploresCell = false
    
//    var isFetchingMore:Bool = false
    var canFetchMoreFollowing:Bool = true

    var audioReference: StorageReference{
        return Storage.storage().reference().child("recordings")

    }
    
    @objc func loadTenUsers(success: @escaping (Bool) -> Void) -> Void{
        DispatchQueue.main.async {
            self.myRefreshControl.endRefreshing()
            self.canFetchMoreFollowing = true
            self.isFetching = true
            self.tableView.reloadData()
        }
        
        if User.current.following.count > 0{
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
                            let copyUser = User(user: newUser)
                            self.users[newUser.uid] = copyUser
                        }
                        success(updateIndex)
                    }
                }
            }
        }
        else{
            canFetchMoreFollowing = false
            loadTopRecordings(forLimit: 5, success: loadUsers)
        }
    }

    func doneLoadingUsers(updateIndex: Bool){
        if (updateIndex) {
            curr_index += 10
            loadTenUsers(success: doneLoadingUsers)
        }
        else {
            loadRecordings(forLimit: 5)
        }
    }
    
    func getCurrentMillis()->Int64{
        return  Int64(NSDate().timeIntervalSince1970 * 1)
    }
    
    @objc func loadRecordings(forLimit limit:Int) {
        queryLimit = limit
        var fetchPosts = [DocumentReference]()
        var recentPost:DocumentReference?
        var maxTimestamp = Timestamp(seconds: 0, nanoseconds:0)
        var numPosts = 0
        var followingRef:User?
        
        while(canFetchMoreFollowing && numPosts < queryLimit){
            for following in followings{
                if following.recordings.count > 0{
                    let userRecordings = following.recordings[following.recordings.count - 1]
                    let currTimestamp = DBViewController.stringToTime(time: Array(userRecordings.keys)[0] )
                    if currTimestamp.dateValue() > maxTimestamp.dateValue(){
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
                canFetchMoreFollowing = false
            }
        }

        if fetchPosts.count > 0{
            var numPostsFetchCounter = 0
            DBViewController.getRec(for: fetchPosts) { [self] (snapshot) in
                let post = Post(snapshot: snapshot)!
                self.recordings.insert(post, at: 0)

                self.recordings.sort(by: { $0.Timestamp.dateValue() > $1.Timestamp.dateValue() })
                numPostsFetchCounter += 1
                if numPostsFetchCounter == numPosts{
                    self.loadTopRecordings(forLimit: 5, success: loadUsers)
                }
            }
        }
        
        else{
            loadTopRecordings(forLimit: 5, success: loadUsers)
        }
    }
    
    @objc func loadTopRecordings(forLimit limit:Int, success: @escaping(() -> Void)) {
//        queryLimit += limit
        DBViewController.getTopPosts(forLimit: limit) { (docs, numFetched) in
            if numFetched == 0{
                DispatchQueue.main.async {
                    self.isFetching = false
                    self.tableView.reloadData()
                    return
                }
            }
            self.topPosts.removeAll()
            for doc in docs{
                self.topPosts.append(doc)
            }
            success()
        }
    }
    
    
    
    @objc func loadUsers() -> Void {
        let mygroup = DispatchGroup()
        for post in self.topPosts {
            if !self.users.keys.contains(post.OwnerID) {
                mygroup.enter()
                DBViewController.getUserById(forUID: post.OwnerID) { (user) in
                    if let user = user {
                        self.users[user.uid] = user
                    }
                    mygroup.leave()
                }
            }
        }
        mygroup.notify(queue: .main){
            DispatchQueue.main.async {
                (self.myRefreshControl.isRefreshing) ? self.myRefreshControl.endRefreshing() : print("stopped refreshing already")
                self.isFetching = false
                UIView.performWithoutAnimation {
                    self.tableView.reloadData()
                    self.tableView.beginUpdates()
                    self.tableView.endUpdates()
                }
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "toProfile") {
            let button = sender as! UIButton
            if let cell = button.superview?.superview as? postCellTableViewCell {
                let vc = segue.destination as! UserProfilePageViewController
                vc.postUser = cell.postUser
            }
        }
        if (segue.identifier == "toComments") {
            let button = sender as! UIButton
            if let cell = button.superview?.superview as? postCellTableViewCell {
                    let vc = segue.destination as! CommentViewController
                    vc.postUser = cell.postUser
                    vc.recording = cell.post
            }
        }
    }
    
    @objc func refreshReload(){
        recordings.removeAll()
        users.removeAll()
        self.userIds = User.current.following
        loadTenUsers(success: doneLoadingUsers)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if HomePageViewController.audioPlayer.isPlaying{
            HomePageViewController.playingCell?.stopPlaying()
        }
        NotificationCenter.default.addObserver(self, selector: #selector(handleLikes), name: Notification.Name("UpdateLikes"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleComment), name: Notification.Name("UpdateComment"), object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = 10000 // or your estimate
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        myRefreshControl.addTarget(self, action: #selector(refreshReload), for: .valueChanged)
        tableView.refreshControl = myRefreshControl

        
        let docRef = Firestore.firestore().collection("user2").document(User.current.uid)

        let dispatchGroup = DispatchGroup()
        DispatchQueue.global().async {
            dispatchGroup.enter()
            docRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    let loadUser = User(snapshot: document)!
                    User.setCurrent(loadUser, writeToUserDefaults: true)
                }
                else {
                    print("Document does not exist")
                }
                dispatchGroup.leave()
            }
        }
        dispatchGroup.notify(queue: DispatchQueue.global()){
            self.userIds = User.current.following
            self.loadTenUsers(success: self.doneLoadingUsers)
        }
    }

    @objc func handleLikes(notification: NSNotification) {
        if let dict = notification.object as? [String:Any] {
            for post in recordings{
                if post.RecID == dict["updateRecID"] as! String{
                    post.numLikes = dict["updateLikes"] as! Int
                }
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    @objc func handleComment(notification: NSNotification) {
        if let dict = notification.object as? [String:Any] {
            for post in recordings{
                if post.RecID == dict["updateRecID"] as! String{
                    post.numComments = dict["updateComment"] as! Int
                }
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
        
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isFetching{
            let cell = tableView.dequeueReusableCell(withIdentifier: "LoadingCell", for: indexPath)
            let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
            
            spinner.startAnimating()
            return cell
        }
        else {
            if indexPath.section == 0{
                if recordings.count == 0{
                    let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
                    return cell
                }
                else{
                    let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as! postCellTableViewCell

                    let recording = recordings[indexPath.row]
                    cell.post = recording

                    if User.current.likedPosts[recording.RecID] != nil{
                        cell.setLiked(User.current.likedPosts[recording.RecID]!, recording.numLikes)
                    }
                    else{
                        cell.setLiked(false, recording.numLikes)
                    }
                    
                    if let user = users[recording.OwnerID]{
                        if user?.uid == User.current.uid{
                            cell.configure(with: recording, for: User.current)
                            cell.postUser = User.current
                        }
                        else{
                            cell.configure(with: recording, for: user)
                            cell.postUser = user
                        }
                    }
                    cell.selectionStyle = UITableViewCell.SelectionStyle.none

                    cell.layer.borderColor =  CGColor(red: 1, green: 1, blue: 1, alpha: 1)
                    cell.layer.borderWidth = 7
                    
                    cell.alpha = 0
                    UIView.animate(
                       withDuration: 0.5,
                       delay: 0.05 * Double(indexPath.row),
                       animations: {
                           cell.alpha = 1
                   })
                    return cell
                }
            }
            else if indexPath.section == 1{
                let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as! postCellTableViewCell

                let recording = topPosts[indexPath.row]
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
                        cell.configure(with: recording, for: User.current)
                        cell.postUser = User.current
                    }
                    else{
                        cell.configure(with: recording, for: user)
                        cell.postUser = user
                    }
                }
                cell.selectionStyle = UITableViewCell.SelectionStyle.none

                cell.layer.borderColor =  CGColor(red: 1, green: 1, blue: 1, alpha: 1)
                cell.layer.borderWidth = 7
                
                cell.alpha = 0

                UIView.animate(
                    withDuration: 0.5,
                    delay: 0.05 * Double(indexPath.row),
                    animations: {
                        cell.alpha = 1
                })
                return cell

            }
            else{
                let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
                cell.textLabel?.text = "View Explore Page Now"
                cell.selectionStyle =  UITableViewCell.SelectionStyle.none
                return cell
            }
        }

    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 2 {
            tabBarController!.selectedIndex = 1
        }
    }
    
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if isFetching{
            return 1
        }
        else{
            return 3
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFetching{
            return 1
        }
        else{
            if section == 0{
                return recordings.count
            }
            else if section == 1{
                return topPosts.count
            }
            else{
                return 1
            }
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if !isFetching, indexPath.section == 0, indexPath.row + 1 == recordings.count, canFetchMoreFollowing{
            print("Fetching more")
            loadRecordings(forLimit: queryLimit + 5)
        }
    }
    
    var sectionTitles = ["Recent", "Top Posts", "Check Out Our Explore Page"]
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if isFetching{
            return nil
        }
        else{
            return sectionTitles[section]
        }
    }
}

