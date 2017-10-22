//
//  MenuViewController.swift
//  fudar-user
//
//  Created by Shaun Bevan on 10/22/17.
//  Copyright © 2017 silverlogic. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SwipeCellKit

final class MenuViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    
    
    // MARK; - Attributes
    var menus = [Menu]()
    var checkoutItems = [Menu]()
    
    @IBAction func checkoutButtonTapped(_ sender: Any) {
        for menu in menus {
            if menu.count > 0 {
                checkoutItems.append(menu)
            }
        }
        print(checkoutItems)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        tableView.delegate = self
        tableView.dataSource = self
        self.navigationController?.navigationBar.isHidden = false
    }
}


// MARK: - UITableViewDataSource
extension MenuViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menus.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MenuTableViewCell") as? MenuTableViewCell else {
            return UITableViewCell()
        }
        let menu = menus[indexPath.row]
        cell.configureCell(menu)
        cell.delegate = self
        return cell
    }
}


// MARK: - UITableViewDelegate
extension MenuViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        menus[indexPath.row].count = menus[indexPath.row].count + 1
        self.tableView.reloadData()
    }
}

extension MenuViewController: SwipeTableViewCellDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        if menus[indexPath.row].count == 0 {
            return nil
        }
        let deleteAction = SwipeAction(style: .destructive, title: "") { [weak self] action, indexPath in
            guard let strongSelf = self else { return }
            strongSelf.menus[indexPath.row].count = strongSelf.menus[indexPath.row].count - 1 ;
            strongSelf.tableView.reloadData()
        }
        deleteAction.image = UIImage(named: "delete")
        return [deleteAction]
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeTableOptions {
        var options = SwipeTableOptions()
        options.expansionStyle = .fill
        options.transitionStyle = .border
        return options
    }
}


// MARK: - Private Instance Methods
extension MenuViewController {
    func loadData() {
        OrderManager.shared.fetchItems() { [weak self] responseObject, error in
            guard let strongSelf = self else { return }
            if let json = responseObject {
                for (_, subJson):(String, JSON) in json["elements"] {
                    let mid = subJson["id"].stringValue
                    let name = subJson["name"].stringValue
                    let price = subJson["price"].intValue
                    let description = subJson["alternateName"].stringValue
                    let menu = Menu(menuId: mid, menuTitle: name, menuPrice: price / 100, menuDescription: description, menuImage: UIImage(named:subJson["name"].stringValue)!)
                    strongSelf.menus.append(menu)
                }
                strongSelf.tableView.reloadData()
            }
        }
    }
}
