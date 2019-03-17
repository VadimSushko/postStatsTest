//
//  TextTableViewCell.swift
//  postStatsTest
//
//  Created by Vadym Sushko on 3/14/19.
//  Copyright © 2019 Vadym Sushko. All rights reserved.
//

import UIKit

class TextTableViewCell: UITableViewCell {

    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var cellLabel: UILabel!
    @IBOutlet weak var backView: UIView! {
        didSet {
            backView.layer.cornerRadius = 5
        }
    }
}
