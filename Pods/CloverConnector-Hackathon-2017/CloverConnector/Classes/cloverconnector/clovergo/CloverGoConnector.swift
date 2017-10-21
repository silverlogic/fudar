//
//  CloverGoConnector.swift
//  CloverGoConnector
//
//  Created by Veeramani, Rajan (Non-Employee) on 4/17/17.
//  Copyright © 2017 Veeramani, Rajan (Non-Employee). All rights reserved.
//

import Foundation
import clovergoclient

public class CloverGoConnector : NSObject, ICloverGoConnector, CardReaderDelegate {
    
    public var CARD_ENTRY_METHOD_MAG_STRIPE: Int = 0
    
    public var CARD_ENTRY_METHOD_ICC_CONTACT: Int = 1
    
    public var CARD_ENTRY_METHOD_NFC_CONTACTLESS: Int = 2
    
    public var CARD_ENTRY_METHOD_MANUAL: Int = 3
    
    public var CARD_ENTRY_METHODS_DEFAULT: Int = 4
    
    public var MAX_PAYLOAD_SIZE: Int = 5
    
    var config:CloverGoDeviceConfiguration!
    
    let cloverGo = CloverGo.sharedInstance
    
    weak var connectorListener :ICloverGoConnectorListener?
    
    var authTransactionDelegate :TransactionDelegate?
    var preAuthTransactionDelegate :TransactionDelegate?
    var saleTransactionDelegate :TransactionDelegate?
    
    var merchantInfo:MerchantInfo?
    
    var deviceReady = false
    
    var lastTransactionRequest : TransactionRequest?
    var lastTransactionResponse : TransactionResult?
    
    public init(config:CloverGoDeviceConfiguration) {
        super.init()
        self.config = config
        
        var env : Env
        switch config.env {
        case .demo:
            env = Env.demo
        case .live:
            env = Env.live
        case .test:
            env = Env.test
        case .sandbox:
            env = Env.sandbox
        case .qa:
            env = Env.qa
        }
        cloverGo.initializeWithAccessToken(accessToken: config.accessToken, apiKey: config.apiKey, secret: config.secret, env: env)
        CloverGo.allowAutoConnect = config.allowAutoConnect
        CloverGo.overrideDuplicateTransaction = config.allowDuplicateTransaction
        
        self.getMerchantInfo()
    }
    
    /// This delegate method is for getting the merchant information
    ///
    private func getMerchantInfo() {
        cloverGo.getMerchantInfo(success: { (merchant) in
            self.merchantInfo = MerchantInfo(id: merchant.id, mid: nil, name: merchant.name, deviceName: nil, deviceSerialNumber: nil, deviceModel: nil)
            self.merchantInfo!.supportsAuths = (merchant.features?.contains(MerchantPropertyType.supportsAuths.toString()) ?? true) ? true : false
            self.merchantInfo!.supportsVaultCards = (merchant.features?.contains(MerchantPropertyType.supportsVaultCards.toString()) ?? true) ? true : false
            self.merchantInfo!.supportsManualRefunds = (merchant.features?.contains(MerchantPropertyType.supportsManualRefunds.toString()) ?? true) ? true : false
            self.merchantInfo!.supportsTipAdjust = (merchant.features?.contains(MerchantPropertyType.supportsTipAdjust.toString()) ?? true) ? true : false
            self.merchantInfo!.supportsPreAuths = (merchant.features?.contains(MerchantPropertyType.supportsPreAuths.toString()) ?? true) ? true : false
            self.merchantInfo!.supportsVoids = (merchant.features?.contains(MerchantPropertyType.supportsVoids.toString()) ?? true) ? true : false
            self.merchantInfo!.supportsSales = (merchant.features?.contains(MerchantPropertyType.supportsSales.toString()) ?? true) ? true : false
            
        }) { (error) in
            //Not expecting an error for now
        }
    }
    
    /// This delegate method is called to connect to a device
    ///
    public func initializeConnection() {
        
        let readerInfo = ReaderInfo(readerType: EnumerationUtil.GoReaderType_toCardReaderType(type: config.deviceType), serialNumber: nil)
        cloverGo.useReader(cardReaderInfo: readerInfo, delegate: self)
    }
    
    /// This delegate method is called for scanning the bluetooth devices
    ///
    public func scanForBluetoothDevices() {
        cloverGo.scanForBluetoothReaders()
    }
    
    /// This delegate method is used to connected with the bluetooth after the scan for devices is finished
    ///
    /// - Parameter deviceInfo: GoDeviceInfo object contains all the details about the device
    public func connectToBluetoothDevice(deviceInfo:CLVModels.Device.GoDeviceInfo) {
        let reader = ReaderInfo(readerType: EnumerationUtil.GoReaderType_toCardReaderType(type: deviceInfo.type), serialNumber: nil)
        reader.bluetoothId = deviceInfo.bluetoothId
        reader.bluetoothName = deviceInfo.name
        cloverGo.connectToBTReader(readerInfo: reader)
    }
    
