SwiftBiometricLogin
-----------

## iOS Biometric Local Authentication using Swift
Project that allows the easy implementation of the session start with touch ID in iOS.
- Written with Swift
- Customizable

## Installation
Download and implement TouchIDClass in your Project. 

## Usage
```swift
class ViewController: UIViewController {

  /// the button to enter via touch id will be hidden by default, until the user has set up an account. 

    @IBOutlet weak var touchIDButton: UIButton!
    @IBOutlet weak var LabelTouch: UILabel!
    
    let biometric = BiometricClass()

    override func viewWillAppear(_ animated: Bool) {
        
        biometric.activeButtons(touchIDButton, labelTitle: LabelTouch)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        biometric.imageToFaceID = UIImage(named: "FaceIcon") ?? UIImage.init()
        biometric.imageToTouchID = UIImage(named: "Touch-icon-lg") ?? UIImage.init()
        biometric.configure(touchIDButton, labelTitle: LabelTouch)
        biometric.delegate = self
        
        // Do any additional setup after loading the view.
    }
}
/// Implement Delegate
extension ViewController : biometricResponse{
    
    func loginWithBiometric(_ error: String?, user: String, pass: String) {
        
       // Check if everything was correct, to get the credentials to use
    }
}
```
## Usage without Buttons
```swift
class ViewController: UIViewController {

 	let biometric = BiometricClass()

   override func viewDidLoad() {
        super.viewDidLoad()
        
        biometric.configure(nil, labelTitle: nil)
        biometric.delegate = self
	// Do any additional setup after loading the view.
    }

    func loginWithTouch(){

	/// Call this method when you want to try to login
	biometric.login(nil)
    }
}
/// Implement Delegate
extension ViewController : biometricResponse{
    
    func loginWithBiometric(_ error: String?, user: String, pass: String) {
        
       // Check if everything was correct, to get the credentials to use
         
    }
}
```
/// This method must be used when the user has successfully logged in. It allows saving or modifying the previously saved user

## Save Credential
```swift

///When your connection is finished, store the user variable and password used by the user momentarily, and save as or modify the existing one as touch ID credential

func successLogin(){

	 biometric.checkBiometricLogin('UserTosave', 'PasstoSave', controller: 	self)	{ [weak self](success) in }
	 // Check if everything was correct, to save or editing credential and continue to next screen
}
```
Customization
-----------

#### Variables:

You can change the text of the alerts in these cases:

| var | value |
| ------ | ------ |
| editCredentialTitleText | "Can you change your credentials of" |
| saveCredentialTitleText | "Next time, would you like log in faster with" |
| messageAlert | "log in fast, easy and secure" |


_**Note:** The variables to edit and save are always completed with the login method to be used.

#### Example:

```
"Can you change your credentials of TouchID" or "Next time, would you like log in faster with FaceID"
```

License
---------
MIT License.<br/>
© 2019, Anthony Merida.

Credits
----------

Razeware LLC 
Created and maintained by Anthony Merida, © 2019.<br/>


