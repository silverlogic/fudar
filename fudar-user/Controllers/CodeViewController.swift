//
//  CodeViewController.swift
//  fudar-user
//
//  Created by Shaun Bevan on 10/22/17.
//  Copyright © 2017 silverlogic. All rights reserved.
//

import UIKit

class CodeViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var timerLabel: UILabel!

    @IBAction func returnButtonTapped(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    // MARK: - Attributes
    var count = 599

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        _ = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(update), userInfo: nil, repeats: true)
    }
    
    @objc func update() {
        if count > 0 {
            let minutes = String(count / 60)
            let seconds = String(count % 60)
            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.timerLabel.text = minutes + ":" + seconds
            }
            count = count - 1
        }
    }
}