    /// This delegate method is called to release a connected device
    ///
    public func disconnectDevice() {
        let readerInfo = ReaderInfo(readerType: EnumerationUtil.GoReaderType_toCardReaderType(type: config.deviceType), serialNumber: nil)
        cloverGo.releaseReader(cardReaderInfo: readerInfo)
    }
    
    /// This delegate method is called to reset a reader
    ///
    public func resetDevice() {
        cloverGo.resetReader(readerInfo: ReaderInfo(readerType: EnumerationUtil.GoReaderType_toCardReaderType(type: config.deviceType), serialNumber: nil))
    }
    
    public func cancel() {
        cloverGo.cancelCardReaderTransaction(readerInfo: ReaderInfo(readerType: EnumerationUtil.GoReaderType_toCardReaderType(type: config.deviceType), serialNumber: nil))
    }
    
    /// This delegate method is used to add a ICloverConnectorListener
    ///
    /// - Parameter cloverConnectorListener: ICloverConnectorListener object
    public func addCloverConnectorListener(_ cloverConnectorListener:ICloverConnectorListener) -> Void {
        //Not to be implemented
    }
    
    /// This delegate method is used to remove a ICloverConnectorListener
    ///
    /// - Parameter cloverConnectorListener: ICloverConnectorListener object
    public func removeCloverConnectorListener(_ cloverConnectorListener:ICloverConnectorListener) -> Void {
        //Not to be implemented
    }
    
    /// This delegate method is used to add a ICloverGoConnectorListener
    ///
    /// - Parameter cloverConnectorListener: ICloverGoConnectorListener object
    public func addCloverGoConnectorListener(cloverConnectorListener: ICloverGoConnectorListener) {
        connectorListener = cloverConnectorListener
    }
    
    /// This delegate method is used to do a sale transaction
    ///
    /// - Parameter saleRequest: Construct SaleRequest object with required fields
    public func sale(_ saleRequest: SaleRequest) {
        resetState()
        if (deviceReady || saleRequest.keyedCardData != nil) {
            if merchantInfo?.supportsSales != nil && !(merchantInfo?.supportsSales)! {
                
                connectorListener?.onSaleResponse(SaleResponse(success: false, result: ResultCode.UNSUPPORTED))
                
            } else {
                saleTransactionDelegate = TransactionDelegateImpl(connectorListener: self.connectorListener, transactionType: .purchase)
                executeTransaction(transactionRequest: saleRequest, delegate: saleTransactionDelegate!)
            }
        } else {
            let errResponse = SaleResponse(success: false, result: ResultCode.ERROR)
            errResponse.message = "Device Not Ready"
            connectorListener?.onSaleResponse(errResponse)
        }
    }
    
    /// This delegate method is used to do a auth transaction
    ///
    /// - Parameter authRequest: Construct AuthRequest object with required fields
    public func auth(_ authRequest: AuthRequest) {
        resetState()
        if (deviceReady || authRequest.keyedCardData != nil) {
            if merchantInfo?.supportsAuths != nil && !(merchantInfo?.supportsAuths)! {
                
                connectorListener?.onAuthResponse(AuthResponse(success: false, result: ResultCode.UNSUPPORTED))
                
            } else {
                authTransactionDelegate = TransactionDelegateImpl(connectorListener: self.connectorListener, transactionType: .auth)
                executeTransaction(transactionRequest: authRequest, delegate: authTransactionDelegate!)
            }
        } else {
            let errResponse = AuthResponse(success: false, result: ResultCode.ERROR)
            errResponse.message = "Device Not Ready"
            connectorListener?.onAuthResponse(errResponse)
        }
    }
    
    /// This delegate method is used to do a preAuth transaction
    ///
    /// - Parameter preAuthRequest: Construct PreAuthRequest object with required fields
    public func preAuth(_ preAuthRequest: PreAuthRequest) {
        resetState()
        if (deviceReady || preAuthRequest.keyedCardData != nil) {
            if merchantInfo?.supportsPreAuths != nil && !(merchantInfo?.supportsPreAuths)! {
                
                connectorListener?.onPreAuthResponse(PreAuthResponse(success: false, result: ResultCode.UNSUPPORTED))
                
            } else {
                preAuthTransactionDelegate = TransactionDelegateImpl(connectorListener: self.connectorListener, transactionType: .preauth)
                executeTransaction(transactionRequest: preAuthRequest, delegate: preAuthTransactionDelegate!)
            }
        } else {
            let errResponse = PreAuthResponse(success: false, result: ResultCode.ERROR)
            errResponse.message = "Device Not Ready"
            connectorListener?.onPreAuthResponse(errResponse)
        }
    }
    
