//
//  FollowersViewController.swift
//  Meditapp
//
//  Created by Karina Ionkina on 4/19/21.
//
import UIKit
import FirebaseFirestore
import FirebaseStorage

class followersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate{

    @IBOutlet var tableView: UITableView!
    var followers = false
    var curr_index = -1
    var users: [User] = []
    var userIds: [String:Bool]?
    var numIds: Int = 0

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "toProfile") {
            let button = sender as! UIButton
            if let cell = button.superview?.superview as? followerCell {
                let vc = segue.destination as! UserProfilePageViewController
                vc.postUser = cell.postUser
            }
        }
    }
    
    @objc func loadTenUsers(success: @escaping (Bool) -> Void) -> Void {
        if (userIds != nil) {
            let keys = userIds?.keys
            var idArr = [String](userIds!.keys)

            var updateIndex: Bool = false
            // there are less than 10 more users to pull
            if (keys!.count > 0) {
                if (keys!.count - (curr_index + 1) > 10) {
                    updateIndex = true
                    idArr = [String](idArr[curr_index + 1...curr_index + 10])
                } else {
                    idArr = [String](idArr[(curr_index + 1)...(keys!.count - 1)])
                }

                DBViewController.loadTenUsers(for: idArr) { (users: [User]) in
                    for newUser in users {
                        self.users.append(newUser)
                    }
                    success(updateIndex)
                }
            }
        }
    }

    func doneLoadingUsers(updateIndex: Bool){
        tableView.reloadData()
        if (updateIndex) {
            curr_index += 10
            loadTenUsers(success: doneLoadingUsers)
        }
        else {
            return
        }

    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if HomePageViewController.audioPlayer.isPlaying{
            HomePageViewController.playingCell?.stopPlaying()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = 10000 // or your estimate
        tableView.delegate = self
        tableView.dataSource = self

        loadTenUsers(success: doneLoadingUsers)

    }

        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "followerCell", for: indexPath) as! followerCell
        
        let user = self.users[indexPath.row]
        cell.configure(for: user)
        
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        return cell
    }
    
    
    // MARK: - Table view data source

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    

}

