//
//  CreateUserViewController.swift
//  Firebase-boilerplate
//
//  Created by Mariano Montori on 7/24/17.
//  Copyright © 2017 Mariano Montori. All rights reserved.
//

import UIKit
import FirebaseAuth

class CreateUserViewController: UIViewController {

    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier == "cancel" {
                print("Back to Login screen!")
            }
        }
    }
    
    @IBAction func signUpClicked(_ sender: UIButton) {
        guard let firstName = firstNameTextField.text,
            let lastName = lastNameTextField.text,
            let username = usernameTextField.text,
            let email = emailTextField.text,
            let password = passwordTextField.text,
            !username.isEmpty,
            !firstName.isEmpty,
            !lastName.isEmpty
        
            else {
                print("Required fields are not all filled!")
                return
            }
        AuthService.createUser(controller: self, email: email, password: password) { (authUser) in
            guard let firUser = authUser else {
                return
            }
            
            UserService.create(firUser, username: username, firstName: firstName, lastName: lastName) { (user) in
                guard let user = user else {
                    return
                }
                
                UserDefaults.standard.removeObject(forKey: "UserLikedPosts")
                User.setCurrent(user, writeToUserDefaults: true)
                self.performSegue(withIdentifier: "selectTags", sender:nil)
            }
        }
    }
}

extension CreateUserViewController{
    func configureView(){
        applyKeyboardPush()
        applyKeyboardDismisser()
        signUpButton.layer.cornerRadius = 10
        signUpButton.backgroundColor = UIColor.init(red: 214/255, green: 178/255, blue: 111/255, alpha: 1);
        signUpButton.tintColor = UIColor.white;
    }
}
