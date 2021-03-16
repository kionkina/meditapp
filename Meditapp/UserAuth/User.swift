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
    
    
    //Standard User init()
    init(uid: String, username: String, firstName: String, lastName: String) {
        self.uid = uid
        self.firstName = firstName
        self.lastName = lastName
        self.username = username
        self.tags = []
        super.init()
    }
    
    //User init using Firebase snapshots
    init?(snapshot: DocumentSnapshot) {
        guard let dict = snapshot.data(),
            let firstName = dict["firstName"] as? String,
            let lastName = dict["lastName"] as? String,
            let username = dict["username"] as? String,
            let tags = dict["tags"] as? [String]
            else { return nil }
        self.uid = snapshot.documentID
        self.firstName = firstName
        self.lastName = lastName
        self.username = username
        self.tags = tags
    }
    
    //UserDefaults
    required init?(coder aDecoder: NSCoder) {
        guard let uid = aDecoder.decodeObject(forKey: "uid") as? String,
            let firstName = aDecoder.decodeObject(forKey: "firstName") as? String,
            let lastName = aDecoder.decodeObject(forKey: "lastName") as? String,
            let username = aDecoder.decodeObject(forKey: "username") as? String,
            let tags = aDecoder.decodeObject(forKey:"tags") as? [String]
            else { return nil }
        
        self.uid = uid
        self.firstName = firstName
        self.lastName = lastName
        self.username = username
        self.tags = tags
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
    }
}
