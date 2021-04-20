//
//  SelectTagsViewController.swift
//  Meditapp
//
//  Created by Karina Ionkina on 3/14/21.

import UIKit

class SelectTagsViewController: UIViewController {
    
    let exploreTags: [String] = ["Morning", "Evening", "Energizing", "Relaxing", "meditation", "Mantra"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func showQuestions() {
        dismissKeyboard()
        performSegue(withIdentifier: "showQuestions", sender: self)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension SelectTagsViewController{
    func configureView(){
        dismissKeyboard()
        applyKeyboardPush()
        applyKeyboardDismisser()
    }
}
