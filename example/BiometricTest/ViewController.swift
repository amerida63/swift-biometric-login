//
//  ViewController.swift
//  BiometricTest
//
//  Created by Anthony on 2019-05-16.
//  Copyright © 2019 Wams. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var Usertext: UITextField?
    @IBOutlet weak var PasswordText: UITextField?
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


    @IBAction func LoginButThis(_ sender: UIButton) {
        
        let validation = validateFields()
        
        if !validation.0{
            
            validation.2?.becomeFirstResponder()
            return
        }
        
        makeConnection(Usertext!.text!, password: PasswordText!.text!)
    }
    /// Example of Connection
    func makeConnection(_ user: String, password: String){
        
        if user == "test4" && password == "1234"{
              succesLogin()
        }else{
            
            let alert = UIAlertController(title: "Error", message: "User or pass wrong", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)

        }
    }
    
    func validateFields() -> (Bool, String, UITextField?){
        
        if Usertext!.text! == ""
        {
            return (false, "User Empty", Usertext)
        }
        if PasswordText!.text! == ""{
            
            return (false, "Password Empty", PasswordText)
        }
        return (true, "", nil)
    }
    
    func succesLogin(){
        
        
        biometric.checkBiometricLogin(Usertext!.text!, PasswordText!.text!, controller: self) { [weak self](success) in
            
            if !success{
                let alert = UIAlertController(title: "Error", message: "Unable to save the biometric login configuration", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                    
                    self?.performSegue(withIdentifier: "login", sender: nil)
                }))
                
                self?.present(alert, animated: true, completion: nil)
                return
            }
            
            let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "home") as UIViewController
            self?.present(viewController, animated: false, completion: nil)
            
        }
    }
}

extension ViewController : biometricResponse{
    
    func loginWithBiometric(_ error: String?, user: String, pass: String) {
        
        if let error = error {
            
            let alert = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
            return
        }
         makeConnection(user, password: pass)
        
    }
    
}