    /// This delegate method is used to perform a transaction
    ///
    /// - Parameters:
    ///   - transactionRequest: Object of TransactionRequest containing the request details
    ///   - delegate: Object of TransactionDelegate containing the transaction delegate methods
    private func executeTransaction(transactionRequest:TransactionRequest, delegate:TransactionDelegate) {
        let order = Order()
        order.addCustomItem(item: CustomItem(name: "Item 1", price: transactionRequest.amount, quantity: 1))
        
        if let saleRequest = transactionRequest as? SaleRequest {
            order.tax = saleRequest.taxAmount ?? 0
            order.tip = saleRequest.tipAmount ?? 0
            order.transactionType = .purchase
        } else if let authRequest = transactionRequest as? AuthRequest {
            order.tax = authRequest.taxAmount ?? -1
            order.tip = -1
            order.transactionType = .auth
        } else if transactionRequest is PreAuthRequest {
            order.transactionType = .preauth
            order.tax = -1
            order.tip = -1
        }
        
        order.externalPaymentId = transactionRequest.externalId
        
        lastTransactionRequest = transactionRequest
        
        if let keyedCardData = transactionRequest.keyedCardData {
            
            let keyedRequest = KeyedRequest(cardNumber: keyedCardData.cardNumber, expDate: keyedCardData.expirationDate, cvv: keyedCardData.cvv, order: order, zipCode: keyedCardData.zipCode, streetAddress: keyedCardData.address, cardPresent: keyedCardData.cardPresent)
            cloverGo.doKeyedTransaction(keyedRequest: keyedRequest, delegate: delegate)
            
        } else {
            let readerType = EnumerationUtil.GoReaderType_toCardReaderType(type: config.deviceType)
            cloverGo.doCardReaderTransaction(readerInfo: ReaderInfo(readerType: readerType, serialNumber: nil), order: order, delegate: delegate)
        }
    }
    
    /// This delegate method is used to do a tipAdjustAuth
    ///
    /// - Parameter authTipAdjustRequest: Construct TipAdjustAuthRequest object with required fields
    public func tipAdjustAuth(_ authTipAdjustRequest: TipAdjustAuthRequest) {
        
        if merchantInfo?.supportsTipAdjust != nil && !(merchantInfo?.supportsTipAdjust)! {
            
            connectorListener?.onTipAdjustAuthResponse(TipAdjustAuthResponse(success: false, result: ResultCode.UNSUPPORTED,paymentId: authTipAdjustRequest.paymentId, tipAmount: authTipAdjustRequest.tipAmount))
            
        } else {
            cloverGo.doAddTipTransaction(paymentId: authTipAdjustRequest.paymentId, amount: authTipAdjustRequest.tipAmount, success: { (result) in
                self.connectorListener?.onTipAdjustAuthResponse(TipAdjustAuthResponse(success: true, result: ResultCode.SUCCESS,paymentId: authTipAdjustRequest.paymentId, tipAmount: authTipAdjustRequest.tipAmount))
            }) { (error) in
                let tipAdjustResponse = TipAdjustAuthResponse(success: false, result: ResultCode.FAIL,paymentId: authTipAdjustRequest.paymentId, tipAmount: authTipAdjustRequest.tipAmount)
                tipAdjustResponse.reason = error.code
                tipAdjustResponse.message = error.message
                self.connectorListener?.onTipAdjustAuthResponse(tipAdjustResponse)
            }
        }
    }
    
    /// This delegate method is used to do a capture a PreAuth transaction
    ///
    /// - Parameter capturePreAuthRequest: Construct CapturePreAuthRequest object with required fields
    public func capturePreAuth(_ capturePreAuthRequest: CapturePreAuthRequest) {
        cloverGo.doCapturePreAuthTransaction(paymentId: capturePreAuthRequest.paymentId, amount: capturePreAuthRequest.amount, tipAmount: capturePreAuthRequest.tipAmount, success: { (result) in
            self.connectorListener?.onCapturePreAuthResponse(CapturePreAuthResponse(success: true, result: ResultCode.SUCCESS, paymentId: capturePreAuthRequest.paymentId, amount: capturePreAuthRequest.amount, tipAmount: capturePreAuthRequest.tipAmount))
        }) { (error) in
            let capturePreAuthResponse = CapturePreAuthResponse(success: false, result: ResultCode.FAIL, paymentId: capturePreAuthRequest.paymentId, amount: capturePreAuthRequest.amount, tipAmount: capturePreAuthRequest.tipAmount)
            capturePreAuthResponse.reason = error.code
            capturePreAuthResponse.message = error.message
            self.connectorListener?.onCapturePreAuthResponse(capturePreAuthResponse)
        }
    }
    
