//
//  CloverGoDeviceConfiguration.swift
//  CloverGoConnector
//
//  Created by Veeramani, Rajan (Non-Employee) on 4/17/17.
//  Copyright © 2017 Veeramani, Rajan (Non-Employee). All rights reserved.
//

import Foundation

@objc
public class CloverGoDeviceConfiguration : NSObject, CloverDeviceConfiguration {
    
    public var apiKey : String
    public var secret : String
    public var accessToken : String
    public var env : CLVGoEnvironment
    public var allowAutoConnect:Bool = false
    public var allowDuplicateTransaction:Bool = false
    public var deviceType : CLVModels.Device.GoDeviceType = .RP450
    
    init(builder:Builder) {
        self.apiKey = builder.apiKey
        self.secret = builder.secret
        self.accessToken = builder.accessToken
        self.env = builder.env
        self.allowAutoConnect = builder.allowAutoConnect
        self.allowDuplicateTransaction = builder.allowDuplicateTransaction
        self.deviceType = builder.deviceType
    }
    
    public class Builder {
        
        var apiKey:String
        var secret : String
        var env : CLVGoEnvironment
        var accessToken : String = ""
        var allowAutoConnect : Bool = false
        var allowDuplicateTransaction:Bool = false
        var deviceType : CLVModels.Device.GoDeviceType = .RP450
        
        public init(apiKey:String, secret:String, env:CLVGoEnvironment) {
            self.apiKey = apiKey
            self.secret = secret
            self.env = env
        }
        
        public func accessToken(accessToken:String) -> Builder {
            self.accessToken = accessToken
            return self
        }
        
        public func allowAutoConnect(allowAutoConnect:Bool) -> Builder {
            self.allowAutoConnect = allowAutoConnect
            return self
        }
        
        public func allowDuplicateTransaction(allowDuplicateTransaction:Bool) -> Builder {
            self.allowDuplicateTransaction = allowDuplicateTransaction
            return self
        }
        
        public func deviceType(deviceType:CLVModels.Device.GoDeviceType) -> Builder {
            self.deviceType = deviceType
            return self
        }
        
        public func build() -> CloverGoDeviceConfiguration {
            return CloverGoDeviceConfiguration(builder: self)
        }
        
    }
    
    public func getCloverDeviceTypeName() -> String {
        return "CloverGo Device"
    }
    
    public func getName() -> String {
        return ""
    }
    
    public func getMessagePackageName() -> String {
        return ""
    }
    
    public func getTransport() -> CloverTransport? {
        return nil
    }
    
    public var remoteApplicationID:String = ""
    
    public var remoteSourceSDK:String {
        get {
            return ""
        }
    }
    
    public func getMaxMessageCharacters() -> Int {
        return 0
    }
    
}

public enum CLVGoEnvironment : Int {
    case demo
    case live
    case test
    case sandbox
    case qa
}
