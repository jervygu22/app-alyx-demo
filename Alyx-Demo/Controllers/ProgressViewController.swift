//
//  ProgressViewController.swift
//  Alyx-Demo
//
//  Created by CDI on 7/4/22.
//

import UIKit

class ProgressViewController: UIViewController {
    static let shared = ProgressViewController()
    
    private let child = SpinnerViewController()
    
    private var authResponse: AuthResponse?
    private var deviceID: String?
    
    private var accessToken: String?
    private var accessToken2: String?
    
    
    private var registeredDevices: [GetDeviceData]?
    private var users: [User]?
    
    private var usersCredential: UserCredentials?
    
    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: Constants.app_logo)
        imageView.contentMode = .scaleAspectFit
        imageView.layer.masksToBounds = true
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private var spinner = UIActivityIndicatorView(style: .large)
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Hide the navigation bar on the this view controller
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = Constants.vcBackgroundColor
        view.addSubview(logoImageView)
        
        createSpinnerView()
        
        UserDefaults.standard.setValue(Constants.demo_franchise_name, forKey: Constants.domain_name)
        UserDefaults.standard.setValue(Constants.demo_device_id, forKey: Constants.generated_device_id)
        
        saveAccessTokens()
        
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        // Show the navigation bar on other view controllers
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let logoImageViewSize: CGFloat = 240
        logoImageView.frame = CGRect(
            x: (view.width-logoImageViewSize) / 2,
            y: (view.height-logoImageViewSize) / 2,
            width: logoImageViewSize,
            height: logoImageViewSize)
    }
    
    private func saveAccessTokens() {
        APICaller.shared.getTokenWithDomain(with: Constants.demo_franchise_name) { [weak self] result in
            switch result {
            case .success(let model):
                print("Success caching token: \(model.token)")
                UserDefaults.standard.setValue(model.token, forKey: Constants.access_token)
                self?.accessToken = model.token
                break
            case .failure(let error):
                print("Failed to get access token: \(error.localizedDescription)")
                break
            }
        }
        APICaller.shared.getTokenWithDomainAndDeviceID(with: Constants.demo_franchise_name, with: Constants.demo_device_id) { [weak self] result in
            switch result {
            case .success(let model):
                print("Success caching token2: \(model.token)")
                UserDefaults.standard.setValue(model.token, forKey: Constants.access_token2)
                self?.accessToken2 = model.token
                self?.fetchDevices()
                
                break
            case .failure(let error):
                print("Failed to get access token 2: \(error.localizedDescription)")
                break
            }
        }
        
    }
    private func fetchDevices() {
        APICaller.shared.getDevices(completion: { [weak self] result in
            switch result {
            case .success(let model):
                self?.registeredDevices = model.data
                if let device = model.data.first(where: { $0.device_id == Constants.demo_device_id && $0.device_id_status }) {
                    self?.saveMachineID(with: device)
                    self?.fetchUsers()
                    self?.fetchIsDemo()
                }
                break
            case .failure(let error):
                print(error.localizedDescription)
                break
            }
        })
    }
    
    
    private func fetchUsers() {
        APICaller.shared.getAllUsers2 { [weak self] result in
            switch result {
            case .success(let model):
                self?.users = model.data
                if let superUser = model.data.first(where: { $0.user_roles.contains("supervisor") }) {
                    self?.saveSuperuser(with: UserCredentials(
                        user_id: superUser.user_id,
                        user_name: superUser.user_name,
                        user_image: superUser.user_image,
                        user_login: superUser.user_login,
                        user_email: superUser.user_email,
                        user_pass: superUser.user_pass,
                        user_emp_id: superUser.user_emp_id,
                        user_pin: superUser.user_pin,
                        user_handles_cash: superUser.user_handles_cash,
                        user_roles: superUser.user_roles,
                        user_access_level: "supervisor"))
                    
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//                        // then remove the spinner view controller
//                        self?.child.willMove(toParent: nil)
//                        self?.child.view.removeFromSuperview()
//                        self?.child.removeFromParent()
//                        self?.goToMenu()
//                    }
                    
                    DispatchQueue.main.async {
                        // then remove the spinner view controller
                        self?.child.willMove(toParent: nil)
                        self?.child.view.removeFromSuperview()
                        self?.child.removeFromParent()
                        self?.goToMenu()
                    }
                }
                break
            case .failure(let error):
                print(error.localizedDescription)
                break
            }
        }
    }
    
    private func saveMachineID(with device: GetDeviceData) {
        if device.device_id_status {
            UserDefaults.standard.setValue(device.mid, forKey: Constants.machine_id)
            UserDefaults.standard.setValue(true, forKey: Constants.is_authorized)
        }
    }
    
    private func saveSuperuser(with user: UserCredentials) {
        UserDefaults.standard.setValue(user.user_id, forKey: Constants.user_id)
        UserDefaults.standard.setValue(user.user_login, forKey: Constants.user_name)
        UserDefaults.standard.setValue(user.user_email, forKey: Constants.user_email)
        UserDefaults.standard.setValue(user.user_pin, forKey: Constants.user_pin)
        UserDefaults.standard.setValue(user.user_handles_cash, forKey: Constants.is_user_handle_cash)
        UserDefaults.standard.setValue(user.user_roles, forKey: Constants.user_role)
        UserDefaults.standard.setValue(user.user_emp_id, forKey: Constants.user_emp_id)
    
//        DispatchQueue.main.async {
//            // then remove the spinner view controller
//            self.child.willMove(toParent: nil)
//            self.child.view.removeFromSuperview()
//            self.child.removeFromParent()
//            self.goToMenu()
//        }
    }
    
    private func goToMenu() {
        
        let vc = MenuViewController()
        let navVC = UINavigationController(rootViewController: vc)
        
        navVC.navigationBar.prefersLargeTitles = false
        navVC.viewControllers.first?.navigationItem.largeTitleDisplayMode = .never
        navVC.modalPresentationStyle = .fullScreen
        navVC.setNavigationBarHidden(false, animated: false)
        
        present(navVC, animated: true, completion: { [weak self] in
            self?.navigationController?.popToRootViewController(animated: false)
        })
    }
    
    public func fetchIsDemo() {
        APICaller.shared.getDemo { result in
            switch result {
            case .success(let model):
                print("fetchIsDemo: \(model.demo_mode)")
                UserDefaults.standard.setValue(model.demo_mode, forKey: Constants.is_demo_build)
                break
            case .failure(let error):
                print("fetchIsDemo error: \(error.localizedDescription)")
                break
            }
        }
    }
    
    public func createSpinnerView() {
        // add the spinner view controller
        addChild(child)
        child.view.frame = view.bounds
        view.addSubview(child.view)
        child.didMove(toParent: self)
    }

}