    /// This delegate method is used to Void a payment
    ///
    /// - Parameter voidPaymentRequest: Construct VoidPaymentRequest object with required fields
    public func voidPayment(_ voidPaymentRequest: VoidPaymentRequest) {
        if merchantInfo?.supportsVoids != nil && !(merchantInfo?.supportsVoids)! {
            connectorListener?.onVoidPaymentResponse(VoidPaymentResponse(success: false, result: ResultCode.UNSUPPORTED, paymentId: voidPaymentRequest.paymentId, transactionNumber: nil))
        } else {
            guard voidPaymentRequest.paymentId != nil && voidPaymentRequest.orderId != nil else {
                let voidErrorResponse = VoidPaymentResponse(success: false, result: ResultCode.FAIL, paymentId: voidPaymentRequest.paymentId, transactionNumber: nil)
                voidErrorResponse.reason = "invalid_request"
                voidErrorResponse.message = "Order Id and Payment Id in the request cannot be nil"
                connectorListener?.onVoidPaymentResponse(voidErrorResponse)
                return
            }
            cloverGo.doVoidTransaction(paymentId: voidPaymentRequest.paymentId!, orderId: voidPaymentRequest.orderId!, voidReason: EnumerationUtil.VoidReason_toString(type: voidPaymentRequest.voidReason),success: { (result) in
                self.connectorListener?.onVoidPaymentResponse(VoidPaymentResponse(success: true, result: ResultCode.SUCCESS, paymentId: voidPaymentRequest.paymentId, transactionNumber: nil))
            }) { (error) in
                let voidResponse = VoidPaymentResponse(success: false, result: ResultCode.FAIL, paymentId: voidPaymentRequest.paymentId, transactionNumber: nil)
                voidResponse.reason = error.code
                voidResponse.message = error.message
                self.connectorListener?.onVoidPaymentResponse(voidResponse)
            }
        }
        
    }
    
    /// This delegate method is used to Refund a payment
    ///
    /// - Parameter refundPaymentRequest: Construct RefundPaymentRequest object with required fields
    public func refundPayment(_ refundPaymentRequest: RefundPaymentRequest) {
        cloverGo.doRefundTransaction(paymentId: refundPaymentRequest.paymentId, amount: refundPaymentRequest.amount, success: { (response) in
            let refund = CLVModels.Payments.Refund()
            refund.id = response.id
            refund.amount = response.amount
            refund.payment = CLVModels.Payments.Payment()
            refund.payment?.id = response.paymentId
            self.connectorListener?.onRefundPaymentResponse(RefundPaymentResponse(success: true, result: ResultCode.SUCCESS, orderId: refundPaymentRequest.orderId, paymentId: refundPaymentRequest.paymentId, refund: refund))
        }) { (error) in
            let refundResponse = RefundPaymentResponse(success: false, result: ResultCode.FAIL)
            refundResponse.reason = error.code
            refundResponse.message = error.message
            self.connectorListener?.onRefundPaymentResponse(refundResponse)
        }
    }
    
    /// This delegate method is used to perform a closeout
    ///
    /// - Parameter closeoutRequest: Construct CloseoutRequest object with required fields
    public func closeout(_ closeoutRequest: CloseoutRequest) {
        cloverGo.doCloseOutTransaction(success: { (status) in
            self.connectorListener?.onCloseoutResponse(CloseoutResponse(batch: nil, success: true, result: ResultCode.SUCCESS))
        }) { (error) in
            let closeOutResponse = CloseoutResponse(batch: nil, success: false, result: ResultCode.FAIL)
            closeOutResponse.reason = error.code
            closeOutResponse.message = error.message
            self.connectorListener?.onCloseoutResponse(closeOutResponse)
        }
    }
    
    /// This delegate method is called when the card reader is detected and selected from the readers list
    ///
    /// - Parameter readers: List of connected readers
    public func onCardReaderDiscovered(readers: [ReaderInfo]) {
        var discoveredReaders : [CLVModels.Device.GoDeviceInfo] = []
        for r in readers {
            let reader = CLVModels.Device.GoDeviceInfo(type: EnumerationUtil.CardReaderType_toGoReaderType(type: r.readerType))
            reader.name = r.bluetoothName ?? r.readerName
            reader.bluetoothId = r.bluetoothId
            discoveredReaders.append(reader)
        }
        connectorListener?.onDevicesDiscovered(devices: discoveredReaders)
    }
    
    /// This delegate method is called after the card reader is connected
    ///
    /// - Parameter cardReaderInfo: ReaderInfo object contains all the details about the reader
    public func onConnected(cardReaderInfo: ReaderInfo) {
        connectorListener?.onDeviceConnected()
    }
    
    /// This delegate method is called after the card reader is disconnected from the app
    ///
    /// - Parameter cardReaderInfo: ReaderInfo object contains all the details about the reader
    public func onDisconnected(cardReaderInfo: ReaderInfo) {
        connectorListener?.onDeviceDisconnected()
    }
    
    /// This delegate method is called if we get any error with the card reader
    ///
    /// - Parameter event: Gives the details about the event which caused the reader error
    public func onError(event: CardReaderErrorEvent) {
        debugPrint("Error Occured while connecting to Reader")
        connectorListener?.onDeviceError(CloverDeviceErrorEvent(errorType: .EXCEPTION, code: 500, cause: nil, message: event.toString()))
    }
    
    /// This delegate method is called when the card reader is undergoing a reader reset
    ///
    /// - Parameter event: Gives the details about the CardReaderEvent during reader reset process
    public func onReaderResetProgress(event: CardReaderEvent) {
        debugPrint("Reader reset is in progress - \(event.toString())")
    }
    
