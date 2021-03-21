//
//  UserProfilePageViewController.swift
//  Meditapp
//
//  Created by Karina Ionkina on 3/18/21.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage

class UserProfilePageViewController:  UIViewController {
    


//    var uid = String()
    var pfpReference: StorageReference{
        return Storage.storage().reference().child("profilephotos")
    }
    
    var postUser: User?
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var lastNameLabel: UILabel!
    @IBOutlet weak var Pfp: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("in profile! uid: " + postUser!.uid)
        loadPfp()
        loadRecordings()
        // Do any additional setup after loading the view.
    }
    
    
    func loadRecordings() {
        print("in loadrecordings")
        
        print(postUser?.recordings)
        DBViewController.getRecordings(for: postUser!.recordings) { (docs) in
            print("doc: ")
            print(docs)
        }
    }
    
    //TODO : CHECK IF USER HAS IMAGE: BOOL.
    func loadPfp(){
        let downloadImageRef = pfpReference.child("default.jpeg")
        
        let downloadTask = downloadImageRef.getData(maxSize: 1024 * 1024 * 12) { (data, error) in
            if let data = data{
                let image = UIImage(data: data)
                self.Pfp.image = image
            }
            // print(error ?? "NONE")
        }
        
        downloadTask.resume()
    }
    
}
