//
//  AppDelegate.swift
//  fudar-user
//
//  Created by Shaun Bevan on 10/21/17.
//  Copyright © 2017 silverlogic. All rights reserved.
//

import UIKit
import CloverConnector_Hackathon_2017
import Intents
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, PairingDeviceConfiguration {
    
    var window: UIWindow?

    public var cloverConnector: ICloverConnector?
    public var cloverConnectorListener: CloverConnectorListener?
    fileprivate var token:String?
    public var store:POSStore?
    
    fileprivate let PAIRING_AUTH_TOKEN_KEY:String = "PAIRING_AUTH_TOKEN"
    
    var delegate:OAuthDelegate? = nil


    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        //FIRDatabase.database().persistenceEnabled = true
        return true
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        UINavigationBar.appearance().barTintColor = .black
        UINavigationBar.appearance().tintColor = .white
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        store = POSStore()
        store?.availableItems.append(POSItem(id: "1", name: "Cheeseburger", price: 579, taxRate: 0.075, taxable: true))
        store?.availableItems.append(POSItem(id: "2", name: "Hamburger", price: 529, taxRate: 0.075, taxable: true))
        store?.availableItems.append(POSItem(id: "3", name: "Bacon Cheeseburger", price: 619, taxRate: 0.075, taxable: true))
        store?.availableItems.append(POSItem(id: "4", name: "Chicken Nuggets", price: 569, taxRate: 0.075, taxable: true))
        store?.availableItems.append(POSItem(id: "5", name: "Large Fries", price: 239, taxRate: 0.075, taxable: true))
        store?.availableItems.append(POSItem(id: "6", name: "Small Fries", price: 179, taxRate: 0.075, taxable: true))
        store?.availableItems.append(POSItem(id: "7", name: "Vanilla Milkshake", price: 229, taxRate: 0.075, taxable: true))
        store?.availableItems.append(POSItem(id: "8", name: "Chocolate Milkshake", price: 229, taxRate: 0.075, taxable: true))
        store?.availableItems.append(POSItem(id: "9", name: "Strawberry Milkshake", price: 229, taxRate: 0.075, taxable: true))
        store?.availableItems.append(POSItem(id: "10", name: "$25 Gift Card", price: 2500, taxRate: 0.00, taxable: false, tippable: false))
        store?.availableItems.append(POSItem(id: "11", name: "$50 Gift Card", price: 5000, taxRate: 0.000, taxable: false, tippable: false))
        
        if let tkn = UserDefaults.standard.string( forKey: PAIRING_AUTH_TOKEN_KEY) {
            token = tkn
        }
        
        return true
    }
    
    override func attemptRecovery(fromError error: Error, optionIndex recoveryOptionIndex: Int) -> Bool {
        debugPrint((error as NSError).domain)
        return true
    }
    
    func onPairingCode(_ pairingCode: String) {
        debugPrint("Pairing Code: " + pairingCode)
        self.cloverConnectorListener?.onPairingCode(pairingCode)
    }
    func onPairingSuccess(_ authToken: String) {
        debugPrint("Pairing Auth Token: " + authToken)
        self.cloverConnectorListener?.onPairingSuccess(authToken)
        self.token = authToken
        UserDefaults.standard.set(self.token, forKey: PAIRING_AUTH_TOKEN_KEY)
        UserDefaults.standard.synchronize()
    }
    
    func clearConnect(_ url:String) {
        self.token = nil
        connect(url)
    }
    
    func connect(_ url:String) {
        cloverConnector?.dispose()
        
        var endpoint = url
        if let components = URLComponents(string: url), let _ = components.url { //Make sure the URL is valid, and break into URL components
            self.token = components.queryItems?.first(where: { $0.name == "authenticationToken"})?.value //we can skip the pairing code if we already have an auth token
            
            endpoint = components.scheme ?? "wss"
            endpoint += "://"
            endpoint += components.host ?? ""
            endpoint += ":" + String(components.port ?? 80)
            endpoint += String(components.path)
        }
        
        let config:WebSocketDeviceConfiguration = WebSocketDeviceConfiguration(endpoint:endpoint, remoteApplicationID: "com.clover.ios.example.app", posName: "iOS Example POS", posSerial: "POS-15", pairingAuthToken: self.token, pairingDeviceConfiguration: self)
        //        config.maxCharInMessage = 2000
        //        config.pingFrequency = 1
        //        config.pongTimeout = 6
        //        config.reportConnectionProblemTimeout = 3
        
        let validCloverConnector = CloverConnectorFactory.createICloverConnector(config: config)
        self.cloverConnector = validCloverConnector
        let validCloverConnectorListener = CloverConnectorListener(cloverConnector: validCloverConnector)
        self.cloverConnectorListener = validCloverConnectorListener
        
        validCloverConnectorListener.viewController = self.window?.rootViewController
        validCloverConnector.addCloverConnectorListener(validCloverConnectorListener)
        validCloverConnector.initializeConnection()
    }
    
    func connectToCloverGoReader() {
        let config : CloverGoDeviceConfiguration = CloverGoDeviceConfiguration.Builder(apiKey: "mexbZJX5D3fa5kje1dZmrJVKOyAF9w8F", secret: "6hak16ff8e76r4565ab988f5d986a911e36f0f2347e3fv3eb719478c98e89io0", env: .test).accessToken(accessToken: "1669926f-c367-6f58-5027-31512f1661eb").deviceType(deviceType: .RP450).allowDuplicateTransaction(allowDuplicateTransaction: true).allowAutoConnect(allowAutoConnect: true).build()
        
        cloverConnector = CloverGoConnector(config: config)
        
        cloverConnectorListener = CloverGoConnectorListener(cloverConnector: cloverConnector!)
        cloverConnectorListener?.viewController = self.window?.rootViewController
        (cloverConnector as? CloverGoConnector)?.addCloverGoConnectorListener(cloverConnectorListener: (cloverConnectorListener as? ICloverGoConnectorListener)!)
        
        cloverConnector!.initializeConnection()
        
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func applicationDidFinishLaunching(_ application: UIApplication) {
        
    }
    
    // FOR iOS versions above 10.0
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        extractParametersForRestCall(url: url)
        return true
    }
    
    // FOR iOS versions below 10.0
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?,
                     annotation: Any) -> Bool {
        extractParametersForRestCall(url: url)
        return true
    }
    
    func extractParametersForRestCall(url: URL)
    {
        print("Redirect received from Safari...url recieved: \(url)")
        
        let codeFromRecievedUrl = url.query?.components(separatedBy: "code=").last
        print("codeFromRecievedUrl: \(String(describing: codeFromRecievedUrl))")
        
        var merchant_idFromRecievedUrl = url.query?.components(separatedBy: "merchant_id").last
        merchant_idFromRecievedUrl = extractStringFromURL(url: merchant_idFromRecievedUrl!)
        print("merchant_idFromRecievedUrl: \(String(describing: merchant_idFromRecievedUrl))")
        
        var employee_idFromRecievedUrl = url.query?.components(separatedBy: "employee_id").last
        employee_idFromRecievedUrl = extractStringFromURL(url: employee_idFromRecievedUrl!)
        print("employee_idFromRecievedUrl: \(String(describing: employee_idFromRecievedUrl))")
        
        var client_idFromRecievedUrl = url.query?.components(separatedBy: "client_id").last
        client_idFromRecievedUrl = extractStringFromURL(url: client_idFromRecievedUrl!)
        print("client_idFromRecievedUrl: \(String(describing: client_idFromRecievedUrl))")
        
        restCallToGetToken(merchant_id: merchant_idFromRecievedUrl!, employee_id: employee_idFromRecievedUrl!, client_id: client_idFromRecievedUrl!, code: codeFromRecievedUrl!)
    }
    
    /// Make a rest call to get the access token
    ///
    /// - Parameters:
    ///   - merchant_id: received from redirect Url
    ///   - employee_id: received from redirect Url
    ///   - client_id: received from redirect Url
    ///   - code: received from redirect Url
    func restCallToGetToken(merchant_id: String, employee_id: String, client_id: String, code: String)
    {
        let configuration = URLSessionConfiguration .default
        let session = URLSession(configuration: configuration)
        
        let apikeyForUrlForRestCall = "byJiyq2GZNmS6LgtAhr2xGS6gz4dpBYX"
        let client_idForUrlForRestCall = client_id
        let client_secretForUrlForRestCall = "6e2f4d4c-da09-a42c-fa72-bbd96a5c63aa"
        
        var urlString = NSString(format: "https://api-int.payeezy.com/clovergoOAuth/?environment=www.clover.com&apikey=")
        urlString = "\(urlString)\(apikeyForUrlForRestCall)" as NSString
        urlString = "\(urlString)&client_id=" as NSString
        urlString = "\(urlString)\(client_idForUrlForRestCall)" as NSString
        urlString = "\(urlString)&client_secret=" as NSString
        urlString = "\(urlString)\(client_secretForUrlForRestCall)" as NSString
        urlString = "\(urlString)&code=" as NSString
        urlString = "\(urlString)\(code)" as NSString
        print("urlString: \(urlString)")
        
        let request : NSMutableURLRequest = NSMutableURLRequest()
        request.url = NSURL(string: NSString(format: "%@", urlString) as String) as URL?
        request.httpMethod = "GET"
        request.timeoutInterval = 30
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let dataTask = session.dataTask(with: request as URLRequest) {
            ( data: Data?, response: URLResponse?, error: Error?) -> Void in
            // 1: Check HTTP Response for successful GET request
            guard let httpResponse = response as? HTTPURLResponse, let receivedData = data
                else {
                    print("error: not a valid http response")
                    return
            }
            
            switch (httpResponse.statusCode)
            {
            case 200:
                let response = NSString (data: receivedData, encoding: String.Encoding.utf8.rawValue)
                print("response is \(response)")
                do {
                    let getResponse = try JSONSerialization.jsonObject(with: receivedData, options: .allowFragments)  as! [String:Any]
                    print("getResponse is \(getResponse)")
                    
                    if (self.delegate != nil){
                        if let accessToken = getResponse["access_token"] as? String {
                            self.delegate?.initSDKWithOAuth(accessTokenReceived: accessToken)
                        } else {
                            
                        }
                    }
                    
                } catch {
                    print("error serializing JSON: \(error)")
                }
                break
                
            case 400:
                break
                
            default:
                print("GET request got response \(httpResponse.statusCode)")
            }
        }
        dataTask.resume()
    }
    
    /// Used to extract a substring from the URL
    ///
    /// - Parameter url: URL from which the string is extracted
    /// - Returns: extracted string
    func extractStringFromURL(url: String) -> String
    {
        if let startRange = url.range(of: "="), let endRange = url.range(of: "&"), startRange.upperBound <= endRange.lowerBound {
            let extractedString = url[startRange.upperBound..<endRange.lowerBound]
            return String(extractedString)
        }
        else {
            print("invalid string")
            return ""
        }
    }
}

