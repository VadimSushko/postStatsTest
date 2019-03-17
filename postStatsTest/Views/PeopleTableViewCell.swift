//
//  PeopleTableViewCell.swift
//  postStatsTest
//
//  Created by Vadym Sushko on 3/14/19.
//  Copyright © 2019 Vadym Sushko. All rights reserved.
//

import UIKit

class PeopleTableViewCell: UITableViewCell {
    
    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var moreLabel: UILabel!
    @IBOutlet weak var moreArrow: UIButton!
    @IBOutlet weak var cellLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var backView: UIView! {
        didSet {
            backView.layer.cornerRadius = 10
        }
    }
}
