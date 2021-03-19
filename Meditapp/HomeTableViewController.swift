//
//  HomeTableViewController.swift
//  Meditapp
//
//  Created by Gabriella Alexis on 3/2/21.
//

import UIKit

class HomeTableViewController: UITableViewController {
    
    
    @IBOutlet var table: UITableView!
    
    var models = [userPost]()
    
    //Dictionary to store user ids and user objects
    var users = [String: User]()

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "toProfile") {
            let button = sender as! UIButton
            if let cell = button.superview?.superview as? postCellTableViewCell {
                print(cell.uid)
                let vc = segue.destination as! UserProfilePageViewController
                vc.uid = cell.uid
            }
        }
    }
    
    func loadRecordings(success: @escaping(() -> Void)) {
        print("loadrecordings")
        //TODO replace with fetch recordings
        models.append(userPost(postTitle: "Morning Meditation", postDescription: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.", postImage: "sunrise", userImage: "profile_pic_1", numLikes: 4, numDislikes: 1, numComments: 2, OwnerID: "QiX9p76TefPhNNqj7Hvlq2KpIuh2"))
        
        models.append(userPost(postTitle: "Take a break", postDescription: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.", postImage: "photo", userImage: "profile_pic_2", numLikes: 10, numDislikes: 2, numComments: 7, OwnerID: "rLYgFmWpvGgtlnHooY76L9bVnOr2"))
        
        success()
    }
    
        
    
    func loadUsers() -> Void {
    
        print("loadUsers")
        //check if ID is not already in users
        for recording in models {
            if !users.keys.contains(recording.OwnerID) {
                DBViewController.getUserById(forUID: recording.OwnerID) { (user) in
                    if let user = user {
                        self.users[user.uid] = user
                    }
                }
            }
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        table.register(postCellTableViewCell.nib(), forCellReuseIdentifier: postCellTableViewCell.identifier)
        table.delegate = self
        table.dataSource = self
        
        loadRecordings(success: loadUsers)
        

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as! postCellTableViewCell
        let recording = models[indexPath.row]
        cell.configure(with: recording, user: users[recording.OwnerID]!)
        cell.uid = models[indexPath.row].OwnerID
        
        return cell
    }
    
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return models.count
    }

}

struct userPost {
    let postTitle: String
    let postDescription: String
    let postImage: String //will change later
    let userImage: String
    let numLikes: Int
    let numDislikes: Int
    let numComments: Int
    let OwnerID: String
}
