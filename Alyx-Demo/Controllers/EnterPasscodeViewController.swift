//
//  EnterPasscodeViewController.swift
//  Jeeves-dev
//
//  Created by Jervy Umandap on 2/4/22.
//

import UIKit

protocol EnterPasscodeViewControllerDelegate {
    func dataReceived(data: UserPassingData)
}

struct UserPassingData {
    let userName: String
    let userLogin: String
    let currentTime: String
    let workingTime: String
    
    let userImage: URL?
    let userRole: String
}

class EnterPasscodeViewController: UIViewController, UITextFieldDelegate {
    
    var enterPasscodeViewControllerDelegate: EnterPasscodeViewControllerDelegate?
    var data = ""
    
//    private var users: [Users]?
//    private var selected_InOut: String?
//    private var selected_shift: String?
//    private var selected_timeSched: String?
//    private var currentMonth: Int?
//    private var currentDate: Int?
//    private var currentYear: Int?
//    private var currentHour: Int?
//    private var currentMinute: Int?
    
//    init(users: [Users],
//         selected_InOut: String,
//         selected_shift: String,
//         selected_timeSched: String,
//         currentMonth: Int,
//         currentDate: Int,
//         currentYear: Int,
//         currentHour: Int,
//         currentMinute: Int
//         ) {
//        self.users = users
//        self.selected_InOut = selected_InOut
//        self.selected_shift = selected_shift
//        self.selected_timeSched = selected_timeSched
//        self.currentMonth = currentMonth
//        self.currentDate = currentDate
//        self.currentYear = currentYear
//        self.currentHour = currentHour
//        self.currentMinute = currentMinute
//        super.init(nibName: nil, bundle: nil)
    
    private var users: [Users]?
    private var selected_InOut: String?
    private var selected_shift: String?
    private var workDate: String?
    
    private var unclosedAttandance: [GetAttendanceData]?
    
