//
//  DomainViewController.swift
//  Jeeves-dev
//
//  Created by Jervy Umandap on 2/4/22.
//

import UIKit

class DomainViewController: UIViewController {
    
    static let shared = DomainViewController()
    
//    private let cachedToken = AuthManager.shared.accessToken
    
    private var createdUniqueID: String?
//    private var postDevice: PostDeviceIDResponse?
//    private var devices: [GetDeviceData] = []
    private var thisDeviceExist: Bool = false
    
    private var authResponse: AuthResponse?
    
//    private var franchisees: [Franchisee] = []
    
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
    
    public var cachedDeviceID: String? = {
        return UserDefaults.standard.string(forKey: "generated_device_id")
    }()
    
    public var isHaveCachedDeviceID: Bool {
        return cachedDeviceID != nil
    }
    
    private let welcomeLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = Constants.blackLabelColor
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.text = "Welcome to Alyx"
        label.textAlignment = .center
        return label
    }()
    
    private let subLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = Constants.secondaryLabelColor
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.text = "Enter Domain"
        label.textAlignment = .center
        return label
    }()
    
    private let alertMessageLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = Constants.secondaryLabelColor
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.text = "You have entered invalid domain, please enter again."
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()
    
    private let domainTextField: UITextField = {
        let textField = UITextField(frame: .zero)
        textField.textAlignment = .left
        textField.borderStyle = .roundedRect
        textField.font = UIFont.systemFont(ofSize: 16, weight: .regular)
//        textField.placeholder = "Your domain"
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.backgroundColor = Constants.vcBackgroundColor
        textField.textColor = Constants.blackLabelColor
        
        textField.attributedPlaceholder = NSAttributedString(
            string: "Your domain",
            attributes: [NSAttributedString.Key.foregroundColor : Constants.lightGrayColor])
        
        return textField
    }()
    
    private let verifyDomainButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = Constants.blackBackgroundColor
        button.setTitle("Verify Domain", for: .normal)
        button.setTitleColor(Constants.whiteLabelColor, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 16)
        button.layer.cornerRadius = 5.0
        button.layer.masksToBounds = true
        return button
    }()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        domainTextField.becomeFirstResponder()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = Constants.vcBackgroundColor
        navigationController?.isNavigationBarHidden = true
        
        fetchData()
        
        view.addSubview(logoImageView)
        view.addSubview(container)
        container.addSubview(welcomeLabel)
        container.addSubview(subLabel)
        container.addSubview(domainTextField)
        container.addSubview(verifyDomainButton)
        
        verifyDomainButton.addTarget(self, action: #selector(didTapVerifyDomain), for: .touchUpInside)
        
        let tapAny = UITapGestureRecognizer(target: self, action: #selector(didTapAny))
        view.addGestureRecognizer(tapAny)
        
        // test code
        domainTextField.text = "demofranchise" // "alyx.codedisruptors.com/demofranchise" // "new-franchisee" //"alyx-staging.codedisruptors.com/new-franchisee"
        
//        print("cachedToken:", cachedToken ?? "No cached token")
        
        print("createdUniqueID: ", createdUniqueID ?? "No createdUniqueID")
        print("cachedDeviceID: ", cachedDeviceID ?? "No cached deviceID")
    }
    
    
    
    @objc func didTapVerifyDomain() {
        // verify domain
        
        guard let domain = domainTextField.text, !domain.isEmpty else {
            print("Enter domain!")
            let alert = UIAlertController(title: "You have'nt entered a domain", message: "Please enter your domain.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        
        getAccessToken(with: domain)
        
//        if franchisees.contains(where: { $0.domain == domain}) {
//            cacheDomainName(with: domain)
//            print("Domain verified!")
//            // present user login vc
//            // let vc = UserLoginViewController()
//            // vc.modalPresentationStyle = .fullScreen
//            // present(vc, animated: true, completion: nil)
//
//            if isHaveCachedDeviceID {
//                guard let cachedDeviceID = cachedDeviceID else { return }
//                print("have cached device id!", cachedDeviceID)
//
//                // id fetched device contains cacheddeviceID
//                if devices.contains(where: { $0.device_id == cachedDeviceID }) {
//                    print("devices contains: ", cachedDeviceID, " true")
//
//                    let filteredDevices = devices.filter({ $0.device_id == cachedDeviceID })
//                    let device = filteredDevices.first
//
//                    guard let safeDevice = device else { return }
//
//                    // if device is authorized - go to check device Y4LQFZCVU6EKG3EI US0G6ICB2RDA
//                    print("device is authorized!: \(safeDevice.device_id)", safeDevice.device_id_status)
//
//                    let vc = CheckDeviceViewController(with: cachedDeviceID)
//                    vc.modalPresentationStyle = .fullScreen
//                    present(vc, animated: false, completion: nil)
//
//                } else {
//                    print("devices contains: ", cachedDeviceID, " false")
//                    APICaller.shared.postDevice(with: cachedDeviceID) { result in
//                        switch result {
//                        case .success(let model):
//                            self.postDevice = model
//                        case .failure(let error):
//                            print("postDevice: ",error.localizedDescription)
//                        }
//                    }
//
//
//                    let vc = CheckDeviceViewController(with: cachedDeviceID)
//                    vc.modalPresentationStyle = .fullScreen
//                    present(vc, animated: false, completion: nil)
//                }
//
//            } else {
//                print("dont have cached device id!")
//                cacheGeneratedDeviceID(with: createdUniqueID)
//                print(createdUniqueID)
//
//                APICaller.shared.postDevice(with: createdUniqueID) { result in
//                    switch result {
//                    case .success(let model):
//                        self.postDevice = model
//                    case .failure(let error):
//                        print("postDevice: ",error.localizedDescription)
//                    }
//                }
//
//                let vc = CheckDeviceViewController(with: createdUniqueID)
//                vc.modalPresentationStyle = .fullScreen
//                present(vc, animated: false, completion: nil)
//            }
//
//        } else {
//            // api call fetch franchisees / devices
//            fetchData()
//            print("Invalid domain!")
//
//            view.layoutIfNeeded()
//            viewWillAppear(true)
//
//            print(franchisees.count)
////            print(AuthManager.shared.accessToken ?? "nil")
//
////            let alert = UIAlertController(title: "Opps", message: "Invalid domain, please enter again", preferredStyle: .alert)
////            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
////            present(alert, animated: trume, completion: nil)
//
//            createAlertLabel(with: "Invalid domain. Please check and try again.")
////            return
//        }
    }
    
    private func createRandomString(length: Int) -> String {
        // EB7481EA-5D35-4B48-AE5B-1D13130DB6C6 - myiPhone7 - 32 characters
        // F2MVRVYDJCL6 - 12 characters serial#
        
        let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789" // abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789
        
//        let first = String((0..<8).map{ _ in letters.randomElement()! })
//        let second = String((0..<4).map{ _ in letters.randomElement()! })
//        let third = String((0..<4).map{ _ in letters.randomElement()! })
//        let fourth = String((0..<4).map{ _ in letters.randomElement()! })
//        let last = String((0..<12).map{ _ in letters.randomElement()! })
//        let combination = "\(first)-\(second)-\(third)-\(fourth)-\(last)"
//        return combination // 19RJ3NSC-DDYI-UP1N-64WP-JS0CNGR97NBV
        
        let generatedString = String((0..<length).map{ _ in letters.randomElement()! })
        
        if !isHaveCachedDeviceID {
//            cacheGeneratedDeviceID(with: generatedString)
        }
        return generatedString
    }
    
    public func cacheGeneratedDeviceID(with generatedID: String) {
        UserDefaults.standard.setValue(generatedID, forKey: "generated_device_id")
    }
    
    
    @objc func didTapVerify() {
        fetchData()
        guard let domainName = domainTextField.text, !domainName.isEmpty else { return }
//        fetchDataWithDomain(with: domainName)
    }
    
    @objc func didTapAny() {
        domainTextField.resignFirstResponder()
    }
    
    private func fetchData() {
//        franchisees.removeAll()
//        devices.removeAll()
        
//        APICaller.shared.getAllFranchisees { [weak self] result in
//            switch result {
//            case .success(let model):
//                self?.franchisees = model.data
//            case .failure(let error):
//                print(error.localizedDescription)
//            }
//        }
        
//        APICaller.shared.getDevices { [weak self] result in
//            switch result {
//            case .success(let model):
//                self?.devices = model.data
//            case .failure(let error):
//                print(error.localizedDescription)
//            }
//        }
    }
    
    private func checkIfDeviceIDExist(with deviceID: String) -> Bool {
//        guard let devices = devices else { return false }
        
//        if devices.contains(where: { $0.device_id == deviceID}) {
//            let filteredDevice = devices.first(where: { $0.device_id == deviceID })
//
//            print("filteredDevice: ", filteredDevice?.device_id ?? "No device id found")
//
//            thisDeviceExist = true
//            return true
//        } else {
//            thisDeviceExist = false
//            return false
//        }
        return false
    }
    
    
    private func getAccessToken(with domainName: String) {

        APICaller.shared.getTokenWithDomain(with: domainName) { [weak self] result in
            
            guard let strongSelf = self else { return }
            let deviceID = strongSelf.cachedDeviceID ?? strongSelf.createRandomString(length: 12)
                
            print("cachedDeviceID: ", strongSelf.cachedDeviceID ?? "no cachedDeviceID")
            print("createdUniqueID: ", strongSelf.createdUniqueID ?? "no createdUniqueID")
            print("isHaveCachedDeviceID: ", strongSelf.isHaveCachedDeviceID)
                        
            switch result {
            case .success(let model):
                self?.authResponse = model
                
                if !model.token.isEmpty {
                    print("token: ", model.token)
                    print("isHaveCachedDeviceID: ", strongSelf.isHaveCachedDeviceID)
                    
                    strongSelf.cacheDomainName(with: domainName)
                    
                    if strongSelf.isHaveCachedDeviceID {
                        print("have cached device id!", deviceID)
                        DispatchQueue.main.async {
//                            let vc = CheckDeviceViewController(with: deviceID)
                            let vc = CheckDeviceViewController()
                            vc.modalPresentationStyle = .fullScreen
                            self?.present(vc, animated: false, completion: nil)
                        }
                    } else {
                        print("new created deviceId: ", deviceID)
                        DispatchQueue.main.async {
//                            let vc = CheckDeviceViewController(with: deviceID)
                            let vc = CheckDeviceViewController()
                            vc.modalPresentationStyle = .fullScreen
                            self?.present(vc, animated: false, completion: nil)
                        }
                    }
                }
                break
            case .failure(let error):
                print("verifyDomain Error: ", error.localizedDescription)
                DispatchQueue.main.async {
//                    self?.createAlertLabel(with: "\(error.localizedDescription)")
                    self?.createAlertLabel(with: "Invalid Domain, please check your franchise name")
                }
                break
            }
        }
    }
    
    private func handleSignIn(success: Bool) {
        // Log user in or show error
    }
    
    public func cacheDomainName(with domainName: String) {
        UserDefaults.standard.setValue(domainName, forKey: Constants.domain_name)
    }
    
    private func createAlertLabel(with title: String) {
        let alertLabel = UILabel()
        alertLabel.text = title
        alertLabel.numberOfLines = 0
        alertLabel.textColor = Constants.systemRedColor
        alertLabel.font = .systemFont(ofSize: 12, weight: .light)
        alertLabel.textAlignment = .center
        
        view.addSubview(alertLabel)
        
        alertLabel.frame = CGRect(x: 20, y: container.bottom+5, width: view.width-40, height: 44)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let containerHeight: CGFloat = 200.0
        let textField_ButtonHeight: CGFloat = 44.0
        
        container.frame = CGRect(
            x: 20,
            y: (view.height-containerHeight)/2,
            width: view.width-40,
            height: containerHeight)
//        container.backgroundColor = .systemTeal
        
        let subViewsHeight = (container.height-(textField_ButtonHeight*2)-20)/2
        
        welcomeLabel.frame = CGRect(
            x: 0,
            y: 0,
            width: container.width,
            height: subViewsHeight)
//        welcomeLabel.backgroundColor = .systemPink
        
        subLabel.frame = CGRect(
            x: 0,
            y: welcomeLabel.bottom+10,
            width: container.width,
            height: subViewsHeight)
//        subLabel.backgroundColor = .green
        
        domainTextField.frame = CGRect(
            x: 0,
            y: subLabel.bottom,
            width: container.width,
            height: textField_ButtonHeight)
//        domainTextField.backgroundColor = .gray
        
        verifyDomainButton.frame = CGRect(
            x: 0,
            y: domainTextField.bottom+10,
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
