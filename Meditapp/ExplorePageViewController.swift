//
//  ExplorePageViewController.swift
//  Meditapp
//
//  Created by Jackson Lu on 4/19/21.
//

import UIKit
import FirebaseStorage
import AVFoundation

class ExplorePageViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, RecommendationsDelegate, GenresDelegate {
//    func userDidTap(forTag tag: String) {
//        performSegue(withIdentifier: "viewMoreGenre", sender: tag)
//    }
    
    func userDidTap(forTags tags:[String]) {
        performSegue(withIdentifier: "viewMore", sender: tags)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "viewMore"{
            let vc = segue.destination as! ViewMoreViewController
            vc.title = "Explore"
            vc.viewforTags = sender as! [String]
        }
        else if segue.identifier == "ontheRiseProfile"{
            let vc = segue.destination as! UserProfilePageViewController
//            let forUser = sender as! Int
            vc.postUser = topUsers[sender as! Int]
        }
        else if segue.identifier == "toProfile"{
            let vc = segue.destination as! UserProfilePageViewController
            vc.postUser = sender as? User
        }
        else if segue.identifier == "toComments"{
            let vc = segue.destination as! CommentViewController
            let dict = sender as! [String:Any]
            vc.postUser = dict["user"] as? User
            vc.recording = dict["post"] as? Post
        }
    }
    
    @IBOutlet weak var tableView: UITableView!
    var titles = ["Recommendations", "Genres", "On The Rise"]
    var topUsers = [User]()
    let myRefreshControl = UIRefreshControl()

    var recommendationCell:RecommendationsTableViewCell?
    
    var pfpRef:StorageReference{
        return Storage.storage().reference().child("profilephotos")
    }
    
    static var playingCell: RecommendationsCollectionViewCell?
    static var audioPlayer = AVAudioPlayer()

    override func viewWillDisappear(_ animated: Bool) {
        if ExplorePageViewController.audioPlayer.isPlaying{
            print("player needs to stop playing")
            ExplorePageViewController.playingCell?.stopPlaying()
        }
    }
    
    

    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    //one row each section, collection view
    //will change for on the rise feature, maybe another tableview for that feature
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) || (section == 1) {
            return 1 + 1
        } else {
            return topUsers.count + 1
        }
    }
    
    
    //
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "HeaderTableViewCell") as! HeaderTableViewCell
            cell.configure(forHeader: titles[indexPath.section], withAlign: (indexPath.section + 2) % 2)
            cell.separatorInset = UIEdgeInsets(top: 0, left: cell.bounds.size.width, bottom: 0, right: 0);
            cell.selectionStyle = .none
            return cell
        }
        if indexPath.section == 0{
//            print("At indexpath section 0")
            let cell = tableView.dequeueReusableCell(withIdentifier: RecommendationsTableViewCell.identifier, for: indexPath) as! RecommendationsTableViewCell
            cell.delegate = self
            cell.layer.borderColor =  CGColor(red: 1, green: 1, blue: 1, alpha: 1)
            cell.layer.borderWidth = 7
            
            recommendationCell = cell
            return cell
        }
        else if indexPath.section == 1{
//            print("At indexpath \(indexPath.section)")
            let cell = tableView.dequeueReusableCell(withIdentifier: GenresTableViewCell.identifier, for: indexPath) as! GenresTableViewCell
            cell.delegate = self
            return cell
        } else {
//            print("At section \(indexPath.section)")
            let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
            // cell.image?.downloadedfrom("")
            cell.textLabel?.textAlignment = .right
            cell.textLabel?.text = topUsers[indexPath.row - 1].username
            cell.imageView?.sd_setImage(with: pfpRef.child(topUsers[indexPath.row - 1].profilePic))
            cell.selectionStyle = .none
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 2{
            performSegue(withIdentifier: "ontheRiseProfile", sender: indexPath.row - 1)
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    
    
    //each row height of 250
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0{
            return 50.0
        }
        if (indexPath.section == 0) || (indexPath.section == 1){
            return 250.0
        } else {
            return 50.0
        }
    }
    
    //register the tableview cells
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myRefreshControl.addTarget(self, action: #selector(refreshReload), for: .valueChanged)
        tableView.refreshControl = myRefreshControl
        
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        tableView.register(RecommendationsTableViewCell.nib(), forCellReuseIdentifier: RecommendationsTableViewCell.identifier)
        tableView.register(GenresTableViewCell.nib(), forCellReuseIdentifier: GenresTableViewCell.identifier)
        
        NotificationCenter.default.addObserver(self, selector: #selector(profileClicked), name: Notification.Name("profileClicked"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(commentClicked), name: Notification.Name("commentsClicked"), object: nil)
        
        loadTopUsers()
        
    }
    
    func loadTopUsers(){
        DBViewController.getTopFiveUsers { (users) in
            for users in users {
                self.topUsers.append(users)
            }
            self.tableView.reloadSections([2], with: .none)
        }
    }
    
    @objc func refreshReload(){
        if ExplorePageViewController.audioPlayer.isPlaying{
            print("player needs to stop playing")
            ExplorePageViewController.playingCell?.stopPlaying()
        }
        topUsers.removeAll()
        recommendationCell?.loadRecordingsFromExplorer()
        loadTopUsers()
        myRefreshControl.endRefreshing()
    }
    
    @objc func profileClicked(notification: NSNotification){
        performSegue(withIdentifier: "toProfile", sender: notification.object as? User)
    }
    
    @objc func commentClicked(notification: NSNotification){
        performSegue(withIdentifier: "toComments", sender: notification.object as? [String:Any])
    }
}
