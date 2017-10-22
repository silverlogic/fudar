//
//  ReaderManager.swift
//  fudar-user
//
//  Created by Shaun Bevan on 10/21/17.
//  Copyright © 2017 silverlogic. All rights reserved.
//

import Foundation
import CloverConnector_Hackathon_2017

final class ReaderManager {
    
    // MARK: - Shared Instance
    static let shared = ReaderManager()
    
    
    // MARK: - Attributes
    var cloverConnector450Reader: ICloverConnector?
    var cloverConnectorListener: CloverConnectorListener?

    
    // MARK: - Initializers
    private init () {}
}


// MARK: - Public Instance Methods
extension ReaderManager {
    
    /// Initialize the Clover 450x Reader
    /// Returns false if it is already initialized
    public func initializeClover450Reader(completion: (_ success: Bool) -> Void) {
        if !FLAGS.is450ReaderInitialized {
            let config450Reader : CloverGoDeviceConfiguration = CloverGoDeviceConfiguration.Builder(apiKey: PARAMETERS.apiKey, secret: PARAMETERS.secret, env: .live).accessToken(accessToken: PARAMETERS.accessToken).allowAutoConnect(allowAutoConnect: true).allowDuplicateTransaction(allowDuplicateTransaction: false).build()
            cloverConnector450Reader = CloverGoConnector(config: config450Reader)
            cloverConnectorListener = CloverGoConnectorListener(cloverConnector: cloverConnector450Reader!)
            (cloverConnector450Reader as? CloverGoConnector)?.addCloverGoConnectorListener(cloverConnectorListener: (cloverConnectorListener as? ICloverGoConnectorListener)!)
            (UIApplication.shared.delegate as! AppDelegate).cloverConnectorListener = cloverConnectorListener
            (UIApplication.shared.delegate as! AppDelegate).cloverConnector = cloverConnector450Reader
            cloverConnector450Reader?.initializeConnection()
            completion(true)
        } else {
            completion(false)
        }
    }
    
    public func initializeForRemoteReader() {
        let config : CloverGoDeviceConfiguration = CloverGoDeviceConfiguration.Builder(apiKey: PARAMETERS.apiKey, secret: PARAMETERS.secret, env: .live).accessToken(accessToken: PARAMETERS.accessToken).allowDuplicateTransaction(allowDuplicateTransaction: false).allowAutoConnect(allowAutoConnect: true).build()
        (UIApplication.shared.delegate as! AppDelegate).cloverConnector = CloverGoConnector(config: config)
        cloverConnectorListener = CloverGoConnectorListener(cloverConnector: (UIApplication.shared.delegate as! AppDelegate).cloverConnector!)
        ((UIApplication.shared.delegate as! AppDelegate).cloverConnector as? CloverGoConnector)?.addCloverGoConnectorListener(cloverConnectorListener: (cloverConnectorListener as? ICloverGoConnectorListener)!)
    }
}
