//
//  Constants.swift
//  fudar-user
//
//  Created by Michael Sevy on 10/21/17.
//  Copyright © 2017 silverlogic. All rights reserved.
//


import UIKit

enum ConfigurationConstants {

    // MARK: - File Constants
    static let globalConfiguration = "globalconfiguration"


    // MARK: - File Type Constants
    static let propertyListType = "plist"


}


/**
 An enum that defines constants used for
 setting up the Core Data stack of the
 application.
 */
enum CoreDataStackConstants {

    // MARK: - File Constants
    static let model = "Model"
    static let sqLite = "Model.sqlite"


    // MARK: - File Type Constants
    static let modelType = "momd"
}

enum SessionConstants {

    // MARK: - User Constants
    static let userId = "userId"


    // MARK: - Authorization Token Constants
    static let authorizationToken = "authorizationToken"
}

enum PushNotificationConstants {

    // MARK: - Registration Constants
    static let isRegistered = "isRegistered"
}

enum StyleConstants {

    // MARK: - Keyboard Constants
    static let keyboardStyle: UIKeyboardAppearance = .default
}

enum OAuthErrorConstants {
    static let invalidProvider = "Invalid provider 😞"
    static let invalidCredentials = "invalid_credentials 😞"
    static let noEmailProvided = "no_email_provided 😞"
    static let emailAlreadyInUse = "email_already_in_use 😞"
}

