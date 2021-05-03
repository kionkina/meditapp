//
//  ViewMoreViewController.swift
//  Meditapp
//
//  Created by Jackson Lu on 4/26/21.
//

import UIKit
import TaggerKit
class ViewMoreViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var viewforTags = [String]()
    
    var recordings = [Post]()
    var users = [String: User?]()
    var tagTaggerKits = [TKCollectionView]()
    
    var queryLimit = 0
    let myRefreshControl = UIRefreshControl()
    
    var isFetchingMore:Bool = false
    var canFetchMore:Bool = true
    
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
        queryLimit = 8
        DBViewController.getPostsExplore(forLimit: queryLimit, forTags: viewforTags) { (docs, numFetched) in
            self.recordings.removeAll()
            for doc in docs{
                let tagger = TKCollectionView()
                tagger.tags = doc.Tags
                self.tagTaggerKits.append(tagger)
                self.recordings.append(doc)
            }
//            self.tableView.reloadData()
            self.myRefreshControl.endRefreshing()
            success()
        }
    }
    
    func loadMoreRecordings(success: @escaping(() -> Void)) {
        queryLimit += 8
        DBViewController.getPostsExplore(forLimit: queryLimit, forTags: viewforTags) { (docs, numFetched) in
            let prevNumPosts = self.recordings.count
            self.recordings.removeAll()
            for doc in docs{
                let tagger = TKCollectionView()
                tagger.tags = doc.Tags
                self.tagTaggerKits.append(tagger)
                self.recordings.append(doc)
            }
            //check is prev num post is equal to new amount of post. if so, cant fetch anymore
            if prevNumPosts == self.recordings.count{
                self.canFetchMore = false
            }
            //in case we already have all users in our users dict, if statement wont check and it wont reload.
            self.tableView.reloadData()
            self.isFetchingMore = false
            success()
        }
    }
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row + 1 == recordings.count{
            if !isFetchingMore && canFetchMore{
                loadMoreRecordings(success: loadUsers)
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if HomePageViewController.audioPlayer.isPlaying{
            print("player needs to stop playing")
            HomePageViewController.playingCell?.stopPlaying()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.estimatedRowHeight = 10000
        myRefreshControl.addTarget(self, action: #selector(refreshReload), for: .valueChanged)
        tableView.refreshControl = myRefreshControl

        loadRecordings(success: loadUsers)
        
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
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        return cell
    }
    
    // MARK: - Table view data source

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return recordings.count
    }
    
}