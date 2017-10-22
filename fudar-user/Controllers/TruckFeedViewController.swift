//
//  TruckFeedViewController.swift
//  fudar-user
//
//  Created by Michael Sevy on 10/21/17.
//  Copyright © 2017 silverlogic. All rights reserved.
//

import UIKit

final class TruckFeedViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!


    // MARK: - Private Instance Variables
    //var trucks: [Truck] = []
    var trucks: [[String: Any]] = [
        ["name" : "Bluth's Frozen Banana Stand", "type" : "Dessert", "image" : "Bluths Orig", "rating": 2, "reviews" : 42],
        ["name" : "Naan Stop", "type" : "Indian", "image" : "NaanStop", "rating": 4, "reviews" : 25],
        ["name" : "Truck Norris", "type" : "Fried Chicken", "image" : "TruckNorrisChicken", "rating": 4, "reviews" : 17],
        ["name" : "I Dream of Weenie", "type" : "Hot Dogs and so forth", "image" : "IDreamofWeenie", "rating": 4, "reviews" : 17],
        ["name" : "Slaw & Order", "type" : "BBQ", "image" : "Slaw&Order", "rating": 5, "reviews" : 73],
        ["name" : "Easy Slider", "type" : "Burgers", "image" : "EASY-SLIDERS", "rating": 4, "reviews" : 13],
//        ["name" : "Starchy & Husk", "type" : "Gourmet Corn on the Cob", "Fries" : "corny", "rating": 3, "reviews" : 25],
        ["name" : "Pasta Dutchie", "type" : "Northen Italian", "image" : "PASTA DOUCHIE", "rating": 5, "reviews" : 35],
        ["name" : "General Cheezious", "type" : "Grilled Cheese", "image" : "GERNERAL CHEESIOUS", "rating": 4, "reviews" : 43]
    ]

    // MARK: - ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        self.navigationController?.navigationBar.isHidden = true
        loginUser()
    }
    
    func loginUser() {
        AuthenticationManager.shared.login(email: "md@tsl.io", password: "123456", success: { [weak self] (user) in
            }, failure: { [weak self] (error: Error) in
                guard let strongSelf = self else { return }
                strongSelf.showInfoAlert(title:NSLocalizedString("Alert.Error", comment: "error"), subTitle: error.localizedDescription)
        })
    }
}


// MARK: - TableView DataSource
extension TruckFeedViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trucks.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: TruckTableVielCell = tableView.dequeueReusableCell(withIdentifier: "TruckCell") as! TruckTableVielCell
        return cell
    }
}


// MARK: - TableView Delegate
extension TruckFeedViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            performSegue(withIdentifier: "goToMenuSegue", sender: self)
        }
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? TruckTableVielCell else { return }
        let truckForCell = trucks[indexPath.row]
        cell.configure(trucks: truckForCell)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return TruckTableVielCell.height()
    }
}

extension TruckFeedViewController {
    func setup() {
        tableView.delegate = self
        tableView.dataSource = self
        //tableView.reloadData()
    }
}
