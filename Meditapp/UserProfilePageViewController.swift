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

//    var uid = String()
    var pfpReference: StorageReference{
        return Storage.storage().reference().child("profilephotos")
    }
    var postUser: User?
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var lastNameLabel: UILabel!
        
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("in profile! uid: " + postUser!.uid)
        // Do any additional setup after loading the view.
    }
}
