//
//  UserService.swift
//
//  Created by Mariano Montori on 7/24/17.
//  Copyright © 2017 Mariano Montori. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestore


struct UserService {

    static func create(_ firUser: FIRUser, username: String, firstName: String, lastName: String, completion: @escaping (User?) -> Void) {
        let userAttrs = ["username": username,
                         "firstName": firstName,
                         "lastName": lastName,
                         "tags": [],
                         "content": [],
                         "likedPosts": [String:Bool](),
                         "profilePic": "default.jpeg",
                         "likedGenres": [String:Int]()
        ] as [String : Any]
        print("in create in userservice")
        let ref = Firestore.firestore().collection("Users").document(firUser.uid)
        
        ref.setData(userAttrs) { error in
            if let error = error {
                assertionFailure(error.localizedDescription)
                return completion(nil)
            }
            else {
                ref.addSnapshotListener { documentSnapshot, error in
                    guard let snapshot = documentSnapshot else {
                            print("Error fetching document: \(error!)")
                            return
                        }
                    let user = User(snapshot: snapshot)
                    completion(user)
                    print("new account created")
                }
            }
        }
    }
    
    static func show(forUID uid: String, completion: @escaping (User?) -> Void) {
        
        print("in show in userservice")
        
        let ref = Firestore.firestore().collection("Users").document(uid)
        print("uid: " + uid)
        ref.addSnapshotListener { documentSnapshot, error in
            guard let snapshot = documentSnapshot else {
                    print("Error fetching document: \(error!)")
                    return
                }
            let user = User(snapshot: snapshot)
            completion(user)
        }
    }
    
    static func deleteUser(forUID uid: String, success: @escaping (Bool) -> Void) {
        let ref = Firestore.firestore().collection("Users").document(uid)
        
        ref.delete() { err in
            if let err = err {
                print("Error removing document: \(err)")
                return success(false)
            } else {
                print("Document successfully removed!")
                return success(true)
            }
        }
    }
}

