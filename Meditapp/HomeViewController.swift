//
//  ViewController.swift
//  Meditapp
//
//  Created by Karina Ionkina on 2/23/21.
//

import UIKit

class HomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        redirect()
        // Do any additional setup after loading the view.
    }

}

    
    
extension HomeViewController{
    func redirect(){
        //Check if user has any preferences listed and redirect accordingly
        
        print("Here")
        print(User.current.firstName)
        print(User.current.tags)
        
        
    }
}
