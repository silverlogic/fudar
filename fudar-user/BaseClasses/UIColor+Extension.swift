//
//  UIColor+Extension.swift
//  fudar-user
//
//  Created by Michael Sevy on 10/21/17.
//  Copyright © 2017 silverlogic. All rights reserved.
//

import UIKit

// MARK: - Private Class Methods
fileprivate extension UIColor {

    fileprivate static func colorFromHexValue(_ hexValue: UInt, alpha: CGFloat = 1.0) -> UIColor {
        let redValue = ((CGFloat)((hexValue & 0xFF0000) >> 16)) / 255.0
        let greenValue = ((CGFloat)((hexValue & 0xFF00) >> 8)) / 255.0
        let blueValue = ((CGFloat)(hexValue & 0xFF)) / 255.0
        return UIColor(red: redValue, green: greenValue, blue: blueValue, alpha: alpha)
    }
}


// MARK: - Application Colors
extension UIColor {

    /// Main color used in the application.
    static var main: UIColor { return colorFromHexValue(mainHexValue) }

    /// Secondary color used in the application.
    static var secondary: UIColor { return colorFromHexValue(secondaryHexValue) }

    /// Teritary color used in the application.
    static var teritary: UIColor { return colorFromHexValue(teritaryHexValue) }

    /// Color used in the light version of the navigation bar
    static var lightNaviagtionBar: UIColor { return colorFromHexValue(lighNavigationHexValue) }

    /// Used when some buttons are deactivated
    static var deactivatedButton: UIColor { return UIColor.lightGray }

    /// Color used to background for tags when creating posts
    static var tagsBackground: UIColor { return UIColor(red:0.85, green:0.85, blue:0.85, alpha:1) }

    static var appGray: UIColor { return UIColor(red:0.33, green:0.33, blue:0.33, alpha:1) }

    static var error: UIColor { return colorFromHexValue(0xD45656) }
}


// MARK: - Hex Value Constants
extension UIColor {
    @nonobjc static var mainHexValue: UInt = 0x33cc99
    @nonobjc static var secondaryHexValue: UInt = 0xFFFFFF
    @nonobjc static var teritaryHexValue: UInt = 0x126AFF
    @nonobjc static var lighNavigationHexValue: UInt = 0xF4F4F9
}

