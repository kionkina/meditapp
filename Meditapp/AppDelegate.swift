//
//  AppDelegate.swift
//  Firebase-boilerplate
//
//  Created by Mariano Montori on 7/24/17.
//  Copyright © 2017 Mariano Montori. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDynamicLinks
import FirebaseCore

typealias FIRUser = FirebaseAuth.User

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow? = UIWindow(frame: UIScreen.main.bounds)
    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        configureInitialRootViewController(for: window)
        return true
    }

}

extension AppDelegate {
    func configureInitialRootViewController(for window: UIWindow?) {
        let defaults = UserDefaults.standard
        let initialViewController: UIViewController
        
        print("HERE")
        print(Auth.auth().currentUser)
        
        if Auth.auth().currentUser != nil,
            let userData = defaults.object(forKey: "currentUser") as? Data,
            let user = NSKeyedUnarchiver.unarchiveObject(with: userData) as? User {
            
            
            User.setCurrent(user)
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            initialViewController = storyboard.instantiateViewController(withIdentifier: "MainViewController")
        }
        else {
            print("MADE IT TO ELSE STATEMENT")
            let storyboard = UIStoryboard(name: "Login", bundle: nil)
            // Look into using UINavigationController
            initialViewController = storyboard.instantiateViewController(withIdentifier:"LoginViewController")
        }
        
        print("HERE 3")
        print(initialViewController) // <UINavigationController: 0x7fa5c3825000>
        window?.rootViewController = initialViewController
        
        print(window?.rootViewController) // nil !! -- fixed
        window?.makeKeyAndVisible()
    }
}
