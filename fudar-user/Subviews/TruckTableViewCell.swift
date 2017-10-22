//
//  TruckTableViewCell.swift
//  fudar-user
//
//  Created by Michael Sevy on 10/21/17.
//  Copyright © 2017 silverlogic. All rights reserved.
//

import UIKit

final class TruckTableVielCell: UITableViewCell {

    // MARK: - IBOutlets
    @IBOutlet weak var truckImageView: BaseImageView!
    @IBOutlet weak var foodTypeLabel: UILabel!
    @IBOutlet weak var truckNameLabel: UILabel!
    @IBOutlet weak var reviewLabel: UILabel!
    @IBOutlet weak var truckImageViewOne: UIImageView!
    @IBOutlet weak var truckImageViewFive: UIImageView!
    @IBOutlet weak var truckImageViewFour: UIImageView!
    @IBOutlet weak var truckImageViewThree: UIImageView!
    @IBOutlet weak var truckImageViewTwo: UIImageView!

    // Private Instance Attributes
    fileprivate static var cellHeight: CGFloat = 91.0

    var mapTapped: (()-> Void)?
  
    @IBAction func onMapTapped(_ sender: UIButton) {
        guard let closure = mapTapped  else { return }
            print("closure tapped")
            closure()
        }
}


extension TruckTableVielCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }

    func configure(trucks: [String : Any]) {
        truckNameLabel.text = trucks["name"] as? String
        foodTypeLabel.text = trucks["type"] as? String
        reviewLabel.text = "\(trucks["reviews"]!) reviews"
        let image = trucks["image"] as? String
        truckImageView.image = UIImage(named: image!)?.withRenderingMode(.alwaysOriginal)
        truckImageView.layer.cornerRadius = 37.5
        truckImageView.layer.masksToBounds = true
        
        switch trucks["rating"] as! Int {
        case 1:
            truckImageViewOne.image = UIImage(named: "activeTruck")
            truckImageViewTwo.image = UIImage(named: "emptyTruck")
            truckImageViewThree.image = UIImage(named: "emptyTruck")
            truckImageViewFour.image = UIImage(named: "emptyTruck")
            truckImageViewFive.image = UIImage(named: "emptyTruck")
        case 2:
            truckImageViewOne.image = UIImage(named: "activeTruck")
            truckImageViewTwo.image = UIImage(named: "activeTruck")
            truckImageViewThree.image = UIImage(named: "emptyTruck")
            truckImageViewFour.image = UIImage(named: "emptyTruck")
            truckImageViewFive.image = UIImage(named: "emptyTruck")
        case 3:
            truckImageViewOne.image = UIImage(named: "activeTruck")
            truckImageViewTwo.image = UIImage(named: "activeTruck")
            truckImageViewThree.image = UIImage(named: "activeTruck")
            truckImageViewFour.image = UIImage(named: "emptyTruck")
            truckImageViewFive.image = UIImage(named: "emptyTruck")
        case 4:
            truckImageViewOne.image = UIImage(named: "activeTruck")
            truckImageViewTwo.image = UIImage(named: "activeTruck")
            truckImageViewThree.image = UIImage(named: "activeTruck")
            truckImageViewFour.image = UIImage(named: "activeTruck")
            truckImageViewFive.image = UIImage(named: "emptyTruck")
        case 5:
            truckImageViewOne.image = UIImage(named: "activeTruck")
            truckImageViewTwo.image = UIImage(named: "activeTruck")
            truckImageViewThree.image = UIImage(named: "activeTruck")
            truckImageViewFour.image = UIImage(named: "activeTruck")
            truckImageViewFive.image = UIImage(named: "activeTruck")
        default:
            break
        }
    }

    open class func height() -> CGFloat {
        return cellHeight
    }
}

// MARK: - ImageAccess
extension TruckTableVielCell: ImageAccess {
    func setImageWithUrl(_ url: URL) {
        truckImageView.setImageWithUrl(url)
    }

    func cancelImageDownload() {
        truckImageView.cancelImageDownload()
    }
}
