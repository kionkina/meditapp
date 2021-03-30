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
    
//    static func getRandomPosts(forDiff diff: Int, forArray arr: [String], success: @escaping ([Post]) -> Void){
////        if diff == 0{ return nil}
//
//        var morePost = [Post]()
//
//        let db = Firestore.firestore()
//        let queryRef = db.collection("Recordings")
//            .whereField("RecID", notIn: arr)
//            .order(by: "Timestamp", descending: true)
//            .limit(to: diff)
//
//        queryRef.getDocuments { (querySnapshot, error) in
//            if let error = error{
//                print("Error getting documents: \(error.localizedDescription)")
//            }
//            else{
//                //querysnapshot can contain multiple documents
//                if querySnapshot!.documents.count <= 0{
//                    print("no more content can be fetched!")
////                    return nil
//                }
//                else{
//                    for snapshot in querySnapshot!.documents{
//                        var curPost = Post(snapshot: snapshot)!
//                        morePost.append(curPost)
//                    }
////                    return morePost
//                }
//            }
//        }
//    }
    
    static func getPostsByTags(forLimit limit: Int , forTags tags: [String], success: @escaping ([Post]) -> Void){
        if tags.isEmpty{
            return
        }
        print("FETCHING BY TAGS")
        print(tags)
        let db = Firestore.firestore()
        print("about to run query")
        //let userRef = db.collection("users").document(User.current.uid)
        //returns a firquery. using orderby requires creating index
        let queryRef = db.collection("Recordings")
            //.whereField("OwnerID", notIn: [User.current.uid])
            .whereField("Tags", arrayContainsAny: tags)
            .order(by: "Timestamp", descending: true)
            .limit(to: 5)
        //get documents from that query
        var setDict = [Post]()
        var foundPosts = [String]()
        queryRef.getDocuments { (querySnapshot, error) in
            if let error = error{
                print("Error getting documents: \(error.localizedDescription)")
            }
            else{
                //querysnapshot can contain multiple documents
                if querySnapshot!.documents.count <= 0{
                    print("no documents fetched")
                }
                else{
                    for snapshot in querySnapshot!.documents{
                        if (snapshot.data()["IdTime"] is String) {
                            print("yes")
                        }
                        else {
                            print("no")
                        }
                        print(snapshot.data())
                        let curPost = Post(snapshot: snapshot)!
                        setDict.append(curPost)
                        foundPosts.append(curPost.IdTime)
                    }
                    
                    if limit - setDict.count <= 0{
                        print("no need to fetch more posts")
                        success(setDict)
                    }
                    else{
                        print("going to fetch more")
                        let queryRef2 = db.collection("Recordings")
                            .whereField("IdTime", notIn: foundPosts)
                            .order(by: "IdTime", descending: true)
                            .limit(to: limit - setDict.count)
                        
                        queryRef2.getDocuments { (querySnapshot, error) in
                            if let error = error{
                                print("Error getting documents: \(error.localizedDescription)")
                            }
                            else{
                                //querysnapshot can contain multiple documents
                                if querySnapshot!.documents.count <= 0{
                                    print("no more content can be fetched!")
                //                    return nil
                                }
                                else{
                                    for snapshot in querySnapshot!.documents{
                                        print(snapshot.data()["IdTime"])
                                        let curPost = Post(snapshot: snapshot)!
                                        setDict.append(curPost)
                                    }
                                }
                                success(setDict)
                            }
                        }
                    }
                }
            }
        }
    }
    
    static func getUserById(forUID uid: String, success: @escaping (User?) -> Void) {
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

    //TODO: ask if using references better
    static func getRecordings(for references: [DocumentReference], success: @escaping (DocumentSnapshot) -> Void){
        var ret : [DocumentSnapshot] = []
        
        for docRef in references {
            docRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    ret.append(document)
                    success(document)
                } else {
                    print("Document does not exist")
                }
            }

        }
    }
    
    static func getCommentsById(forPost: String, success: @escaping (([DocumentSnapshot]) -> Void)) {
        let db = Firestore.firestore()
        db.collection("Recordings").document(forPost).collection("Comments").order(by: "Timestamp", descending: true).getDocuments{ (qs: QuerySnapshot?, err) in
            success(qs!.documents)
        }
    }
    
    static func insertComment(postID: String, comment: Comment, success: @escaping ()  -> Void) {
        let db = Firestore.firestore()
        let recRef = db.collection("Recordings").document(postID)
        recRef.collection("Comments").addDocument(data: [
            "Content": comment.Content,
            "Timestamp" : comment.Timestamp,
            "OwnerID" : comment.OwnerID
            ]){ err in
                if let err = err {
                    print("Error adding document: \(err)")
                } else {
                    print("Document added")
                    success()
                }
        }
    }
    
    static func createLike(for postID: String, success: @escaping (Int) -> Void){
        let db = Firestore.firestore()
        let postRef = db.collection("Recordings").document(postID)
        let userRef = db.collection("users").document(User.current.uid)

        db.runTransaction({ (transaction, errorPointer) -> Any? in
            let postDoc: DocumentSnapshot
            do {
                try postDoc = transaction.getDocument(postRef)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }

            guard let oldLikes = postDoc.data()?["numLikes"] as? Int else {
                let error = NSError(
                    domain: "AppErrorDomain",
                    code: -1,
                    userInfo: [
                        NSLocalizedDescriptionKey: "Unable to retrieve population from snapshot \(postDoc)"
                    ]
                )
                errorPointer?.pointee = error
                return nil
            }
            // Note: this could be done without a transaction
            //       by updating the population using FieldValue.increment()
            let newLikes = oldLikes + 1
            guard newLikes <= 1000000 else {
                let error = NSError(
                    domain: "AppErrorDomain",
                    code: -2,
                    userInfo: [NSLocalizedDescriptionKey: "likes \(newLikes) too big"]
                )
                errorPointer?.pointee = error
                return nil
            }

            transaction.updateData(["numLikes": newLikes], forDocument: postRef)
            //messed up b4
            transaction.updateData(["likedPosts.\(postID)":true], forDocument: userRef)
            success(newLikes)
            return newLikes
        }) { (object, error) in
            if let error = error {
                print("Error updating population: \(error)")
            } else {
                print("Population increased to \(object!)")
            }
        }
    }
    
    static func destroyLike(for postID: String, success: @escaping (Int) -> Void){
        let db = Firestore.firestore()
        let postRef = db.collection("Recordings").document(postID)
        let userRef = db.collection("users").document(User.current.uid)

        db.runTransaction({ (transaction, errorPointer) -> Any? in
            let postDoc: DocumentSnapshot
            do {
                try postDoc = transaction.getDocument(postRef)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }

            guard let oldLikes = postDoc.data()?["numLikes"] as? Int else {
                let error = NSError(
                    domain: "AppErrorDomain",
                    code: -1,
                    userInfo: [
                        NSLocalizedDescriptionKey: "Unable to retrieve population from snapshot \(postDoc)"
                    ]
                )
                errorPointer?.pointee = error
                return nil
            }
            // Note: this could be done without a transaction
            //       by updating the population using FieldValue.increment()
            let newLikes = oldLikes - 1
            guard newLikes <= 1000000 else {
                let error = NSError(
                    domain: "AppErrorDomain",
                    code: -2,
                    userInfo: [NSLocalizedDescriptionKey: "likes \(newLikes) too big"]
                )
                errorPointer?.pointee = error
                return nil
            }

            transaction.updateData(["numLikes": newLikes], forDocument: postRef)
            //messed up b4
            transaction.updateData(["likedPosts.\(postID)": FieldValue.delete()], forDocument: userRef)
            success(newLikes)
            return newLikes
        }) { (object, error) in
            if let error = error {
                print("Error updating population: \(error)")
            } else {
                print("Population increased to \(object!)")
            }
        }
    }
    
}
