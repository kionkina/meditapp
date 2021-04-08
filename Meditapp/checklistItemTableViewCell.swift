//
//  checklistItemTableViewCell.swift
//  Meditapp
//
//  Created by Gabriella Alexis on 4/7/21.
//

import UIKit

class checklistItemTableViewCell: UITableViewCell {

    @IBOutlet weak var genreView: UIView!
    @IBOutlet weak var genre: UILabel!
    @IBOutlet weak var genreImg: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
