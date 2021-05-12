//
//  AppDelegate.swift
//  Firebase-boilerplate
//
//  Created by Mariano Montori on 7/24/17.
//  Copyright © 2017 Mariano Montori. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDynamicLinks
import FirebaseCore
import FirebaseFirestore

typealias FIRUser = FirebaseAuth.User

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow? = UIWindow(frame: UIScreen.main.bounds)
    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        let db = Firestore.firestore()
        configureInitialRootViewController(for: window)
        return true
    }

}

extension AppDelegate {
    func configureInitialRootViewController(for window: UIWindow?) {
        let defaults = UserDefaults.standard
        
        if Auth.auth().currentUser != nil{
            print("auth.current not nil")
        }
        else{
            print("auth.current NIL")
        }
        
        if let userData = defaults.object(forKey: "currentUser") as? Data{
            print("there exist user data", userData)
            if (NSKeyedUnarchiver.unarchiveObject(with: userData) as? User) != nil{
                print("unarchived")
            }
            else{
                print("cannot unarchive")
            }
        }
        else{
            print("there isnt user data in defualts")
        }
        

        
        if Auth.auth().currentUser != nil,
            let userData = defaults.object(forKey: "currentUser") as? Data,
            let user = NSKeyedUnarchiver.unarchiveObject(with: userData) as? User {
            
            User.setCurrent(user)
            
            
            if let UserLikedPosts = UserDefaults.standard.dictionary(forKey: "UserLikedPosts") as? [String:Bool]{
                User.current.likedPosts = UserLikedPosts
            }
            else{
                print("No user liked posts object")
            }
            
            let docRef = Firestore.firestore().collection("user2").document(user.uid)

            docRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    let loadUser = User(snapshot: document)!
                    User.setCurrent(loadUser, writeToUserDefaults: true)
//                    User.current.recordings = document.get("content") as! [[String:DocumentReference]]
//                    User.current.likedGenres = document.get("likedGenres") as! [String:Int]
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let initialViewController = storyboard.instantiateViewController(withIdentifier: "tabController")
                    window?.rootViewController = initialViewController
                    window?.makeKeyAndVisible()
                }
                else {
                    print("Document does not exist")
                }
            }
        }
        else {
            print("i am not logged in")
            let storyboard = UIStoryboard(name: "Login", bundle: nil)
            // Look into using UINavigationController
            let initialViewController = storyboard.instantiateViewController(withIdentifier:"LoginViewController")
            window?.rootViewController = initialViewController
            window?.makeKeyAndVisible()
        }
    }
}
