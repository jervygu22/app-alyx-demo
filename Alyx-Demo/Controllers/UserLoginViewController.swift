//
//  UserLoginViewController.swift
//  Jeeves-dev
//
//  Created by Jervy Umandap on 2/4/22.
//

import UIKit
import CoreData

// MARK: - Users
struct UserCredentials: Codable {
    let user_id: String
    let user_name: String
    let user_image: String
    let user_login: String
    let user_email: String
    let user_pass: String
    let user_emp_id: String
    let user_pin: String
    let user_handles_cash: Bool
    let user_roles: [String]
    let user_access_level: String
    
//    "user_id": "42",
//    "user_name": "Armando Santos",
//    "user_image": "https://secure.gravatar.com/avatar/365182863336d84e697e2c52a834bd31?s=96&d=mm&r=g",
//    "user_login": "newfranchisestaff1",
//    "user_email": "nf1@mail.com",
//    "user_pass": "12345aA!",
//    "user_emp_id": "",
//    "user_pin": "4422",
//    "user_handles_cash": false,
//    "user_roles": [
//        "staff"
//    ]
}

class UserLoginViewController: UIViewController {
    
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    private var usersEntity = [Users_Entity]()
    private var users: [Users] = []
    
    private var usersCredential: UserCredentials?
    
