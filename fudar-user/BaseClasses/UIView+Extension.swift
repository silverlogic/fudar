//
//  UIView+Extension.swift
//  fudar-user
//
//  Created by Michael Sevy on 10/21/17.
//  Copyright © 2017 silverlogic. All rights reserved.
//

import UIKit

extension UIView {

    static func performRootViewControllerAnimation(snapshot: UIView) {
        UIView.animate(withDuration: 0.3, animations: {() in
            snapshot.layer.opacity = 0;
            snapshot.layer.transform = CATransform3DMakeScale(1.5, 1.5, 1.5);
        }, completion: {
            (value: Bool) in
            snapshot.removeFromSuperview();
        });
    }
}


// MARK: - Show/Hide Animation
extension UIView {

    /// Animates showing an instance.
    func animateShow() {
        UIView.animate(withDuration: 0.5) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.alpha = 1
        }
    }

    /// Animates hiding an instance.
    func animateHide() {
        UIView.animate(withDuration: 0.5) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.alpha = 0
        }
    }
}


// MARK: - Nib Loader
extension UIView {

    func loadXibView(with xibFrame: CGRect) -> UIView {
        let className = String(describing: type(of: self))
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: className, bundle: bundle)
        guard let xibView = nib.instantiate(withOwner: self, options: nil)[0] as? UIView else {
            return UIView()
        }
        xibView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        xibView.frame = xibFrame
        return xibView
    }
}

