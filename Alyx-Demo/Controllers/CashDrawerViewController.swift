//
//  CashDrawerViewController.swift
//  Jeeves-dev
//
//  Created by Jervy Umandap on 2/4/22.
//

import UIKit

struct CashDrawerData {
    let id: Int
    let billAmount: Double
    let count: Int?
}

class CashDrawerViewController: UIViewController, CashDrawerEnterPasscodeViewControllerDelegate {
    
    private var cashDrawerData = [CashDrawerData]()
    private var cashCount: CashCountPostModel?
    
    private var createdCashCount = [String: Int]()
    
    private var users = [Users]()
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        tableView.register(CashDrawerTableViewCell.self, forCellReuseIdentifier: CashDrawerTableViewCell.idenditifier)
        
        tableView.isHidden = false
        tableView.separatorStyle = .singleLine
        tableView.backgroundColor = Constants.whiteBackgroundColor
        
        return tableView
    }()
    
    private let bottomContainer: UIView = {
        let container = UIView(frame: .zero)
        container.layer.masksToBounds = true
        container.clipsToBounds = true
        container.backgroundColor = Constants.whiteBackgroundColor
        container.addTopBorder(with: Constants.lightGrayBorderColor, andWidth: 0.5)
        return container
    }()
    
    private let submitCashCountButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = Constants.blackBackgroundColor
        button.setTitle("Submit Cash Drawer", for: .normal)
        button.setTitleColor(Constants.whiteLabelColor, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.layer.cornerRadius = 8.0
        button.layer.masksToBounds = true
//        button.setImage(UIImage(systemName: "arrow.clockwise.icloud.fill"), for: .normal)
        button.imageEdgeInsets.left = -25
        button.tintColor = Constants.whiteBackgroundColor
        return button
    }()
    
    private let grandTotalLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = Constants.blackLabelColor
        label.font = .systemFont(ofSize: 18, weight: .regular)
        label.text = "Grand Total: "
        label.textAlignment = .left
        return label
    }()
    
    private let grandTotalValueLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = Constants.blackLabelColor
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.text = "₱0.00"
        label.textAlignment = .right
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Cash Drawer"
        
        fetchUsers()
        
        view.backgroundColor = Constants.whiteBackgroundColor

        view.addSubview(tableView)
        view.addSubview(bottomContainer)
        
        bottomContainer.addSubview(submitCashCountButton)
        bottomContainer.addSubview(grandTotalLabel)
        bottomContainer.addSubview(grandTotalValueLabel)
        
        tableView.delegate = self
        tableView.dataSource = self
        configureCashDrawerData()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        submitCashCountButton.addTarget(self, action: #selector(didTapSubmitCash), for: .touchUpInside)
        
        isDeviceAuthorized()
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height + tableView.rowHeight, right: 0)
        }
    }

    @objc private func keyboardWillHide(notification: NSNotification) {
        tableView.contentInset = .zero
    }
    
    private func fetchUsers() {
        users.removeAll()
        APICaller.shared.getUsers { [weak self] result in
            switch result {
            case .success(let model):
                self?.users = model.data
            case .failure(let error):
                print("Error getting users: \(error.localizedDescription)")
                
                let alert = UIAlertController(title: "Can't Proceed", message: "No internet connection. Please check your connection and try again.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: {_ in
                    self?.navigationController?.popViewController(animated: true)
                }))
                DispatchQueue.main.async {
                    self?.present(alert, animated: true, completion: nil)
                }
            }
        }
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
    
    @objc private func didTapSubmitCash() {
        
        print("createdCashCount:",createdCashCount.count)
        

        guard let superUserID = UserDefaults.standard.string(forKey: "user_id") else {
            print("superUserID nil")
            return
        }
        guard let deviceID = UserDefaults.standard.string(forKey: "generated_device_id") else {
            print("deviceID nil")
            return
        }
        guard let shift = UserDefaults.standard.string(forKey: "pin_entered_employee_shift") else {
            print("shift nil")
            
            let alert = UIAlertController(title: "Can't proceed", message: "Please check if you already time in.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
            
            DispatchQueue.main.async {
                self.present(alert, animated: true, completion: nil)
            }
            return
        }
        
        var grandTotal: Double = 0
        
        for bill in cashDrawerData {
            if let billCount = bill.count {
                createdCashCount["\(bill.billAmount)"] = billCount
                grandTotal += Double(billCount) * bill.billAmount
            }
        }
        
        cashCount = CashCountPostModel(
            userid: Int(superUserID) ?? 0,
            superuserid: Int(superUserID) ?? 0,
            deviceid: deviceID,
            initial: 1,
            cashcount: createdCashCount,
            //    cashcount: [
            //    "1000.00" : 1,
            //    "500.00" : 1,
            //    "200.00" : 1,
            //    "100.00" : 1,
            //    "50.00" : 1,
            //    "20.00" : 1,
            //    "10.00" : 1,
            //    "5.00" : 1,
            //    "1.00" : 1,
            //    "0.25" : 1,
            //    "0.1" : 1,
            //    "0.05" : 1,
            //    "0.01" : 1,
            //    ],
            total: grandTotal, //1886.41
            workdate: Date().workDate(),
            shift: shift)
        
        if !createdCashCount.isEmpty {
            if cashCount != nil { // if let cashCountToPost = cashCount {
                createEnterPasscodeView(users: users, createdCashCount: createdCashCount)
            }
        } else {
            showAlertWith(title: "", message: "You haven't input count yet", style: .alert, shouldReload: false)
        }

        
//        if !createdCashCount.isEmpty {
//            print("cashCount: ", cashCount ?? "no cashCount")
//            if let cashCount = cashCount {
//                APICaller.shared.postCashCount(with: cashCount) { success in
//                    switch success {
//                    case true:
//                        print("success")
//                        DispatchQueue.main.async {
//                            self.showAlertWith(title: "Success submitting cash drawer", message: "", style: .alert, shouldReload: true)
//                        }
//                    case false:
//                        print("failed to post cashcount")
//                    }
//                }
//            }
//        } else {
//            showAlertWith(title: "", message: "You haven't input count yet", style: .alert, shouldReload: false)
//        }
        
    }
    
    func createEnterPasscodeView(users: [Users], createdCashCount: [String : Int]) {
        
        let vc = CashDrawerEnterPasscodeViewController(users: users, createdCashCount: createdCashCount)
        
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        vc.cashDrawerEnterPasscodeViewControllerDelegate = self
        present(vc, animated: true, completion: nil)
    }
    
    public func showAlertWith(title: String, message: String, style: UIAlertController.Style = .alert, shouldReload: Bool) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: style)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: { (action) in
            self.dismiss(animated: true) {
                if shouldReload {
                    print("shouldReload")
                    
//                    self.configureCashDrawerData()
                    self.navigationController?.popToRootViewController(animated: true)
                }
            }
        }))
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func shouldPopToRootVC() {
        print("shouldPopToRootVC")
        showAlertWith(title: "Success", message: "Cash drawer submitted succesfully.", style: .alert, shouldReload: true)
//        navigationController?.popToRootViewController(animated: true)
    }
    
    
    
    private func configureCashDrawerData() {
        cashDrawerData.removeAll()
        
        var bills = [CashDrawerData]()
        bills.append(CashDrawerData(id: 1, billAmount: 1000.0, count: nil))
        bills.append(CashDrawerData(id: 2, billAmount: 500.0, count: nil))
        bills.append(CashDrawerData(id: 3, billAmount: 200.0, count: nil))
        bills.append(CashDrawerData(id: 4, billAmount: 100.0, count: nil))
        bills.append(CashDrawerData(id: 5, billAmount: 50.0, count: nil))
        bills.append(CashDrawerData(id: 6, billAmount: 20.0, count: nil))
        bills.append(CashDrawerData(id: 7, billAmount: 10.0, count: nil))
        bills.append(CashDrawerData(id: 8, billAmount: 5.0, count: nil))
        bills.append(CashDrawerData(id: 9, billAmount: 1.0, count: nil))
        bills.append(CashDrawerData(id: 10, billAmount: 0.25, count: nil))
        bills.append(CashDrawerData(id: 11, billAmount: 0.10, count: nil))
        bills.append(CashDrawerData(id: 12, billAmount: 0.05, count: nil))
        bills.append(CashDrawerData(id: 13, billAmount: 0.01, count: nil))
        
//        priceLabel.text = String(format:"₱%.2f", Double(product.price))
        
        cashDrawerData.append(contentsOf: bills.compactMap({ bill in
            return CashDrawerData(id: bill.id, billAmount: bill.billAmount, count: bill.count)
        }))
        
        tableView.reloadData()
    }
    
    private func calculateGrandTotal() {
        var grandTotal: Double = 0
        for item in cashDrawerData {
            grandTotal += item.billAmount * Double(item.count ?? 0)
        }
        DispatchQueue.main.async {
            self.grandTotalValueLabel.text = String(format:"₱%.2f", grandTotal)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let bottomContainerHeight: CGFloat = 100+view.safeAreaInsets.bottom
        let grandTotalLabelHeight: CGFloat = bottomContainerHeight/2.2
        let submitCashCountButtonHeight: CGFloat = bottomContainerHeight-grandTotalLabelHeight-10
        
        tableView.frame = CGRect(
            x: 0,
            y: 0,
            width: view.width,
            height: view.height-bottomContainerHeight)
        bottomContainer.frame = CGRect(
            x: 14,
            y: tableView.bottom,
            width: view.width-28,
            height: bottomContainerHeight-view.safeAreaInsets.bottom)
//        bottomContainer.backgroundColor = .darkGray
        
        grandTotalLabel.frame = CGRect(
            x: 0,
            y: 0,
            width: bottomContainer.width/2,
            height: grandTotalLabelHeight-(view.safeAreaInsets.bottom/2))
//        grandTotalLabel.backgroundColor = .red
        
        grandTotalValueLabel.frame = CGRect(
            x: grandTotalLabel.right,
            y: 0,
            width: bottomContainer.width/2,
            height: grandTotalLabelHeight-(view.safeAreaInsets.bottom/2))
//        grandTotalValueLabel.backgroundColor = .yellow
        
        submitCashCountButton.frame = CGRect(
            x: 0,
            y: grandTotalLabel.bottom,
            width: bottomContainer.width,
            height: submitCashCountButtonHeight-(view.safeAreaInsets.bottom/2))
//        submitCashCountButton.backgroundColor = .blue
    }
}

