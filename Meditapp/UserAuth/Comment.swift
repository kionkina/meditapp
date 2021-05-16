//
//  Comment.swift
//  Meditapp
//
//  Created by Karina Ionkina on 3/29/21.
//

import Foundation
import UIKit
import FirebaseFirestore

class Comment : NSObject {
    
    //User variables
    let Content : String
    let OwnerID : String
    let Timestamp: Timestamp


    //add pic param
    init(Content: String, OwnerID: String, Timestamp: Timestamp) {
        self.Content = Content
        self.OwnerID = OwnerID
        self.Timestamp = Timestamp
        super.init()
    }

    //Post init using Firebase snapshots
    init?(snapshot: DocumentSnapshot!) {
        guard let dict = snapshot.data(),
            let Content = dict["Content"] as? String,
            let OwnerID = dict["OwnerID"] as? String,
            let Timestamp = dict["Timestamp"] as? Timestamp
            else {
                return nil
            }
        self.Content = Content
        self.OwnerID = OwnerID
        self.Timestamp = Timestamp
    }
}
