//
//  RiseTableViewCell.swift
//  Meditapp
//
//  Created by Karina Ionkina on 5/15/21.
//

import UIKit
import FirebaseStorage

class RiseTableViewCell: UITableViewCell {

    @IBOutlet weak var imgView: UIImageView!
    
    @IBOutlet weak var totalLikes: UILabel!
    @IBOutlet weak var username: UILabel!
    
    static let identifier = "RiseTableViewCell"
    
    static func nib() -> UINib{
        return UINib(nibName: "RiseTableViewCell", bundle: nil)
    }
    
    
    func configure(name: String, photo: String, totalLikes: Int) {

        username.text = name
        imgView.sd_setImage(with: Storage.storage().reference().child("profilephotos").child(photo))
        imgView.layer.cornerRadius = (imgView.frame.size.width) / 2
        self.totalLikes.text = String(totalLikes)
        
        }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
