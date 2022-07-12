//
//  VoidPasscodeViewController.swift
//  Jeeves-dev
//
//  Created by CDI on 3/28/22.
//

import UIKit
import CoreData


protocol VoidPasscodeViewControllerDelegate {
    func shouldPopToRootViewController()
}

class VoidPasscodeViewController: UIViewController, UITextFieldDelegate {
    
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var voidPasscodeViewControllerDelegate: VoidPasscodeViewControllerDelegate?
    
    public var pinEntered: [Character] = []
    private var usersEntity = [Users_Entity]()
    
    private var orderID: Int
    
    init(orderID: Int) {
        self.orderID = orderID
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let headerLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = Constants.blackLabelColor
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.text = "Enter your passcode"
        label.textAlignment = .center //.left
        return label
    }()
    
    private let headerLabelForDemo: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = Constants.systemRedColor
        label.font = .systemFont(ofSize: 14, weight: .medium)
        if let userPin = UserDefaults.standard.string(forKey: Constants.user_pin) {
            label.text = "for DEMO purpose only:\n\(userPin)"
        } else {
            label.text = "for DEMO purpose only:\n4412"
        }
        label.textAlignment = .center //.left
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
//        view.backgroundColor = .red
        
        fetchUsers()
        
        
        view.addSubview(passcodeContainer)
        passcodeContainer.addSubview(headerLabel)
        passcodeContainer.addSubview(headerLabelForDemo)
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
        
        print(pin, "?=", cachedSuperUserPin)
        
//        if pin == userPin && pin == String(storedUser.user_pin) && storedUser.user_access_level == "supervisor"  {
        if pin == cachedSuperUserPin && superUserRole == "supervisor" {
            
            /// void order
            print("Voiding order")
            
            APICaller.shared.voidOrder(with: self.orderID) { [weak self] success in
                switch success {
                case true:
                    DispatchQueue.main.async {
                        self?.showAlertWith(title: "Success voiding order ID \(self?.orderID ?? 0)", message: "Go to history", style: .alert, success: true)
                    }
                case false:
                    DispatchQueue.main.async {
                        self?.showAlertWith(title: "Error voiding order ID \(self?.orderID ?? 0)", message: "Dismiss", style: .alert, success: false)
                    }
                }
            }
            
        } else {
            print("Invalid pin!: ", pin)
            
            let alert = UIAlertController(title: "Access Denied!", message: "Error voiding order.", preferredStyle: .alert)
            
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
    
    
    private func showAlertWith(title: String?, message: String?, style: UIAlertController.Style = .alert, success: Bool) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: style)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: { [weak self] action in
            self?.dismiss(animated: true, completion: nil)
            if success {
//                self?.navigationController?.popToRootViewController(animated: true)
                self?.voidPasscodeViewControllerDelegate?.shouldPopToRootViewController()
            }
        }))
        present(alert, animated: true, completion: nil)
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
        
        let headerLabelHeight: CGFloat = 20
        let headerLabelForDemoHeight: CGFloat = 40
        let headerHeight = headerLabelHeight + headerLabelForDemoHeight
        
        let passcodeContainerWidth: CGFloat = 368.0
        let passcodeContainerHeight: CGFloat = 146.0
        
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
            height: headerLabelHeight)
//        headerLabel.backgroundColor = .systemPink
        
        headerLabelForDemo.frame = CGRect(
            x: 10,
            y: headerLabel.bottom,
            width: passcodeContainer.width-20,
            height: headerLabelForDemoHeight)
//        headerLabelForDemo.backgroundColor = .systemGreen
        
        passcodeField1.frame = CGRect(
            x: 10,
            y: headerLabelForDemo.bottom,
            width: codeFieldSize,
            height: passcodeContainer.height-10-headerHeight)
        passcodeField2.frame = CGRect(
            x: passcodeField1.right+pcGapSize,
            y: headerLabelForDemo.bottom,
            width: codeFieldSize,
            height: passcodeContainer.height-10-headerHeight)
        passcodeField3.frame = CGRect(
            x: passcodeField2.right+pcGapSize,
            y: headerLabelForDemo.bottom,
            width: codeFieldSize,
            height: passcodeContainer.height-10-headerHeight)
        passcodeField4.frame = CGRect(
            x: passcodeField3.right+pcGapSize,
            y: headerLabelForDemo.bottom,
            width: codeFieldSize,
            height: passcodeContainer.height-10-headerHeight)
    }
    
    
    public func fetchUsers() {
        do {
            usersEntity = try context.fetch(Users_Entity.fetchRequest())
        } catch {
            print("failed to fetchUsers: \(error.localizedDescription)")
        }
    }
    
    
}
