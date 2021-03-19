//
//  UserProfilePageViewController.swift
//  Meditapp
//
//  Created by Karina Ionkina on 3/18/21.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage

class UserProfilePageViewController: UIViewController {

    var uid = String()
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var lastNameLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("in profile! uid: " + uid)
        // Do any additional setup after loading the view.
        
        let db = Firestore.firestore()
        let docRef = db.collection("users").document(uid)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let user = User(snapshot: document)
                //usernameLabel
                print("Document data: \(document.data())")
            } else {
                print("Document does not exist")
            }
        }

        
        

    }
    


}
