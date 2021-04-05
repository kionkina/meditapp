//
//  CommentTableViewCell.swift
//  Meditapp
//
//  Created by Karina Ionkina on 3/29/21.
//

import UIKit
import UserNotifications
import FirebaseStorage
import Firebase

class commentCellTableViewCell: UITableViewCell {
    

    @IBOutlet weak var content: UILabel!
    @IBOutlet weak var time: UILabel!

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var username:UIButton!
    
    
    var postUser: User?
    var comment: Comment?

    func secondsToString (seconds : Int) -> String {
            let newSeconds = (seconds % 3600) % 60
            let minutes = (seconds % 3600) / 60
            let hours = seconds / 3600
            let days = hours/24

            if (days > 0) {
                let day = days == 1 ? "day" : "days"
                return "\(days) \(day) ago "
            }
            else if (hours > 0) {
                let hour = hours == 1 ? "hour" : "hours"
                return "\(hours) \(hour) ago"
            }
            else if (minutes > 0) {
                let mins = minutes == 1 ? "minute" : "minutes"
                return "\(minutes) \(mins) ago"
            }
            else {
                let sec = seconds == 1 ? "second" : "seconds"
                return "\(newSeconds) \(sec) ago"
            }

        }
        
        func convertTime(stamp: Timestamp) -> String {
            let dv = Int(stamp.dateValue().distance(to: Date()))
            return(secondsToString(seconds: dv))
        }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    //removed extra param: , user: User?
    func configure(with model: Comment, for user: User?){

        self.content.text = model.Content
        //self.time.text = model.Timestamp
        //retrieves image from postphotos in storage
        //fix user image when implement profile picture
        let imageRef = Storage.storage().reference().child("profilephotos").child(user!.profilePic)
        //sets the image from the path to the UIImageView
        self.userImage.sd_setImage(with: imageRef)
        self.username.setTitle(user!.username, for: .normal)
        self.time.text = convertTime(stamp: model.Timestamp)
        
        self.postUser = user
        self.comment = model
    }

    

}
