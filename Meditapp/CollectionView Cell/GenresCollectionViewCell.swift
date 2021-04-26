//
//  GenresCollectionViewCell.swift
//  Meditapp
//
//  Created by Jackson Lu on 4/19/21.
//

import UIKit

class GenresCollectionViewCell: UICollectionViewCell {

    static let identifier = "GenresCollectionViewCell"
    
    static func nib() -> UINib{
        return UINib(nibName: "GenresCollectionViewCell", bundle: nil)
    }
    
    @IBOutlet weak var genreImage:UIImageView!
    @IBOutlet weak var genreText:UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configure(forGenre genre:String){
        genreImage.image = UIImage(named: genre)
        genreImage.contentMode = .scaleAspectFill
        genreImage.layer.cornerRadius = 12
        genreText.text = genre
    }
}
