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
        print(snapshot.data())
        guard let dict = snapshot.data(),
            let Content = dict["Content"] as? String,
            let OwnerID = dict["OwnerID"] as? String,
            let Timestamp = dict["Timestamp"] as? Timestamp
            else {
            print ("returning nil")
            return nil
        }
        self.Content = Content
        self.OwnerID = OwnerID
        self.Timestamp = Timestamp
    }
    
////    UserDefaults
//    required init?(coder aDecoder: NSCoder) {
//        guard let Description = aDecoder.decodeObject(forKey: "Description") as? String,
//            let Name = aDecoder.decodeObject(forKey: "Name") as? String,
//            let OwnerID = aDecoder.decodeObject(forKey: "OwnerID") as? String,
//            let RecID = aDecoder.decodeObject(forKey: "RecID") as? String,
//            let Tags = aDecoder.decodeObject(forKey:"Tags") as? [String],
//            let Timestamp = aDecoder.decodeObject(forKey:"timestamp") as? Timestamp,
//            let numLikes = aDecoder.decodeObject(forKey:"numLikes") as? Int
//            else { return nil }
//
//        self.Description = Description
//        self.Name = Name
//        self.OwnerID = OwnerID
//        self.RecID = RecID
//        self.Tags = Tags
//        self.Timestamp = Timestamp
//        self.numLikes = numLikes
//    }
//
//
//
//}
//
//extension Post: NSCoding {
//    func encode(with aCoder: NSCoder) {
//        aCoder.encode(Description, forKey: "Description")
//        aCoder.encode(Name, forKey: "Name")
//        aCoder.encode(OwnerID, forKey: "OwnerID")
//        aCoder.encode(RecID, forKey: "RecID")
//        aCoder.encode(Tags, forKey: "Tags")
//        aCoder.encode(Timestamp, forKey: "Timestamp")
//        aCoder.encode(numLikes, forKey: "numLikes")
//    }
}
