//
//  PurchaseManager.swift
//  fudar-user
//
//  Created by Shaun Bevan on 10/21/17.
//  Copyright © 2017 silverlogic. All rights reserved.
//

import Foundation
import CloverConnector_Hackathon_2017
import Alamofire

final class PurchaseManager {
    
    // MARK: - Shared Instance
    static let shared = PurchaseManager()
    
    
    // MARK: - Attributes
    fileprivate var store: POSStore?
    var itemsToDi = NSMutableDictionary()
    var currentDisplayOrder: DisplayOrder = DisplayOrder()
    
    // MARK: - Initializers
    private init () {
        store = (UIApplication.shared.delegate as? AppDelegate)?.store
        store?.addCurrentOrderListener(self)
        store?.addStoreListener(self)
    }
}


// MARK; - Public Instance Methods
extension PurchaseManager {
    public func processOrderForStore(isKeyedTransaction: Bool = false, completion: (_ success: Bool) -> Void) {
        if let store = store {
            store.currentOrder?.addLineItem(POSLineItem(item: store.availableItems[1]))
        }
        guard let currentOrder = store?.currentOrder else { return }
        if let cloverConnector = (UIApplication.shared.delegate as? AppDelegate)?.cloverConnector {
            currentOrder.pendingPaymentId = String(arc4random())
            let ar = AuthRequest(amount: currentOrder.getTotal(), externalId: currentOrder.pendingPaymentId!)
            // below are all optional
            ar.allowOfflinePayment = store?.transactionSettings.allowOfflinePayment
            ar.approveOfflinePaymentWithoutPrompt = store?.transactionSettings.approveOfflinePaymentWithoutPrompt
            ar.autoAcceptSignature = store?.transactionSettings.autoAcceptSignature
            ar.autoAcceptPaymentConfirmations = store?.transactionSettings.autoAcceptPaymentConfirmations
            ar.cardEntryMethods = store?.transactionSettings.cardEntryMethods ?? cloverConnector.CARD_ENTRY_METHODS_DEFAULT
            ar.disableCashback = store?.transactionSettings.disableCashBack
            ar.disableDuplicateChecking = store?.transactionSettings.disableDuplicateCheck
            if let enablePrinting = store?.transactionSettings.cloverShouldHandleReceipts {
                ar.disablePrinting = !enablePrinting
            }
            ar.disableReceiptSelection = store?.transactionSettings.disableReceiptSelection
            ar.disableRestartTransactionOnFail = store?.transactionSettings.disableRestartTransactionOnFailure
                
            ar.forceOfflinePayment = store?.transactionSettings.forceOfflinePayment
            ar.cardNotPresent = store?.cardNotPresent
            
            ar.tippableAmount = currentOrder.getTippableAmount()
            if isKeyedTransaction {
                ar.keyedCardData = CLVModels.Payments.KeyedCardData(cardNumber: "36185973325928", expirationDate: "0418", cvv: "123")
            }
            (UIApplication.shared.delegate as? AppDelegate)?.cloverConnector?.auth(ar)
            completion(true)
        } else {
            completion(false)
        }
    }
    
    private func auth(_ authRequest: AuthRequest) {
    }
}


// MARK: Network Calls
extension PurchaseManager {
    func postOrder(_ order: POSOrder, success: @escaping () -> Void, failure: @escaping () -> Void) {
        let url = "https://api.clover.com/v3/merchants/3S2JC4YEV2XTE/orders"
        let params = ["": ""]
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: nil)
            .responseJSON { response in
                if let userResponse = response.result.value {
                    print("**response: \(userResponse)")
                }
                success()
                if response.result.isFailure {
                    print(response.result.error as Any)
                }
        }
    }
}


// MARK: - POSStoreListener
extension PurchaseManager: POSStoreListener {
    func newOrderCreated(_ order:POSOrder) {
        (UIApplication.shared.delegate as? AppDelegate)?.cloverConnector?.removeDisplayOrder(currentDisplayOrder)
        currentDisplayOrder = DisplayOrder()
        currentDisplayOrder.id = String(arc4random())
        itemsToDi.removeAllObjects() // cleanup
    }
    
    func preAuthAdded(_ payment: POSPayment) {
        // not needed in register
    }
    
    func preAuthRemoved(_ payment: POSPayment) {
        // not needed in register
    }
    
    func vaultCardAdded(_ card: POSCard) {
        // not needed in register
    }
    
    func manualRefundAdded(_ credit: POSNakedRefund) {
        // not needed in register
    }
}


// MARK: -  POSOrderListener
extension PurchaseManager: POSOrderListener {
    func itemAdded(_ item:POSLineItem) {
        guard let itemName = item.item.name,
            let formattedItemPrice = CurrencyUtils.IntToFormat(item.item.price) else { return }
        let displayLineItem = DisplayLineItem(id: String(arc4random()), name:itemName, price: formattedItemPrice, quantity: String(item.quantity))
        currentDisplayOrder.lineItems.append(displayLineItem)
        itemsToDi.setObject(displayLineItem, forKey: item.item.id as NSCopying)
        (UIApplication.shared.delegate as? AppDelegate)?.cloverConnector?.showDisplayOrder(currentDisplayOrder)
    }
    
    func itemRemoved(_ item:POSLineItem) {
        (UIApplication.shared.delegate as? AppDelegate)?.cloverConnector?.showDisplayOrder(currentDisplayOrder)
    }
    
    func itemModified(_ item:POSLineItem) {
        if let displayLineItem = itemsToDi.object(forKey: item.item.id) as? DisplayLineItem {
            displayLineItem.quantity = String(item.quantity)
            displayLineItem.name = item.item.name
            displayLineItem.price = CurrencyUtils.IntToFormat(item.item.price)
        }
        
        (UIApplication.shared.delegate as? AppDelegate)?.cloverConnector?.showDisplayOrder(currentDisplayOrder)
        
    }
    
    func discountAdded(_ item:POSDiscount) {
    }
    
    func paymentAdded(_ item:POSPayment) {
    }
    
    func refundAdded(_ refund: POSRefund) {
    }
    
    func paymentChanged(_ item:POSPayment) {
    }
}
