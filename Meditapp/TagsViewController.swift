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
        
        allTagsCollection.tags = ["Morning", "Evening", "Energizing", "Relaxing", "Meditation", "Mantra"]
        productTagsCollection.action     = .removeTag
        
        textField.sender = allTagsCollection
        textField.receiver = productTagsCollection
        
        allTagsCollection.action = .addTag
        allTagsCollection.receiver = productTagsCollection
        allTagsCollection.delegate     = self
        productTagsCollection.delegate     = self
    }
    func tagIsBeingAdded(name: String?) {
        return
    }

    func tagIsBeingRemoved(name: String?) {
        return
    }
    
    @IBAction func done(_ sender: Any) {
        delegate?.TagsViewController(self, didAddTags: productTagsCollection.tags)
        dismiss(animated: true, completion: nil)
    }
}
