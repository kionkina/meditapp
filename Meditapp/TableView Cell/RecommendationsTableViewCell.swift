//
//  RecommendationsTableViewCell.swift
//  Meditapp
//
//  Created by Jackson Lu on 4/19/21.
//

import UIKit
import TaggerKit
protocol RecommendationsDelegate: class {
    func userDidTap(forTags tags:[String])
}

class RecommendationsTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isFetching{
            return 1
        }
        else{
            return recordings.count + 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == recordings.count{
            delegate!.userDidTap(forTags: toplikedGenres)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if isFetching{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LoadingCell", for: indexPath)
            let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
            
            spinner.startAnimating()
            return cell
        }
        else{
            if indexPath.row < recordings.count{
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecommendationsCollectionViewCell.identifier, for: indexPath) as! RecommendationsCollectionViewCell
                
                let recording = recordings[indexPath.row]
                cell.userPost = recording
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

                return cell
            }
            else{
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LoadMoreCollectionViewCell.identifier, for: indexPath) as! LoadMoreCollectionViewCell
                if !displayMoreCell{
                    cell.viewMore.isEnabled = false
                }
                else{
                    cell.viewMore.isEnabled = true
                }
                return cell
            }
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.row == recordings.count{
            return CGSize(width: 210, height: 270)
        }
        else{
            return CGSize(width: 400, height: 210)
        }
    }

    static let identifier = "RecommendationsTableViewCell"
    
    static func nib() -> UINib{
        return UINib(nibName: "RecommendationsTableViewCell", bundle: nil)
    }
    
    @IBOutlet var collectionView:UICollectionView!
    
    weak var delegate: RecommendationsDelegate?

    var recordings = [Post]()
    var users = [String: User?]()
    var toplikedGenres:[String] = {
        let topGenresDicts = User.current.likedGenres.sorted { $0.value > $1.value }.prefix(3)
        var topGenres = [String]()
        for dict in topGenresDicts{
            topGenres.append(dict.key)
        }
        return topGenres
    }()
    
    var queryLimit = 0
    var displayMoreCell = false
    deinit {
        print("Recommendations table view cell destroyed")
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.register(RecommendationsCollectionViewCell.nib(), forCellWithReuseIdentifier: RecommendationsCollectionViewCell.identifier)
        collectionView.register(LoadMoreCollectionViewCell.nib(), forCellWithReuseIdentifier: LoadMoreCollectionViewCell.identifier)
        collectionView.register(LoadingCell.nib(), forCellWithReuseIdentifier: LoadingCell.identifier)

        
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleLikes), name: Notification.Name("UpdateLikes"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleComment), name: Notification.Name("UpdateComment"), object: nil)

        loadRecordings(forTags: toplikedGenres, success: loadUsers)
        
    }
    
    @objc func handleLikes(notification: NSNotification) {
        print("like fired off handler in recommended cell")
        if let dict = notification.object as? [String:Any] {
            for post in recordings{
                if post.RecID == dict["updateRecID"] as! String{
                    post.numLikes = dict["updateLikes"] as! Int
                }
            }
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    @objc func handleComment(notification: NSNotification) {
        print("like fired off comment handler in recommended cell")
        if let dict = notification.object as? [String:Any] {
            for post in recordings{
                if post.RecID == dict["updateRecID"] as! String{
                    post.numComments = dict["updateComment"] as! Int
                }
            }
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    var isFetching = true
    
    func loadRecordingsFromExplorer(){
        loadRecordings(forTags: toplikedGenres, success: loadUsers)
    }
    
    func loadRecordings(forTags tags:[String], success: @escaping(() -> Void)) {
        DispatchQueue.main.async {
            self.isFetching = true
            self.recordings.removeAll()
            self.collectionView.reloadData()
        }
        queryLimit = 5
        DBViewController.getPostsExplore(forLimit: queryLimit, forTags: tags) { (docs, numFetched) in
            if numFetched == 0{
                DispatchQueue.main.async {
                    self.isFetching = false
                    self.collectionView.reloadData()
                    return
                }
            }
            
            self.recordings.removeAll()
            for doc in docs{
                self.recordings.append(doc)
            }
//            self.collectionView.reloadData()
            success()
        }
    }
    
    func loadUsers() -> Void {
        var i = 0
        let mygroup = DispatchGroup()
        for post in recordings {
            if !users.keys.contains(post.OwnerID) {
                mygroup.enter()
                
                DBViewController.getUserById(forUID: post.OwnerID) { (user) in
                    print("Finished request \(i)")
                    if let user = user {
                        self.users[user.uid] = user
//                        self.tableView.reloadData()
                    }
                    i += 1
                    mygroup.leave()
                }
            }
        }
        mygroup.notify(queue: .main){
            DispatchQueue.main.async {
                print("finished all request")
                self.isFetching = false
                self.collectionView.reloadData()
                print("called reload table")
            }
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
