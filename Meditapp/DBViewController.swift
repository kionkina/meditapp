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
    
    static func getPostsByTags(forTags tags: [String], success: @escaping ([Post]) -> Void){
        print("IM IN")
        let db = Firestore.firestore()
        //let userRef = db.collection("users").document(User.current.uid)
        //returns a firquery. using orderby requires creating index
        let queryRef = db.collection("Recordings")
            //.whereField("OwnerID", notIn: [User.current.uid])
            .whereField("Tags", arrayContainsAny: tags)
            .order(by: "Timestamp", descending: true)
            .limit(to: 5)
        
        print("Boutta get snapshots")
        //get documents from that query
        var setDict = [Post]()
        queryRef.getDocuments { (querySnapshot, error) in
            if let error = error{
                print("Error getting documents: \(error.localizedDescription)")
            }
            else{
                print("BOUTTA PRINT")
                print(querySnapshot!)
                //querysnapshot can contain multiple documents
                if querySnapshot!.documents.count > 0{
                    print("no documents fetched")
                }
                else{
                    for snapshot in querySnapshot!.documents{
                        print("THIS IS \(snapshot.documentID)")
                        setDict.append(Post(snapshot: snapshot)!)
                    }
                    success(setDict)
                }
            }
        }
        
        
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
