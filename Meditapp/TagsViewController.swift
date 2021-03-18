//
//  TagsViewController.swift
//  Meditapp
//
//  Created by Jackson Lu on 3/14/21.
//

import UIKit
import TaggerKit

protocol TagsViewControllerDelegate: class {
    func TagsViewController(_ controller: TagsViewController, didAddTags tags: [String])
}
class TagsViewController: UIViewController, TKCollectionViewDelegate {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var containerView2: UIView!
    
    @IBOutlet weak var textField: TKTextField!
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    weak var delegate: TagsViewControllerDelegate?

    var allTagsCollection = TKCollectionView()
    var productTagsCollection = TKCollectionView()

    override func viewDidLoad() {
        super.viewDidLoad()
        add(allTagsCollection, toView: containerView)
        add(productTagsCollection, toView: containerView2)
        
        allTagsCollection.tags = ["Sleep", "Relaxing", "Anxiety"]
        productTagsCollection.action     = .removeTag
        
        textField.sender = allTagsCollection
        textField.receiver = productTagsCollection
        
        allTagsCollection.action = .addTag
        allTagsCollection.receiver = productTagsCollection

        allTagsCollection.delegate     = self
        productTagsCollection.delegate     = self
        // Do any additional setup after loading the view.
    }
    func tagIsBeingAdded(name: String?) {
        // Example: save testCollection.tags to UserDefault
        print("added \(name!)")
    }

    func tagIsBeingRemoved(name: String?) {
        print("removed \(name!)")
    }
    
    @IBAction func done(_ sender: Any) {
        delegate?.TagsViewController(self, didAddTags: productTagsCollection.tags)
        dismiss(animated: true, completion: nil)
    }
}
