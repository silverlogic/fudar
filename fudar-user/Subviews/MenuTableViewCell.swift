//
//  MenuTableViewCell.swift
//  fudar-user
//
//  Created by Shaun Bevan on 10/22/17.
//  Copyright © 2017 silverlogic. All rights reserved.
//

import UIKit
import SwipeCellKit

class MenuTableViewCell: SwipeTableViewCell {
    
    // MARK: - IBOutlets
    @IBOutlet weak var menuItemImageView: UIImageView!
    @IBOutlet weak var menuItemTitleLabel: UILabel!
    @IBOutlet weak var menuItemDescriptionLabel: UILabel!
    @IBOutlet weak var menuItemPriceLabel: UILabel!
    @IBOutlet weak var menuPurchaseCountLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}


// MARK: - Private Instance Methods
extension MenuTableViewCell {
    func configureCell(_ menuItem: Menu) {
        if let menuImage = menuItem.image {
            menuItemImageView.image = menuImage
        }
        menuItemTitleLabel.text = menuItem.name
        menuItemDescriptionLabel.text = menuItem.descriptionText
        menuItemPriceLabel.text = "$\(menuItem.price)"
        menuPurchaseCountLabel.text = "\(menuItem.count)"
    }
}
