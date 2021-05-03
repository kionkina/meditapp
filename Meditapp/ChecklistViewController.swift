//
//  ChecklistViewController.swift
//  Meditapp
//
//  Created by Karina Ionkina on 3/15/21.
//

import UIKit
import Firebase
import FirebaseFirestore

class ChecklistViewController: UITableViewController {
    
    var checklist: [String] = ["Morning", "Evening", "Relaxing", "Energizing", "Mantra"]
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        // Do any additional setup after loading the view.
    }
    

    
    func configureText(for cell: UITableViewCell,
                        with item: String) {
        
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
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "ChecklistItem",
                for: indexPath) as! checklistItemTableViewCell
            let item = checklist[indexPath.row]
            configureText(for: cell, with: item)
            let genres = checklist[indexPath.row]
            cell.genreImg.image = UIImage(named: genres)
            cell.genreView.layer.cornerRadius = cell.genreView.frame.height / 2
            cell.genreImg.layer.cornerRadius = cell.genreImg.frame.height / 2

            return cell
    }
    

    
    @IBAction func done() {
        
        var userSelection: [String] = []
        var userGenres = [String:Int]()
        //unwrap optional
        if let selectedRows = tableView.indexPathsForSelectedRows {
            for item: IndexPath in selectedRows {
                userSelection.append(checklist[item.row])
                userGenres[checklist[item.row]] = 5
            }
        }
        
        User.current.tags = userSelection
        User.current.likedGenres = userGenres
        print("user liked genres in checklist = \(userGenres)")
        updateData(selectedTags: userSelection)
        updatelikedGenres(forGenres: userGenres)
        //send this to db
        
        //TODO: check that at least one is selected
        let initialViewController = UIStoryboard.initialViewController(for: .main)
        self.view.window?.rootViewController = initialViewController
        self.view.window?.makeKeyAndVisible()
    }
    
    //TODO: move logic to controller
    func updateData(selectedTags: [String]){
        let docRef = Firestore.firestore().collection("user1").document(User.current.uid)

        docRef.updateData([
            "tags": selectedTags
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                User.setCurrent(User.current, writeToUserDefaults: true)
                print("Document successfully updated")
            }
        }
    }
    
    func updatelikedGenres(forGenres genres: [String:Int]){
        let docRef = Firestore.firestore().collection("user1").document(User.current.uid)

        docRef.updateData([
            "likedGenres": genres
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
                User.setCurrent(User.current, writeToUserDefaults: true)
            }
        }
        
    }
}
