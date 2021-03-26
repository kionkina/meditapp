//
//  User.swift
//
//  Created by Mariano Montori on 7/24/17.
//  Copyright © 2017 Mariano Montori. All rights reserved.
//

import Foundation
import UIKit
import FirebaseFirestore

class Post : NSObject {
    
    //User variables
    let Description : String
    let Name : String
    let OwnerID : String
    let RecID : String
    var Tags: [String]
    let Timestamp: Timestamp
    let numLikes: Int
//    var dictValue: [String: Any] {
//        return ["Description" : Description,
//                "Name" : Name,
//                "OwnerID" : OwnerID,
//                "RecID": RecID,
//                "Tags": Tags,
//                "Timestamp": Timestamp]
//    }
    
    //Standard Post init()
    init(Description: String, Name: String, OwnerID: String, RecID:String, Tags:[String], Timestamp: Timestamp, numLikes: Int) {
        self.Description = Description
        self.Name = Name
        self.OwnerID = OwnerID
        self.RecID = RecID
        self.Tags = Tags
        self.Timestamp = Timestamp
        self.numLikes = numLikes
        super.init()
    }

    //Post init using Firebase snapshots
    init?(snapshot: DocumentSnapshot!) {
        guard let dict = snapshot.data(),
            let Description = dict["Description"] as? String,
            let Name = dict["Name"] as? String,
            let OwnerID = dict["OwnerID"] as? String,
            let RecID = dict["RecID"] as? String,
            let Tags = dict["Tags"] as? [String],
            let Timestamp = dict["Timestamp"] as? Timestamp,
            let numLikes = dict["numLikes"] as? Int
            else {
            print ("returning nil")
            return nil
        }
        self.Description = Description
        self.Name = Name
        self.OwnerID = OwnerID
        self.RecID = RecID
        self.Tags = Tags
        self.Timestamp = Timestamp
        self.numLikes = numLikes
    }
    
//    UserDefaults
    required init?(coder aDecoder: NSCoder) {
        guard let Description = aDecoder.decodeObject(forKey: "Description") as? String,
            let Name = aDecoder.decodeObject(forKey: "Name") as? String,
            let OwnerID = aDecoder.decodeObject(forKey: "OwnerID") as? String,
            let RecID = aDecoder.decodeObject(forKey: "RecID") as? String,
            let Tags = aDecoder.decodeObject(forKey:"Tags") as? [String],
            let Timestamp = aDecoder.decodeObject(forKey:"timestamp") as? Timestamp,
            let numLikes = aDecoder.decodeObject(forKey:"numLikes") as? Int
            else { return nil }

        self.Description = Description
        self.Name = Name
        self.OwnerID = OwnerID
        self.RecID = RecID
        self.Tags = Tags
        self.Timestamp = Timestamp
        self.numLikes = numLikes
    }



}

extension Post: NSCoding {
    func encode(with aCoder: NSCoder) {
        aCoder.encode(Description, forKey: "Description")
        aCoder.encode(Name, forKey: "Name")
        aCoder.encode(OwnerID, forKey: "OwnerID")
        aCoder.encode(RecID, forKey: "RecID")
        aCoder.encode(Tags, forKey: "Tags")
        aCoder.encode(Timestamp, forKey: "Timestamp")
        aCoder.encode(numLikes, forKey: "numLikes")
    }
}
