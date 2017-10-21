//
//  CloverGoExtensions.swift
//  Pods
//
//  Created by Veeramani, Rajan (Non-Employee) on 6/21/17.
//
//

import Foundation

extension CLVModels.Payments {
    
    public class KeyedCardData : NSObject {
        
        public let cardNumber : String
        public let expirationDate : String
        public let cvv : String
        
        public var address : String?
        public var zipCode : String?
        
        public let cardPresent : Bool = false
        
        public init(cardNumber:String, expirationDate:String, cvv:String) {
            self.cardNumber = cardNumber
            self.expirationDate = expirationDate
            self.cvv = cvv
        }
    }
    
    @objc public enum GoTransactionEvent : Int {
        case CARD_SWIPED
        case CARD_TAPPED
        case SWIPE_FAILED
        case EMV_CARD_SWIPED_ERROR
        case EMV_DIP_FAILED_PROCEED_WITH_SWIPE
        case EMV_CARD_DIP_FAILED
        case EMV_CARD_INSERTED
        case EMV_CARD_REMOVED
        case CONTACTLESS_FAILED_TRY_AGAIN
        case SWIPE_DIP_OR_TAP_CARD
        case REMOVE_CARD
        
        public func getDescription() -> String {
            switch self {
            case .CARD_SWIPED:
                return "Card Swiped"
            case .CARD_TAPPED:
                return "Card Tapped"
            case .SWIPE_FAILED:
                return "Swipe Failed, Reswipe again"
            case .EMV_CARD_SWIPED_ERROR:
                return "EMV Card Swiped, Instead Dip the EMV Card"
            case .EMV_DIP_FAILED_PROCEED_WITH_SWIPE:
                return "EMV DIP failed, Proceed with Swipe"
            case .EMV_CARD_DIP_FAILED:
                return "EMV Dip Failed, Reinsert the Card"
            case .EMV_CARD_INSERTED:
                return "EMV Card Inserted"
            case .EMV_CARD_REMOVED:
                return "EMV Card Removed"
            case .CONTACTLESS_FAILED_TRY_AGAIN:
                return "Contactless Failed Try Again"
            case .SWIPE_DIP_OR_TAP_CARD:
                return "Transaction Started, Swipe or Dip or Tap Card"
            case .REMOVE_CARD:
                return "Please Remove Card"
            }
        }
    }
    
    public class CardApplicationIdentifier : NSObject {
        public let applicationLabel:String
        public let applicationIdentifier:String
        
        public init(applicationLabel:String, applicationIdentifier:String) {
            self.applicationLabel = applicationLabel
            self.applicationIdentifier = applicationIdentifier
        }
    }
    
}

extension CLVModels.Device {
    
    public class GoDeviceInfo : NSObject {
        public let type:GoDeviceType
        public var name : String?
        public var batteryPercentage:Int = -1
        public var serialNumber:String?
        public var connected:Bool = false
        
        public var bluetoothId:String?
        
        public init(type:GoDeviceType) {
            self.type = type
        }
    }
    
    @objc public enum GoDeviceType : Int {
        case RP350
        case RP450
    }
}
