//
//  CloverGoConnectorListener.swift
//  CloverConnector_Example
//
//  Created by Rajan Veeramani on 10/9/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation
import CloverConnector_Hackathon_2017

class CloverGoConnectorListener {
    weak var cloverConnector:ICloverGoConnector?

    public init(cloverConnector:ICloverGoConnector){
        self.cloverConnector = cloverConnector;
    }
}

extension CloverGoConnectorListener: ICloverGoConnectorListener {
    func onAidMatch(cardApplicationIdentifiers: [CLVModels.Payments.CardApplicationIdentifier]) {
        
    }
    
    func onDevicesDiscovered(devices: [CLVModels.Device.GoDeviceInfo]) {
        print("Discovered Readers...")
        let choiceAlert = UIAlertController(title: "Choose your reader", message: "Please select one of the reader", preferredStyle: .actionSheet)
        for device in devices {
            let action = UIAlertAction(title: device.name, style: .default, handler: {
                (action:UIAlertAction) in
                ((UIApplication.shared.delegate as! AppDelegate).cloverConnector as? CloverGoConnector)?.connectToBluetoothDevice(deviceInfo: device)
                
            })
            choiceAlert.addAction(action)
        }
        choiceAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (action:UIAlertAction) in
            
        }))
        
        var topController = UIApplication.shared.keyWindow!.rootViewController! as UIViewController
        while ((topController.presentedViewController) != nil) {
            topController = topController.presentedViewController!
        }
        
        if let popoverController = choiceAlert.popoverPresentationController {
            popoverController.sourceView = topController.view
            popoverController.sourceRect = CGRect(x: topController.view.bounds.midX, y: topController.view.bounds.midY, width: 0, height: 0)
        }
        
        topController.present(choiceAlert, animated:true, completion:nil)
    }
    
    func onTransactionProgress(event: CLVModels.Payments.GoTransactionEvent) {
        
    }
    
    func onSignatureRequired() {
        
    }
    
    func onSendReceipt() {
        
    }
    
    func onSaleResponse(_ response: SaleResponse) {
        
    }
    
    func onAuthResponse(_ authResponse: AuthResponse) {
        
    }
    
    func onPreAuthResponse(_ preAuthResponse: PreAuthResponse) {
        
    }
    
    func onCapturePreAuthResponse(_ capturePreAuthResponse: CapturePreAuthResponse) {
        
    }
    
    func onTipAdjustAuthResponse(_ tipAdjustAuthResponse: TipAdjustAuthResponse) {
        
    }
    
    func onVoidPaymentResponse(_ voidPaymentResponse: VoidPaymentResponse) {
        
    }
    
    func onRefundPaymentResponse(_ refundPaymentResponse: RefundPaymentResponse) {
        
    }
    
    func onManualRefundResponse(_ manualRefundResponse: ManualRefundResponse) {
        
    }
    
    func onCloseoutResponse(_ closeoutResponse: CloseoutResponse) {
        
    }
    
    func onVerifySignatureRequest(_ signatureVerifyRequest: VerifySignatureRequest) {
        
    }
    
    func onVaultCardResponse(_ vaultCardResponse: VaultCardResponse) {
        
    }
    
    func onDeviceActivityStart(_ deviceEvent: CloverDeviceEvent) {
        
    }
    
    func onDeviceActivityEnd(_ deviceEvent: CloverDeviceEvent) {
        
    }
    
    func onDeviceError(_ deviceErrorEvent: CloverDeviceErrorEvent) {
        
    }
    
    func onDeviceConnected() {
        
    }
    
    func onDeviceReady(_ merchantInfo: MerchantInfo) {
        
    }
    
    func onDeviceDisconnected() {
        
    }
    
    func onConfirmPaymentRequest(_ request: ConfirmPaymentRequest) {
        
    }
    
    func onTipAdded(_ message: TipAddedMessage) {
        
    }
    
    func onPrintManualRefundReceipt(_ printManualRefundReceiptMessage: PrintManualRefundReceiptMessage) {
        
    }
    
    func onPrintManualRefundDeclineReceipt(_ printManualRefundDeclineReceiptMessage: PrintManualRefundDeclineReceiptMessage) {
        
    }
    
    func onPrintPaymentReceipt(_ printPaymentReceiptMessage: PrintPaymentReceiptMessage) {
        
    }
    
    func onPrintPaymentDeclineReceipt(_ printPaymentDeclineReceiptMessage: PrintPaymentDeclineReceiptMessage) {
        
    }
    
    func onPrintPaymentMerchantCopyReceipt(_ printPaymentMerchantCopyReceiptMessage: PrintPaymentMerchantCopyReceiptMessage) {
        
    }
    
    func onPrintRefundPaymentReceipt(_ printRefundPaymentReceiptMessage: PrintRefundPaymentReceiptMessage) {
        
    }
    
    func onRetrievePrintersResponse(_ retrievePrintersResponse: RetrievePrintersResponse) {
        
    }
    
    func onPrintJobStatusResponse(_ printJobStatusResponse: PrintJobStatusResponse) {
        
    }
    
    func onRetrievePendingPaymentsResponse(_ retrievePendingPaymentResponse: RetrievePendingPaymentsResponse) {
        
    }
    
    func onReadCardDataResponse(_ readCardDataResponse: ReadCardDataResponse) {
        
    }
    
    func onCustomActivityResponse(_ customActivityResponse: CustomActivityResponse) {
        
    }
    
    func onResetDeviceResponse(_ response: ResetDeviceResponse) {
        
    }
    
    func onMessageFromActivity(_ response: MessageFromActivity) {
        
    }
    
    func onRetrievePaymentResponse(_ response: RetrievePaymentResponse) {
        
    }
    
    func onRetrieveDeviceStatusResponse(_ _response: RetrieveDeviceStatusResponse) {
        
    }
    
    
}

