//
//  User.swift
//
//  Created by Mariano Montori on 7/24/17.
//  Copyright © 2017 Mariano Montori. All rights reserved.
//

import Foundation
import UIKit
import FirebaseFirestore

class User : NSObject {
    
    //User variables
    let uid : String
    let firstName : String
    let lastName : String
    let username : String
    var dictValue: [String : Any] {
        return ["firstName" : firstName,
                "lastName" : lastName,
                "username" : username]
    }
    var tags: [String]
    var recordings: [DocumentReference]
    var likedPosts: [String:Bool]
    var profilePic: String
    var numFollowers: Int
    var numFollowing: Int
    var following: [String:Bool]
    var followers: [String:Bool]

    
    //Standard User init()
    init(uid: String, username: String, firstName: String, lastName: String, profilePic: String) {
        self.uid = uid
        self.firstName = firstName
        self.lastName = lastName
        self.username = username
        self.tags = []
        self.recordings = []
        self.likedPosts = [String:Bool]()
        self.profilePic = profilePic
        self.numFollowers = 0
        self.numFollowing = 0
        self.followers = [String:Bool]()
        self.following = [String:Bool]()
            
        super.init()
    }
    
    //User init using Firebase snapshots
    init?(snapshot: DocumentSnapshot) {
        if let dict = snapshot.data(){
            self.uid = snapshot.documentID
            self.firstName = (dict["firstName"] as? String) ?? ""
            self.lastName = (dict["lastName"] as? String) ?? ""
            self.username = (dict["username"] as? String) ?? ""
            self.tags = (dict["tags"] as? [String]) ?? []
            self.recordings = (dict["content"] as? [DocumentReference]) ?? []
            self.likedPosts = (dict["likedPosts"] as? [String:Bool]) ?? [String:Bool]()
            self.followers = (dict["followers"] as? [String:Bool]) ?? [String:Bool]()
            self.following = (dict["following"] as? [String:Bool]) ?? [String:Bool]()
            self.numFollowing = (dict["numFollowing"] as? Int) ?? 0
            self.numFollowers = (dict["numFollowers"] as? Int) ?? 0
            
//            self.profilePic = ( (dict.keys.contains("profilePic") ) ? dict["profilePic"] as! String : "default.jpeg")
            if dict.keys.contains("profilePic"){
                self.profilePic = dict["profilePic"] as! String
            }
            else{
                print("initiallizing with snapshot")
                self.profilePic = "default.jpeg"
            }
        }
        else{
            print("ERROR")
            return nil
        }
    }
    
    //UserDefaults
    required init?(coder aDecoder: NSCoder) {
        guard let uid = aDecoder.decodeObject(forKey: "uid") as? String,
            let firstName = aDecoder.decodeObject(forKey: "firstName") as? String,
            let lastName = aDecoder.decodeObject(forKey: "lastName") as? String,
            let username = aDecoder.decodeObject(forKey: "username") as? String,
            let tags = aDecoder.decodeObject(forKey:"tags") as? [String],
//            let recordings = aDecoder.decodeObject(forKey:"recordings") as? [DocumentReference],
            let likedPosts = aDecoder.decodeObject(forKey:"likedPosts") as? [String:Bool],
            let profilePic = aDecoder.decodeObject(forKey: "profilePic") as? String,
            let numFollowers = aDecoder.decodeObject(forKey: "numFollowers") as? Int,
            let numFollowing = aDecoder.decodeObject(forKey: "numFollowing") as? Int,
            let following = aDecoder.decodeObject(forKey: "following") as? [String:Bool],
            let followers = aDecoder.decodeObject(forKey: "followers") as? [String:Bool]
            else { return nil }
        
        self.uid = uid
        self.firstName = firstName
        self.lastName = lastName
        self.username = username
        self.tags = tags
        self.recordings = []
        self.likedPosts = likedPosts
        self.profilePic = profilePic
        self.numFollowing = numFollowing
        self.numFollowers = numFollowers
        self.following = following
        self.followers = followers
        print(self.profilePic, "PROFILEPIC")
        print(self.likedPosts, "IN USERSWIFT")
    }
    
    
    //User singleton for currently logged user
    private static var _current: User?
    
    static var current: User {
        guard let currentUser = _current else {
            fatalError("Error: current user doesn't exist")
        }
        
        return currentUser
    }
    
    class func setCurrent(_ user: User, writeToUserDefaults: Bool = false) {
        if writeToUserDefaults {
            let data = NSKeyedArchiver.archivedData(withRootObject: user)
            
            UserDefaults.standard.set(data, forKey: "currentUser")
        }
        
        _current = user
    }
}

extension User: NSCoding {
    func encode(with aCoder: NSCoder) {
        aCoder.encode(uid, forKey: "uid")
        aCoder.encode(firstName, forKey: "firstName")
        aCoder.encode(lastName, forKey: "lastName")
        aCoder.encode(username, forKey: "username")
        aCoder.encode(tags, forKey: "tags")
//        aCoder.encode(recordings, forKey: "recordings")
        aCoder.encode(likedPosts, forKey: "likedPosts")
        aCoder.encode(profilePic, forKey: "profilePic")
        aCoder.encode(numFollowing, forKey: "numFollowing")
        aCoder.encode(numFollowers, forKey: "numFollowers")
        
    }
}