    /// This delegate method is called when the reader is ready to start a new transaction. Start transaction should be called after this method.
    ///
    /// - Parameter cardReaderInfo: ReaderInfo object contains details about the connected reader
    public func onReady(cardReaderInfo: ReaderInfo) {
        debugPrint("Reader is Ready!")
        deviceReady = true
        let currMerchantInfo = MerchantInfo(id: self.merchantInfo?.merchantId, mid: nil, name: self.merchantInfo?.merchantName, deviceName: cardReaderInfo.bluetoothName ?? cardReaderInfo.readerName, deviceSerialNumber: cardReaderInfo.serialNumber, deviceModel: cardReaderInfo.readerType.toString())
        if let mercInfo = self.merchantInfo {
            currMerchantInfo.supportsAuths = mercInfo.supportsAuths
            currMerchantInfo.supportsVaultCards = mercInfo.supportsVaultCards
            currMerchantInfo.supportsManualRefunds = mercInfo.supportsManualRefunds
            currMerchantInfo.supportsTipAdjust = mercInfo.supportsTipAdjust
            currMerchantInfo.supportsPreAuths = mercInfo.supportsPreAuths
            currMerchantInfo.supportsVoids = mercInfo.supportsVoids
            currMerchantInfo.supportsSales = mercInfo.supportsSales
        } else {
            getMerchantInfo()
            debugPrint("Could not retrieve Merchant properties")
        }
        self.connectorListener?.onDeviceReady(currMerchantInfo)
    }
    
    
    //TODO: Throw exceptions instead of logs
    /*
     * Request receipt options be displayed for a payment.
     */
    public func displayPaymentReceiptOptions( orderId:String, paymentId: String) -> Void {
        debugPrint("Not supported with CloverGo Connector")
    }
    
    
    /*
     * Accept a signature verification request.
     */
    public func  acceptSignature ( _ signatureVerifyRequest:VerifySignatureRequest ) -> Void {
        debugPrint("Not supported with CloverGo Connector")
    }
    
    
    /*
     * Reject a signature verification request.
     */
    public func  rejectSignature ( _ signatureVerifyRequest:VerifySignatureRequest ) -> Void {
        debugPrint("Not supported with CloverGo Connector")
    }
    
    
    /*
     * Request to vault a card.
     */
    public func  vaultCard ( _ vaultCardRequest:VaultCardRequest ) -> Void {
        debugPrint("Not supported with CloverGo Connector")
        connectorListener?.onVaultCardResponse(VaultCardResponse(success: false, result: ResultCode.UNSUPPORTED))
    }
    
    
    /*
     * Request to print some text on the default printer.
     */
    public func  printText ( _ lines:[String] ) -> Void {
        debugPrint("Not supported with CloverGo Connector")
    }
    
    public func printImageFromURL(_ url:String) -> Void {
        debugPrint("Not supported with CloverGo Connector")
    }
    
    
    /*
     * Request that the cash drawer connected to the device be opened.
     */
    public func  openCashDrawer (reason: String) -> Void {
        debugPrint("Not supported with CloverGo Connector")
    }
    
    
    /*
     * Request to place a message on the device screen.
     */
    public func  showMessage ( _ message:String ) -> Void {
        debugPrint("Not supported with CloverGo Connector")
    }
    
    
    /*
     * Request to display the default welcome screen on the device.
     */
    public func  showWelcomeScreen () -> Void {
        debugPrint("Not supported with CloverGo Connector")
    }
    
    
    /*
     * Request to display the default thank you screen on the device.
     */
    public func  showThankYouScreen () -> Void {
        debugPrint("Not supported with CloverGo Connector")
    }
    
    
    /*
     * Request to display an order on the device.
     */
    public func  showDisplayOrder ( _ order:DisplayOrder ) -> Void {
        debugPrint("Not supported with CloverGo Connector")
    }
    
    
    /*
     * Request to display an order on the device.
     */
    public func  removeDisplayOrder ( _ order:DisplayOrder ) -> Void {
        debugPrint("Not supported with CloverGo Connector")
    }
    
    public func invokeInputOption( _ inputOption:InputOption ) -> Void {
        debugPrint("Not supported with CloverGo Connector")
    }
    
    public func readCardData( _ request:ReadCardDataRequest ) -> Void {
        debugPrint("Not supported with CloverGo Connector")
        connectorListener?.onReadCardDataResponse(ReadCardDataResponse(success: false, result: ResultCode.UNSUPPORTED))
    }
    
    public func print(_ request: PrintRequest) {
        debugPrint("Not supported with CloverGo Connector")
    }
    
    public func retrievePrinters(_ request: RetrievePrintersRequest) {
        debugPrint("Not supported with CloverGo Connector")
    }
    
    public func retrievePrintJobStatus(_ request: PrintJobStatusRequest) {
        debugPrint("Not supported with CloverGo Connector")
    }
    
