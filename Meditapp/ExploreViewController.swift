//
//  ExploreViewController.swift
//  Meditapp
//
//  Created by Gabriella Alexis on 4/14/21.
// 
import AVFoundation
import UIKit
import FirebaseFirestore
import FirebaseStorage
import StreamingKit

class ExploreViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDelegate, UITableViewDataSource {
    
    
    var genreArray = ["Morning", "Evening", "Mantra", "Relaxing", "Energizing"]
    
    @IBOutlet weak var tableView: UITableView!
    var recordings = [Post]()
    var users = [String: User?]()
    var audioPlayer = AVAudioPlayer()
    var queryLimit = 0
    let myRefreshControl = UIRefreshControl()
    
    static var audioPlayer = AVAudioPlayer()
    static var playingCell: postCellTableViewCell?
    
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
        queryLimit = 4
        print("about to make call to get posts")
        DBViewController.getPostsByTags(forLimit: queryLimit, forTags: User.current.tags) { (docs, numFetched) in
            self.recordings.removeAll()
            for doc in docs{
                self.recordings.append(doc)
            }
//            print(self.recordings.count, "after first load")
            print("successfully appended to datamodel")
//            self.tableView.reloadData()
//            self.separator = numFetched
            self.myRefreshControl.endRefreshing()
            success()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if ExploreViewController.audioPlayer.isPlaying{
            print("player needs to stop playing")
            ExploreViewController.playingCell?.stopPlaying()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.estimatedRowHeight = 10000 // or your estimate

        myRefreshControl.addTarget(self, action: #selector(refreshReload), for: .valueChanged)
        tableView.refreshControl = myRefreshControl

        loadRecordings(success: loadUsers)
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
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return genreArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "genreCell", for: indexPath) as! GenreCollectionViewCell
        
//        cell.genreImg.image = genreArray[indexPath.row]
        cell.genreImg.image = UIImage(named: genreArray[indexPath.row])
        cell.genreName.text = genreArray[indexPath.row]
        
        return cell
    }

    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recordings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCell") as! postCellTableViewCell
        
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
        
        return cell
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