extension CashDrawerViewController {
    
    private func createCashCount(with denote: [String: Int]) {
    }
}


extension CashDrawerViewController: UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cashDrawerData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = cashDrawerData[indexPath.row]
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CashDrawerTableViewCell.idenditifier, for: indexPath) as? CashDrawerTableViewCell else {
            return UITableViewCell()
        }
        cell.billCountTextField.delegate = self
        cell.billCountTextField.tag = indexPath.row
        cell.configure(with:
                        CashDrawerTableViewCellViewModel(
                            bill: model.billAmount,
                            count: model.count,
                            subTotal: model.billAmount * Double(model.count ?? 0)))
        
        return cell
    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        var text = textField.text!
        if let newRange = Range(range, in: text) {
            text.replaceSubrange(newRange, with: string)
        }

        
        let tag = textField.tag
        let indexPath = IndexPath(row: tag, section: 0)
        let cell = tableView.cellForRow(at: indexPath) as! CashDrawerTableViewCell
        
        let bill = cell.billAmount
        let count = Int(text)//Int(cell.billCountTextField.text ?? "")
        let subTotal = Double(count ?? 0) * bill
        
        cashDrawerData.remove(at: tag)
        
        cashDrawerData.insert(CashDrawerData(
            id: tag+1,
            billAmount: bill,
            count: count ?? nil),
                              at: tag)
        DispatchQueue.main.async {
            cell.totalLabel.text = String(format:"₱%.2f", subTotal)
        }
        
        _ = cashDrawerData.compactMap({ print($0) })
        
        calculateGrandTotal()
        
        return true
    }
    
