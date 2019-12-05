//
//  ViewController.swift
//  ChangePhotoIndex
//
//  Created by Trinh Thai on 12/5/19.
//  Copyright © 2019 Trinh Thai. All rights reserved.
//

import UIKit

class PreviewAndEditBookViewController: UIViewController {
    
    @IBOutlet weak var ibTableView: UITableView!
    var objects: [String] = ["1", "2", "3"]
    override func viewDidLoad() {
        super.viewDidLoad()
        ibTableView.delegate = self
        ibTableView.dataSource = self
        ibTableView.isEditing = true
    }
}

extension PreviewAndEditBookViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "PreviewAndEditTableViewCell", for: indexPath) as? PreviewAndEditTableViewCell {
            cell.backgroundColor = .yellow
            cell.textLabel?.text = objects[indexPath.row]
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150//UITableView.automaticDimension
    }
    
     func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
     func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
     func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movedObject = self.objects[sourceIndexPath.row]
        objects.remove(at: sourceIndexPath.row)
        objects.insert(movedObject, at: destinationIndexPath.row)
    }
    
    // Change default icon (hamburger) for moving cells in UITableView
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let imageView = cell.subviews.first(where: { $0.description.contains("Reorder") })?.subviews.first(where: { $0 is UIImageView }) as? UIImageView
        
        imageView?.image = UIImage(named: "move-up-down")
        let size = cell.bounds.height * 0.6 // scaled for padding between cells
        imageView?.frame.size.width = size
        imageView?.frame.size.height = size
    }
}
