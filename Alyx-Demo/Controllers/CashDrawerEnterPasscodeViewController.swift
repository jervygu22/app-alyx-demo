//
//  CashDrawerEnterPasscodeViewController.swift
//  Jeeves-dev
//
//  Created by Jervy Umandap on 2/18/22.
//

import UIKit

protocol CashDrawerEnterPasscodeViewControllerDelegate: AnyObject {
    func shouldPopToRootVC()
}

class CashDrawerEnterPasscodeViewController: UIViewController, UITextFieldDelegate {
    
    weak var cashDrawerEnterPasscodeViewControllerDelegate: CashDrawerEnterPasscodeViewControllerDelegate?
    
    private let cashCountBody: CashCountPostModel?
    
    private let createdCashCount: [String: Int]?
    
    
    public var completionHandler: ((Bool) -> Void)?
    public var pinEntered: [Character] = []
    private var users: [User]?
    
    init(users: [User], createdCashCount: [String: Int])  {
        self.users = users
//        self.cashCountBody = cashCountPostModel
        self.createdCashCount = createdCashCount
        self.cashCountBody = nil
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
        label.text = "for DEMO purpose only:\n4412"
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
                
//                DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
//                    self.passcodeField1.text = nil
//                    self.passcodeField2.text = nil
//                    self.passcodeField3.text = nil
//                    self.passcodeField4.text = nil
//
////                    self.passcodeField1.becomeFirstResponder()
//                }
                
            default:
                break
            }
        } else {
            
        }
    }
    
    public func checkValidPinCode(with pin: String) {
        
        guard let users = users,
              let createdCashCount = createdCashCount,
              let superUserID = UserDefaults.standard.string(forKey: Constants.user_id),
              let deviceID = UserDefaults.standard.string(forKey: Constants.generated_device_id),
              let cashierID = UserDefaults.standard.string(forKey: Constants.pin_entered_user_id),
              let shift = UserDefaults.standard.string(forKey: Constants.pin_entered_employee_shift) else {
            print("Data incomplete!")
            return
        }
        
        print("createdCashCount:", createdCashCount)
        print("users:", users)
        
        
        if users.contains(where: { $0.user_pin == pin && $0.user_id == superUserID }) {
            // login successful
            print("Pin verified!: ", pin)
            // post
            
            // get user data
            guard let userPassingCode = users.filter( { $0.user_pin == pin }).first,
                  let intSuperUserID = Int(superUserID),
                  let intUserID = Int(cashierID) else {
                return
            }
            
            let isInitialSent = UserDefaults.standard.bool(forKey: Constants.is_initial_sent)
            
            var grandTotal: Double = 0
            
            
            for bill in createdCashCount {
                if let billAmount = Double(bill.key) {
                    grandTotal += Double(bill.value) * billAmount
                }
            }
            
            let cashCountToPost = CashCountPostModel(
                userid: intUserID,
                superuserid: intSuperUserID,
                deviceid: deviceID,
                initial: isInitialSent ? 0 : 1,
                cashcount: createdCashCount,
                total: grandTotal,
                workdate: Date().workDate(),
                shift: shift)
            
//            cashCountBody.userid = Int(from: userPassingCode.user_id ?? 0)
            
            print("userID: ", userPassingCode.user_emp_id)
            print("cashCountToPost: ", cashCountToPost)
            print("createdCashCount: ", createdCashCount)
            print("superUserID: ", intSuperUserID)
            print("userID: ", intUserID)
            print("deviceID: ", deviceID)
            print("shift: ", shift)
            print("workdate: ", Date().workDate())
            
            
            APICaller.shared.postCashCount(with: cashCountToPost) { [weak self] success in
                switch success {
                case true:
                    print("success")
                    
                    // set if initial cash is sent
                    UserDefaults.standard.setValue(!isInitialSent, forKey: Constants.is_initial_sent)

                    DispatchQueue.main.async {
//                        self?.headerLabel.text = "Success submitting cash count by \(userPassingCode.user_name.capitalized)!"
                        self?.dismiss(animated: false, completion: nil)
                        self?.cashDrawerEnterPasscodeViewControllerDelegate?.shouldPopToRootVC()
                    }

//                    DispatchQueue.main.asyncAfter(deadline: .now()+1.5) {
//                        self?.dismiss(animated: true, completion: nil)
//                        self?.cashDrawerEnterPasscodeViewControllerDelegate?.shouldPopToRootVC()
//                    }

                case false:
                    print("failed to post cashcount")
                    
                    let alert = UIAlertController(title: "Request failed!", message: "No internet connection. Please check your connection and try again.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: {_ in
                        self?.passcodeField1.text = nil
                        self?.passcodeField2.text = nil
                        self?.passcodeField3.text = nil
                        self?.passcodeField4.text = nil
                        self?.passcodeField1.becomeFirstResponder()
                    }))
                    DispatchQueue.main.async {
                        self?.present(alert, animated: true, completion: nil)
                    }
                    
                }
            }
            
            
            do {
                let model = cashCountToPost
                let modelJson = try JSONEncoder().encode(model)
                let modelJsontoString = String(data: modelJson, encoding: .utf8)!
                print("updateCouponsJsontoString: \(modelJsontoString)")
            } catch {
                print("error coding cashCountToPost: \(error.localizedDescription)")
            }
            
        } else {
            print("Invalid pin!: ", pin)
            
            let alert = UIAlertController(title: "Access denied!", message: "Enter a valid pin.", preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: { [weak self] _ in
//                self?.passcodeField1.becomeFirstResponder()
//            }))
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: {_ in
                self.passcodeField1.text = nil
                self.passcodeField2.text = nil
                self.passcodeField3.text = nil
                self.passcodeField4.text = nil
                self.passcodeField1.becomeFirstResponder()
            }))
            DispatchQueue.main.async {
                self.present(alert, animated: true, completion: nil)
            }
        }
        
    }
    
    
