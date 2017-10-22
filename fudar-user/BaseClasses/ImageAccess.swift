//
//  ImageAccess.swift
//  fudar-user
//
//  Created by Michael Sevy on 10/21/17.
//  Copyright © 2017 silverlogic. All rights reserved.
//

import Foundation

protocol ImageAccess {

    // MARK: - Public Instance Methods
    func setImageWithUrl(_ url: URL)
    func cancelImageDownload()
}

