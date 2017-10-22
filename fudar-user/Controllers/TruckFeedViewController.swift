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
        ["name" : "Bluth's Frozen Banana Stand", "type" : "Dessert", "image" : "bluth_logo", "rating": 2, "reviews" : 42],
        ["name" : "Naan Stop", "type" : "Indian", "image" : "Naan_logo", "rating": 4, "reviews" : 25],
        ["name" : "Truck Norris", "type" : "Fried Chicken", "image" : "nunchicken", "rating": 4, "reviews" : 17],
        ["name" : "I Dream of Weenie", "type" : "Hot Dogs and so forth", "image" : "weenie_logo", "rating": 4, "reviews" : 17],
        ["name" : "Easy Slider", "type" : "Burgers", "image" : "easy_logo", "rating": 4, "reviews" : 13],
        ["name" : "Starchy & Husk", "type" : "Gourmet Corn on the Cob", "image" : "corny", "rating": 3, "reviews" : 25],
        ["name" : "Pasta Dutchie", "type" : "Northen Italian", "image" : "spaghetti", "rating": 5, "reviews" : 35],
        ["name" : "General Cheezious", "type" : "Grilled Cheese", "image" : "cheese", "rating": 4, "reviews" : 43],
        ["name" : "Slaw & Order", "type" : "BBQ", "image" : "BBQ", "rating": 5, "reviews" : 73]
    ]

    // MARK: - ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
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
