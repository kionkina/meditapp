//
//  LoadMoreCollectionViewCell.swift
//  Meditapp
//
//  Created by Jackson Lu on 4/26/21.
//

import UIKit

class LoadMoreCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var viewMore: UIButton!
    
    static let identifier = "LoadMoreCollectionViewCell"
    
    static func nib() -> UINib{
        return UINib(nibName: "LoadMoreCollectionViewCell", bundle: nil)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

}
