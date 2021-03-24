//
//  ChecklistViewController.swift
//  Meditapp
//
//  Created by Karina Ionkina on 3/15/21.
//

import UIKit
import Firebase

class ChecklistViewController: UITableViewController {
    
    var checklist: [String] = ["Morning", "Evening", "Relaxing", "Energizing", "Mantra"]
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    
    func configureText(for cell: UITableViewCell,
                        with item: String) {
         print("in config text")
         print(cell)
        
        let label = cell.viewWithTag(1000) as! UILabel
         label.text = item
 //        label.text = "\(item.itemID): \(item.text)"
     }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return checklist.count
    }
    
    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath)
        -> UITableViewCell {
            print("CLICKED")
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "ChecklistItem",
                for: indexPath)
            print("cell: ")
            print(cell)
            print("indexPath:")
            print(indexPath)
            let item = checklist[indexPath.row]
            print(item)
            configureText(for: cell, with: item)

            return cell
    }
    

    
    @IBAction func done() {
        print("done!")
        
        var userSelection: [String] = []
        //unwrap optional
        if let selectedRows = tableView.indexPathsForSelectedRows {
            
            for item: IndexPath in selectedRows {
                userSelection.append(checklist[item.row])
                print(checklist[item.row])
            }
        }
        
        print(userSelection)
        User.current.tags = userSelection
        updateData(selectedTags: userSelection)
        //send this to db
        
        //TODO: check that at least one is selected
        let initialViewController = UIStoryboard.initialViewController(for: .main)
        self.view.window?.rootViewController = initialViewController
        self.view.window?.makeKeyAndVisible()
    }
    
    //TODO: move logic to controller
    func updateData(selectedTags: [String]){
        let docRef = Firestore.firestore().collection("users").document(User.current.uid)

        docRef.updateData([
            "tags": selectedTags
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
            }
        }
        
    }
}
