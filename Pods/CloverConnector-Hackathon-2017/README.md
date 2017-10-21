# Clover Universal SDK 
## Overview
The Clover Universal iOS SDK enables your custom mobile point-of-sale (POS) to accept card present transactions by connecting to EMV compliant Clover Go Card Readers.

Clover Go supports two types of card readers a magnetic stripe, EMV chip-and-signature card reader and an all-in-one card reader that supports Swipe, EMV Dip, and NFC Contactless payments. The SDK is designed to allow merchants to take payments on iPhone smartphones and iPad tablets.  

Integrating with the Universal SDK enables merchants to take advantage of the Clover platform’s low credit card processing fees, as well as all of the other services Clover provides.


# Getting Started for Hackathon Developers
## System Requirements
* XCode 9 and above 
* iOS 9.2 and above
* Clover Go Contactless Card Reader provided during registration
* Credit Card provided during registration or any personal live credit card

## XCode iOS Project Setup
add pod 'CloverConnector-Hackathon-2017', '~> 0.0.2' in your PODFILE in target

For example -

platform :ios, '9.0'

use_frameworks!

target 'CloverConnector_Example' do

pod 'CloverConnector-Hackathon-2017', '~> 0.0.2'

end

## Initial Steps

### Leveraging Clover Universal SDK within your application
#### 1. In your ```AppDelegate.swift``` file declare the following...
``` import CloverConnector_Hackathon_2017
    public var cloverConnector:ICloverGoConnector?
    public var cloverConnectorListener:CloverGoConnectorListener?
```
#### 2. Create ```CloverGoConnectorListener.swift``` inherit from ```ICloverGoConnectorListener```
```
    import CloverConnector_Hackathon_2017
    weak var cloverConnector:ICloverGoConnector?

    public init(cloverConnector:ICloverGoConnector){
        self.cloverConnector = cloverConnector;
    }
```
  Below are the methods which will be useful to add in this class
  Implement all ``` CardReaderDelegate ``` methods in here...

* ``` func onDevicesDiscovered(devices: [CLVModels.Device.GoDeviceInfo]) ``` - This delegate method is called when the card reader is detected and selected from the readers list
* ``` func onDeviceReady(merchantInfo: MerchantInfo) ``` - called when the device is ready to communicate
* ``` func  onDeviceConnected () -> Void ``` - called when the device is initially connected
* ``` func  onDeviceDisconnected () -> Void ``` - called when the device is disconnected, or not responding
* ``` func onDeviceError( _ deviceErrorEvent: CloverDeviceErrorEvent ) -> Void ``` – called when there is error connecting to reader

Implement all ``` TransactionDelegate ``` methods in here...
* ``` func onTransactionProgress(event: CLVModels.Payments.GoTransactionEvent) -> Void ``` - called when there is any event with the card reader after the transaction is started

Parameter event: Gives the details about the CardReaderEvent during the transaction
```
switch event
        {
        case .EMV_CARD_INSERTED,.CARD_SWIPED,.CARD_TAPPED:
            break
        case .EMV_CARD_REMOVED:
            break
        case .EMV_CARD_DIP_FAILED:
            break
        case .EMV_CARD_SWIPED_ERROR:
            break
        case .EMV_DIP_FAILED_PROCEED_WITH_SWIPE:
            break
        case .SWIPE_FAILED:
            break
        case .CONTACTLESS_FAILED_TRY_AGAIN:
            break
        case .SWIPE_DIP_OR_TAP_CARD:
            break
        default:
            break;
        }
```
* ``` func onSaleResponse(response: SaleResponse)``` – called at the completion of a sale request with either a payment or a cancel state

* ``` func onAuthResponse(response: AuthResponse) ``` – called at the completion of an auth request with either a payment or a cancel state

* sale - collect a final sale payment
* auth - collect a payment that can be tip adjusted

**Note**: Rest of the methods of ``` ICloverConnectorListener ``` class you have to add here but can be left blank like ``` onRetrieveDeviceStatusResponse, onMessageFromActivity, ``` etc.

#### 3. SDK Initialization with 450 Reader

