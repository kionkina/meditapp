//
//  ChecklistViewController.swift
//  Meditapp
//
//  Created by Karina Ionkina on 3/15/21.
//

import UIKit

struct ChecklistItem {
    var text = ""
      var checked = false
      
      var dueDate = Date()
      var date = "Reminde Me: Off"
      var shouldRemind = false
      var itemID = -1
      
    mutating func toggleChecked() {
          checked = !checked
      }
}

class ChecklistViewController: UITableViewController {

    
    var checklist: [ChecklistItem] = []
    override func viewDidLoad() {
        
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return checklist.count
    }
    
    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath)
        -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "ChecklistItem",
                for: indexPath)
            let item = checklist[indexPath.row]
            configureText(for: cell, with: item)
            configureCheckmark(for: cell, with: item)
            return cell
    }

    override func tableView(_ tableView: UITableView,
                            didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            let item = checklist[indexPath.row]
            configureCheckmark(for: cell, with: item)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    func configureCheckmark(for cell: UITableViewCell,
                            with item: ChecklistItem) {
        let label = cell.viewWithTag(1001) as! UILabel
        if item.checked {
            label.text = "●"
        } else {
            label.text = ""
        }
    }
    
    func configureText(for cell: UITableViewCell,
                        with item: ChecklistItem) {
         let label = cell.viewWithTag(1000) as! UILabel
         let detailLabel = cell.viewWithTag(1002) as! UILabel
         label.text = item.text
         detailLabel.text = item.date
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

}
