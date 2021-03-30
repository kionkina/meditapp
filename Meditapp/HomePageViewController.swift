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
    var userIDs = Set<String>()
    var audioPlayer = AVAudioPlayer()
    var queryLimit = 0
    let myRefreshControl = UIRefreshControl()

    var fetchingMore:Bool = false
    var isLoadingStarted:Bool = false
    
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
        print(userIDs, "My set of userIDs")
        print("loadUsers")
        //check if ID is not already in users
        var i:Int = 1
        for recording in recordings {
            if !users.keys.contains(recording.OwnerID) {
                if i < userIDs.count{
                    i += 1
                    DBViewController.getUserById(forUID: recording.OwnerID) { (user) in
                        if let user = user {
                            self.users[user.uid] = user
                        }
                    }
                }
                else{
                    print("No more new users")
                    DBViewController.getUserById(forUID: recording.OwnerID) { (user) in
                        //instantiate user using snapshot, append to users dict
                        if let user = user {
                            self.users[user.uid] = user
                            self.fetchingMore = false
                            self.tableView.reloadData()
                        }
                    }
                }
            }
        }
    }
    
    @objc func loadRecordings(success: @escaping(() -> Void)) {
        print("i'm in loadrecordings")
        queryLimit = 5
        DBViewController.getPostsByTags(forLimit: queryLimit, forTags: User.current.tags) { docs in
            self.recordings.removeAll()
            self.userIDs.removeAll()
            for doc in docs{
                self.recordings.append(doc)
                self.userIDs.insert(doc.OwnerID)
            }
            print(self.recordings.count, "after first load")
            success()
            self.myRefreshControl.endRefreshing()
        }
    }
    
    func loadMoreRecordings(success: @escaping(() -> Void)) {
        print("load more recordings being called")
        queryLimit += 5
        DBViewController.getPostsByTags(forLimit: queryLimit, forTags: User.current.tags) { docs in
            self.recordings.removeAll()
            self.userIDs.removeAll()
            for doc in docs{
                self.recordings.append(doc)
                self.userIDs.insert(doc.OwnerID)
            }
            print(self.recordings.count)
            success()
        }
    }
    
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        let position = scrollView.contentOffset.y
//        if position > (tableView.contentSize.height-100-scrollView.frame.height){
////            print("need more data")
//            guard !fetchingMore else{
//                print("already fetching")
//                return
//            }
////            tableView.tableFooterView = createSpinnerFooter()
//            loadMoreRecordings(success: loadUsers)
//            fetchingMore = true
//        }
//    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        
        if offsetY > contentHeight - scrollView.frame.height {
            if !fetchingMore{
                print("need more")
                fetchingMore = true
                loadMoreRecordings(success: loadUsers)
            }
        }
    }
    
//    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
//        self.isLoadingStarted = true
//    }
    
//    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        if indexPath.row + 1 == recordings.count{
//            print("need to fetch more")
////            print(indexPath.row, "calling willdisplay")
////            guard !fetchingMore else{
////                print("already fetching")
////                return
////            }
////            print("scrolled to bottom. need fetch more")
////            fetchingMore = true
//            loadMoreRecordings(success: loadUsers)
//        }
//    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myRefreshControl.addTarget(self, action: #selector(refreshReload), for: .valueChanged)
        tableView.refreshControl = myRefreshControl
        
        loadRecordings(success: loadUsers)

        print(User.current.tags, "my current tags")
        NotificationCenter.default.addObserver(self, selector: #selector(handleLikes), name: Notification.Name("UpdateLikes"), object: nil)
        print(recordings.count, "current count")
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

