//
//  UserService.swift
//
//  Created by Mariano Montori on 7/24/17.
//  Copyright © 2017 Mariano Montori. All rights reserved.
//

import Foundation
import Firebase


struct UserService {

    static func create(_ firUser: FIRUser, username: String, firstName: String, lastName: String, completion: @escaping (User?) -> Void) {
        let userAttrs = ["username": username,
                         "firstName": firstName,
                         "lastName": lastName]
        print("IN USER SERVICE")
        print("UID: " + firUser.uid)

        let ref = Firestore.firestore().collection("users").document(firUser.uid)
        
        
        
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
                    
                    }

            }
        }
    }
    
    static func show(forUID uid: String, completion: @escaping (User?) -> Void) {
        
        let ref = Firestore.firestore().collection("users").document(uid)
        
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
        let ref = Firestore.firestore().collection("users").document(uid)
        
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