    public func openCashDrawer(_ request: OpenCashDrawerRequest) {
        debugPrint("Not supported with CloverGo Connector")
    }

    
    public func acceptPayment( _ payment:CLVModels.Payments.Payment ) -> Void {
        if (lastTransactionRequest as? SaleRequest) != nil {
            (saleTransactionDelegate as? TransactionDelegateImpl)?.proceedOnErrorDelegate?.proceed(value: true)
        } else if (lastTransactionRequest as? AuthRequest) != nil {
            (authTransactionDelegate as? TransactionDelegateImpl)?.proceedOnErrorDelegate?.proceed(value: true)
        } else if (lastTransactionRequest as? PreAuthRequest) != nil {
            (preAuthTransactionDelegate as? TransactionDelegateImpl)?.proceedOnErrorDelegate?.proceed(value: true)
        }
    }
    
    public func rejectPayment( _ payment:CLVModels.Payments.Payment, challenge:Challenge ) -> Void {
        if (lastTransactionRequest as? SaleRequest) != nil {
            (saleTransactionDelegate as? TransactionDelegateImpl)?.proceedOnErrorDelegate?.proceed(value: false)
        } else if (lastTransactionRequest as? AuthRequest) != nil {
            (authTransactionDelegate as? TransactionDelegateImpl)?.proceedOnErrorDelegate?.proceed(value: false)
        } else if (lastTransactionRequest as? PreAuthRequest) != nil {
            (preAuthTransactionDelegate as? TransactionDelegateImpl)?.proceedOnErrorDelegate?.proceed(value: false)
        }
    }
    
    public func retrievePendingPayments() -> Void {
        debugPrint("Not supported with CloverGo Connector")
        let response = RetrievePendingPaymentsResponse(code: .UNSUPPORTED, message: "Not Supported", payments: nil)
        response.success = false
        connectorListener?.onRetrievePendingPaymentsResponse(response)
    }
    
    public func dispose() -> Void {
        debugPrint("Not supported with CloverGo Connector")
    }
    
    public func startCustomActivity(_ request:CustomActivityRequest) -> Void {
        debugPrint("Not supported with CloverGo Connector")
    }
    /*
     * Request an amount be refunded.
     */
    public func  manualRefund ( _ manualRefundRequest:ManualRefundRequest ) -> Void{
        debugPrint("Not supported with CloverGo Connector")
        connectorListener?.onManualRefundResponse(ManualRefundResponse(success: false, result: ResultCode.UNSUPPORTED))
    }
    
    /// This delegate method is used to select an Aid to proceed with in case of multiple Aid
    ///
    /// - Parameter cardApplicationIdentier: Object of CardApplicationIdentifier containing the Aid
    public func selectCardApplicationIdentifier(cardApplicationIdentier: CLVModels.Payments.CardApplicationIdentifier) {
        if (lastTransactionRequest as? SaleRequest) != nil {
            if let delegate = saleTransactionDelegate as? TransactionDelegateImpl {
                delegate.proceedWithSelectedAid(cardApplicationIdentifier: cardApplicationIdentier)
            }
        } else if (lastTransactionRequest as? AuthRequest) != nil {
            if let delegate = authTransactionDelegate as? TransactionDelegateImpl {
                delegate.proceedWithSelectedAid(cardApplicationIdentifier: cardApplicationIdentier)
            }
        } else if (lastTransactionRequest as? PreAuthRequest) != nil {
            if let delegate = preAuthTransactionDelegate as? TransactionDelegateImpl {
                delegate.proceedWithSelectedAid(cardApplicationIdentifier: cardApplicationIdentier)
            }
        }
    }
    
    private func resetState() {
        self.authTransactionDelegate = nil
        self.preAuthTransactionDelegate = nil
        self.saleTransactionDelegate = nil
        self.lastTransactionRequest = nil
    }
    
    /// This delegate method is used to capture the signature after a payment is made
    ///
    /// - Parameters:
    ///   - payment: Object of Payment containing the payment details
    ///   - signature: Object of Signature
    public func captureSignature(payment: CLVModels.Payments.Payment, signature: Signature) {
        if let paymentId = payment.id {
            var strokesArray :Array<[[Int]]> = []
            if let strokes = signature.strokes {
                for stroke in strokes {
                    if let points = stroke.points {
                        var pointsArray:[[Int]] = []
                        for point in points {
                            if let x = point.x, let y = point.y {
                                pointsArray.append([x,y])
                            }
                        }
                        strokesArray.append(pointsArray)
                    }
                }
            }
            cloverGo.captureSignature(transactionId: paymentId, xy: strokesArray)
        }
    }
    
