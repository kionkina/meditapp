//
//  ExplorePageViewController.swift
//  Meditapp
//
//  Created by Jackson Lu on 4/19/21.
//

import UIKit

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
            vc.viewforTags = sender as! [String]
        }
    }
    
    @IBOutlet weak var tableView: UITableView!
    var titles = ["Recommendations", "Genres"]
    var sectionHeaderHeight:CGFloat = 0
    
    //will eventually be 3 sections
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    //one row each section, collection view
    //will change for on the rise feature, maybe another tableview for that feature
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return sectionHeaderHeight
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HeaderTableViewCell") as! HeaderTableViewCell
        if section == 0{
            cell.configure(forHeader: "Recommended", withAlign: false)
        }
        else{
            cell.configure(forHeader: "Genres", withAlign: true)
        }
        return cell.contentView
    }
    
    //
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0{
            print("At indexpath section 0")
            let cell = tableView.dequeueReusableCell(withIdentifier: RecommendationsTableViewCell.identifier, for: indexPath) as! RecommendationsTableViewCell
            cell.delegate = self
            return cell
        }
        else{
            print("At indexpath \(indexPath.section)")
            let cell = tableView.dequeueReusableCell(withIdentifier: GenresTableViewCell.identifier, for: indexPath) as! GenresTableViewCell
            cell.delegate = self
            return cell
        }
    }
    
    //each row height of 250
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 250.0
    }
    
    //register the tableview cells
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(RecommendationsTableViewCell.nib(), forCellReuseIdentifier: RecommendationsTableViewCell.identifier)
        tableView.register(GenresTableViewCell.nib(), forCellReuseIdentifier: GenresTableViewCell.identifier)
        
        sectionHeaderHeight = tableView.dequeueReusableCell(withIdentifier: "HeaderTableViewCell")?.contentView.bounds.height ?? 0
        
        print(User.current.likedGenres, "user liked genres")
        print(User.current.tags)
    }
}
