//
//  DBViewController.swift
//  Meditapp
//
//  Created by Karina Ionkina on 3/19/21.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage

class DBViewController: UIViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    
    static func getUserById(forUID uid: String, success: @escaping (User?) -> Void) {
        print("Getting user with uid \(uid)")
        let docRef = Firestore.firestore().collection("users").document(uid)
        
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let user = User(snapshot: document)
                success(user) 
            } else {
                print("Document does not exist")
            }
        }
    }

//    static func getUserPosts(forUID uid: String, success: @escaping ([DocumentSnapshot]?) -> Void) )

}
