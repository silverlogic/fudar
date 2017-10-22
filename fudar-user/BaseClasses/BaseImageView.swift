//
//  BaseImageView.swift
//  fudar-user
//
//  Created by Michael Sevy on 10/21/17.
//  Copyright © 2017 silverlogic. All rights reserved.
//

import UIKit
import Kingfisher

@IBDesignable final class BaseImageView: UIImageView {
    override func draw(_ rect: CGRect) {
        super.draw(rect)
    }

    // MARK: - IBInspectable
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }

    @IBInspectable var borderColor: UIColor = UIColor.clear {
        didSet {
            layer.borderColor = borderColor.cgColor
        }
    }

    @IBInspectable var clipToBounds: Bool = true {
        didSet {
            clipsToBounds = clipToBounds
        }
    }

    @IBInspectable var shadowColor: UIColor = UIColor.black {
        didSet {
            layer.shadowColor = shadowColor.cgColor
        }
    }

    @IBInspectable var shadowOffset: CGSize = CGSize(width: 3.0, height: 3.0) {
        didSet {
            layer.shadowOffset = shadowOffset
        }
    }

    @IBInspectable var shadowOpacity: Float = 0.7 {
        didSet {
            layer.shadowOpacity = shadowOpacity
        }
    }

    @IBInspectable var shadowRadius: CGFloat = 0.2 {
        didSet {
            layer.shadowRadius = shadowRadius
        }
    }
}


// MARK: - Kingfisher
extension BaseImageView {


    public func setImageWithUrl(_ url: URL) {
        kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "icon-imageplaceholder-blue"), options: [.transition(ImageTransition.fade(1))], progressBlock: nil) { [weak self] (image: Image?, error: NSError?, type: CacheType, url: URL?) in
            guard let strongSelf = self,
                let downloadedImage = image else { return }
            strongSelf.image = downloadedImage
            strongSelf.contentMode = .scaleAspectFill
        }
    }

    /// Cancels downloading the image from the url.
    public func cancelImageDownload() {
        kf.cancelDownloadTask()
    }
}

