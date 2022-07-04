//
//  SettingsViewController.swift
//  Jeeves-dev
//
//  Created by Jervy Umandap on 2/4/22.
//

import UIKit


struct SettingsTableData {
    let id: Int
    let title: String
//    let imageIcon: String
}

class SettingsViewController: UIViewController {
    
    private var settingsTableData = [SettingsTableData]()
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.isHidden = false
        tableView.separatorStyle = .singleLine
        tableView.backgroundColor = Constants.whiteBackgroundColor
        
        return tableView
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isDeviceAuthorized()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Settings"
        
        view.backgroundColor = Constants.vcBackgroundColor
        
        configureTableData()
        
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
    
    
    public func isDeviceAuthorized() {
        APICaller.shared.getDevices { result in
            switch result {
            case .success(let model):
                if let deviceID = UserDefaults.standard.string(forKey: "generated_device_id") {
                    if !model.data.contains(where: { $0.device_id == deviceID && $0.device_id_status == true }) {
                        // logout
                        self.showAlertForDeviceAuth()
                    }
                }
                break
            case .failure(let error):
                print("isDeviceAuthorized error: \(error.localizedDescription)")
                break
            }
        }
    }
    
    private func showAlertForDeviceAuth() {
        let alert = UIAlertController(title: "Invalid Device ID", message: "You will be logged out because your device id is invalid.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: { action in
            AuthManager.shared.shouldClearSavedUserData()
            let navVC = UINavigationController(rootViewController: DomainViewController())
            navVC.navigationBar.prefersLargeTitles = false
            navVC.viewControllers.first?.navigationItem.largeTitleDisplayMode = .never
            navVC.modalPresentationStyle = .fullScreen
            navVC.setNavigationBarHidden(true, animated: true)
            DispatchQueue.main.async {
                self.present(navVC, animated: true, completion: {
                    self.navigationController?.popToRootViewController(animated: false)
                })
            }
        }))
        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
    }
    
    private func configureTableData() {
        settingsTableData.append(SettingsTableData(id: 1, title: "Submit Cash Drawer"))
//        settingsTableData.append(SettingsTableData(id: 2, title: "Terms and Agreement"))
//        settingsTableData.append(SettingsTableData(id: 2, title: "Logout"))
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    private func logOutTapped() {
        let alert = UIAlertController(
            title: "Log Out",
            message: "Are you sure you want to log out?",
            preferredStyle: .alert)
        
        alert.addAction(
            UIAlertAction(
                title: "Cancel",
                style: .cancel,
                handler: nil))
        
        alert.addAction(UIAlertAction(title: "Log out", style: .destructive, handler: { [weak self] success in
            // enter userpasscode to logout
            self?.createLogoutPasscodeView()
        }))
        // addActionSheetForiPad(actionSheet: alert)
        present(alert, animated: true, completion: nil)
    }
    
    
    func createLogoutPasscodeView() {
        let vc = LogoutPasscodeViewController()
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        present(vc, animated: true, completion: nil)
    }
    
    
}

extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingsTableData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = settingsTableData[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        if model.id == 2 {
            cell.accessoryType = .none
        } else {
            cell.accessoryType = .disclosureIndicator
        }
        
        cell.backgroundColor = Constants.tableViewCellColor
        cell.textLabel?.textColor = Constants.blackLabelColor
        
        cell.textLabel?.text = model.title
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = settingsTableData[indexPath.row]
        
        print(settingsTableData[indexPath.row].title)
        
        if model.id == 1 {
            print("Settings tapped")
            let vc = CashDrawerViewController()
            navigationController?.pushViewController(vc, animated: true)
        } else if model.id == 2 {
            print("Logging out")
            logOutTapped()
        }
        
    }
    
}
