//
//  GenresTableViewCell.swift
//  Meditapp
//
//  Created by Jackson Lu on 4/19/21.
//

import UIKit

protocol GenresDelegate: class {
    func userDidTap(forTags tags:[String])
}

class GenresTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        genres.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        var arr = [String]()
//        arr.append(genres[indexPath.row])
        delegate!.userDidTap(forTags: Array(arrayLiteral: genres[indexPath.row]))
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GenresCollectionViewCell.identifier, for: indexPath) as! GenresCollectionViewCell
        cell.configure(forGenre: genres[indexPath.row])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 250, height: 210)
    }
    
    

    static let identifier = "GenresTableViewCell"
    
    static func nib() -> UINib{
        return UINib(nibName: "GenresTableViewCell", bundle: nil)
    }
    
    @IBOutlet var collectionView:UICollectionView!
    
    let genres = ["Morning", "Evening", "Energizing", "Relaxing", "Meditation", "Mantra"]
    
    weak var delegate: GenresDelegate?

    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        print("Genres table view cell generated")
        collectionView.register(GenresCollectionViewCell.nib(), forCellWithReuseIdentifier: GenresCollectionViewCell.identifier)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
