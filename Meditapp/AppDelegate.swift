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
        
        if Auth.auth().currentUser != nil,
            let userData = defaults.object(forKey: "currentUser") as? Data,
            let user = NSKeyedUnarchiver.unarchiveObject(with: userData) as? User {
            
            User.setCurrent(user)
            
            
            if let UserLikedPosts = UserDefaults.standard.dictionary(forKey: "UserLikedPosts") as? [String:Bool]{
                User.current.likedPosts = UserLikedPosts
            }
            
            
            UserDefaults.standard.set(false, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")
        }
        else {
            let storyboard = UIStoryboard(name: "Login", bundle: nil)
            // Look into using UINavigationController
            let initialViewController = storyboard.instantiateViewController(withIdentifier:"LoginViewController")
            window?.rootViewController = initialViewController
            window?.makeKeyAndVisible()
        }
    }
}
