//
//  Menu.swift
//  fudar-user
//
//  Created by Shaun Bevan on 10/22/17.
//  Copyright © 2017 silverlogic. All rights reserved.
//

import Foundation
import UIKit

public class Menu {
    
    public var name: String?
    public var price: Int = 0
    public var descriptionText = ""
    public var image: UIImage?
    public var itemId: String?
    public var count: Int = 0
    
    public init(menuId: String, menuTitle: String, menuPrice: Int, menuDescription: String, menuImage: UIImage) {
        self.name = menuTitle
        self.price = menuPrice
        self.descriptionText = menuDescription
        self.image = menuImage
    }
}
