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
    
    var queryLimit = 0
    let myRefreshControl = UIRefreshControl()
    
    var canFetchMore:Bool = true
    
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
        loadRecordings(success: loadUsers)
    }
    
    var isFetching = true
    
    @objc func loadRecordings(success: @escaping(() -> Void)) {
        DispatchQueue.main.async {
            self.myRefreshControl.endRefreshing()
            self.canFetchMore = true
            self.isFetching = true
            self.tableView.reloadData()
        }
        queryLimit = 4
        DBViewController.getPostsExplore(forLimit: queryLimit, forTags: viewforTags) { (docs, numFetched) in
            if numFetched == 0{
                DispatchQueue.main.async {
                    self.isFetching = false
                    self.canFetchMore = false
                    self.tableView.reloadData()
                    return
                }
            }
            self.recordings.removeAll()
            for doc in docs{
                self.recordings.append(doc)
            }
//            self.tableView.reloadData()
            success()
        }
    }
    
    func loadMoreRecordings(success: @escaping(() -> Void)) {
        queryLimit += 4
        DBViewController.getPostsExplore(forLimit: queryLimit, forTags: viewforTags) { (docs, numFetched) in
            
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
//            self.tableView.reloadData()
            success()
        }
    }
    
    @objc func loadUsers() -> Void {
        let mygroup = DispatchGroup()
        for post in recordings {
            if !users.keys.contains(post.OwnerID) {
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
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row + 1 == recordings.count{
            if !isFetching && canFetchMore{
                loadMoreRecordings(success: loadUsers)
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if HomePageViewController.audioPlayer.isPlaying{
            HomePageViewController.playingCell?.stopPlaying()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        tableView.estimatedRowHeight = 10000
        myRefreshControl.addTarget(self, action: #selector(refreshReload), for: .valueChanged)
        tableView.refreshControl = myRefreshControl

        loadRecordings(success: loadUsers)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleLikes), name: Notification.Name("UpdateLikes"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleComment), name: Notification.Name("UpdateComment"), object: nil)
    }

    @objc func handleLikes(notification: NSNotification) {
        if let dict = notification.object as? [String:Any] {
            for post in recordings{
                if post.RecID == dict["updateRecID"] as! String{
                    post.numLikes = dict["updateLikes"] as! Int
                }
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
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isFetching{
            let cell = tableView.dequeueReusableCell(withIdentifier: "LoadingCell", for: indexPath)
            let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
            
            spinner.startAnimating()
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
            return cell
        }
    }
    
    // MARK: - Table view data source

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFetching{
            return 1
        }
        else{
            return recordings.count
        }
    }
}
