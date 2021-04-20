//
//  ExplorePageViewController.swift
//  Meditapp
//
//  Created by Jackson Lu on 4/19/21.
//

import UIKit

class ExplorePageViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    var titles = ["Recommendations", "Genres"]
    
    //will eventually be 3 sections
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    //one row each section, collection view
    //will change for on the rise feature, maybe another tableview for that feature
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    //titles for each header in section
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return titles[section]
    }
    
    //
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0{
            print("At indexpath section 0")
            let cell = tableView.dequeueReusableCell(withIdentifier: RecommendationsTableViewCell.identifier, for: indexPath) as! RecommendationsTableViewCell
            return cell
        }
        else{
            print("At indexpath \(indexPath.section)")
            let cell = tableView.dequeueReusableCell(withIdentifier: GenresTableViewCell.identifier, for: indexPath) as! GenresTableViewCell
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
        print(User.current.likedGenres, "user liked genres")
        print(User.current.tags)
    }
}
