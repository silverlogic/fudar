//
//  PaymentViewController.swift
//  fudar-user
//
//  Created by Shaun Bevan on 10/21/17.
//  Copyright © 2017 silverlogic. All rights reserved.
//

import UIKit
import CloverConnector_Hackathon_2017
import CoreLocation
import FirebaseDatabase

final class PaymentViewController: UIViewController, StartTransactionDelegate {
    
    // MARK: - Attributes
    var cloverConnector450Reader: ICloverConnector?
    let locationManager = CLLocationManager()

    // MARK: - IBOutlets
    @IBOutlet weak var deviceConnectedLabel: UILabel!
    @IBOutlet weak var connectDeviceButton: UIButton!
    @IBOutlet weak var purchaseButton: UIButton!
    @IBOutlet weak var purchaseSaleButtonTapped: UIButton!

    
    // MARK: - IBActions
    @IBAction func connectDeviceButtonTapped(_ sender: Any) {
        ReaderManager.shared.initializeClover450Reader { success in
            if !success {
                let alert = UIAlertController(title: nil, message: "Reader 450 is already initialized", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
        SHARED.delegateStartTransaction = self
    }
    
    @IBAction func purchaseButtonTapped(_ sender: Any) {
        authSale()
    }
    
    @IBAction func keyedPurchaseButtonTapped(_ sender: Any) {
        keyedSale()
        authSale()
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        loginUser()
        connectDeviceButton.layer.masksToBounds = true
        connectDeviceButton.layer.cornerRadius = 62.5
        purchaseButton.layer.masksToBounds = true
        purchaseButton.layer.cornerRadius = 125.0

        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        checkReaderConnectedStatus()
        (UIApplication.shared.delegate as? AppDelegate)?.cloverConnectorListener?.viewController = self
    }
    
    
    // MARK: - StartTransactionDelegate
    func proceedAfterReaderReady(merchantInfo: MerchantInfo) {
        FLAGS.is450ReaderInitialized = true
        checkReaderConnectedStatus()
    }
}

// MARK: - Purchase Methods
extension PaymentViewController {
    func keyedSale() {
        ReaderManager.shared.initializeForRemoteReader()
        PurchaseManager.shared.processOrderForStore(isKeyedTransaction: true) { success in
            if !success {
                DispatchQueue.main.async { [weak self] in
                    guard let strongSelf = self else { return }
                    let alert = UIAlertController(title: "", message: "Transaction Failed", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction!) in
                    }))
                    strongSelf.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    func authSale() {
        PurchaseManager.shared.processOrderForStore(isKeyedTransaction: false) { success in
            if !success {
                DispatchQueue.main.async { [weak self] in
                    guard let strongSelf = self else { return }
                    let alert = UIAlertController(title: "", message: "Reader not connected", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction!) in
                    }))
                    strongSelf.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
}


// MARK: - Reader Methods
extension PaymentViewController {
    func checkReaderConnectedStatus() {
        if FLAGS.is450ReaderInitialized {
            deviceConnectedLabel.text = "Reader 450 Connected"
            connectDeviceButton.setTitle("Disconnect", for: .normal)
        } else {
            deviceConnectedLabel.text = "Reader 450 Not Connected"
            connectDeviceButton.setTitle("Connect", for: .normal)
        }
    }
    
    func readerDisconnected() {
        FLAGS.is450ReaderInitialized = false
        checkReaderConnectedStatus()
    }
    
    func loginUser() {
        AuthenticationManager.shared.login(email: "md@tsl.io", password: "123456", success: { [weak self] (user) in
            }, failure: { [weak self] (error: Error) in
                guard let strongSelf = self else { return }
                strongSelf.showInfoAlert(title:NSLocalizedString("Alert.Error", comment: "error"), subTitle: error.localizedDescription)
        })
    }
}


// MARK: - CLLocationManagerDelegate
extension PaymentViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        print("locations = \(locValue.latitude) \(locValue.longitude)")
        let ref = Database.database().reference().child("truck")
        ref.updateChildValues(["lat": locValue.latitude])
        ref.updateChildValues(["lon": locValue.longitude])
    }
}
