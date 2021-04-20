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
                //print(cell.uid)
                let vc = segue.destination as! UserProfilePageViewController
                vc.postUser = cell.postUser
            }
        }
    }
    
    @objc func refreshReload(){
//        print("i have refreshed")
//        canFetchMore = true
//        //because if we dont remove users, in the loadusers post, all our users already stored, so it wont get to point of reloading data, since if statement never checks in loaduser since we run the loop on recordings we already fetched where it checks if ownerid exists in dict we had prior before we removed. The table then tries to load the cell before table has been reloading so it tries to load the row from data model that is no longer dere.
//        recordings.removeAll()
//        users.removeAll()
//        tableView.reloadData()
//        loadRecordings(success: loadUsers)
    }
    
    @objc func loadTenUsers(success: @escaping (Bool) -> Void) -> Void {
        if (userIds != nil) {
            print("userIds")
            print(userIds)
            //takes 10 user ids from current index
            let keys = userIds?.keys
            var idArr = [String](userIds!.keys)
            print("idArR:")
            print(idArr)
            var updateIndex: Bool = false
            // there are less than 10 more users to pull
            if (keys!.count > 0) {
                if (keys!.count - (curr_index + 1) > 11) {
                    updateIndex = true
                    idArr = [String](idArr[curr_index + 1...curr_index + 10])
                } else {
                    idArr = [String](idArr[(curr_index + 1)...(keys!.count - 1)])
                }

                DBViewController.loadTenUsers(for: idArr) { (users: [User]) in
                    for newUser in users {
                        self.users.append(newUser)
                        print(users)
                    }
                    success(updateIndex)
                }
            }
        }
    }

    func doneLoadingUsers(updateIndex: Bool){
        print("in done loading users")
        tableView.reloadData()
        if (updateIndex) {
            curr_index += 10
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if HomePageViewController.audioPlayer.isPlaying{
            print("player needs to stop playing")
            HomePageViewController.playingCell?.stopPlaying()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = 10000 // or your estimate
        tableView.delegate = self
        tableView.dataSource = self
        //tableView.register(followerCell.self, forCellReuseIdentifier: "followerCell")
        loadTenUsers(success: doneLoadingUsers)

    }

        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("RELOADING")

        let cell = tableView.dequeueReusableCell(withIdentifier: "followerCell", for: indexPath) as! followerCell
        
        let user = self.users[indexPath.row]
        print("index is")
        print(indexPath.row)
        print("configuring for ")
        print(user.username)
        cell.configure(for: user)
        
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        return cell
    }
    
    
    // MARK: - Table view data source

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("in tablevie")
        // #warning Incomplete implementation, return the number of rows
        return users.count
    }
    
    

}

