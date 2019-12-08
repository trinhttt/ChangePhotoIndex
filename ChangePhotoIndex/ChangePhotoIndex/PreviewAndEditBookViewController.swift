//
//  ViewController.swift
//  ChangePhotoIndex
//
//  Created by Trinh Thai on 12/5/19.
//  Copyright © 2019 Trinh Thai. All rights reserved.
//

import UIKit

class PreviewAndEditBookViewController: UIViewController,  UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
     private var snapShot: UIView?
    private var sourceIndexPath: NSIndexPath?

    var itemsArray : [String]
    required init(coder aDecoder: NSCoder) {
        itemsArray = [String]()
        
        let item1 = "A"
        let item2 = "B"
        let item3 = "C"
        let item4 = "D"
        let item5 = "E"
        let item6 = "F"
        let item7 = "G"
        let item8 = "H"
        let item9 = "J"
        let item10 = "K"
        
        itemsArray.append(item1)
        itemsArray.append(item2)
        itemsArray.append(item3)
        itemsArray.append(item4)
        itemsArray.append(item5)
        itemsArray.append(item6)
        itemsArray.append(item7)
        itemsArray.append(item8)
        itemsArray.append(item9)
        itemsArray.append(item10)
        
        super.init(coder: aDecoder)!
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
//        ibTableView.isUserInteractionEnabled = true
//        ibTableView.isEditing true
//        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func handleOverSizeOfTableView(position: CGFloat) -> CGFloat {
           var positionTmp = position
           if positionTmp <= 0 {
               positionTmp = 1
           } else if position >= tableView.contentSize.height {
               positionTmp = tableView.contentSize.height - 1
           }
           return positionTmp
       }
    
    func customSnapShotFromView(inputView: UIView) -> UIImageView {
        // Make an image from the input view.
        UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, false, 0)
        if let graphicGetCurrentContext = UIGraphicsGetCurrentContext() {
            inputView.layer.render(in: graphicGetCurrentContext)
        }
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        let snapshot = UIImageView(image: image)
        snapshot.layer.masksToBounds = false
        snapshot.layer.cornerRadius = 0.0
