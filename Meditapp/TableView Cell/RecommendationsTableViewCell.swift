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
        return recordings.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == recordings.count{
            delegate!.userDidTap(forTags: toplikedGenres)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row < recordings.count{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecommendationsCollectionViewCell.identifier, for: indexPath) as! RecommendationsCollectionViewCell
            
            let recording = recordings[indexPath.row]
            if let user = users[recording.OwnerID]{
                cell.configure(withPost: recording, forUser: user!, forView: tagsforPosts[indexPath.row])
            }
            cell.layer.borderColor = UIColor.black.cgColor
            cell.layer.borderWidth = 1
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.row == recordings.count{
            return CGSize(width: 210, height: 250)
        }
        else{
            return CGSize(width: 380, height: 210)
        }
    }

    static let identifier = "RecommendationsTableViewCell"
    
    static func nib() -> UINib{
        return UINib(nibName: "RecommendationsTableViewCell", bundle: nil)
    }
    
    @IBOutlet var collectionView:UICollectionView!
    
    weak var delegate: RecommendationsDelegate?

    var tagsforPosts = [TKCollectionView]()
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
        
//        print("Recommendations table view cell generated")
        //get users top 3 liked genres
        //get recordings
        loadRecordings(forTags: toplikedGenres, success: loadUsers)
    }

    func loadRecordings(forTags tags:[String], success: @escaping(() -> Void)) {
        queryLimit = 5
        DBViewController.getPostsByTags(forLimit: queryLimit, forTags: tags) { (docs, numFetched) in
            self.recordings.removeAll()
            for doc in docs{
                self.recordings.append(doc)
                let tagsForPost = TKCollectionView()
                tagsForPost.tags = doc.Tags
                self.tagsforPosts.append(tagsForPost)
            }
            self.collectionView.reloadData()
            print("number of fetched post by tags \(docs.count)")
            success()
        }
    }
    
    func loadUsers() -> Void {
        for recording in recordings {
            if !users.keys.contains(recording.OwnerID) {
                DBViewController.getUserById(forUID: recording.OwnerID) { (user) in
                    if let user = user {
                        self.users[user.uid] = user
                        self.collectionView.reloadData()
                    }
                }
            }
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