    private var passedDeviceID: String
    
    
    init(deviceID: String?) {
        self.passedDeviceID = deviceID ?? "-"
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: Constants.app_logo)
        imageView.contentMode = .scaleAspectFit
        imageView.layer.masksToBounds = true
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let container: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.layer.masksToBounds = true
        return view
    }()
    
    private let uLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = Constants.blackLabelColor
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.text = "User Login"
        label.textAlignment = .center
        return label
    }()
    
    private let subLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = Constants.lightGrayColor
        label.font = .systemFont(ofSize: 16, weight: .regular) // UIFont.systemFont(ofSize: 16, weight: .regular)
        label.text = "Login with Supervisor Account"
        label.textAlignment = .center
        return label
    }()
    
    private let usernameTextField: UITextField = {
        let textField = UITextField(frame: .zero)
        textField.textAlignment = .left
        textField.borderStyle = .roundedRect
        textField.font = UIFont.systemFont(ofSize: 16, weight: .regular)
//        textField.placeholder = "Username"
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.backgroundColor = Constants.whiteBackgroundColor
        textField.textColor = Constants.blackLabelColor
        
        textField.attributedPlaceholder = NSAttributedString(
            string: "Username",
            attributes: [NSAttributedString.Key.foregroundColor : Constants.lightGrayColor])
        
        return textField
    }()
    
    private let passwordField: UITextField = {
        let textField = UITextField(frame: .zero)
        textField.textColor = Constants.blackLabelColor
        textField.textAlignment = .left
        textField.borderStyle = .roundedRect
        textField.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        textField.placeholder = "Password"
        textField.isSecureTextEntry = true
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.backgroundColor = Constants.whiteBackgroundColor
        
        textField.attributedPlaceholder = NSAttributedString(
            string: "Password",
            attributes: [NSAttributedString.Key.foregroundColor : Constants.lightGrayColor])
        
        return textField
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = Constants.blackBackgroundColor
        button.setTitle("Login", for: .normal)
        button.setTitleColor(Constants.whiteLabelColor, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 16)
        button.layer.cornerRadius = 5.0
        button.layer.masksToBounds = true
        return button
    }()
    
    private let alertLabel = UILabel()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        usernameTextField.becomeFirstResponder()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Constants.vcBackgroundColor
        navigationController?.isNavigationBarHidden = true
        
        fetchData()
        
        view.addSubview(logoImageView)
        view.addSubview(container)
        container.addSubview(uLabel)
        container.addSubview(subLabel)
        container.addSubview(usernameTextField)
        container.addSubview(passwordField)
        container.addSubview(loginButton)
        
        loginButton.addTarget(self, action: #selector(didTapLogin), for: .touchUpInside)
        
        let tapAny: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboardByTappingOutside))
        view.addGestureRecognizer(tapAny)
        
        // test code
        usernameTextField.text = "demosupervisor1" // "newfranchisesupervisor1"
        passwordField.text = "DF0024412" // "4411" // "12345aA!"
    }
    
    
    @objc func hideKeyboardByTappingOutside() {
        print("hideKeyboardByTappingOutside")
        view.endEditing(true)
    }
    
    private func fetchToken2(domain: String, deviceID: String) {
        APICaller.shared.getTokenWithDomainAndDeviceID(with: domain, with: deviceID) { result in
            switch result {
            case .success(let model):
                print("Success caching token2: \(model.token)")
                break
            case .failure(let error):
                print("fetchToken2: \(error.localizedDescription)")
                break
            }
        }
    }
    
    @objc func didTapLogin() {
        // safe textfields
        guard let username = usernameTextField.text, !username.isEmpty,
              let password = passwordField.text, !password.isEmpty else {
            print("Enter un and pw!")
            
            let alert = UIAlertController(title: "You have'nt entered a username or password", message: "Please fill out textfields.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
            
            return
        }
        
        // check if user exist
        
        print("users: \(users)")
        
        if users.contains(where: { $0.user_login == username && $0.user_pass == password }) {
            print("Succesfully signed in!")
            
            
            // get user data
            guard let userLoggingIn = users.filter( { $0.user_login == username && $0.user_pass == password  }).first,
                  let domain = UserDefaults.standard.string(forKey: "domain_name")
            else {
                return
            }
            
            if userLoggingIn.user_roles.contains("supervisor") {
                
                // fetch and cache token2
                self.fetchToken2(domain: domain, deviceID: passedDeviceID)
                
                handleCredentials(with: UserCredentials(
                                    user_id: userLoggingIn.user_id,
                                    user_name: userLoggingIn.user_name,
                                    user_image: userLoggingIn.user_image,
                                    user_login: userLoggingIn.user_login,
                                    user_email: userLoggingIn.user_email,
                                    user_pass: userLoggingIn.user_pass,
                                    user_emp_id: userLoggingIn.user_emp_id,
                                    user_pin: userLoggingIn.user_pin,
                                    user_handles_cash: userLoggingIn.user_handles_cash,
                                    user_roles: userLoggingIn.user_roles,
                                    user_access_level: "supervisor"))
                
                let vc = MenuViewController()
                let navVC = UINavigationController(rootViewController: vc)
                
                navVC.navigationBar.prefersLargeTitles = false
                navVC.viewControllers.first?.navigationItem.largeTitleDisplayMode = .never
                navVC.modalPresentationStyle = .fullScreen
                navVC.setNavigationBarHidden(false, animated: false)
                
                present(navVC, animated: true, completion: { [weak self] in
                    
                    guard let usersCredential = self?.usersCredential else {
                        print("empty userCredential")
                        return
                    }
                    
                    self?.cacheUserCredentials(with: usersCredential)
                    self?.storeUserCredentials(with: usersCredential)
                    
                    self?.navigationController?.popToRootViewController(animated: false)
                })
                
            } else {
                print("Access Denied!")
                createAlertLabel(with: "Access denied!")
                
                let alert = UIAlertController(title: "Unauthorized", message: "Only Supervisor can access login.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
                DispatchQueue.main.async {
                    self.present(alert, animated: true, completion: nil)
                }
            }
            
            
        } else {
            print("Invalid User!")
            createAlertLabel(with: "Access denied, please enter your correct username & password.")
        }
    }
    
    private func fetchData() {
        APICaller.shared.getAllUsers { [weak self] result in
            switch result {
            case .success(let model):
                self?.users = model.data
                break
            case .failure(let error):
                print(error.localizedDescription)
                break
            }
        }
    }
    
    
    private func createAlertLabel(with title: String) {
        alertLabel.text = title
        alertLabel.numberOfLines = 0
        alertLabel.textColor = Constants.systemRedColor
        alertLabel.font = .systemFont(ofSize: 12, weight: .light)
        alertLabel.textAlignment = .center
        
        view.addSubview(alertLabel)
        
        alertLabel.frame = CGRect(x: 20, y: container.bottom+5, width: view.width-40, height: 44)
    }
    
    private func handleCredentials(with model: UserCredentials){
        usersCredential = model
    }
    
    public func cacheUserCredentials(with user: UserCredentials) {
        
        UserDefaults.standard.setValue(user.user_id, forKey: Constants.user_id)
        UserDefaults.standard.setValue(user.user_login, forKey: Constants.user_name)
        UserDefaults.standard.setValue(user.user_email, forKey: Constants.user_email)
        UserDefaults.standard.setValue(user.user_pin, forKey: Constants.user_pin)
        UserDefaults.standard.setValue(user.user_handles_cash, forKey: Constants.is_user_handle_cash)
        UserDefaults.standard.setValue(user.user_roles, forKey: Constants.user_role)
        UserDefaults.standard.setValue(user.user_emp_id, forKey: Constants.user_emp_id)
        
    }
    
    private func storeUserCredentials(with user: UserCredentials) {
        CartViewController.shared.fetchUsers()
        CartViewController.shared.storeUserCredentials(with: user)
        
    }
    
    
    
//    public func storeUserCredentials(with user: UserCredentials, storedUsers: [Users_Entity]) {
//
//        let storedFilteredUsers = storedUsers.filter({ String($0.user_id) == user.user_id })
//        print("storedFilteredUsers: \(storedFilteredUsers)")
////        shouldDeleteStoredUser(users: storedFilteredUsers)
//
//        let userEntity = Users_Entity(context: context)
//
//        userEntity.user_id = Int64(user.user_id) ?? 0
//        userEntity.user_name = user.user_name
//        userEntity.user_image = user.user_image
//        userEntity.user_login = user.user_login
//        userEntity.user_email = user.user_email
//        userEntity.user_pass = user.user_pass
//        userEntity.user_emp_id = user.user_emp_id
//        userEntity.user_pin = Int64(user.user_pin) ?? 0
//        userEntity.user_handles_cash = user.user_handles_cash
//
//        userEntity.user_roles = user.user_roles
//        userEntity.user_access_level = user.user_access_level
//        print("Success stored userEntity: \(userEntity)")
//
//
//        do {
//            try context.save()
//        } catch {
//            // error
//        }
//    }
    
//    public func fetchUsers() {
//        do {
//            usersEntity = try context.fetch(Users_Entity.fetchRequest())
//        } catch {
//            print("failed to fetchUsers: \(error.localizedDescription)")
//        }
//    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let containerHeight: CGFloat = 244.0
        let textField_ButtonHeight: CGFloat = 44.0
        
        container.frame = CGRect(
            x: 20,
            y: (view.height-containerHeight)/2,
            width: view.width-40,
            height: containerHeight)
//        container.backgroundColor = .systemTeal
        
        let labelHeight = container.height-(textField_ButtonHeight*4)-30
        
        uLabel.frame = CGRect(
            x: 0,
            y: 0,
            width: container.width,
            height: labelHeight)
//        welcomeLabel.backgroundColor = .systemPink
        
        subLabel.frame = CGRect(
            x: 0,
            y: uLabel.bottom,
            width: container.width,
            height: labelHeight)
//        welcomeLabel.backgroundColor = .systemPink
        
        usernameTextField.frame = CGRect(
            x: 0,
            y: subLabel.bottom+10,
            width: container.width,
            height: textField_ButtonHeight)
//        subLabel.backgroundColor = .green
        
        passwordField.frame = CGRect(
            x: 0,
            y: usernameTextField.bottom+10,
            width: container.width,
            height: textField_ButtonHeight)
//        domainTextField.backgroundColor = .gray
        
        loginButton.frame = CGRect(
            x: 0,
            y: passwordField.bottom+10,
            width: container.width,
            height: textField_ButtonHeight)
        
        let logoImageViewSize: CGFloat = 150
        logoImageView.frame = CGRect(
            x: (view.width-logoImageViewSize)/2,
            y: container.top-logoImageViewSize,
            width: logoImageViewSize,
            height: logoImageViewSize)
//        logoImageView.backgroundColor = .red
    }
}
