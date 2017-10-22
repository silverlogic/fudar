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
        FirebaseManager.shared.addOrder(item: "Pizza", price: 8.99, success: { [weak self] (success) in
            print("success")
            self?.fetchOrderId()
        }) { (error) in
            print(error)
        }

//        OrderManager.shared.getItems()
//        OrderManager.shared.createEmptyOrder()
//        OrderManager.shared.addLineItemToOrder("QVB000P613WCY", itemId: "2HDH3QRPEN29W")
    }


    func fetchOrderId() {
        //FirebaseManager.shared.fetchOrderId(success: { (posItems) in
//            OrderManager.shared.getItems(<#(JSON?, Error?) -> ()#>)
//            print(postorder)
//        }) { (error) in
//            print(error)
//        }
        //}
    }

}


