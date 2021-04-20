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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configure(forGenre Genre:String){
        genreImage.image = UIImage(named: Genre)
        genreImage.contentMode = .scaleAspectFill
    }
}
