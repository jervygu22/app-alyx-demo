//
//  CheckDeviceViewController.swift
//  Jeeves-dev
//
//  Created by Jervy Umandap on 2/4/22.
//

import UIKit

class CheckDeviceViewController: UIViewController {
    
    private var cachedToken = UserDefaults.standard.string(forKey: "access_token") // AuthManager.shared.accessToken
    
//    private let createdDeviceID: String
    private var createdDeviceID: String = ""
    
    
    private var postDevice: PostDeviceIDResponse?
    private var registeredDevices: [GetDeviceData]?
    
//    init(with generatedID: String) {
//        self.createdDeviceID = generatedID
//        super.init(nibName: nil, bundle: nil)
//    }
    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var franchisees: [Franchisee] = []
    
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
        label.text = "Device ID"
        label.textAlignment = .center
        return label
    }()
    
    private let alertMessageLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.numberOfLines = 0
        label.textColor = Constants.systemRedColor
        label.font = .systemFont(ofSize: 12, weight: .light)
        label.textAlignment = .center
        label.text = "Your device is not authorized to use the app."
        label.isHidden = true
        return label
    }()
    
    private let deviceIDTextField: UITextField = {
        let textField = UITextField(frame: .zero)
        textField.textColor = Constants.darkGrayColor
        textField.textAlignment = .left
        textField.borderStyle = .roundedRect
        textField.font = UIFont.systemFont(ofSize: 16, weight: .regular)
//        textField.placeholder = "Device ID"
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.isEnabled = true
        textField.backgroundColor = Constants.whiteBackgroundColor
        
        textField.attributedPlaceholder = NSAttributedString(
            string: "Device ID",
            attributes: [NSAttributedString.Key.foregroundColor : Constants.lightGrayColor])
        
        return textField
    }()
    
    private let verifyDomainButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = Constants.blackBackgroundColor
        button.setTitle("Verify Device", for: .normal)
        button.setTitleColor(Constants.whiteLabelColor, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 16)
        button.layer.cornerRadius = 5.0
        button.layer.masksToBounds = true
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        configureTextField()
        
        view.backgroundColor = Constants.vcBackgroundColor
        navigationController?.isNavigationBarHidden = true
        
        fetchData()
        
        view.addSubview(logoImageView)
        view.addSubview(container)
        container.addSubview(welcomeLabel)
        container.addSubview(subLabel)
        container.addSubview(deviceIDTextField)
        container.addSubview(verifyDomainButton)
        
        verifyDomainButton.addTarget(self, action: #selector(didTapVerifyDevice), for: .touchUpInside)
        
        let tapAny = UITapGestureRecognizer(target: self, action: #selector(didTapAny))
        view.addGestureRecognizer(tapAny)
        
        // test code
        deviceIDTextField.text = "SIMULATOR_iP13PM" // "SIMULATOR_IP13PM"
    }
    
    @objc func didTapVerifyDevice() {
        // FGESOK4ZETGY
        // iP11 DX6DC4UBN72J
        fetchData()
        
        guard let deviceText = deviceIDTextField.text, !deviceText.isEmpty else {
            createAlertLabel(with: "Please enter your device Serial Number.")
            return }
        createdDeviceID = deviceText
        
        print("cachedToken:", cachedToken ?? "No token cached")
        print("getDeviceData: ", registeredDevices ?? "Empty registeredDevices")
        // if devices contains creadtedevice id
        
        createAlertLabel(with: "Fetching registered devices...")
        guard let getDeviceData = registeredDevices else {
            return
        }
        
        createAlertLabel(with: "Verifying...")
        if getDeviceData.contains(where: { $0.device_id == createdDeviceID}) {
            
            DomainViewController.shared.cacheGeneratedDeviceID(with: createdDeviceID)
            
            guard let device = getDeviceData.first(where: { $0.device_id == createdDeviceID }) else {
                return
            }
            
            UserDefaults.standard.setValue(device.mid, forKey: Constants.machine_id)
            
            if device.device_id_status {
                createAlertLabel(with: "Verified!")
                UserDefaults.standard.set(true, forKey: Constants.isAuthorized)
                
                print("\(device.device_id) is authorized = \(device.device_id_status)")
                let vc = UserLoginViewController(deviceID: device.device_id)
                vc.modalPresentationStyle = .fullScreen
                present(vc, animated: true, completion: nil)
            } else {
                createAlertLabel(with: "Unauthorized device. Please check and try again.")
            }
        } else {
            createAlertLabel(with: "Could not find device, \(createdDeviceID) is being registered.")
            // post device
            
            enableVerifyDomainButton(enableButton: false)
            APICaller.shared.postDevice(with: createdDeviceID) { [weak self] result in
                switch result {
                case .success(let model):
                    self?.postDevice = model
                    self?.fetchData()
                    print("getDeviceData after post: ", getDeviceData)
                    self?.enableVerifyDomainButton(enableButton: true)
                    break
                case .failure(let error):
                    print("verify device error: ",error.localizedDescription)
                    self?.enableVerifyDomainButton(enableButton: true)
                    break
                }
            }
            
        }
    }
    
    private func enableVerifyDomainButton(enableButton: Bool) {
        DispatchQueue.main.async {
            self.verifyDomainButton.isEnabled = enableButton
        }
    }
    
    private func showAlertWith(enteredDeviceID: String, title: String, message: String, style: UIAlertController.Style = .alert) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: style)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
            self.dismiss(animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Continue", style: .destructive, handler: { (action) in
            DomainViewController.shared.cacheGeneratedDeviceID(with: enteredDeviceID)
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    private func fetchData() {
        APICaller.shared.getDevices(completion: { [weak self] (result) in
            switch result {
            case .success(let model):
                self?.registeredDevices = model.data
                break
            case .failure(let error):
                print(error.localizedDescription)
                break
            }
        })
    }
    
    @objc func didTapAny() {
        deviceIDTextField.resignFirstResponder()
    }
    
    private func createAlertLabel(with title: String) {
        alertMessageLabel.text = title
        alertMessageLabel.isHidden = false
        view.addSubview(alertMessageLabel)
        alertMessageLabel.frame = CGRect(x: 20, y: container.bottom+5, width: view.width-40, height: 44)
    }
    
    
    private func configureTextField() {
        deviceIDTextField.text = createdDeviceID
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
        
        deviceIDTextField.frame = CGRect(
            x: 0,
            y: subLabel.bottom,
            width: container.width,
            height: textField_ButtonHeight)
//        deviceIDTextField.backgroundColor = .gray
        
        verifyDomainButton.frame = CGRect(
            x: 0,
            y: deviceIDTextField.bottom+10,
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
