//
//  CreditCardViewController.swift
//  fudar-user
//
//  Created by Shaun Bevan on 10/22/17.
//  Copyright © 2017 silverlogic. All rights reserved.
//

import UIKit
import Stripe
import CreditCardForm
import SCLAlertView

class CreditCardViewController: UIViewController, STPPaymentCardTextFieldDelegate {

    // MARK: - IBOutlets
    @IBOutlet weak var cardFormView: CreditCardFormView!
    @IBOutlet weak var purchaseOrderButton: UIButton!
    let paymentTextField = STPPaymentCardTextField()

    // MARK: - Attributes
    var creditCardNumber: String?
    var expirationDate: String?
    var cvcNumber: String?

    @IBAction func purchaseOrderButtonTapped(_ sender: Any) {
        guard let _ = creditCardNumber, let _ = expirationDate, let _ = cvcNumber else {
            SCLAlertView().showInfo("Error", subTitle: "Please fill in your credit card information.")
            return
        }
        ReaderManager.shared.initializeForRemoteReader()
        PurchaseManager.shared.processOrderForStore(isKeyedTransaction: true) { success in
            if success {
                SCLAlertView().showInfo("Thank you for your purchase", subTitle: "Please see the cashier at the window.")
                performSegue(withIdentifier: "goToConfirmation", sender: self)
            } else {
                SCLAlertView().showInfo("Error", subTitle: "Please see the cashier at the window.")
            }
        }
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set up stripe textfield
        cardFormView.cardHolderString = "Clover Field"
        cardFormView.expireDatePlaceholderText = "10/22"
        paymentTextField.delegate = self
        paymentTextField.frame = CGRect(x: 15, y: 199, width: self.view.frame.size.width - 30, height: 44)
        paymentTextField.translatesAutoresizingMaskIntoConstraints = false
        paymentTextField.borderWidth = 0
        
        let border = CALayer()
        let width = CGFloat(1.0)
        border.borderColor = UIColor.darkGray.cgColor
        border.frame = CGRect(x: 0, y: paymentTextField.frame.size.height - width, width:  paymentTextField.frame.size.width, height: paymentTextField.frame.size.height)
        border.borderWidth = width
        paymentTextField.layer.addSublayer(border)
        paymentTextField.layer.masksToBounds = true
        
        view.addSubview(paymentTextField)
        
        NSLayoutConstraint.activate([
            paymentTextField.topAnchor.constraint(equalTo: cardFormView.bottomAnchor, constant: 20),
            paymentTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            paymentTextField.widthAnchor.constraint(equalToConstant: self.view.frame.size.width-20),
            paymentTextField.heightAnchor.constraint(equalToConstant: 44)
            ])
    }
    
    func paymentCardTextFieldDidChange(_ textField: STPPaymentCardTextField) {
        cardFormView.paymentCardTextFieldDidChange(cardNumber: textField.cardNumber, expirationYear: textField.expirationYear, expirationMonth: textField.expirationMonth, cvc: textField.cvc)
    }
    
    func paymentCardTextFieldDidEndEditingExpiration(_ textField: STPPaymentCardTextField) {
        cardFormView.paymentCardTextFieldDidEndEditingExpiration(expirationYear: textField.expirationYear)
    }
    
    func paymentCardTextFieldDidBeginEditingCVC(_ textField: STPPaymentCardTextField) {
        cardFormView.paymentCardTextFieldDidBeginEditingCVC()
    }
    
    func paymentCardTextFieldDidEndEditingCVC(_ textField: STPPaymentCardTextField) {
        cardFormView.paymentCardTextFieldDidEndEditingCVC()
        creditCardNumber = textField.cardNumber
        if textField.expirationMonth < 10 {
            expirationDate = "0\(textField.expirationMonth)\(textField.expirationYear)"
        } else {
            expirationDate = "\(textField.expirationMonth)\(textField.expirationYear)"
        }
        cvcNumber = textField.cvc
    }
}
