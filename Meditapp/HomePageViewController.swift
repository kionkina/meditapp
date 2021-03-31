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

class HomePageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate{

    @IBOutlet var tableView: UITableView!

    var recordings = [Post]()
    var users = [String: User?]()
    var audioPlayer = AVAudioPlayer()
    var queryLimit = 0
    let myRefreshControl = UIRefreshControl()

    var isFetchingMore:Bool = false
    var canFetchMore:Bool = true
    
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
    
    @objc func refreshReload(){
        print("i have refreshed")
        canFetchMore = true
        //because if we dont remove users, in the loadusers post, all our users already stored, so it wont get to point of reloading data, since if statement never checks in loaduser since we run the loop on recordings we already fetched where it checks if ownerid exists in dict we had prior before we removed. The table then tries to load the cell before table has been reloading so it tries to load the row from data model that is no longer dere.
        recordings.removeAll()
        users.removeAll()
        
        loadRecordings(success: loadUsers)
    }
    
    func createSpinnerFooter() -> UIView{
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 100))
        let spinner = UIActivityIndicatorView()
        spinner.center = footerView.center
        spinner.startAnimating()
        
        return footerView
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
        queryLimit = 4
        print("about to make call to get posts")
        DBViewController.getPostsByTags(forLimit: queryLimit, forTags: User.current.tags) { docs in
            self.recordings.removeAll()
            for doc in docs{
                self.recordings.append(doc)
            }
//            print(self.recordings.count, "after first load")
            print("successfully appended to datamodel")
//            self.tableView.reloadData()
            self.myRefreshControl.endRefreshing()
            success()
        }
    }
    
    func loadMoreRecordings(success: @escaping(() -> Void)) {
        print("load more recordings being called")
        queryLimit += 4
        DBViewController.getPostsByTags(forLimit: queryLimit, forTags: User.current.tags) { docs in
            let prevNumPosts = self.recordings.count
            self.recordings.removeAll()
            for doc in docs{
                self.recordings.append(doc)
            }
            //check is prev num post is equal to new amount of post. if so, cant fetch anymore
            if prevNumPosts == self.recordings.count{
                self.canFetchMore = false
                print("no more posts to fetch")
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
                print("fetching more")
                loadMoreRecordings(success: loadUsers)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = 1000 // or your estimate

        myRefreshControl.addTarget(self, action: #selector(refreshReload), for: .valueChanged)
        tableView.refreshControl = myRefreshControl

        loadRecordings(success: loadUsers)

        print(User.current.tags, "my current tags")
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleLikes), name: Notification.Name("UpdateLikes"), object: nil)
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
        //if user to current post found in dict
        if let user = users[recording.OwnerID]{
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
    
    
    // MARK: - Table view data source

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return recordings.count
    }
    
    

}

