//
//  SecondViewController.swift
//  fudar-user
//
//  Created by Shaun Bevan on 10/21/17.
//  Copyright © 2017 silverlogic. All rights reserved.
//

import UIKit
import FirebaseAuth

class SecondViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        //FirebaseManager.shared.createItem(userId: Auth.auth().currentUser?.uid, name: "Fish Taco", price: 3.99)
        FirebaseManager.shared.addOrder(userId: (Auth.auth().currentUser?.uid)!, item: "Pizza", price: 8.99, success: { (success) in
            print("success")
        }) { (error) in
            print(error)
        }
//        OrderManager.shared.getItems()
//        OrderManager.shared.createEmptyOrder()
//        OrderManager.shared.addLineItemToOrder("QVB000P613WCY", itemId: "2HDH3QRPEN29W")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

