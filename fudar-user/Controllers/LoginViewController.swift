//
//  LoginViewController.swift
//  fudar-user
//
//  Created by Michael Sevy on 10/21/17.
//  Copyright © 2017 silverlogic. All rights reserved.
//

import UIKit
import JVFloatLabeledTextField
import Firebase
import CoreLocation

final class LoginViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var emailTextField: JVFloatLabeledTextField!
    @IBOutlet weak var passwordTextField: JVFloatLabeledTextField!


    // MARK: - Private Instance Attributes
    fileprivate let locationManager = CLLocationManager()
    fileprivate var refreshControl: UIRefreshControl!
    fileprivate var latitude: String?
    fileprivate var longitude: String?


    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        setup()
    }

    @IBAction func logOnTapped(_ sender: UIButton) {
        showProgressHud()
        AuthenticationManager.shared.login(email: emailTextField.text!, password: passwordTextField.text!, success: { [weak self] (user) in
            guard let strongSelf = self else { return }
            strongSelf.dismissProgressHud()
            }, failure: { [weak self] (error: Error) in
                guard let strongSelf = self else { return }
                strongSelf.dismissProgressHud()

                strongSelf.showInfoAlert(title:NSLocalizedString("Alert.Error", comment: "error"), subTitle: error.localizedDescription)
                strongSelf.passwordTextField.text = ""
        })
    }

}


extension LoginViewController {
    func setup() {
        if let userId = Auth.auth().currentUser?.uid {
            print("user: \(userId) logged in")
            fetchCurrentLocation()
        } else {
            print("no user logged in")
        }
    }
}

// CLLOCATION Delegate
extension LoginViewController: CLLocationManagerDelegate {
    func fetchCurrentLocation() {
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        } else {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!)
            } else {
                print("location denied")
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        var currentLocation = CLLocation()
        currentLocation = locations.sorted { $0.horizontalAccuracy < $1.horizontalAccuracy }.first!
        latitude = String(currentLocation.coordinate.latitude)
        longitude = String(currentLocation.coordinate.longitude)
        locationManager.stopUpdatingLocation()
        if let latitude = latitude {
            if let longitude = longitude {
                print("latitude: \(latitude) and longitude: \(longitude)")
                performSegue(withIdentifier: UIStoryboardSegue.goToTruckFeedSegue, sender:self)
                return
            } else {
                print("location services not working")
            }
        } else {
            print("location services not working")
        }
    }
}