    init(users: [Users], selected_InOut: String, selected_shift: String, workDate: String, unclosedAttandance: [GetAttendanceData]) {
        self.users = users
        self.selected_InOut = selected_InOut
        self.selected_shift = selected_shift
        self.workDate = workDate
        
        self.unclosedAttandance = unclosedAttandance
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public var completionHandler: ((Bool) -> Void)?
    
    public var pinEntered: [Character] = []
    
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

//    @objc private func textfieldDidChange(textfield: UITextField) {
//        let text = textfield.text
//
//        // if entered 1 pin, next textfield becomeFirstResponder
//        if text?.utf8.count == 1 {
//            switch textfield {
//            case passcodeField1:
//                passcodeField2.becomeFirstResponder()
//                pinEntered.append(contentsOf: passcodeField1.text!)
//            case passcodeField2:
//                passcodeField3.becomeFirstResponder()
//                pinEntered.append(contentsOf: passcodeField2.text!)
//            case passcodeField3:
//                passcodeField4.becomeFirstResponder()
//                pinEntered.append(contentsOf: passcodeField3.text!)
//            case passcodeField4:
//                passcodeField4.resignFirstResponder()
//                pinEntered.append(contentsOf: passcodeField4.text!)
//
//                let pinArrayToString = String(pinEntered)
////                print(pinArrayToString)
//
//                guard let pin1 = passcodeField1.text, !pin1.isEmpty,
//                      let pin2 = passcodeField2.text, !pin2.isEmpty,
//                      let pin3 = passcodeField3.text, !pin3.isEmpty else {
//                    print("Fill all!")
//                    return
//                }
//
//                // if pincode is valid. then post infos
//                checkValidPinCode(with: pinArrayToString)
//
//
//                // clear pinEntered array and textfields after textfield 4 is filled out
//                pinEntered.removeAll()
//
//
////                DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
////                    self.passcodeField1.text = nil
////                    self.passcodeField2.text = nil
////                    self.passcodeField3.text = nil
////                    self.passcodeField4.text = nil
////
//////                    self.passcodeField1.becomeFirstResponder()
////                }
//
//            default:
//                break
//            }
//        } else {
//
//        }
//    }
    
    private func shouldClearStaffCachedData(inOrOut: String) {
        if inOrOut.lowercased() == "out" {
            UserDefaults.standard.setValue(nil, forKey: Constants.pin_code_entered)
            UserDefaults.standard.setValue(nil, forKey: Constants.pin_entered_username)
            UserDefaults.standard.setValue(nil, forKey: Constants.pin_entered_employee_shift)
            UserDefaults.standard.setValue(nil, forKey: Constants.pin_entered_user_image)
            UserDefaults.standard.setValue(nil, forKey: Constants.pin_entered_user_roles)
            UserDefaults.standard.setValue(nil, forKey: Constants.pin_entered_user_id)
            UserDefaults.standard.setValue(nil, forKey: Constants.pin_entered_work_date)
        }
    }
    
    public func checkValidPinCode(with pin: String) {
//        guard let users = users,
//              let selected_InOut = selected_InOut,
//              let selected_shift = selected_shift,
//              let selected_timeSched = selected_timeSched,
//              let currentMonth = currentMonth,
//              let currentDate = currentDate,
//              let currentYear = currentYear,
//              let currentHour = currentHour,
//              let currentMinute = currentMinute else {
//            return
//        }
        print("users: ", users)
        guard let users = users,
              let selected_InOut = selected_InOut,
              let selected_shift = selected_shift,
              let workDate = workDate else {
            print("incomplete data")
            return
        }
        
        
        if users.contains(where: { $0.user_pin == pin }) {
            // login successful
            print("Pin verified!: ", pin)
            
            // post
            
            // get user data
            guard let userPassingCode = users.filter( { $0.user_pin == pin }).first else {
                return
            }
            
            let withUnclosedAttendance = unclosedAttandance?.first(where: { $0.user_id == userPassingCode.user_id && $0.shift == selected_shift })
            let unclosedAttendanceshiftType = withUnclosedAttendance?.shift
            let unclosedAttendanceWorkDate = withUnclosedAttendance?.workdate
            
//            print("Selected Time In/ Out: ", selected_InOut)
//            print("Selected Shift: ", selected_shift)
//            print("Selected start time: ", selected_timeSched) // add to api
//            print("UserID: ", userPassingCode.user_id)
//            print("month: ", currentMonth)
//            print("date: ", currentDate)
//            print("year: ", currentYear)
//            print("hour: ", currentHour)
//            print("minute: ", currentMinute)
            
            print("Selected Time In/ Out: ", selected_InOut)
            print("Selected Shift: ", unclosedAttendanceshiftType ?? selected_shift)
            print("Work date: ", unclosedAttendanceWorkDate ?? workDate) // add to api
            print("UserID: ", userPassingCode.user_id)
            print("UserImage: ", userPassingCode.user_image)
            
            
//            DispatchQueue.main.async {
//                if selected_InOut.lowercased() == "in" {
//                    self.headerLabel.text = "Welcome \(userPassingCode.user_name.capitalized)!"
//                } else {
//                    self.headerLabel.text = "\(userPassingCode.user_name.capitalized) timeout successful."
//                }
//            }
            
            guard let superID = UserDefaults.standard.string(forKey: "user_id"),
                  let deviceID = UserDefaults.standard.string(forKey: "generated_device_id") else { return }
            
            APICaller.shared.postAttendance(
                userId: userPassingCode.user_id,
                superID: superID,
                type: selected_InOut,
                shift: unclosedAttendanceshiftType ?? selected_shift,
                workDate: unclosedAttendanceWorkDate ?? workDate,
                deviceID: deviceID) { [weak self] result in
                    switch result {
                    case .success(let model):
                        if model.success {
                            // go back
                            print("success posting attendance!")

                            // cache pin entered
                            // as cashier!!
                            if selected_InOut.lowercased() == "in" && userPassingCode.user_handles_cash {
                                
                                self?.showAlertToCacheCashier(title: "Time-in as Cashier", message: "Do you want to time-in as cashier?", style: .alert, user: userPassingCode, shift: selected_shift, workDate: workDate)
                                
                            }
                            
                            // pass back the data to account vc using delegate and protocol
                            // staffname, current time, work time
                            // AccountViewController.staffName = userPassingCode.user_login
                            let actualDate = Date()
                            let actualTime = actualDate.current12FHour()
                            let actualDateTime = actualDate.dateTimeDay()

                            self?.enterPasscodeViewControllerDelegate?.dataReceived(
                                data: UserPassingData(
                                    userName: userPassingCode.user_name,
                                    userLogin: userPassingCode.user_login,
                                    currentTime: actualTime,
                                    workingTime: "sample value",
                                    userImage: URL(string: userPassingCode.user_image),
                                    userRole: userPassingCode.user_roles.first ?? ""))

                            // clear user pinentered cached data
                            print("userPassingCode", userPassingCode.user_pin)
                            print("AuthManager.shared.pinCodeEntered", UserDefaults.standard.string(forKey: "pin_code_entered") ?? "nil pinCodeEntered")


                            if userPassingCode.user_pin == UserDefaults.standard.string(forKey: "pin_code_entered") {
                                self?.shouldClearStaffCachedData(inOrOut: selected_InOut)
                                if selected_InOut.lowercased() != "in" {
                                    // remove workdate
                                    UserDefaults.standard.setValue(nil, forKey: Constants.pin_entered_work_date)
                                }
                            }
                            if selected_InOut.lowercased() == "in" {
                                self?.showAlertWith(title: "Time In", message: "Time-in successful! Thankyou \(userPassingCode.user_name) for submitting your attendance\n\(actualDateTime).\nWould you like to go to Menu?", style: .alert)
                            } else {
                                self?.showAlertWith(title: "Time Out", message: "Time-out successful! Thankyou \(userPassingCode.user_name) for submitting your attendance\n\(actualDateTime).\nWould you like to go to Menu?", style: .alert)
                            }
                            
                        } else {
//                            self?.showAlertWith(
//                                title: "Failed to submit attendance",
//                                message: "\(model.message)", style: .alert)
                                
                            let alert = UIAlertController(title: "Failed to submit attendance", message: model.message, preferredStyle: .alert)
                            
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
                        break
                    case .failure(let error):
                        print("postAttendance error: \(error.localizedDescription)")
                        break
                    }
                }
            
            
//            APICaller.shared.postAttendance(
//                userId: userPassingCode.user_id,
//                superID: superID,
//                type: selected_InOut,
//                shift: selected_shift,
//                workDate: workDate,
//                deviceID: deviceID) { [weak self] (success) in
//                if success {
//                    // go back
//                    print("success posting attendance!")
//
//
//                    // cache pin entered
//                    // as cashier!!
//                    if selected_InOut.lowercased() == "in" && userPassingCode.user_handles_cash {
//                        self?.cachePinCodeEntered(with: pin)
//                        self?.cachePinUsername(with: userPassingCode.user_name)
//                        self?.cacheEmployeeShift(with: selected_shift)
//                        self?.cacheUserImage(with: userPassingCode.user_image)
//                        self?.cacheUserRoles(with: userPassingCode.user_roles)
//                        self?.cachePinEnteredUserID(with: userPassingCode.user_id)
//                        // cache workdate
//                        UserDefaults.standard.setValue(workDate, forKey: Constants.pin_entered_work_date)
//                        // store staff credentials
//                        CartViewController.shared.storeUserCredentials(
//                            with: UserCredentials(
//                                user_id: userPassingCode.user_id,
//                                user_name: userPassingCode.user_name,
//                                user_image: userPassingCode.user_image,
//                                user_login: userPassingCode.user_login,
//                                user_email: userPassingCode.user_email,
//                                user_pass: userPassingCode.user_pass,
//                                user_emp_id: userPassingCode.user_emp_id,
//                                user_pin: userPassingCode.user_pin,
//                                user_handles_cash: userPassingCode.user_handles_cash,
//                                user_roles: userPassingCode.user_roles,
//                                user_access_level: "staff"))
//                    }
//
//                    // pass back the data to account vc using delegate and protocol
//                    // staffname, current time, work time
//                    // AccountViewController.staffName = userPassingCode.user_login
//                    let actualDate = Date()
//                    let actualTime = actualDate.current12FHour()
//                    let actualDateTime = actualDate.dateTimeDay()
//
//                    self?.enterPasscodeViewControllerDelegate?.dataReceived(
//                        data: UserPassingData(
//                            userName: userPassingCode.user_name,
//                            userLogin: userPassingCode.user_login,
//                            currentTime: actualTime,
//                            workingTime: "sample value",
//                            userImage: URL(string: userPassingCode.user_image),
//                            userRole: userPassingCode.user_roles.first ?? ""))
//
//                    // clear user pinentered cached data
//                    print("userPassingCode", userPassingCode.user_pin)
//                    print("AuthManager.shared.pinCodeEntered", UserDefaults.standard.string(forKey: "pin_code_entered") ?? "nil pinCodeEntered")
//
//
//                    if userPassingCode.user_pin == UserDefaults.standard.string(forKey: "pin_code_entered") {
//                        self?.shouldClearStaffCachedData(inOrOut: selected_InOut)
//                        if selected_InOut.lowercased() != "in" {
//                            // remove workdate
//                            UserDefaults.standard.setValue(nil, forKey: Constants.pin_entered_work_date)
//                        }
//                    }
//
//
//                    DispatchQueue.main.async {
//                        if selected_InOut.lowercased() == "in" {
//                            self?.showAlertWith(title: "Time In", message: "Time-in successful! Thankyou \(userPassingCode.user_name) for submitting your attendance\n\(actualDateTime).\nWould you like to go to Menu?", style: .alert)
//                        } else {
//                            self?.showAlertWith(title: "Time Out", message: "Time-out successful! Thankyou \(userPassingCode.user_name) for submitting your attendance\n\(actualDateTime).\nWould you like to go to Menu?", style: .alert)
//                        }
//                    }
//                } else {
//                    print("Failed to post attendance")
//                }
//            }
            
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
    
    private func showAlertToCacheCashier(title: String, message: String, style: UIAlertController.Style, user: Users, shift: String, workDate: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { [weak self] _ in
            self?.dismiss(animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { [weak self] _ in
            self?.cachePinCodeEntered(with: user.user_pin)
            self?.cachePinUsername(with: user.user_name)
            self?.cacheEmployeeShift(with: shift)
            self?.cacheUserImage(with: user.user_image)
            self?.cacheUserRoles(with: user.user_roles)
            self?.cachePinEnteredUserID(with: user.user_id)
            // cache workdate
            UserDefaults.standard.setValue(workDate, forKey: Constants.pin_entered_work_date)
            
            // store staff credentials
            CartViewController.shared.storeUserCredentials(
                with: UserCredentials(
                    user_id: user.user_id,
                    user_name: user.user_name,
                    user_image: user.user_image,
                    user_login: user.user_login,
                    user_email: user.user_email,
                    user_pass: user.user_pass,
                    user_emp_id: user.user_emp_id,
                    user_pin: user.user_pin,
                    user_handles_cash: user.user_handles_cash,
                    user_roles: user.user_roles,
                    user_access_level: "staff"))
            
                
                
            // pass back the data to account vc using delegate and protocol
            // staffname, current time, work time
            // AccountViewController.staffName = userPassingCode.user_login
            let actualDate = Date()
            let actualTime = actualDate.current12FHour()
            let actualDateTime = actualDate.dateTimeDay()
            
            self?.enterPasscodeViewControllerDelegate?.dataReceived(
                data: UserPassingData(
                    userName: user.user_name,
                    userLogin: user.user_login,
                    currentTime: actualTime,
                    workingTime: "sample value",
                    userImage: URL(string: user.user_image),
                    userRole: user.user_roles.first ?? ""))
            
            // clear user pinentered cached data
            print("userPassingCode", user.user_pin)
            print("AuthManager.shared.pinCodeEntered", UserDefaults.standard.string(forKey: "pin_code_entered") ?? "nil pinCodeEntered")
            
            self?.showAlertWith(title: "Time In", message: "Time-in successful! Thankyou \(user.user_name) for submitting your attendance\n\(actualDateTime).\nWould you like to go to Menu?", style: .alert)
        }))
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    private func showAlertWith(title: String, message: String, style: UIAlertController.Style = .alert) {
        
//        let alert = UIAlertController(title: "Time In", message: "Time-in successful! Thankyou for submitting your attendance. Please go to Menu.", preferredStyle: style)
        let alert = UIAlertController(title: title, message: message, preferredStyle: style)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
            self.dismiss(animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {_ in
            let nav = self.presentingViewController?.children.first as? MenuViewController
            nav?.didSelectDrawerItem(at: 0, menuItem: .menu)
            nav?.refetchCatsProducts()
            self.dismiss(animated: true, completion: nil)
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
    
    private func cachePinEnteredUserID(with userID: String) {
        UserDefaults.standard.setValue(userID, forKey: Constants.pin_entered_user_id)
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
