//
//  ViewController.swift
//  ChangePhotoIndex
//
//  Created by Trinh Thai on 12/5/19.
//  Copyright © 2019 Trinh Thai. All rights reserved.
//

import UIKit

class PreviewAndEditBookViewController: UIViewController,  UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var ibTableView: UITableView!
    
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
        ibTableView.delegate = self
        ibTableView.dataSource = self
        ibTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func longPressGestureRecognized(gestureRecognizer: UIGestureRecognizer) {
        // Variable to store long press gesture
        let longPress = gestureRecognizer as! UILongPressGestureRecognizer
        
        // Variable to save the state of long press: states such as began, changed, ended are saved
        let state = longPress.state
        
        // A variable (x: 11.0, y: 13.0) that stores the long pressed position on the screen (coordinate value), changes when moved
        let locationInView = longPress.location(in: ibTableView)
        
        // Store the indexPath of the selected cell ([0, 4])
        let indexPath = ibTableView.indexPathForRow(at: locationInView)
        
        struct My {
            // variable to store snapshot
            static var cellSnapshot : UIView? = nil
            static var cellIsAnimating : Bool = false
            static var cellNeedToShow : Bool = false
        }
        struct Path {
            // First path of cell to long press
            static var initialIndexPath : NSIndexPath? = nil
        }
        
        switch state {
        case UIGestureRecognizerState.began: // When you start pressing a cell
            if indexPath != nil {
                
                // Save first path of cell to variable
                Path.initialIndexPath = indexPath as NSIndexPath?
                // Save snapshot of cell to variable
                let cell = ibTableView.cellForRow(at: indexPath!) as UITableViewCell?
                My.cellSnapshot  = snapshotOfCell(inputView: cell!)
                
                // Save center of cell
                var center = cell?.center
                
                // To position the snapshot in the center
                My.cellSnapshot!.center = center!
                // Make alpha transparent by zooming to zero
                My.cellSnapshot!.alpha = 0.0
                
                // Added snapshot to table view
                ibTableView.addSubview(My.cellSnapshot!)
                
                // start animation effect
                UIView.animate(withDuration: 0.25, animations: { () -> Void in
                    
                    // Adjust y to show finger position when snapshot
                    center?.y = locationInView.y
                    My.cellIsAnimating = true
                    My.cellSnapshot!.center = center!
                    
                    // make the snapshot size 105%
                    My.cellSnapshot!.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
                    
                    // change the alpha value of the snapshot to expose
                    My.cellSnapshot!.alpha = 0.98
                    
                    // change the original cell to be invisible
                    cell?.alpha = 0.0
                    
                }, completion: { (finished) -> Void in
                    if finished {
                        My.cellIsAnimating = false
                        if My.cellNeedToShow {
                            My.cellNeedToShow = false
                            UIView.animate(withDuration: 0.25, animations: { () -> Void in
                                cell?.alpha = 1
                            })
                        } else {
                            // Change to invisible after animation
                            cell?.isHidden = true
                        }
                    }
                })
            }
            
        case UIGestureRecognizerState.changed: // When we move long press
            // The event occurs all the time by moving your finger !!
            
            // First there is a snapshot
            if My.cellSnapshot != nil {
                
                // Store the coordinates of the snapshot
                var center = My.cellSnapshot!.center
                
                // Move the y coordinate of the snapshot to the y coordinate of the finger movement. x coordinate does not move
                center.y = locationInView.y
                My.cellSnapshot!.center = center
                //                print("index1: \(indexPath!)")
                //                print("index2: \(Path.initialIndexPath! as IndexPath)")
                if ((indexPath != nil) && (indexPath != Path.initialIndexPath! as IndexPath)) {
                    //???? What's this, probably because array data isn't persistent data in this case doesn't seem to make sense
                    itemsArray.insert(itemsArray.remove(at: Path.initialIndexPath!.row), at: indexPath!.row)
                    
                    // Change the cell of the table view. It is easier to understand that you change it every time you move.
                    // UIGestureRecognizerState.changed event is based on indexPath of table view
                    // i.e. when the finger's position is at the position that changes the indexPath, it immediately reverses the cell position in the actual table view
                    // As soon as the finger moves up from cell 7 to cell 6, the positions of cells 6 and 7 are reversed.
                    ibTableView.moveRow(at: Path.initialIndexPath! as IndexPath, to: indexPath!)
                    // print("\(Path.initialIndexPath!.row) : \(indexPath!.row)")
                    
                    // The moment the event ends because the value of indexPath may change when the long press event starts and ends.
                    // Change the path.initialIndexPath value to the indexpath value of the table view that we changed above.
                    // Since the location of the cell has already been changed by the above event, it is necessary to change Path.initialIndexPath to work properly.
                    Path.initialIndexPath = indexPath as NSIndexPath?
                }
            }
        default: // When the long press event ends, when the finger is lifted off the screen
            if Path.initialIndexPath != nil {
                let cell = ibTableView.cellForRow(at: Path.initialIndexPath! as IndexPath) as UITableViewCell?
                if My.cellIsAnimating {
                    My.cellNeedToShow = true
                } else {
                    cell?.isHidden = false
                    cell?.alpha = 0.0
                }
                
                UIView.animate(withDuration: 0.25, animations: { () -> Void in
                    // Reset Snapshot Settings
                    My.cellSnapshot!.center = (cell?.center)!
                    My.cellSnapshot!.transform = CGAffineTransform.identity
                    My.cellSnapshot!.alpha = 0.0
                    
                    // Change alpha value of cell back to 1
                    cell?.alpha = 1.0
                    
                }, completion: { (finished) -> Void in
                    if finished {
                        // Remove snapshot
                        Path.initialIndexPath = nil
                        My.cellSnapshot!.removeFromSuperview()
                        My.cellSnapshot = nil
                    }
                })
            }
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
    
    // MARK: - Table view data source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = ibTableView.dequeueReusableCell(withIdentifier: "PreviewAndEditTableViewCell", for: indexPath as IndexPath) as! PreviewAndEditTableViewCell

        cell.longTapHandle = { gestureRecognizer in
            self.longPressGestureRecognized(gestureRecognizer: gestureRecognizer)
        }
        cell.ibLabel.text = "\(indexPath.row) \(itemsArray[indexPath.row])"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        ibTableView.deselectRow(at: indexPath as IndexPath, animated: false)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
}


////Reorder hold all cell
//extension PreviewAndEditBookViewController: UITableViewDelegate, UITableViewDataSource {
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return objects.count
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        if let cell = ibTableView.dequeueReusableCell(withIdentifier: "PreviewAndEditTableViewCell", for: indexPath) as? PreviewAndEditTableViewCell {
//            cell.backgroundColor = .yellow
//            cell.textLabel?.text = objects[indexPath.row]
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
//        let movedObject = self.objects[sourceIndexPath.row]
//        objects.remove(at: sourceIndexPath.row)
//        objects.insert(movedObject, at: destinationIndexPath.row)
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