//        snapshot.shadow(color: .blackColor(), offset: CGSize(width: -5.0, height: 0.0), opacity: 0.4, radius: 5.0)
        return snapshot
    }
    func longPressGestureRecognized(gestureRecognizer: UIGestureRecognizer) {
       let state = gestureRecognizer.state
        var location = gestureRecognizer.location(in: tableView)
        location.y = handleOverSizeOfTableView(position: location.y)
        guard let indexPath = tableView.indexPathForRow(at: location) else { return }
        switch state {
        case .began:
            sourceIndexPath = indexPath as NSIndexPath
            guard let cell = tableView.cellForRow(at: indexPath) else { return }
            // Take a snapshot of the selected row using helper method.
            snapShot = customSnapShotFromView(inputView: cell)
            // Add the snapshot as subview, centered at cell's center...
            var center = cell.center
            snapShot?.center = center
            snapShot?.alpha = 0.0
            guard let snapShot = snapShot else { return }
            tableView.addSubview(snapShot)
            UIView.animate(withDuration: 0.25,
                animations: {
                    // Offset for gesture location.
                    center.y = location.y
                    self.snapShot?.center = center
                    self.snapShot?.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
                    self.snapShot?.alpha = 0.98
                    cell.alpha = 0.0
                },
                completion: { _ in
                    cell.isHidden = true
            })
        case .changed:
            guard let snapShot = snapShot, let sourceIndexPathTmp = sourceIndexPath else { return }
            var center = snapShot.center
            center.y = location.y
            snapShot.center = center

            // Is destination valid and is it different from source?
            if indexPath != sourceIndexPathTmp as IndexPath {
                // self made exchange method
//                exchangeObjectAtIndex(index: indexPath.row, withObjectAtIndex: sourceIndexPathTmp.row)
                // ... move the rows.
                tableView.moveRow(at: sourceIndexPathTmp as IndexPath, to: indexPath)
                // ... and update source so it is in sync with UI changes.
                sourceIndexPath = indexPath as NSIndexPath
            }
            scrollTableView()
        default:
            guard let sourceIndexPathTmp = sourceIndexPath else { return }
            guard let cell = tableView.cellForRow(at: sourceIndexPathTmp as IndexPath) else { return }
            cell.isHidden = false
            cell.alpha = 0.0

            UIView.animate(withDuration: 0.25,
                animations: {
                    self.snapShot?.center = cell.center
                    self.snapShot?.transform = CGAffineTransform.identity
                    self.snapShot?.alpha = 0.0
                    cell.alpha = 1.0
                },
                completion: { _ in
                    self.sourceIndexPath = nil
                    self.snapShot?.removeFromSuperview()
                    self.snapShot = nil
            })
        }
    }
    
    func snapshotOfCell(inputView: UIView) -> UIView {
        UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, false, 0.0)
        inputView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()! as UIImage
        UIGraphicsEndImageContext()
        
        let cellSnapshot : UIView = UIImageView(image: image)
        cellSnapshot.layer.masksToBounds = false
        cellSnapshot.layer.cornerRadius = 0.0
        cellSnapshot.layer.shadowOffset = CGSize(width: -5.0, height: 0.0)
        cellSnapshot.layer.shadowRadius = 5.0
        cellSnapshot.layer.shadowOpacity = 0.4
        return cellSnapshot
    }
    private func scrollToUp() {
           if tableView.contentOffset.y != 0 {
               let y = tableView.contentOffset.y - 5
               tableView.contentOffset.y = y > 0 ? y : 0
               if let cellSnapshot = snapShot {
                   if cellSnapshot.frame.origin.y < tableView.contentOffset.y {
                       scrollToUp()
                   }
               }
           }
       }

       private func scrollToDown() {
           let y = tableView.contentOffset.y + 5
           if y + tableView.frame.height < tableView.contentSize.height {
               tableView.contentOffset.y = y
               if let cellSnapshot = snapShot {
                   let contentY = tableView.contentOffset.y + tableView.frame.height
                   if cellSnapshot.frame.origin.y < tableView.contentOffset.y {
                       scrollToUp()
                   } else if cellSnapshot.frame.origin.y + cellSnapshot.frame.height > contentY && tableView.contentOffset.y + tableView.frame.height < tableView.contentSize.height {
                       scrollToDown()
                   }
               }
           }
       }
    
    private func scrollTableView() {
          guard let snapShot = snapShot else { return }
          let contentY = tableView.contentOffset.y + tableView.frame.height
          if snapShot.frame.origin.y < tableView.contentOffset.y {
              scrollToUp()
          } else if snapShot.frame.origin.y + snapShot.frame.height > contentY && tableView.contentOffset.y + tableView.frame.height < tableView.contentSize.height {
              scrollToDown()
          }
      }
    // MARK: - Table view data source

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemsArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PreviewAndEditTableViewCell", for: indexPath as IndexPath) as! PreviewAndEditTableViewCell

        cell.longTapHandle = { gestureRecognizer in
            self.longPressGestureRecognized(gestureRecognizer: gestureRecognizer)
//            TableViewCellProvider.shared.longPressGestureRecognized(gestureRecognizer: gestureRecognizer, tableView: self.ibTableView) { (sourceIndex, destinationIndex) in
//                print(self.itemsArray)
//
//                let movedObject = self.itemsArray[sourceIndex]
//                self.itemsArray.remove(at: sourceIndex)
//                self.itemsArray.insert(movedObject, at: destinationIndex)
//                print(self.itemsArray)
////                self.ibTableView.reloadData()
//            }
        }
        cell.ibLabel.text = "\(indexPath.row) \(itemsArray[indexPath.row])"
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath as IndexPath, animated: false)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
}


//Reorder hold all cell
//extension PreviewAndEditBookViewController {
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return itemsArray.count
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        if let cell = ibTableView.dequeueReusableCell(withIdentifier: "PreviewAndEditTableViewCell", for: indexPath) as? PreviewAndEditTableViewCell {
//            cell.backgroundColor = .yellow
//            cell.textLabel?.text = itemsArray[indexPath.row]
//            return cell
//        }
//        return UITableViewCell()
//    }
//
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 150//UIibTableView.automaticDimension
//    }
//
//     func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
//        return .none // do not show delete styl
//    }
//
//     func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
//        return false
//    }
//     func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
//        let movedObject = self.itemsArray[sourceIndexPath.row]
//        itemsArray.remove(at: sourceIndexPath.row)
//        itemsArray.insert(movedObject, at: destinationIndexPath.row)
//    }
//
//    // Change default icon (hamburger) for moving cells in UITableView
//    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        let imageView = cell.subviews.first(where: { $0.description.contains("Reorder") })?.subviews.first(where: { $0 is UIImageView }) as? UIImageView
//
//        imageView?.image = UIImage(named: "move-up-down")
//        let size = cell.bounds.height * 0.4 // scaled for padding between cells
//        imageView?.frame.size.width = size
//        imageView?.frame.size.height = size
//    }
//}
