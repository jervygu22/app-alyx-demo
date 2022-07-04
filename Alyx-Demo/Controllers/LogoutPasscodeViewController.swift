//
//  LogoutPasscodeViewController.swift
//  Jeeves-dev
//
//  Created by Jervy Umandap on 2/4/22.
//

import UIKit
import CoreData

class LogoutPasscodeViewController: UIViewController, UITextFieldDelegate {
    
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    public var pinEntered: [Character] = []
    private var usersEntity = [Users_Entity]()
    
    private let headerLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = Constants.blackLabelColor
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.text = "Enter your passcode"
        label.textAlignment = .left
        return label
    }()
    
    private let passcodeContainer: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 5.0
        view.backgroundColor = Constants.whiteBackgroundColor
        return view
    }()
    
    private let passcodeField1: UITextField = {
        let textField = UITextField()
        textField.textColor = Constants.blackLabelColor
        textField.textAlignment = .center
        textField.borderStyle = .roundedRect
        textField.font = UIFont.systemFont(ofSize: 30, weight: .heavy)
        textField.keyboardType = .numberPad
        textField.backgroundColor = Constants.passcodeBackGroundColor
        
        textField.isSecureTextEntry = true
        return textField
    }()
    
    private let passcodeField2: UITextField = {
        let textField = UITextField()
        textField.textColor = Constants.blackLabelColor
        textField.textAlignment = .center
        textField.borderStyle = .roundedRect
        textField.font = UIFont.systemFont(ofSize: 30, weight: .heavy)
        textField.keyboardType = .numberPad
        textField.backgroundColor = Constants.passcodeBackGroundColor
        
        textField.isSecureTextEntry = true
        return textField
    }()
    
    private let passcodeField3: UITextField = {
        let textField = UITextField()
        textField.textColor = Constants.blackLabelColor
        textField.textAlignment = .center
        textField.borderStyle = .roundedRect
        textField.font = UIFont.systemFont(ofSize: 30, weight: .heavy)
        textField.keyboardType = .numberPad
        textField.backgroundColor = Constants.passcodeBackGroundColor
        
        textField.isSecureTextEntry = true
        return textField
    }()
    
    private let passcodeField4: UITextField = {
        let textField = UITextField()
        textField.textColor = Constants.blackLabelColor
        textField.textAlignment = .center
        textField.borderStyle = .roundedRect
        textField.font = UIFont.systemFont(ofSize: 30, weight: .heavy)
        textField.keyboardType = .numberPad
        textField.backgroundColor = Constants.passcodeBackGroundColor
        
        textField.isSecureTextEntry = true
        return textField
    }()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        passcodeField1.becomeFirstResponder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(white: 0, alpha: 0.5)
        
        fetchUsers()
        
        
        view.addSubview(passcodeContainer)
        passcodeContainer.addSubview(headerLabel)
        passcodeContainer.addSubview(passcodeField1)
        passcodeContainer.addSubview(passcodeField2)
        passcodeContainer.addSubview(passcodeField3)
        passcodeContainer.addSubview(passcodeField4)
        
        passcodeField1.delegate = self
        passcodeField2.delegate = self
        passcodeField3.delegate = self
        passcodeField4.delegate = self
        
