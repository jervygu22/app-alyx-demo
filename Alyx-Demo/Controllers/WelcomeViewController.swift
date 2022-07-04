//
//  WelcomeViewController.swift
//  Jeeves-dev
//
//  Created by Jervy Umandap on 2/4/22.
//

import UIKit

class WelcomeViewController: UIViewController, UITextFieldDelegate {
    private var users: [Users] = []
    
    public var completionHandler: ((Bool) -> Void)?
    
    public var pinEntered: [Character] = []
    
    private let signInButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemGreen
        button.setTitle("Sign In with Spotify", for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 16)
        button.layer.cornerRadius = 25.0
        button.layer.masksToBounds = true
        return button
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "albums_background")
        return imageView
    }()
    
    private let logoImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: Constants.app_logo))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let logoLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = Constants.blackLabelColor
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.text = "Alyx"
        label.textAlignment = .center
        return label
    }()
    
    private let signInLbel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = Constants.blackLabelColor
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.text = "Sign In"
        label.textAlignment = .center
        return label
    }()
    
    private let subLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = Constants.secondaryLabelColor
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.text = "Enter your last 4 employee number"
        label.textAlignment = .center
        return label
    }()
    
    private let passcodeContainer: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.layer.masksToBounds = true
        return view
    }()
    
    private let passcodeField1: UITextField = {
        let textField = UITextField()
        textField.textColor = Constants.blackLabelColor
        textField.textAlignment = .center
        textField.borderStyle = .roundedRect
        textField.font = UIFont.systemFont(ofSize: 30, weight: .heavy)
        textField.keyboardType = .numberPad
        
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
        
        textField.isSecureTextEntry = true
        return textField
    }()
    
    private let versionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = Constants.blackLabelColor
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.text = Constants.version
        label.textAlignment = .right
        return label
    }()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        passcodeField1.becomeFirstResponder()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

