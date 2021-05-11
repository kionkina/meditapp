//
//  LoadingCell.swift
//  Meditapp
//
//  Created by Jackson Lu on 5/10/21.
//

import UIKit

class LoadingCell: UICollectionViewCell {

    static let identifier = "LoadingCell"
    
    static func nib() -> UINib{
        return UINib(nibName: "LoadingCell", bundle: nil)
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
