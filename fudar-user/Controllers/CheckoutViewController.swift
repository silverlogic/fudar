//
//  CheckoutViewController.swift
//  fudar-user
//
//  Created by Shaun Bevan on 10/22/17.
//  Copyright © 2017 silverlogic. All rights reserved.
//

import UIKit
import SCLAlertView

class CheckoutViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var truckNameLabel: UILabel!
    @IBOutlet weak var subTotalLabel: UILabel!
    @IBOutlet weak var taxLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    
    
    // MARK: - Attributes
    var menus: [Menu]?
    
    
    // MARK: - IBActions
    @IBAction func confirmOrderButtonTapped(_ sender: Any) {
        /// Send to Firebase
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        truckNameLabel.text = "Bluth's Frozen Banana Stand"
        calculateTotal()
    }
}


// MARK: - UITableViewDataSource
extension CheckoutViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let menus = menus else { return 0 }
        return menus.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MenuTableViewCell") as? MenuTableViewCell,
              let menus = menus else { return UITableViewCell() }
        let menu = menus[indexPath.row]
        cell.configureCellForCheckout(menu.name!, count: menu.count, price: (menu.price * menu.count))
        return cell
    }
}


// MARK: - UITableViewDelegate
extension CheckoutViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75.0
    }
}


// MARK: - Private Instance Methods
extension CheckoutViewController {
    func calculateTotal() {
        guard let menus = menus else { return }
        var subTotal = 0
        for menu in menus {
            subTotal = subTotal + menu.price
        }
        let tax = 0.06
        let taxTotal = Double(subTotal) * tax
        let formattedSubtotal = String(format: "%.2f", Double(subTotal))
        let formattedTaxTotal = String(format: "%.2f", Double(taxTotal))
        let formattedTotal = String(format: "%.2f", (Double(subTotal) + taxTotal))
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.subTotalLabel.text = "Sub Total: $\(formattedSubtotal)"
            strongSelf.taxLabel.text = "Tax: $\(formattedTaxTotal)"
            strongSelf.totalLabel.text = "TOTAL:  $\(formattedTotal)"
        }
    }
}