//        title = "Log in"
        view.backgroundColor = Constants.vcBackgroundColor
        navigationController?.isNavigationBarHidden = true
        
        view.addSubview(imageView)
        view.addSubview(signInButton)
        
        
        view.addSubview(logoImageView)
        view.addSubview(logoLabel)
        view.addSubview(signInLbel)
        view.addSubview(subLabel)
        view.addSubview(versionLabel)
        
        //passcode fields
        view.addSubview(passcodeContainer)
        passcodeContainer.addSubview(passcodeField1)
        passcodeContainer.addSubview(passcodeField2)
        passcodeContainer.addSubview(passcodeField3)
        passcodeContainer.addSubview(passcodeField4)
        
        passcodeField1.delegate = self
        passcodeField2.delegate = self
        passcodeField3.delegate = self
        passcodeField4.delegate = self
        
        passcodeField1.addTarget(self, action: #selector(textfieldDidChange(textfield:)), for: .editingChanged)
        passcodeField2.addTarget(self, action: #selector(textfieldDidChange(textfield:)), for: .editingChanged)
        passcodeField3.addTarget(self, action: #selector(textfieldDidChange(textfield:)), for: .editingChanged)
        passcodeField4.addTarget(self, action: #selector(textfieldDidChange(textfield:)), for: .editingChanged)
        
        let tapAny: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.hideKeyboardByTappingOutside))
        self.view.addGestureRecognizer(tapAny)
        
        fetchData()
    }
    
    private func fetchData() {
        APICaller.shared.getUsers(completion: { [weak self] result in
            switch result {
            case .success(let model):
                self?.users = model.data
            case .failure(let error):
                print(error.localizedDescription)
            }
        })
    }
    
    @objc func hideKeyboardByTappingOutside() {
        self.view.endEditing(true)
    }
    
    @objc private func textfieldDidChange(textfield: UITextField) {
        let text = textfield.text
        
        // if entered 1 pin, next textfield becomeFirstResponder
        if text?.utf8.count == 1 {
            switch textfield {
            case passcodeField1:
                passcodeField2.becomeFirstResponder()
                pinEntered.append(contentsOf: passcodeField1.text!)
                break
            case passcodeField2:
                passcodeField3.becomeFirstResponder()
                pinEntered.append(contentsOf: passcodeField2.text!)
                break
            case passcodeField3:
                passcodeField4.becomeFirstResponder()
                pinEntered.append(contentsOf: passcodeField3.text!)
                break
            case passcodeField4:
                passcodeField4.resignFirstResponder()
                pinEntered.append(contentsOf: passcodeField4.text!)
                
                let pinArrayToString = String(pinEntered)
                print(pinArrayToString)
                
                guard let pin1 = passcodeField1.text, !pin1.isEmpty,
                      let pin2 = passcodeField2.text, !pin2.isEmpty,
                      let pin3 = passcodeField3.text, !pin3.isEmpty else {
                    print("Fill all!")
                    return
                }
                
                // if pincode is valid go to home
                checkValidPinCode(with: pinArrayToString)
                
                // clear pinEntered array and textfields after textfield 4 is filled out
                pinEntered.removeAll()
                DispatchQueue.main.async {
                    self.passcodeField1.text = nil
                    self.passcodeField2.text = nil
                    self.passcodeField3.text = nil
                    self.passcodeField4.text = nil
                }
                self.passcodeField1.becomeFirstResponder()
                
                break
            default:
                break
            }
        } else {
            
        }
    }
    
    public func checkValidPinCode(with pin: String){
        if users.contains(where: { $0.user_pin == pin }) {
            // login successful
            print("Pin verified!")
            cachePinCodeEntered(with: pin)
            goToHome()
        } else {
            print("Invalid pin!")
            
            let alert = UIAlertController(title: "Access denied!", message: "Enter a valid pin.", preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: { [weak self] _ in
//                self?.passcodeField1.becomeFirstResponder()
//            }))
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
            passcodeField1.becomeFirstResponder()
            present(alert, animated: true, completion: nil)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        passcodeField1.sizeToFit()
        passcodeField2.sizeToFit()
        passcodeField3.sizeToFit()
        passcodeField4.sizeToFit()
        versionLabel.sizeToFit()
        
        imageView.frame = view.bounds
        let logoSize: CGFloat = 220
        
//        signInButton.frame = CGRect(
//            x: 30,
//            y: view.height-50-view.safeAreaInsets.bottom-30,
//            width: view.width-60,
//            height: 50)
        
        logoImageView.frame = CGRect(
            x: (view.width-logoSize)/2,
            y: (view.height-logoSize)/4,
            width: logoSize,
            height: logoSize-50)
//        logoImageView.backgroundColor = .systemPink
        
        logoLabel.frame = CGRect(
            x: 30,
            y: logoImageView.bottom+15,
            width: view.width-60,
            height: 50)
//        logoLabel.backgroundColor = .systemRed
        
        signInLbel.frame = CGRect(
            x: 30,
            y: logoLabel.bottom+10,
            width: view.width-60,
            height: 50)
//        signInLbel.backgroundColor = .systemGreen
        
        subLabel.frame = CGRect(
            x: 30,
            y: signInLbel.bottom+10,
            width: view.width-60,
            height: 25)
//        subLabel.backgroundColor = .systemBlue
        
        let passcodeContainerWidth: CGFloat = 368.0
        let passcodeContainerHeight: CGFloat = 100.0
        passcodeContainer.frame = CGRect(
            x: (view.width-passcodeContainerWidth)/2,
            y: subLabel.bottom,
            width: passcodeContainerWidth,
            height: passcodeContainerHeight)
//        passcodeContainer.backgroundColor = .gray
        
        let codeFieldSize = passcodeContainer.width/5
        let pcGapSize = ((passcodeContainer.width/5)/3)
        
        passcodeField1.frame = CGRect(
            x: 0,
            y: (passcodeContainer.height-codeFieldSize)/2,
            width: codeFieldSize,
            height: codeFieldSize)
        passcodeField1.backgroundColor = Constants.whiteLabelColor
        
        passcodeField2.frame = CGRect(
            x: passcodeField1.right+pcGapSize,
            y: (passcodeContainer.height-codeFieldSize)/2,
            width: codeFieldSize,
            height: codeFieldSize)
        passcodeField2.backgroundColor = Constants.whiteLabelColor
        
        passcodeField3.frame = CGRect(
            x: passcodeField2.right+pcGapSize,
            y: (passcodeContainer.height-codeFieldSize)/2,
            width: codeFieldSize,
            height: codeFieldSize)
        passcodeField3.backgroundColor = Constants.whiteLabelColor
        
        passcodeField4.frame = CGRect(
            x: passcodeField3.right+pcGapSize,
            y: (passcodeContainer.height-codeFieldSize)/2,
            width: codeFieldSize,
            height: codeFieldSize)
        passcodeField4.backgroundColor = Constants.whiteLabelColor
        
        versionLabel.frame = CGRect(
            x: 10,
            y: view.height-view.safeAreaInsets.bottom-25,
            width: view.width-20,
            height: 25)
//        versionLabel.backgroundColor = .systemPink
    }
    
    @objc func didEndEnteringPincode() -> Bool {
        if passcodeField4.hasText {
            completionHandler = { [weak self] success in
                DispatchQueue.main.async {
                    self?.handlePinVerification(success: success)
                }
            }
            return true
        } else {
            return false
        }
    }
    
    private func handlePinVerification(success: Bool) {
        // Log user in or show error
        
        guard success else {
            let alert = UIAlertController(title: "Opps", message: "Something went wrong when signing in.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        
        let mainAppViewController = MenuViewController()
        mainAppViewController.modalPresentationStyle = .fullScreen
        present(mainAppViewController, animated: true, completion: nil)
    }
    
    /// for testing only
    private func goToHome() {
        let vc = MenuViewController()
        vc.modalPresentationStyle = .fullScreen
        
        navigationController?.isNavigationBarHidden = false
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func cachePinCodeEntered(with code: String) {
        UserDefaults.standard.setValue(code, forKey: Constants.pin_code_entered)
    }

}