The following parameters are required for SDK initialization
* apiKey - Provided to developers during registration
* secret - Provided to developers during registration
* accessToken - Provided to developers during registration
* allowDuplicateTransaction - set to true for hackathon purpose
* allowAutoConnect - set to true for hackathon purpose
```
func connectToCloverGoReader() {
        let config : CloverGoDeviceConfiguration = CloverGoDeviceConfiguration.Builder(apiKey: "", secret: "", env:   .live).accessToken(accessToken: "").deviceType(deviceType: .RP450).allowDuplicateTransaction(allowDuplicateTransaction: true).allowAutoConnect(allowAutoConnect: true).build()
        
        cloverConnector = CloverGoConnector(config: config)
        
        cloverConnectorListener = CloverGoConnectorListener(cloverConnector: cloverConnector!)
        cloverConnectorListener?.viewController = self.window?.rootViewController
        (cloverConnector as? CloverGoConnector)?.addCloverGoConnectorListener(cloverConnectorListener:         (cloverConnectorListener as? ICloverGoConnectorListener)!)
        cloverConnector!.initializeConnection()   
    }
```

#### 4. Execute a Sale Transaction
Required parameters for sale transaction:
1.	amount – which will be total amount you want to make a transaction
2.	externalId: random unique number for this transaction

Other Optional Parameters can be ignored for the hackathon
```
@IBAction func doSaleTransaction(sender: AnyObject) {
        let totalInInt = Int(totalAmount * 100) --  amount should be in cents
        let saleReq = SaleRequest(amount:totalInInt, externalId:"\(arc4random())") – pass total amount in cents and random external Id
        (UIApplication.sharedApplication().delegate as! AppDelegate).cloverConnector?.sale(saleReq) – make sale request
    }
```

#### 4. Execute a Auth Transaction
Required parameters for auth transaction:
1.	amount – which will be total amount you want to make a transaction
2.	externalId: random unique number for this transaction

Other Optional Parameters can be ignored for the hackathon
``` 
@IBAction func doAuthTransaction(sender: AnyObject) {
        let totalInInt = Int(totalAmount * 100) --  amount should be in cents
        let authReq = AuthRequest(amount:totalInInt, externalId:"\(arc4random())") – pass total amount in cents and random external Id
        (UIApplication.sharedApplication().delegate as! AppDelegate).cloverConnector?.auth(authReq) – make auth request
    }
```
#### 5. Handling Duplicate and AVS Transaction Error

``` public func onConfirmPaymentRequest(_ request: ConfirmPaymentRequest) ``` -- called if the device needs confirmation of a payment (duplicate verification)

Example Code to Handle Duplicate Transactions:
If there is a duplicate transaction returned there will be a pop up to user whether to proceed or not (i.e with 2 options “Accept” or “Reject”)
* Accept -  ``` strongSelf.cloverConnector?.acceptPayment(payment) ```
* Reject – ``` strongSelf.cloverConnector?.rejectPayment(payment) ```

``` 
public func onConfirmPaymentRequest(_ request: ConfirmPaymentRequest) {
        if let payment = request.payment,
            let challenges = request.challenges {
            confirmPaymentRequest(payment: payment, challenges: challenges)
        } else {
            showMessage("No payment in request..")
        }
    }  

  func confirmPaymentRequest(payment:CLVModels.Payments.Payment, challenges: [Challenge]) {
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            if challenges.count == 0 {
                print("accepting")
                strongSelf.cloverConnector?.acceptPayment(payment)
            } else {
                print("showing verify payment message")
                var challenges = challenges
                let challenge = challenges.removeFirst()
                var alertActions = [UIAlertAction]()
                alertActions.append(UIAlertAction(title: "Accept", style: .default, handler: { [weak self] action in
                    guard let strongSelf = self else { return }
                    strongSelf.confirmPaymentRequest(payment: payment, challenges: challenges)
                }))
                alertActions.append(UIAlertAction(title: "Reject", style: .cancel, handler: { [weak self] action in
                    guard let strongSelf = self else { return }
                    strongSelf.cloverConnector?.rejectPayment(payment, challenge: challenge)
                }))
                strongSelf.showMessageWithOptions(title: "Verify Payment", message: challenge.message ?? "", alertActions: alertActions)
            }
        }
    }
```