//    func textFieldDidEndEditing(_ textField: UITextField) {
//        let tag = textField.tag
//        let indexPath = IndexPath(row: tag, section: 0)
//        let cell = tableView.cellForRow(at: indexPath) as! CashDrawerTableViewCell
//
//        let bill = cell.billAmount
//        let count = Int(cell.billCountTextField.text ?? "")
//        let subTotal = Double(count ?? 0) * bill
//
//        cashDrawerData.remove(at: tag)
//        cashDrawerData.insert(CashDrawerData(
//                                id: tag+1,
//                                billAmount: bill,
//                                count: count ?? nil),
//                              at: tag)
//
//        cell.totalLabel.text = String(format:"₱%.2f", subTotal)
//
//
//        _ = cashDrawerData.compactMap({ print($0) })
//
//        calculateGrandTotal()
//    }
    
//    func textFieldDidBeginEditing(_ textField: UITextField) {
//        let tag = textField.tag
//        let indexPath = IndexPath(row: tag, section: 0)
//        let cell = tableView.cellForRow(at: indexPath) as! CashDrawerTableViewCell
//
//        let bill = cell.billAmount
//        let count = Int(cell.billCountTextField.text ?? "")
//        let subTotal = Double(count ?? 0) * bill
//
//        cashDrawerData.remove(at: tag)
//        cashDrawerData.insert(CashDrawerData(
//                                id: tag+1,
//                                billAmount: bill,
//                                count: count ?? nil),
//                              at: tag)
//
//        cell.totalLabel.text = String(format:"₱%.2f", subTotal)
//
//
//        _ = cashDrawerData.compactMap({ print($0) })
//
//        calculateGrandTotal()
//    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        let tag = textField.tag
        let nextTag = textField.tag+1
        
        let indexPath = IndexPath(row: tag, section: 0)
        let cell = tableView.cellForRow(at: indexPath) as! CashDrawerTableViewCell
        
        
        let nextIndexPath = IndexPath(row: nextTag, section: 0)
        
        if let nextCell = tableView.cellForRow(at: nextIndexPath) as? CashDrawerTableViewCell {
            
            
            if nextTag < tableView.numberOfRows(inSection: 0) {
                
                tableView.scrollToRow(at: nextIndexPath, at: .none, animated: true)
                
                nextCell.billCountTextField.becomeFirstResponder()
                if nextTag == tableView.numberOfRows(inSection: 0) {
                    cell.billCountTextField.resignFirstResponder()
                    
                }
                
            }
            
        } else {
            textField.resignFirstResponder()
        }
        
        let bill = cell.billAmount
        let count = Int(cell.billCountTextField.text ?? "")
        let subTotal = Double(count ?? 0) * bill
        
        cashDrawerData.remove(at: tag)
        cashDrawerData.insert(CashDrawerData(
                                id: tag+1,
                                billAmount: bill,
                                count: count ?? nil),
                              at: tag)
        
        cell.totalLabel.text = String(format:"₱%.2f", subTotal )
        
        
        _ = cashDrawerData.compactMap({ print($0) })
        
//        if tableView.reloadData()
        
        
        
        return true
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
}

//{
//    "userid": 17,
//    "superuserid": 17,
//    "deviceid": "FGESOK4ZETGY",
//    "initial": 1,
//    "cashcount": {
//        "1000.00" : 1,
//        "500.00" : 1,
//        "200.00" : 1,
//        "100.00" : 1,
//        "50.00" : 1,
//        "20.00" : 1,
//        "10.00" : 1,
//        "5.00" : 1,
//        "1.00" : 1,
//        "0.25" : 1,
//        "0.1" : 1,
//        "0.05" : 1,
//        "0.01" : 1
//    },
//    "total": 150,
//    "workdate": "2021-12-28",
//    "shift": "mid"
//}
