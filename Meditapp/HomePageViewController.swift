//
//  HomePageViewController.swift
//  Meditapp
//
//  Created by Jackson Lu on 3/20/21.
//

import UIKit

class HomePageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var tableView: UITableView!
    
    var recordings = [userPost]()
    var users = [String: User?]()

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "toProfile") {
            let button = sender as! UIButton
            if let cell = button.superview?.superview as? postCellTableViewCell {
                //print(cell.uid)
                let vc = segue.destination as! UserProfilePageViewController
                vc.postUser = cell.postUser
            }
        }
    }
    
    func loadRecordings(success: @escaping(() -> Void)) {
        print("loadrecordings")
        print("I am user:",User.current.uid, "and my tags are ",User.current.tags)
        //TODO replace with fetch recordings
        recordings.append(userPost(postTitle: "Morning Meditation", postDescription: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.", postImage: "sunrise", userImage: "profile_pic_1", numLikes: 4, numDislikes: 1, numComments: 2, OwnerID: "pbUueL7HvfVOCPoCVhTJlZIiXiM2"))
        
        recordings.append(userPost(postTitle: "Take a break", postDescription: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.", postImage: "photo", userImage: "profile_pic_2", numLikes: 10, numDislikes: 2, numComments: 7, OwnerID: "pbUueL7HvfVOCPoCVhTJlZIiXiM2"))
        
//        tableView.reloadData()
        success()
    }
    
    func loadUsers() -> Void {
        print("loadUsers")
        //check if ID is not already in users
        for recording in recordings {
            if !users.keys.contains(recording.OwnerID) {
                DBViewController.getUserById(forUID: recording.OwnerID) { (user) in
                    //instantiate user using snapshot, append to users dict
                    print("before let user")
                    if let user = user {
                        print("after let user")
                        self.users[user.uid] = user
                        self.tableView.reloadData()
                        print(self.users)
                        print("reloaded")
                    }
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadRecordings(success: loadUsers)

    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as! postCellTableViewCell
        
        let recording = recordings[indexPath.row]
        //if user to current post found in dict
        //configure the cell
//        cell.configure(with: recording)
        if let user = users[recording.OwnerID]{
//            cell.configure(with: recording, user: user)
//            cell.configure(with: recording)
            //cell.uid = recordings[indexPath.row].OwnerID
            cell.configure(with: recording, for: user )
            //cell.postUser = user
        }
        
        return cell
    }
    
    
    // MARK: - Table view data source

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return recordings.count
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



