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
        print(snapshot.data())
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
        self.numComments = numComments
        self.PostImg = PostImg
        self.IdTime = IdTime
//        if let dict = snapshot.data(){
//            self.description = (dict["Description"] as? String) ?? ""
//            self.Name = (dict["Name"] as? String) ?? ""
//            self.OwnerID = (dict["OwnerID"] as? String) ?? ""
//            self.RecID = (dict["RecID"] as? String) ?? ""
//            self.Tags = (dict["Tags"] as? [String]) ?? []
//            self.Timestamp = (dict["Timestamp"] as? Timestamp) ?? 
//            self.likedPosts = (dict["likedPosts"] as? [String:Bool]) ?? [String:Bool]()
//        }
//        else{
//            print("ERROR")
//            return nil
//        }
    }
}