    public func captureSignature(signature: Signature) {
        var strokesArray :Array<[[Int]]> = []
        if let strokes = signature.strokes {
            for stroke in strokes {
                if let points = stroke.points {
                    var pointsArray:[[Int]] = []
                    for point in points {
                        if let x = point.x, let y = point.y {
                            pointsArray.append([x,y])
                        }
                    }
                    strokesArray.append(pointsArray)
                }
            }
        }
        
        var delegate : TransactionDelegateImpl?
        
        if (lastTransactionRequest as? SaleRequest) != nil {
            delegate = saleTransactionDelegate as? TransactionDelegateImpl
        } else if (lastTransactionRequest as? AuthRequest) != nil {
            delegate = authTransactionDelegate as? TransactionDelegateImpl
        } else if (lastTransactionRequest as? PreAuthRequest) != nil {
            delegate = preAuthTransactionDelegate as? TransactionDelegateImpl
        }
        if let paymentId = delegate?.lastTransactionResult?.transactionId {
            cloverGo.captureSignature(transactionId: paymentId, xy: strokesArray)
            connectorListener?.onSendReceipt()
        }
        
    }
    
    /// This method is called for sending the payment receipt after a successful transaction is done
    ///
    /// - Parameters:
    ///   - payment: Object of Payment containing the payment details
    ///   - email: email id to which the receipt is sent
    ///   - phone: phone no to which the receipt is sent
    public func sendReceipt(email:String?, phone:String?) {
        var delegate : TransactionDelegateImpl?
        
        if (lastTransactionRequest as? SaleRequest) != nil {
            delegate = saleTransactionDelegate as? TransactionDelegateImpl
        } else if (lastTransactionRequest as? AuthRequest) != nil {
            delegate = authTransactionDelegate as? TransactionDelegateImpl
        } else if (lastTransactionRequest as? PreAuthRequest) != nil {
            delegate = preAuthTransactionDelegate as? TransactionDelegateImpl
        }
        if let orderId = delegate?.lastTransactionResult?.orderId {
            cloverGo.sendReceipt(orderId: orderId, email: email, phone: phone)
            delegate?.sendTransactionResponse()
        }
    }
    
    public func printImage(_ image: UIImage) {
        debugPrint("Not supported with CloverGo Connector")
    }
    
    public func retrievePayment(_ _request: RetrievePaymentRequest) {
        debugPrint("Not supported with CloverGo Connector")
    }
    
    public func retrieveDeviceStatus(_ _request: RetrieveDeviceStatusRequest) {
        debugPrint("Not supported with CloverGo Connector")
    }
    
    public func sendMessageToActivity(_ request: MessageToActivity) {
        debugPrint("Not supported with CloverGo Connector")
    }
}

class TransactionDelegateImpl : NSObject, TransactionDelegate {
    
    weak var connectorListener : ICloverGoConnectorListener?
    
    let transactionType : CLVGoTransactionType
    
    var proceedOnErrorDelegate : ProceedOnError?
    var aidSelectionDelegate : AidSelection?
    var aidSelectionList : [CardApplicationIdentifier]?
    
    var lastTransactionResult : TransactionResult?
    
    init(connectorListener: ICloverGoConnectorListener?, transactionType:CLVGoTransactionType) {
        self.connectorListener = connectorListener
        self.transactionType = transactionType
    }
    
    /// This delegate method is called when there is any event with the card reader after the transaction is started
    ///
    /// - Parameter event: Gives the details about the CardReaderEvent during the transaction
    func onProgress(event: CardReaderEvent) {
        if let transactionEvent = EnumerationUtil.CardReaderEvent_toGoReaderTransactionEvent(event: event) {
            self.connectorListener?.onTransactionProgress(event: transactionEvent)
        }
    }
    
    /// This delegate method is called when there is any error from the backend during a transaction
    ///
    /// - Parameter error: CloverGoError containing the error details
    func onError(error: CloverGoError) {
        if transactionType == CLVGoTransactionType.purchase {
            let saleResponse = SaleResponse(success: false, result: ResultCode.FAIL)
            saleResponse.reason = error.code
            saleResponse.message = error.message
            connectorListener?.onSaleResponse(saleResponse)
        } else if transactionType == CLVGoTransactionType.auth {
            let authResponse = AuthResponse(success: false, result: ResultCode.FAIL)
            authResponse.reason = error.code
            authResponse.message = error.message
            connectorListener?.onAuthResponse(authResponse)
        } else if transactionType == CLVGoTransactionType.preauth {
            let preAuthResponse = PreAuthResponse(success: false, result: ResultCode.FAIL)
            preAuthResponse.reason = error.code
            preAuthResponse.message = error.message
            connectorListener?.onPreAuthResponse(preAuthResponse)
        }
    }
    
    /// This delegate method is called upon receiving a response after the transaction is done
    ///
    /// - Parameter transactionResponse: TransactionResult object containing details of the transaction
    func onTransactionResponse(transactionResponse: TransactionResult) {
        self.lastTransactionResult = transactionResponse
        let cvmResult = EnumerationUtil.CvmResult_toEnum(type: transactionResponse.cvmResult ?? "")
        if cvmResult == .SIGNATURE {
            connectorListener?.onSignatureRequired()
        } else {
            connectorListener?.onSendReceipt()
        }
        
    }
    
