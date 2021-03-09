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
        /*let ref = Database.database().reference().child("users").child(uid)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let user = User(snapshot: snapshot) else {
                return completion(nil)
            }
            
            completion(user)
        })*/
    }
    
    static func deleteUser(forUID uid: String, success: @escaping (Bool) -> Void) {
        /*let ref = Database.database().reference().child("users")
        let object = [uid : NSNull()]
        ref.updateChildValues(object) { (error, ref) -> Void in
            if let error = error {
                print("error : \(error.localizedDescription)")
                return success(false)
            }
            return success(true)
        }
        
    */
    }
}

