//
//  RecommendationsTableViewCell.swift
//  Meditapp
//
//  Created by Jackson Lu on 4/19/21.
//

import UIKit

class RecommendationsTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return recordings.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecommendationsCollectionViewCell.identifier, for: indexPath) as! RecommendationsCollectionViewCell
        
        let recording = recordings[indexPath.row]
        if let user = users[recording.OwnerID]{
            cell.configure(withPost: recording, forUser: user!)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 380, height: 210)
    }

    static let identifier = "RecommendationsTableViewCell"
    
    static func nib() -> UINib{
        return UINib(nibName: "RecommendationsTableViewCell", bundle: nil)
    }
    
    @IBOutlet var collectionView:UICollectionView!
    
    var recordings = [Post]()
    var users = [String: User?]()
    
    var queryLimit = 0
    
    deinit {
        print("Recommendations table view cell destroyed")
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.register(RecommendationsCollectionViewCell.nib(), forCellWithReuseIdentifier: RecommendationsCollectionViewCell.identifier)
        
//        print("Recommendations table view cell generated")
        //get users top 3 liked genres
        let topGenresDicts = User.current.likedGenres.sorted { $0.value > $1.value }.prefix(3)
        var topGenres = [String]()
        for dict in topGenresDicts{
            topGenres.append(dict.key)
        }
        
        print(topGenres, " top genres selected")
        //get recordings
        loadRecordings(forTags: topGenres, success: loadUsers)
    }

    func loadRecordings(forTags tags:[String], success: @escaping(() -> Void)) {
        queryLimit = 5
        DBViewController.getPostsByTags(forLimit: queryLimit, forTags: tags) { (docs, numFetched) in
            self.recordings.removeAll()
            for doc in docs{
                self.recordings.append(doc)
                self.collectionView.reloadData()
            }
            success()
        }
    }
    
    func loadUsers() -> Void {
        for recording in recordings {
            if !users.keys.contains(recording.OwnerID) {
                DBViewController.getUserById(forUID: recording.OwnerID) { (user) in
                    if let user = user {
                        self.users[user.uid] = user
                    }
                }
            }
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
