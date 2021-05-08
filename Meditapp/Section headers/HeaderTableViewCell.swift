//
//  HeaderTableViewCell.swift
//  Meditapp
//
//  Created by Jackson Lu on 4/20/21.
//

import UIKit

class HeaderTableViewCell: UITableViewCell {

    @IBOutlet weak var headerLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func configure(forHeader header:String, withAlign alignment:Int){
        if alignment == 1{
            headerLabel.textAlignment = .left
        }
        else{
            headerLabel.textAlignment = .right
        }
        headerLabel.text = header
    }
}
