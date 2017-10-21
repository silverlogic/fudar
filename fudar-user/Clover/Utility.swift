//
//  Utility.swift
//  CloverConnector_Example
//
//  Created by Rajan Veeramani on 10/9/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation
import CloverConnector_Hackathon_2017

protocol OAuthDelegate{
    func initSDKWithOAuth(accessTokenReceived: String)
}

protocol SignatureViewDelegate {
    func isSignaturePresent(valid: Bool)
}

protocol StartTransactionDelegate {
    func proceedAfterReaderReady(merchantInfo: MerchantInfo)
    func readerDisconnected()
}

struct PARAMETERS {
    static var accessToken = "1669926f-c367-6f58-5027-31512f1661eb"
    static var apiKey = "mexbZJX5D3fa5kje1dZmrJVKOyAF9w8F"
    static var secret = "6hak16ff8e76r4565ab988f5d986a911e36f0f2347e3fv3eb719478c98e89io0"
}

struct FLAGS {
    static var isCloverGoMode = false
    static var isOAuthMode = false
    static var is350ReaderInitialized = false
    static var is450ReaderInitialized = false
    static var isKeyedTransaction = false
}

struct SHARED {
    static let workingQueue = DispatchQueue.init(label: "my_queue")
    static var delegateStartTransaction:StartTransactionDelegate? = nil
}

struct API {
    static let baseURL = "https://api.clover.com/v3/merchants/3S2JC4YEV2XTE/"
    static let headers = ["authorization": "Bearer 1669926f-c367-6f58-5027-31512f1661eb", "cache-control": "no-cache"]

}
