//
//  RecordingCell.swift
//  Meditapp
//
//  Created by Jackson Lu on 3/8/21.
//

import UIKit

class RecordingCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    
    var playAudio: ((UITableViewCell) -> Bool?)?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func playTap(_ sender: Any) {
        if let playing = playAudio?(self){
            if playing{
                playButton.setImage(UIImage(named: "play"), for: UIControl.State.normal)
            }
            else{
                playButton.setImage(UIImage(named: "stop"), for: UIControl.State.normal)
            }
        }
    }
    
}
