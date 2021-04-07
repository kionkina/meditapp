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
    
    public var fetchingMore:Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    static func secondsToString (seconds : Int) -> String {
            let newSeconds = (seconds % 3600) % 60
            let minutes = (seconds % 3600) / 60
            let hours = seconds / 3600
            let days = hours/24

            if (days > 0) {
                let day = days == 1 ? "day" : "days"
                return "\(days) \(day) ago "
            }
            else if (hours > 0) {
                let hour = hours == 1 ? "hour" : "hours"
                return "\(hours) \(hour) ago"
            }
            else if (minutes > 0) {
                let mins = minutes == 1 ? "minute" : "minutes"
                return "\(minutes) \(mins) ago"
            }
            else {
                let sec = seconds == 1 ? "second" : "seconds"
                return "\(newSeconds) \(sec) ago"
            }

        }
        
        static func convertTime(stamp: Timestamp) -> String {
            let dv = Int(stamp.dateValue().distance(to: Date()))
            return(secondsToString(seconds: dv))
        }
    
    static func getPostsByTags(forLimit limit: Int , forTags tags: [String], success: @escaping ([Post], _ numFetched: Int) -> Void){
        let db = Firestore.firestore()
        var fetchedPosts = [Post]()
        if tags.isEmpty{
            return
        }
        print("FETCHING BY TAGS", tags)
        print("about to run query")
        //let userRef = db.collection("users").document(User.current.uid)
        //returns a firquery. using orderby requires creating index
        let queryRef = db.collection("recordings")
            //.whereField("OwnerID", notIn: [User.current.uid])
            .whereField("Tags", arrayContainsAny: tags)
            .order(by: "Timestamp", descending: true)
            .limit(to: limit)
        //get documents from that query
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
                        fetchedPosts.append(curPost)
                        foundPosts.append(curPost.IdTime)
                    }
                    
                    if limit - fetchedPosts.count <= 0{
                        print("no need to fetch more posts")
                        success(fetchedPosts, fetchedPosts.count)
                    }
                    else{
                        print("going to fetch more")
                        let original = fetchedPosts.count
                        let queryRef2 = db.collection("recordings")
                            .whereField("IdTime", notIn: foundPosts)
                            .order(by: "IdTime", descending: true)
                            .limit(to: limit - fetchedPosts.count)
                        
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
                                        print(snapshot.data()["IdTime"], "the ID time of doc")
                                        let curPost = Post(snapshot: snapshot)!
                                        fetchedPosts.append(curPost)
                                    }
                                }
                                success(fetchedPosts, original)
                            }
                        }
                    }
                }
            }
        }
    }
    
    static func getUserById(forUID uid: String, success: @escaping (User?) -> Void) {

        let docRef = Firestore.firestore().collection("Users").document(uid)
        
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
        db.collection("recordings").document(forPost).collection("Comments").order(by: "Timestamp", descending: true).getDocuments{ (qs: QuerySnapshot?, err) in
            success(qs!.documents)
        }
    }
    
    static func insertComment(postID: String, comment: Comment, oldNumComments: Int, success: @escaping (Int)  -> Void) {
        let db = Firestore.firestore()
        let recRef = db.collection("recordings").document(postID)
        let commentRef = recRef.collection("Comments")
        let newDocRef = commentRef.document()
        let newNumComments = oldNumComments + 1

        db.runTransaction({ (transaction, errorPointer) -> Any? in
            do {
                try transaction.setData([
                    "Content": comment.Content,
                    "Timestamp" : comment.Timestamp,
                    "OwnerID" : comment.OwnerID
                    ], forDocument: newDocRef)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }

            print("updating num comments")
            transaction.updateData(["numComments": newNumComments], forDocument: recRef)
            return newNumComments
             }) { (object, error) in
            if let error = error {
                print("Transaction failed: \(error)")
            } else {
                print("Transaction successfully committed!")
                success(newNumComments)
                //return newNumComments
            }
        }
    }

    static func createLike(for postID: String, success: @escaping (Int) -> Void){
        let db = Firestore.firestore()
        let postRef = db.collection("recordings").document(postID)
        let userRef = db.collection("Users").document(User.current.uid)

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
        let postRef = db.collection("recordings").document(postID)
        let userRef = db.collection("Users").document(User.current.uid)

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
