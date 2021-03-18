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

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "toProfile") {
            let vc = segue.destination as! UserProfilePageViewController
            vc.uid = sender.uid
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        table.register(postCellTableViewCell.nib(), forCellReuseIdentifier: postCellTableViewCell.identifier)
        table.delegate = self
        table.dataSource = self
        
        models.append(userPost(postTitle: "Morning Meditation", postDescription: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.", postImage: "sunrise", userImage: "profile_pic_1", numLikes: 4, numDislikes: 1, numComments: 2, OwnerID: "QiX9p76TefPhNNqj7Hvlq2KpIuh2"))
        
        models.append(userPost(postTitle: "Take a break", postDescription: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.", postImage: "photo", userImage: "profile_pic_2", numLikes: 10, numDislikes: 2, numComments: 7, OwnerID: "QiX9p76TefPhNNqj7Hvlq2KpIuh2"))

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as! postCellTableViewCell
        cell.configure(with: models[indexPath.row])
        
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