//        passcodeField1.addTarget(self, action: #selector(textfieldDidChange(textfield:)), for: .editingChanged)
//        passcodeField2.addTarget(self, action: #selector(textfieldDidChange(textfield:)), for: .editingChanged)
//        passcodeField3.addTarget(self, action: #selector(textfieldDidChange(textfield:)), for: .editingChanged)
//        passcodeField4.addTarget(self, action: #selector(textfieldDidChange(textfield:)), for: .editingChanged)
        
        let tapOut = UITapGestureRecognizer(target: self, action: #selector(didTapOutSide))
        self.view.addGestureRecognizer(tapOut)
    }
    
    @objc func didTapOutSide() {
        print("did tap outside")
        dismiss(animated: true, completion: nil)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if ((textField.text?.count)! < 1 ) && (string.count > 0) {
            if textField == passcodeField1 {
                pinEntered.append(contentsOf: string)
                passcodeField2.becomeFirstResponder()
            }
            
            if textField == passcodeField2 {
                pinEntered.append(contentsOf: string)
                passcodeField3.becomeFirstResponder()
            }
            
            if textField == passcodeField3 {
                pinEntered.append(contentsOf: string)
                passcodeField4.becomeFirstResponder()
            }
            
            if textField == passcodeField4 {
                pinEntered.append(contentsOf: string)
                passcodeField4.resignFirstResponder()
                
                let pinArrayToString = String(pinEntered)
                print("pinArrayToString: \(pinArrayToString)")
                
                guard let pin1 = passcodeField1.text, !pin1.isEmpty,
                      let pin2 = passcodeField2.text, !pin2.isEmpty,
                      let pin3 = passcodeField3.text, !pin3.isEmpty else {
                    print("Fill all!")
                    return true
                }
                
                // if pincode is valid. then post infos
                checkValidPinCode(with: pinArrayToString)
                
                
                // clear pinEntered array and textfields after textfield 4 is filled out
                pinEntered.removeAll()
                
            }
            
            print("pinEntered: \(pinEntered)")
            
            textField.text = string
            return false
        } else if ((textField.text?.count)! >= 1) && (string.count == 0) {
            if textField == passcodeField4 {
                pinEntered.removeLast()
                passcodeField3.becomeFirstResponder()
            }
            if textField == passcodeField3 {
                pinEntered.removeLast()
                passcodeField2.becomeFirstResponder()
            }
            if textField == passcodeField2 {
                pinEntered.removeLast()
                passcodeField1.becomeFirstResponder()
            }
            if textField == passcodeField1 {
                pinEntered.removeLast()
                passcodeField1.resignFirstResponder()
            }
            if pinEntered.isEmpty {
                dismiss(animated: true)
            }
            
            
            print("pinEntered: \(pinEntered)")
            
            textField.text = ""
            return false
        } else if (textField.text?.count)! >= 1 {
            textField.text = string
            return false
        }
        
        return true
    }
    
    @objc private func textfieldDidChange(textfield: UITextField) {
        let text = textfield.text
        
        // if entered 1 pin, next textfield becomeFirstResponder
        if text?.utf8.count == 1 {
            switch textfield {
            case passcodeField1:
                passcodeField2.becomeFirstResponder()
                pinEntered.append(contentsOf: passcodeField1.text!)
            case passcodeField2:
                passcodeField3.becomeFirstResponder()
                pinEntered.append(contentsOf: passcodeField2.text!)
            case passcodeField3:
                passcodeField4.becomeFirstResponder()
                pinEntered.append(contentsOf: passcodeField3.text!)
            case passcodeField4:
                passcodeField4.resignFirstResponder()
                pinEntered.append(contentsOf: passcodeField4.text!)
                
                let pinArrayToString = String(pinEntered)
                //                print(pinArrayToString)
                
                guard let pin1 = passcodeField1.text, !pin1.isEmpty,
                      let pin2 = passcodeField2.text, !pin2.isEmpty,
                      let pin3 = passcodeField3.text, !pin3.isEmpty else {
                    print("Fill all!")
                    return
                }
                
                // if pincode is valid. then post infos
                checkValidPinCode(with: pinArrayToString)
                
                // clear pinEntered array and textfields after textfield 4 is filled out
                pinEntered.removeAll()
            
            default:
                break
            }
        } else {
            
        }
    }
    
    public func checkValidPinCode(with pin: String) {
        print("logging out")
        
        guard let cachedSuperUserPin = UserDefaults.standard.string(forKey: "user_pin"),
              let cachedSuperUserRoles = UserDefaults.standard.stringArray(forKey: "user_role"),
              let superUserRole = cachedSuperUserRoles.first(where: { $0 == "supervisor" })
        else { return }
        
        guard let storedUser = usersEntity.filter({ $0.user_pin ==  Int64(pin)}).first else {
            print("error logging out: checkValidPinCode")
            showAlert(title: "", message: "Error logging out, enter your correct pin.", style: .alert)
            return
        }
        
        print(pin, "?=", cachedSuperUserPin)
        
//        if pin == userPin && pin == String(storedUser.user_pin) && storedUser.user_access_level == "supervisor"  {
        if pin == cachedSuperUserPin && superUserRole == "supervisor" {
            
            // signout, clear cached credentials
            CartViewController.shared.fetchUsers()
            CartViewController.shared.shouldDeleteStoredUser(users: [storedUser])
            clearStoredInCart()
            clearStoredUsers()
            
//            UserDefaults.standard.setValue(nil, forKey: Constants.access_token)
            UserDefaults.standard.setValue(nil, forKey: Constants.user_id)
            UserDefaults.standard.setValue(nil, forKey: Constants.user_name)
            UserDefaults.standard.setValue(nil, forKey: Constants.user_email)
            UserDefaults.standard.setValue(nil, forKey: Constants.user_pin)
            UserDefaults.standard.setValue(nil, forKey: Constants.is_user_handle_cash)
            UserDefaults.standard.setValue(nil, forKey: Constants.user_role)
            UserDefaults.standard.setValue(nil, forKey: Constants.user_emp_id)
            
            // should clear cached cashier
            UserDefaults.standard.setValue(nil, forKey: Constants.pin_code_entered)
            UserDefaults.standard.setValue(nil, forKey: Constants.pin_entered_username)
            UserDefaults.standard.setValue(nil, forKey: Constants.pin_entered_user_id)
            UserDefaults.standard.setValue(nil, forKey: Constants.pin_entered_user_image)
            UserDefaults.standard.setValue(nil, forKey: Constants.pin_entered_user_roles)
            UserDefaults.standard.setValue(nil, forKey: Constants.pin_entered_employee_shift)
            UserDefaults.standard.setValue(nil, forKey: Constants.pin_entered_work_date)
            
            UserDefaults.standard.setValue(nil, forKey: Constants.is_initial_sent)
            

            let navVC = UINavigationController(rootViewController: UserLoginViewController(deviceID: AuthManager.shared.cachedDeviceID))
            navVC.navigationBar.prefersLargeTitles = false
            navVC.viewControllers.first?.navigationItem.largeTitleDisplayMode = .never
            navVC.modalPresentationStyle = .fullScreen
            navVC.setNavigationBarHidden(true, animated: true)
            
            self.present(navVC, animated: true, completion: {
                self.navigationController?.popToRootViewController(animated: false)
            })
            
            /// after logging out dim display and follow it with this snippet
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
//                UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                    exit(0)
//                }
//            }

        } else {
            print("Invalid pin!: ", pin)
            
            let alert = UIAlertController(title: "", message: "Error logging out, enter your correct pin.", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: {_ in
                self.passcodeField1.text = nil
                self.passcodeField2.text = nil
                self.passcodeField3.text = nil
                self.passcodeField4.text = nil
                self.passcodeField1.becomeFirstResponder()
            }))
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    private func showAlert(title: String, message: String, style: UIAlertController.Style) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: style)
        
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: { (action) in
            self.passcodeField1.text = nil
            self.passcodeField2.text = nil
            self.passcodeField3.text = nil
            self.passcodeField4.text = nil
            self.passcodeField1.becomeFirstResponder()
//            self.dismiss(animated: true, completion: nil)
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let passcodeContainerWidth: CGFloat = 368.0
        let passcodeContainerHeight: CGFloat = 130.0
        
        let codeFieldSize = passcodeContainerWidth/5
        let pcGapSize = (((passcodeContainerWidth/5)-20)/3)
        
        passcodeContainer.frame = CGRect(
            x: (view.width-passcodeContainerWidth)/2,
            y: (view.height-passcodeContainerHeight)/2,
            width: passcodeContainerWidth,
            height: passcodeContainerHeight)
        
        headerLabel.frame = CGRect(
            x: 10,
            y: 0,
            width: passcodeContainer.width-20,
            height: 44)
        
        passcodeField1.frame = CGRect(
            x: 10,
            y: headerLabel.bottom,
            width: codeFieldSize,
            height: passcodeContainer.height-10-headerLabel.height)
        passcodeField2.frame = CGRect(
            x: passcodeField1.right+pcGapSize,
            y: headerLabel.bottom,
            width: codeFieldSize,
            height: passcodeContainer.height-10-headerLabel.height)
        passcodeField3.frame = CGRect(
            x: passcodeField2.right+pcGapSize,
            y: headerLabel.bottom,
            width: codeFieldSize,
            height: passcodeContainer.height-10-headerLabel.height)
        passcodeField4.frame = CGRect(
            x: passcodeField3.right+pcGapSize,
            y: headerLabel.bottom,
            width: codeFieldSize,
            height: passcodeContainer.height-10-headerLabel.height)
    }
    
    
    public func fetchUsers() {
        do {
            usersEntity = try context.fetch(Users_Entity.fetchRequest())
        } catch {
            print("failed to fetchUsers: \(error.localizedDescription)")
        }
    }
    
    private func clearStoredInCart() {
        do {
            let cartEntity = try context.fetch(Cart_Entity.fetchRequest())
            let cartAdded = cartEntity.filter({ $0.cart_status == "added" })
            
            for item in cartAdded {
                context.delete(item)
            }
            
            try context.save()
        } catch {
            print("clearCart failed: ", error.localizedDescription)
        }
    }
    
    private func clearStoredUsers() {
        do {
            let usersEntity = try context.fetch(Users_Entity.fetchRequest())
            
            for user in usersEntity {
                context.delete(user)
            }
            
            try context.save()
        } catch {
            print("clearStoredUsersCart failed: ", error.localizedDescription)
        }
    }
    
    
}
