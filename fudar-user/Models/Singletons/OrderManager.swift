//
//  OrderManager.swift
//  fudar-user
//
//  Created by Shaun Bevan on 10/21/17.
//  Copyright © 2017 silverlogic. All rights reserved.
//

import Foundation
import CloverConnector_Hackathon_2017
import Alamofire
import SwiftyJSON

final class OrderManager {
    
    // MARK: - Shared Instance
    static let shared = OrderManager()
    
    
    // MARK: - Attributes
//    fileprivate var store: POSStore?
//    var itemsToDi = NSMutableDictionary()
//    var currentDisplayOrder: DisplayOrder = DisplayOrder()
    
    // MARK: - Initializers
    private init () {
//        store = (UIApplication.shared.delegate as? AppDelegate)?.store
//        store?.addCurrentOrderListener(self)
//        store?.addStoreListener(self)
    }
}


// MARK: - Network Calls
extension OrderManager {
    
    func fetchItems(_ completionHandler: @escaping (JSON?, Error?) -> ()){
        getItems(completionHandler)
    }
    
    func getItems(_ completionHandler: @escaping (JSON?, Error?) -> ()){
        let endpoint = "tags/KW3TE8QSB4FYE/items"
        let url = "\(API.baseURL)\(endpoint)"
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: API.headers)
            .responseJSON { response in
                if let userResponse = response.result.value {
                    print("** GET ITEMS RESPONSE: \(userResponse)")
                    completionHandler(JSON(userResponse), nil)
                }
                if response.result.isFailure {
                    print(response.result.error as Any)
                }
        }
    }
    
    func createEmptyOrder() {
        let endpoint = "orders"
        let url = "\(API.baseURL)\(endpoint)"
        Alamofire.request(url, method: .post, parameters: nil, encoding: JSONEncoding.default, headers: API.headers).responseJSON { response in
            if let response = response.result.value {
                print("**CREATE EMPTY ORDER RESPONSE: \(response)")
            }
            if response.result.isFailure {
                print(response.result.error as Any)
            }
        }
    }
    
    func addLineItemToOrder(_ orderId: String, itemId: String) {
        let endpoint = "orders/\(orderId)/line_items"
        let url = "\(API.baseURL)\(endpoint)"
        let parameters: Parameters = [
            "item": ["id": itemId]
        ]
        Alamofire.request(url, method: .post, parameters: parameters, encoding: JSONEncoding(), headers: API.headers).responseJSON { response in
            if let response = response.result.value {
                print("**ADD ITEM: \(response)")
            }
            if response.result.isFailure {
                print(response.result.error as Any)
            }
        }
    }
}
