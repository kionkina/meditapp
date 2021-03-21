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
                print("got document")

                let user = User(snapshot: document)
                print(user?.recordings)
                success(user) 
            } else {
                print("Document does not exist")
            }
        }
    }

    //TODO: ask if using references better
    static func getRecordings(for references: [DocumentReference], success: @escaping (DocumentSnapshot) -> Void){
        print(references)
        var ret : [DocumentSnapshot] = []
        
        let dispatchGroup = DispatchGroup()
        
        for docRef in references {
            docRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    print("appending docboi")
                    ret.append(document)
                    success(document)
                } else {
                    print("Document does not exist")
                }
            }

        }
        

    }
}