    func sendTransactionResponse() {
        if let transactionResponse = lastTransactionResult {
            let payment = CLVModels.Payments.Payment()
            payment.id = transactionResponse.transactionId
            payment.amount = transactionResponse.amountCharged
            payment.taxAmount = transactionResponse.taxAmount
            payment.tipAmount = transactionResponse.tipAmount
            payment.externalPaymentId = transactionResponse.externalPaymentId
            
            payment.order = CLVModels.Base.Reference()
            payment.order?.id = transactionResponse.orderId
            
            payment.cardTransaction = CLVModels.Payments.CardTransaction()
            payment.cardTransaction?.authCode = transactionResponse.authCode
            payment.cardTransaction?.type_ = EnumerationUtil.CardTransactionType_toEnum(type: transactionResponse.transactionType ?? "")
            payment.cardTransaction?.cardType = EnumerationUtil.CardType_toEnum(type: transactionResponse.cardType ?? "")
            payment.cardTransaction?.entryType = EnumerationUtil.CardEntryType_toEnum(type: transactionResponse.mode ?? "")
            if let maskedCardNo = transactionResponse.maskedCardNo {
                payment.cardTransaction?.first6 = String(maskedCardNo.prefix(6))
                payment.cardTransaction?.last4 = String(maskedCardNo.suffix(4))
            }
            payment.cardTransaction?.cardholderName = transactionResponse.cardHolderName
            
            if transactionType == CLVGoTransactionType.purchase {
                let response = SaleResponse(success: true, result: ResultCode.SUCCESS)
                payment.result = CLVModels.Payments.Result.SUCCESS
                response.payment = payment
                connectorListener?.onSaleResponse(response)
            } else if transactionType == CLVGoTransactionType.auth {
                let response = AuthResponse(success: true, result: ResultCode.SUCCESS)
                payment.result = CLVModels.Payments.Result.SUCCESS
                response.payment = payment
                connectorListener?.onAuthResponse(response)
            } else if transactionType == CLVGoTransactionType.preauth {
                let response = PreAuthResponse(success: true, result: ResultCode.SUCCESS)
                payment.result = CLVModels.Payments.Result.AUTH
                response.payment = payment
                connectorListener?.onPreAuthResponse(response)
            }
        }
    }
    
    /// This delegate method is called on AVS failure or for duplicate transaction
    ///
    /// - Parameters:
    ///   - event: TransactionEvent object
    ///   - proceedOnErrorDelegate: ProceedOnError delegate
    func proceedOnError(event: TransactionEvent, proceedOnErrorDelegate: ProceedOnError) {
        
        var challenges : [Challenge] = []
        switch event {
        case .duplicate_transaction:
            let challenge = Challenge()
            challenge.message = "Duplicate Transaction"
            challenge.type = ChallengeType.DUPLICATE_CHALLENGE
            challenges.append(challenge)
        case .partial_auth:
            let challenge = Challenge()
            challenge.message = "Transaction Partially Authorized"
            challenge.type = ChallengeType.PARTIAL_AUTH_CHALLENGE
            challenges.append(challenge)
        case .avs_failure:
            let challenge = Challenge()
            challenge.message = "AVS Verification Failed"
            challenge.type = ChallengeType.AVS_FAILURE_CHALLENGE
            challenges.append(challenge)
        default:()
        }
        let confirmPaymentRequest = ConfirmPaymentRequest()
        confirmPaymentRequest.challenges = challenges
        
        let payment = CLVModels.Payments.Payment()
        payment.id = "Pending"
        
        confirmPaymentRequest.payment = payment
        connectorListener?.onConfirmPaymentRequest(confirmPaymentRequest)
        self.proceedOnErrorDelegate = proceedOnErrorDelegate
        
    }
    
    func onAidMatch(cardApplicationIdentifiers: [CardApplicationIdentifier], delegate: AidSelection) {
        self.aidSelectionDelegate = delegate
        self.aidSelectionList = cardApplicationIdentifiers
        var aidList : [CLVModels.Payments.CardApplicationIdentifier] = []
        for caid in cardApplicationIdentifiers {
            let aid = CLVModels.Payments.CardApplicationIdentifier(applicationLabel: caid.applicationLabel, applicationIdentifier: caid.applicationIdentifier)
            aidList.append(aid)
        }
        connectorListener?.onAidMatch(cardApplicationIdentifiers: aidList)
    }
    
    /// This delegate method is used to proceed with a transaction after selecting an Aid
    ///
    /// - Parameter cardApplicationIdentifier: Object of CardApplicationIdentifier containing the Aid 
    func proceedWithSelectedAid(cardApplicationIdentifier:CLVModels.Payments.CardApplicationIdentifier) {
        if (aidSelectionList != nil) {
            for aid in self.aidSelectionList! {
                if aid.applicationIdentifier == cardApplicationIdentifier.applicationIdentifier && aid.applicationLabel == cardApplicationIdentifier.applicationLabel {
                    self.aidSelectionDelegate?.selectApplicationIdentifier(cardApplicationIdentifier: aid)
                }
            }
        }
    }
    
}
