//
//  AuthViewController.swift
//  Jeeves-dev
//
//  Created by Jervy Umandap on 2/4/22.
//

import UIKit

class AuthViewController: UIViewController {
    
    static let shared = AuthViewController()
    
    private var authResponse: AuthResponse?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Constants.whiteBackgroundColor
        navigationController?.isNavigationBarHidden = true
        
        cacheToken()
        createSpinnerView()
//        didFinishCachingToken()
        doesHaveCachedDomain()
    }
    
    public var completionHandler: ((Bool) -> Void)?
    
    private func cacheToken() {
        APICaller.shared.getToken(completion: { [weak self] result in
            switch result {
            case .success(let model):
                self?.authResponse = model
                break
            case .failure(let error):
                print(error.localizedDescription)
                break
            }
        })
    }
    
    private func doesHaveCachedDomain() {
        print("doesHaveCachedDomain: ",UserDefaults.standard.string(forKey: "domain_name"))
        if let cachedDomain = UserDefaults.standard.string(forKey: "domain_name") {
            if cachedDomain.isEmpty {
                didFinishCachingToken()
            } else {
                didFinishCachingToken()
            }
        }
    }
    
    public var domainName: String? = {
        return UserDefaults.standard.string(forKey: "domain_name")
    }()
    
    private func didFinishCachingToken() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            let vc = DomainViewController()
            vc.modalPresentationStyle = .fullScreen
            vc.modalTransitionStyle = .crossDissolve
            self?.present(vc, animated: true, completion: nil)
        }
    }
    
    private func goToUserLogin() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            let vc = UserLoginViewController(deviceID: AuthManager.shared.cachedDeviceID)
            vc.modalPresentationStyle = .fullScreen
            vc.modalTransitionStyle = .crossDissolve
            self?.present(vc, animated: true, completion: nil)
        }
    }
    
    
    public func createSpinnerView() {
        let child = SpinnerViewController()

        // add the spinner view controller
        addChild(child)
        child.view.frame = view.bounds
        view.addSubview(child.view)
        child.didMove(toParent: self)

        // wait 1 second to simulate some work happening
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // then remove the spinner view controller
            child.willMove(toParent: nil)
            child.view.removeFromSuperview()
            child.removeFromParent()
        }
    }
}
