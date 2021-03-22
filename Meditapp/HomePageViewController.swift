//
//  HomePageViewController.swift
//  Meditapp
//
//  Created by Jackson Lu on 3/20/21.
//

import UIKit
import FirebaseFirestore

class HomePageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var tableView: UITableView!
    
    var recordings = [Post]()

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "toProfile") {
            let button = sender as! UIButton
            if let cell = button.superview?.superview as? postCellTableViewCell {
                //print(cell.uid)
                let vc = segue.destination as! UserProfilePageViewController
//                vc.postUser = cell.postUser
                recordings[tableView.indexPath(for: cell)!.row].OwnerRef.getDocument(completion: { (doc, error) in
                    if let error = error{
                        print("Error getting documents: \(error.localizedDescription)")
                    }
                    else{
                        vc.postUser = User(snapshot: doc!)
                    }
                })
                
            }
        }
    }
    


    
    
    func loadRecordings() {
        DBViewController.getPostsByTags(forTags: User.current.tags) { docs in
            for doc in docs{
                self.recordings.append(doc)
            }
            self.tableView.reloadData()
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(User.current.tags, "and my username is", User.current.username)
        
        loadRecordings()
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as! postCellTableViewCell
        
        let recording = recordings[indexPath.row]

        return cell
    }
    
    
    // MARK: - Table view data source

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recordings.count
    }
}

