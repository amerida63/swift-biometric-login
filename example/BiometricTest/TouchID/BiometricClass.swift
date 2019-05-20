///
///  Created by Anthony Merida on 2019-05-16.
///  Copyright © 2019 wamsmobile.com.
///
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import Foundation
import UIKit

struct KeychainConfiguration {
    static let serviceName = "https://my.leaderboard.io"
    static let accessGroup: String? = nil
    static let userDefault = "userBiometrickey"
}

protocol biometricResponse {

    func loginWithBiometric(_ error : String?, user : String, pass: String)
}

enum typeActionsKeychange{
    case delete
    case save
    case read
    
}
class BiometricClass {
    
    private var userSaved : String?{
        get{
            let value =  UserDefaults.standard.string(forKey: KeychainConfiguration.userDefault)
            return value
        }
        set{
            if newValue != nil && newValue != ""{
            UserDefaults.standard.set(newValue, forKey: KeychainConfiguration.userDefault)
            }
        }
    }
    
   private let touchMe = BiometricIDAuth()
    
    
    var localizedFallbackTitle : String? = nil
    
    /// IF this var is tru, the app use passCode to autenticate
    var onlyBiometricAutenticate : Bool = false
    
    var imageToTouchID : UIImage = .init()
    var imageToFaceID : UIImage = .init()
    var editCredentialTitleText : String = "Can you change your credentials of"
    var saveCredentialTitleText : String = "Next time, would you like log in faster with"
    var messageAlert: String = "log in fast, easy and secure"
    var delegate:biometricResponse?
    var buttonTouch : UIButton?
    var labelTitles: UILabel?
    
    private var isLoginwithTouch : Bool = false
    private var type : BiometricType = .none
    
  private var activeTouchID : Bool = false
    
    
    func configure(_ buttontouch: UIButton, labelTitle: UILabel){
        
        buttonTouch = buttontouch
        labelTitles = labelTitle
        
        buttontouch.isHidden = true
        labelTitle.isHidden = true
        
        type = touchMe.biometricType()
        
        touchMe.context.localizedFallbackTitle = localizedFallbackTitle
       
        switch type {
        case .none:
            break;
        default:
            
            activeTouchID = true
               
            if userSaved == nil{
                break
            }
            
            buttontouch.isHidden = false
            buttontouch.setImage(type == .faceID ? imageToFaceID : imageToTouchID,  for: .normal)
            buttontouch.addTarget(self, action: #selector(login(_:)), for: .touchUpInside)
            labelTitle.isHidden = false
            labelTitle.text = type == .faceID ? "Use FaceID" : "Use TouchID"
            break;
        }
    }
    
    func activeButtons(_ buttontouch: UIButton, labelTitle: UILabel){
        
        if !activeTouchID || userSaved == nil {
            
            return
        }
        
         buttontouch.isHidden = false
         labelTitle.isHidden = false
         buttontouch.addTarget(self, action: #selector(login(_:)), for: .touchUpInside)

    }
    
    @objc private  func login(_ sender: UIButton){
        
        if !onlyBiometricAutenticate{
            
            loginWithPassCode()
            return
        }
        loginBiometric()
        return
    }
    
    private  func loginBiometric(){
        
        self.touchMe.authenticateUserPass() { [weak self] message in
        self?.checkResultFromAuthenticator(message)
        }
    
    }
    
    private func  loginWithPassCode(){
    
        self.touchMe.authenticateUserPass { [weak self](message) in
         
            self?.checkResultFromAuthenticator(message)
        }
    }
    
    private func checkResultFromAuthenticator(_ message : String?){
    
        if let message = message {
    
                if message == "You pressed cancel."{
                    
                    return
                }
    
            self.delegate?.loginWithBiometric(message, user: "", pass: "")
            return
        }
        
        self.checkTouchIDCredential()
    }
    
   private func checkTouchIDCredential(){
        
        guard activeTouchID, let user = userSaved else{
            
            delegate?.loginWithBiometric("the login data could not be verified", user: "", pass: "")
            return
        }
        
        isLoginwithTouch = true
        
        let loginData = serviceBiometric(account: user, password: "", action: .read)
        
        guard let pass = loginData.password else{
            
            delegate?.loginWithBiometric("the login data could not be verified", user: "", pass: "")
            return
        }
        
        delegate?.loginWithBiometric(nil, user: user, pass: pass)
       
    }
    
    func checkBiometricLogin(_ username: String, _ password: String, controller : UIViewController, then: @escaping (_ succes: Bool)->()){
        
        guard activeTouchID else{
            
            then(false)
            return
        }
        
        if isLoginwithTouch || userSaved == username{
            
            then(true)
            return
        }
        
        var edit = false
        
        if let user = userSaved{
            
             edit = user != username ? true : false

        }
        
        isLoginwithTouch = false
        
        
        
        let typeText = type == .faceID ? " Face ID" : " Touch ID"
        let alertTitle = edit ? editCredentialTitleText + "\(typeText)" : saveCredentialTitleText + "\(typeText)"
        
        let alert = UIAlertController(title: alertTitle, message: messageAlert, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            
            var deleted = false
            
            if edit{
                
                guard let user = self.userSaved else{
                    
                    then(false)
                    return
                }
                
                 deleted = self.serviceBiometric(account: user, password: password, action: typeActionsKeychange.delete).succes
            }
            
            if edit && !deleted{
                
                then(false)
                return
            }
            
            let save = self.serviceBiometric(account: username, password: password, action: typeActionsKeychange.save).succes
            
            if save{
                
                self.userSaved = username
                then(true)
                return
            }
            
            then(false)
            return
            
        }))
        
        alert.addAction(UIAlertAction(title: "Later", style: .cancel, handler: { action in
            
            then(true)
        }))
        
        controller.present(alert, animated: true, completion: nil)
        
    }

    private func serviceBiometric(account: String, password: String, action:typeActionsKeychange) -> (succes: Bool, password: String?){
        
        guard account != "" else{ return (false, nil) }
        do {
            
            let passwordItem = KeychainPasswordItem(service: KeychainConfiguration.serviceName,
                                                    account: account,
                                                    accessGroup: KeychainConfiguration.accessGroup)
            
            var keychainPassword : String? = nil
            
            switch action {
            case .delete:
                try passwordItem.deleteItem()
            case .read:
                  keychainPassword = try passwordItem.readPassword()
            case .save:
                try passwordItem.savePassword(password)
            }
            
            return (true, keychainPassword)
        }
        catch {
            return (false, nil)
            //fatalError("Error reading password from keychain - \(error)")
        }
        
    }
    
}