//    public func checkValidPinCode(with pin: String) {
//
//        guard let users = users,
//              let createdCashCount = createdCashCount,
//              let superUserID = UserDefaults.standard.string(forKey: "user_id"),
//              let deviceID = UserDefaults.standard.string(forKey: "generated_device_id"),
//              let shift = UserDefaults.standard.string(forKey: "pin_entered_employee_shift") else {
//            print("Data incomplete!")
//            return
//        }
//
//        print("createdCashCount:", createdCashCount)
//        print("users:", users)
//
//
//        if users.contains(where: { $0.user_pin == pin && $0.user_handles_cash == true }) {
//            // login successful
//            print("Pin verified!: ", pin)
//            // post
//
//            // get user data
//            guard let userPassingCode = users.filter( { $0.user_pin == pin }).first,
//                  let intSuperUserID = Int(superUserID),
//                  let intUserID = Int(userPassingCode.user_id) else {
//                return
//            }
//
//            let isInitialSent = UserDefaults.standard.bool(forKey: Constants.is_initial_sent)
//
//            var grandTotal: Double = 0
//
//
//            for bill in createdCashCount {
//                if let billAmount = Double(bill.key) {
//                    grandTotal += Double(bill.value) * billAmount
//                }
//            }
//
//            let cashCountToPost = CashCountPostModel(
//                userid: intUserID,
//                superuserid: intSuperUserID,
//                deviceid: deviceID,
//                initial: isInitialSent ? 0 : 1,
//                cashcount: createdCashCount,
//                total: grandTotal,
//                workdate: Date().workDate(),
//                shift: shift)
//
////            cashCountBody.userid = Int(from: userPassingCode.user_id ?? 0)
//
//            print("userID: ", userPassingCode.user_emp_id)
//            print("cashCountToPost: ", cashCountToPost)
//            print("createdCashCount: ", createdCashCount)
//            print("superUserID: ", intSuperUserID)
//            print("userID: ", intUserID)
//            print("deviceID: ", deviceID)
//            print("shift: ", shift)
//            print("workdate: ", Date().workDate())
//
//
//            APICaller.shared.postCashCount(with: cashCountToPost) { [weak self] success in
//                switch success {
//                case true:
//                    print("success")
//
//                    // set if initial cash is sent
//                    UserDefaults.standard.setValue(!isInitialSent, forKey: Constants.is_initial_sent)
//
//                    DispatchQueue.main.async {
////                        self?.headerLabel.text = "Success submitting cash count by \(userPassingCode.user_name.capitalized)!"
//                        self?.dismiss(animated: false, completion: nil)
//                        self?.cashDrawerEnterPasscodeViewControllerDelegate?.shouldPopToRootVC()
//                    }
//
////                    DispatchQueue.main.asyncAfter(deadline: .now()+1.5) {
////                        self?.dismiss(animated: true, completion: nil)
////                        self?.cashDrawerEnterPasscodeViewControllerDelegate?.shouldPopToRootVC()
////                    }
//
//                case false:
//                    print("failed to post cashcount")
//
//                    let alert = UIAlertController(title: "Request failed!", message: "No internet connection. Please check your connection and try again.", preferredStyle: .alert)
//                    alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: {_ in
//                        self?.passcodeField1.text = nil
//                        self?.passcodeField2.text = nil
//                        self?.passcodeField3.text = nil
//                        self?.passcodeField4.text = nil
//                        self?.passcodeField1.becomeFirstResponder()
//                    }))
//                    DispatchQueue.main.async {
//                        self?.present(alert, animated: true, completion: nil)
//                    }
//
//                }
//            }
//
//
//            do {
//                let model = cashCountToPost
//                let modelJson = try JSONEncoder().encode(model)
//                let modelJsontoString = String(data: modelJson, encoding: .utf8)!
//                print("updateCouponsJsontoString: \(modelJsontoString)")
//            } catch {
//                print("error coding cashCountToPost: \(error.localizedDescription)")
//            }
//
//        } else {
//            print("Invalid pin!: ", pin)
//
//            let alert = UIAlertController(title: "Access denied!", message: "Enter a valid pin.", preferredStyle: .alert)
////            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: { [weak self] _ in
////                self?.passcodeField1.becomeFirstResponder()
////            }))
//            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: {_ in
//                self.passcodeField1.text = nil
//                self.passcodeField2.text = nil
//                self.passcodeField3.text = nil
//                self.passcodeField4.text = nil
//                self.passcodeField1.becomeFirstResponder()
//            }))
//            DispatchQueue.main.async {
//                self.present(alert, animated: true, completion: nil)
//            }
//        }
//
//    }
    
    
    public func showAlertWith(title: String, message: String, style: UIAlertController.Style = .alert, shouldReload: Bool) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: style)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: { (action) in
            self.dismiss(animated: true) {
                if shouldReload {
                    print("shouldReload")
//                    self.configureCashDrawerData()
                }
            }
        }))
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    private func cachePinCodeEntered(with code: String) {
        UserDefaults.standard.setValue(code, forKey: Constants.pin_code_entered)
    }
    
    private func cachePinUsername(with name: String) {
        UserDefaults.standard.setValue(name, forKey: Constants.pin_entered_username)
    }
    
    private func cacheEmployeeShift(with shift: String) {
        UserDefaults.standard.setValue(shift, forKey: Constants.pin_entered_employee_shift)
    }
    
    private func cacheUserImage(with userImage: String) {
        UserDefaults.standard.setValue(userImage, forKey: Constants.pin_entered_user_image)
    }
    
    private func cacheUserRoles(with userRole: [String]) {
        UserDefaults.standard.setValue(userRole, forKey: Constants.pin_entered_user_roles)
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
        
//        let passcodeContainerWidth: CGFloat = 368.0
//        let passcodeContainerHeight: CGFloat = 130.0
//
//        let codeFieldSize = passcodeContainerWidth/5
//        let pcGapSize = (((passcodeContainerWidth/5)-20)/3)
//
//        passcodeContainer.frame = CGRect(
//            x: (view.width-passcodeContainerWidth)/2,
//            y: (view.height-passcodeContainerHeight)/2,
//            width: passcodeContainerWidth,
//            height: passcodeContainerHeight)
//
//        headerLabel.frame = CGRect(
//            x: 10,
//            y: 0,
//            width: passcodeContainer.width-20,
//            height: 44)
//
//        passcodeField1.frame = CGRect(
//            x: 10,
//            y: headerLabel.bottom,
//            width: codeFieldSize,
//            height: passcodeContainer.height-10-headerLabel.height)
//        passcodeField2.frame = CGRect(
//            x: passcodeField1.right+pcGapSize,
//            y: headerLabel.bottom,
//            width: codeFieldSize,
//            height: passcodeContainer.height-10-headerLabel.height)
//        passcodeField3.frame = CGRect(
//            x: passcodeField2.right+pcGapSize,
//            y: headerLabel.bottom,
//            width: codeFieldSize,
//            height: passcodeContainer.height-10-headerLabel.height)
//        passcodeField4.frame = CGRect(
//            x: passcodeField3.right+pcGapSize,
//            y: headerLabel.bottom,
//            width: codeFieldSize,
//            height: passcodeContainer.height-10-headerLabel.height)
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

}
