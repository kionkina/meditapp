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
    var numLikes: Int
    var numComments: Int
    let PostImg: String
    let IdTime: String
    
//    var dictValue: [String: Any] {
//        return ["Description" : Description,
//                "Name" : Name,
//                "OwnerID" : OwnerID,
//                "RecID": RecID,
//                "Tags": Tags,
//                "Timestamp": Timestamp]
//    }
    
    //Standard Post init()

    //add pic param
    init(Description: String, Name: String, OwnerID: String, RecID:String, Tags:[String], Timestamp: Timestamp, numLikes: Int, numComments: Int = 0, PostImg: String, IdTime:String) {
        self.Description = Description
        self.Name = Name
        self.OwnerID = OwnerID
        self.RecID = RecID
        self.Tags = Tags
        self.Timestamp = Timestamp
        self.numLikes = numLikes
        self.numComments = numComments
        self.PostImg = PostImg
        self.IdTime = IdTime
        //self.pic
        super.init()
    }

    //Post init using Firebase snapshots
    init?(snapshot: DocumentSnapshot!) {
        guard let dict = snapshot.data(),
            let Description = dict["Description"] as? String,
            let IdTime = dict["IdTime"]! as? String,
            let Name = dict["Name"] as? String,
            let OwnerID = dict["OwnerID"] as? String,
            let RecID = dict["RecID"] as? String,
            let Tags = dict["Tags"] as? [String],
            let Timestamp = dict["Timestamp"] as? Timestamp,
            let numLikes = dict["numLikes"] as? Int,
            let numComments = ( (dict.keys.contains("numComments") ) ? dict["numComments"] as? Int : 0),
            let PostImg = dict["Image"] as? String
            else {
                return nil
        }
        self.Description = Description
        self.Name = Name
        self.OwnerID = OwnerID
        self.RecID = RecID
        self.Tags = Tags
        self.Timestamp = Timestamp
        self.numLikes = numLikes
        self.numComments = numComments
        self.PostImg = PostImg
        self.IdTime = IdTime
    }
    
    required init?(coder aDecoder: NSCoder) {
        guard let Description = aDecoder.decodeObject(forKey: "Description") as? String,
            let Name = aDecoder.decodeObject(forKey: "Name") as? String,
            let OwnerID = aDecoder.decodeObject(forKey: "OwnerID") as? String,
            let RecID = aDecoder.decodeObject(forKey: "RecID") as? String,
            let Tags = aDecoder.decodeObject(forKey:"Tags") as? [String],
            let Timestamp = aDecoder.decodeObject(forKey:"timestamp") as? Timestamp,
            let numLikes = aDecoder.decodeObject(forKey:"numLikes") as? Int,
            let numComments = aDecoder.decodeObject(forKey:"numComments") as? Int,
            let PostImg = aDecoder.decodeObject(forKey:"PostImg") as? String,
            let IdTime = aDecoder.decodeObject(forKey:"IdTime") as? String
            else { return nil }

        self.Description = Description
        self.Name = Name
        self.OwnerID = OwnerID
        self.RecID = RecID
        self.Tags = Tags
        self.Timestamp = Timestamp
        self.numLikes = numLikes
        self.numComments = numComments
        self.PostImg = PostImg
        self.IdTime = IdTime
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
        aCoder.encode(numComments, forKey: "numComments")
        aCoder.encode(PostImg, forKey: "PostImg")
        aCoder.encode(IdTime, forKey: "IdTime")
    }
}
