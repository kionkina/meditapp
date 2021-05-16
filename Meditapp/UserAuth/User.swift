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
    var tags: [String]
    var recordings: [[String:DocumentReference]]
    var likedPosts: [String:Bool]
    var profilePic: String
    var numFollowers: Int
    var numFollowing: Int
    var following: [String:Bool]
    var followers: [String:Bool]
    var likedGenres: [String:Int]
    var totalLikes: Int

    init(user: User){
        self.uid = user.uid
        self.firstName = user.firstName
        self.lastName = user.lastName
        self.username = user.username
        self.tags = user.tags
        self.recordings = user.recordings
        self.likedPosts = user.likedPosts
        self.profilePic = user.profilePic
        self.numFollowers = user.numFollowers
        self.numFollowing = user.numFollowing
        self.followers = user.followers
        self.following = user.following
        self.likedGenres = user.likedGenres
        self.totalLikes = user.totalLikes
        
    }
    //Standard User init()
    init(uid: String, username: String, firstName: String, lastName: String, profilePic: String, numFollowing: Int = 0, numfollowers: Int = 0) {
        self.uid = uid
        self.firstName = firstName
        self.lastName = lastName
        self.username = username
        self.tags = []
        self.recordings = []
        self.likedPosts = [String:Bool]()
        self.profilePic = profilePic
        self.numFollowing = numFollowing
        self.numFollowers = numfollowers
        self.followers = [String:Bool]()
        self.following = [String:Bool]()
        self.likedGenres = [String:Int]()
        self.totalLikes = 0
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
            self.recordings = (dict["content"] as? [[String:DocumentReference]]) ?? []
            self.likedPosts = (dict["likedPosts"] as? [String:Bool]) ?? [String:Bool]()
            self.followers = (dict["followers"] as? [String:Bool]) ?? [String:Bool]()
            self.following = (dict["following"] as? [String:Bool]) ?? [String:Bool]()
            self.numFollowing = (dict["numFollowing"] as? Int) ?? 0
            self.numFollowers = (dict["numFollowers"] as? Int) ?? 0
            self.likedGenres = (dict["likedGenres"] as? [String:Int]) ?? [String:Int]()
            self.totalLikes = (dict["totalLikes"] as? Int) ?? 0
            if dict.keys.contains("profilePic"){
                self.profilePic = dict["profilePic"] as! String
            }
            else{
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
            let numFollowing = aDecoder.decodeInteger(forKey: "numFollowing") as? Int,
            let numFollowers = aDecoder.decodeInteger(forKey: "numFollowers") as? Int,
            let following = aDecoder.decodeObject(forKey: "following") as? [String:Bool],
            let followers = aDecoder.decodeObject(forKey: "followers") as? [String:Bool],
            let likedGenres = aDecoder.decodeObject(forKey:"likedGenres") as? [String:Int],
            let totalLikes = aDecoder.decodeInteger(forKey: "totalLikes") as? Int
            else {
                print("cannot decode for some reason")
                return nil
        }
        
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
        self.profilePic = profilePic
        self.likedGenres = likedGenres
        self.totalLikes = totalLikes
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
            do {let data = try NSKeyedArchiver.archivedData(withRootObject: user, requiringSecureCoding: false)
                UserDefaults.standard.set(data, forKey: "currentUser")
            }
            catch {
                print("couldn't set")
            }
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
        aCoder.encode(likedPosts, forKey: "likedPosts")
        aCoder.encode(profilePic, forKey: "profilePic")
        aCoder.encode(numFollowers, forKey: "numFollowers")
        aCoder.encode(following, forKey: "following")
        aCoder.encode(followers, forKey: "followers")
        aCoder.encode(likedGenres, forKey: "likedGenres")
        aCoder.encode(totalLikes, forKey: "totalLikes")
    }
}
