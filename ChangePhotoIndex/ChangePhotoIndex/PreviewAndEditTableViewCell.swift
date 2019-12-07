//
//  PreviewAndEditTableViewCell.swift
//  ChangePhotoIndex
//
//  Created by Trinh Thai on 12/5/19.
//  Copyright © 2019 Trinh Thai. All rights reserved.
//

import UIKit

class PreviewAndEditTableViewCell: UITableViewCell {
    @IBOutlet weak var ibButton: UIButton!
    @IBOutlet weak var ibLabel: UILabel!
    var longTapHandle: ((UIGestureRecognizer) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(longTap))
        ibButton.addGestureRecognizer(longGesture)
    }
    
    @objc func longTap(_ sender : UIGestureRecognizer){
        longTapHandle?(sender)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
