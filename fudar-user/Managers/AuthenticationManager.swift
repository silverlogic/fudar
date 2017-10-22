//
//  AuthenticationManager.swift
//  fudar-user
//
//  Created by Michael Sevy on 10/21/17.
//  Copyright © 2017 silverlogic. All rights reserved.
//

import UIKit
import Firebase

final class AuthenticationManager {

    // MARK: - Shared Instance
    static let shared = AuthenticationManager()
    var user: User?

    /**
     Initializes a shared instance of `AuthenticationManager`.
     */
    private init() {}
}


internal extension AuthenticationManager {

    // Create the user
    func createUser(email: String, password: String, success: @escaping (_ user: User) -> Void, failure: @escaping (_ error: Error) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
            if (user != nil) {
                success(user!)
            }
            if (error != nil) {
                failure(error!)
            }
        })
    }

    // log the user in
    func login(email: String, password: String, success: @escaping (_ user: User) -> Void, failure: @escaping (_ error: Error) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
            if (user != nil) {
                self.user = user
                success(user!)
            }
            if (error != nil) {
                failure(error!)
            }
        })
    }

    // listen for state changes of the user
    func stateChangeListener(success: @escaping () -> Void, failure: @escaping (_ failed: Bool) -> Void) {
        Auth.auth().addStateDidChangeListener() { auth, user in
            if (user != nil) {
                self.user = user
                success()
                return
            }
            failure(true)
        }
    }

    // log the user out
    func logout(success: @escaping () -> Void, failure: @escaping (_ error: NSError) -> Void) {
        do {
            try Auth.auth().signOut()
            //UserDefaults.standard.set(true, forKey: ConfigurationConstants.hasPreviouslyLaunchedApp)
        } catch let error as NSError {
            failure(error)
            return
        }
        success()
    }
}


