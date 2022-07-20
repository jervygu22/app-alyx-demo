//
//  HistoryItemViewController.swift
//  Jeeves-dev
//
//  Created by Jervy Umandap on 2/4/22.
//

import UIKit


protocol HistoryItemViewControllerDelegate {
    func shouldReloadData()
}

class HistoryItemViewController: UIViewController, VoidPasscodeViewControllerDelegate {
    
//    private let orders: [FakeOrders]
//    private let orders: HistoryData// [YourCart]
    
    var historyItemViewControllerDelegate: HistoryItemViewControllerDelegate?
    
    private let orderID: Int
    private let isCancelled: Bool
    private var orders: HistoryItemByIDResponse?
    private var orderReceipt: String?
    
//    init(queueItem: HistoryData) {
//        self.orders = queueItem
//        super.init(nibName: nil, bundle: nil)
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    
    init(orderID: Int, isCancelled: Bool) {
        self.orderID = orderID
        self.isCancelled = isCancelled
        super.init(nibName: nil, bundle: nil)
    }
//
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.register(OrdersTableViewCell.self, forCellReuseIdentifier: OrdersTableViewCell.identifier)
        
        tableView.backgroundColor = Constants.whiteBackgroundColor
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        return tableView
    }()
    
    private let bottomContainer: UIView = {
        let container = UIView(frame: .zero)
        container.layer.masksToBounds = true
        container.clipsToBounds = true
        return container
    }()
    
    // MARK: - labels
    private let subTotalLabel: UILabel = {
        let label = UILabel()
        label.textColor = Constants.secondaryDarkLabelColor
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.text = "Subtotal"
        label.textAlignment = .left
        return label
    }()
    
    private let vatableLabel: UILabel = {
        let label = UILabel()
        label.textColor = Constants.secondaryDarkLabelColor
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.text = "Vatable Sales"
        label.textAlignment = .left
        return label
    }()
    
    private let vatExemptLabel: UILabel = {
        let label = UILabel()
        label.textColor = Constants.secondaryDarkLabelColor
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.text = "Vat Exempt Sales"
        label.textAlignment = .left
        return label
    }()
    
    private let surchargeLabel: UILabel = {
        let label = UILabel()
        label.textColor = Constants.secondaryDarkLabelColor
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.text = "Surcharge"
        label.textAlignment = .left
        return label
    }()
    
    private let vatLabel: UILabel = {
        let label = UILabel()
        label.textColor = Constants.secondaryDarkLabelColor
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.text = "Vat (12%)"
        label.textAlignment = .left
        return label
    }()
    
    private let seniorPwdDiscountLabel: UILabel = {
        let label = UILabel()
        label.textColor = Constants.secondaryDarkLabelColor
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.text = "Senior/PWD Discount"
        label.textAlignment = .left
        return label
    }()
    
    private let totalLabel: UILabel = {
        let label = UILabel()
        label.textColor = Constants.blackLabelColor
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.text = "Total"
        label.textAlignment = .left
        return label
    }()
    
    private let cashTenderedLabel: UILabel = {
        let label = UILabel()
        label.textColor = Constants.secondaryDarkLabelColor
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.text = "Cash Tendered"
        label.textAlignment = .left
        return label
    }()

    private let changeLabel: UILabel = {
        let label = UILabel()
        label.textColor = Constants.blackLabelColor
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.text = "Change"
        label.textAlignment = .left
        return label
    }()
    
    
    // MARK: - Value labels
    private let subTotalValueLabel: UILabel = {
        let label = UILabel()
        label.textColor = Constants.secondaryDarkLabelColor
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textAlignment = .right
        return label
    }()
    
    private let vatableSalesValueLabel: UILabel = {
        let label = UILabel()
        label.textColor = Constants.secondaryDarkLabelColor
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textAlignment = .right
        return label
    }()
    
    private let vatExemptValueLabel: UILabel = {
        let label = UILabel()
        label.textColor = Constants.secondaryDarkLabelColor
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textAlignment = .right
        return label
    }()
    
    private let surchargeValueLabel: UILabel = {
        let label = UILabel()
        label.textColor = Constants.secondaryDarkLabelColor
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textAlignment = .right
        return label
    }()
    
    private let vatValueLabel: UILabel = {
        let label = UILabel()
        label.textColor = Constants.secondaryDarkLabelColor
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textAlignment = .right
        return label
    }()
    
    private let seniorPwdDiscountValueLabel: UILabel = {
        let label = UILabel()
        label.textColor = Constants.secondaryDarkLabelColor
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textAlignment = .right
        return label
    }()
    
    private let totalValueLabel: UILabel = {
        let label = UILabel()
        label.textColor = Constants.blackLabelColor
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textAlignment = .right
        return label
    }()
    
    private let cashTenderedValueLabel: UILabel = {
        let label = UILabel()
        label.textColor = Constants.secondaryDarkLabelColor
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textAlignment = .right
        return label
    }()
    
    private let changeValueLabel: UILabel = {
        let label = UILabel()
        label.textColor = Constants.blackLabelColor
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textAlignment = .right
        return label
    }()
    
    private let printBillsButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = Constants.blackBackgroundColor
        button.setTitle("Print Bills", for: .normal)
        button.setTitleColor(Constants.whiteLabelColor, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.layer.cornerRadius = 5.0
        button.layer.masksToBounds = true
        return button
    }()
    
    private let voidOrderButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = Constants.blackBackgroundColor
        button.setTitle("Void", for: .normal)
        button.setTitleColor(Constants.whiteLabelColor, for: .normal)
        button.setTitleColor(Constants.darkGrayColor, for: .disabled)
        
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.layer.cornerRadius = 5.0
        button.layer.masksToBounds = true
        return button
    }()
    
    private var voidButton = UIBarButtonItem()
    
    
//    private let voidStampedLabel: UILabel = {
//        let label = UILabel()
//        label.textColor = Constants.systemRedColor
//        label.numberOfLines = 0
//        label.adjustsFontSizeToFitWidth = false
//        label.font = .systemFont(ofSize: 50, weight: .heavy)
//        label.text = "VOID"
//        label.textAlignment = .center
//        label.isHidden = true
//        return label
//    }()
    
    private let voidStampedImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "void_stamp")
        imageView.layer.masksToBounds = true
        imageView.clipsToBounds = true
        imageView.isHidden = true
        return imageView
    }()
    
    private let demoLabelContainer: UIView = {
        let view = UIView(frame: .zero)
//        view.layer.masksToBounds = true
//        view.clipsToBounds = true
        view.transform = CGAffineTransform(rotationAngle: -CGFloat.pi / 4)
        return view
    }()
    
    private let demoLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = Constants.whiteLabelColor
        label.font = .systemFont(ofSize: 18, weight: .heavy)
        label.text = "DEMO"
        label.textAlignment = .center
        return label
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Constants.whiteBackgroundColor
        
        tableView.delegate = self
        tableView.dataSource = self
        
        view.addSubview(tableView)
        view.addSubview(bottomContainer)
        view.addSubview(voidStampedImageView)
        voidStampedImageView.isHidden = !isCancelled
        
        getOrderData()
        fetchReceipt()
        
        configureBottomContainer()
//        configureBottomContainerData()
//        configureRightBarButton()
        
        isDeviceAuthorized()
        
        let isDemo = UserDefaults.standard.bool(forKey: Constants.is_demo_build)
        if isDemo {
            addDemoLabel()
        }
    }
    
    private func addDemoLabel() {
        view.addSubview(demoLabelContainer)
        demoLabelContainer.addSubview(demoLabel)
    }
    
    private func layoutDemoLabel() {
        let demoLabelContainerHeight: CGFloat = 30
        let demoLabelContainerWidth = demoLabelContainerHeight * 2
        demoLabelContainer.frame = CGRect(
            x: view.width-demoLabelContainerWidth,
            y: view.height-demoLabelContainerWidth,
            width: demoLabelContainerWidth,
            height: demoLabelContainerHeight*2)
        demoLabelContainer.backgroundColor = .gray
        
        demoLabel.sizeToFit()
        demoLabel.frame = CGRect(
            x: -(demoLabelContainerWidth*1.5),
            y: demoLabelContainerHeight/1.5,
            width: demoLabelContainerWidth*3,
            height: demoLabelContainerHeight)
        //        demoLabel.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        //        demoLabel.backgroundColor = UIColor.red.withAlphaComponent(0.75)
        demoLabel.backgroundColor = Constants.demoLabelAlphaBackgroundColor
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
    
    
    private func configureRightBarButton() {
//        voidButton = UIBarButtonItem(
//            image: UIImage(systemName: "person.fill"),
//            style: .done,
//            target: self,
//            action: #selector(didTapVoidOrder))
        voidButton = UIBarButtonItem(
            title: "Void",
            style: .plain,
            target: self,
            action: #selector(didTapVoidOrder))
        
        navigationItem.rightBarButtonItem = !isCancelled ? voidButton : nil
    }
    
    @objc func didTapVoidOrder() {
        print("didTapVoidOrder")
        
        let alert = UIAlertController(title: nil, message: "Are you sure you want to cancel this order?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "NO", style: .cancel, handler: nil)) // Cancel & Proceed
        alert.addAction(UIAlertAction(title: "YES", style: .destructive, handler: { [weak self] action in
            self?.createVoidPasscodeView(with: self?.orderID ?? 0)
        }))
        present(alert, animated: true, completion: nil)
    }
    
//    private func showAlertWith(title: String?, message: String?, style: UIAlertController.Style = .alert, success: Bool) {
//        let alert = UIAlertController(title: title, message: message, preferredStyle: style)
//        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: { [weak self] action in
//            self?.dismiss(animated: true, completion: nil)
//            if success {
//                self?.navigationController?.popToRootViewController(animated: true)
//                
//            }
//        }))
//        present(alert, animated: true, completion: nil)
//    }
    
    func createVoidPasscodeView(with orderID: Int) {
        let vc = VoidPasscodeViewController(orderID: orderID)
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        vc.voidPasscodeViewControllerDelegate = self
        present(vc, animated: true, completion: nil)
    }
    
    func shouldPopToRootViewController() {
        print("popToRootViewController")
        navigationController?.popToRootViewController(animated: true)
        historyItemViewControllerDelegate?.shouldReloadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let bottomContainerHeight: CGFloat = 220.0+44.0+10
        
        tableView.frame = CGRect(
            x: 0,
            y: 0,
            width: view.width,
            height: view.height-bottomContainerHeight)
        
//        voidStampedImageView.frame = tableView.bounds
        let voidStampedImageViewSize = tableView.height/3
        voidStampedImageView.frame = CGRect(
            x: (tableView.width-voidStampedImageViewSize)/2,
            y: (tableView.height-voidStampedImageViewSize)/2,
            width: voidStampedImageViewSize,
            height: voidStampedImageViewSize)
        
        bottomContainer.frame = CGRect(
            x: 14,
            y: tableView.bottom,
            width: view.width-28-view.safeAreaInsets.right,
            height: bottomContainerHeight-view.safeAreaInsets.bottom)
        bottomContainer.addTopBorder(with: Constants.lightGrayBorderColor, andWidth: 0.5)
//        bottomContainer.backgroundColor = .systemGreen
        
        let buttonHeight: CGFloat = 44.0
        let labelHeight: CGFloat = (bottomContainer.height-10-buttonHeight-10-10)/9
        let labelWidth: CGFloat = bottomContainer.width/2
            
        subTotalLabel.frame = CGRect(x: 0, y: 10, width: labelWidth, height: labelHeight)
        vatableLabel.frame = CGRect(x: 0, y: subTotalLabel.bottom, width: labelWidth, height: labelHeight)
        
        vatExemptLabel.frame = CGRect(x: 0, y: vatableLabel.bottom, width: labelWidth, height: labelHeight)
        
        vatLabel.frame = CGRect(x: 0, y: vatExemptLabel.bottom, width: labelWidth, height: labelHeight)
        seniorPwdDiscountLabel.frame = CGRect(x: 0, y: vatLabel.bottom, width: labelWidth, height: labelHeight)
        surchargeLabel.frame = CGRect(x: 0, y: seniorPwdDiscountLabel.bottom, width: labelWidth, height: labelHeight)
        totalLabel.frame = CGRect(x: 0, y: surchargeLabel.bottom, width: labelWidth, height: labelHeight)
        cashTenderedLabel.frame = CGRect(x: 0, y: totalLabel.bottom, width: labelWidth, height: labelHeight)
        changeLabel.frame = CGRect(x: 0, y: cashTenderedLabel.bottom, width: labelWidth, height: labelHeight)
        
        subTotalValueLabel.frame = CGRect(x: subTotalLabel.right, y: 10, width: labelWidth, height: labelHeight)
        vatableSalesValueLabel.frame = CGRect(x: vatableLabel.right, y: subTotalValueLabel.bottom, width: labelWidth, height: labelHeight)
        
        vatExemptValueLabel.frame = CGRect(x: vatableLabel.right, y: vatableSalesValueLabel.bottom, width: labelWidth, height: labelHeight)
        
        vatValueLabel.frame = CGRect(x: vatLabel.right, y: vatExemptValueLabel.bottom, width: labelWidth, height: labelHeight)
        seniorPwdDiscountValueLabel.frame = CGRect(x: seniorPwdDiscountLabel.right, y: vatValueLabel.bottom, width: labelWidth, height: labelHeight)
        surchargeValueLabel.frame = CGRect(x: surchargeLabel.right, y: seniorPwdDiscountValueLabel.bottom, width: labelWidth, height: labelHeight)
        totalValueLabel.frame = CGRect(x: totalLabel.right, y: surchargeValueLabel.bottom, width: labelWidth, height: labelHeight)
        cashTenderedValueLabel.frame = CGRect(x: cashTenderedLabel.right, y: totalValueLabel.bottom, width: labelWidth, height: labelHeight)
        changeValueLabel.frame = CGRect(x: changeLabel.right, y: cashTenderedValueLabel.bottom, width: labelWidth, height: labelHeight)
        
        voidOrderButton.frame = CGRect(
            x: 0,
            y: changeLabel.bottom+10,
            width: (bottomContainer.width/2)-5,
            height: buttonHeight)
        
        printBillsButton.frame = CGRect(
            x: voidOrderButton.right+10,
            y: changeLabel.bottom+10,
            width: (bottomContainer.width/2)-5,
            height: buttonHeight)
        
        layoutDemoLabel()
    }
    
    func configureBottomContainer() {
        bottomContainer.addSubview(subTotalLabel)
        bottomContainer.addSubview(vatableLabel)
        bottomContainer.addSubview(vatExemptLabel)
        bottomContainer.addSubview(surchargeLabel)
        bottomContainer.addSubview(vatLabel)
        bottomContainer.addSubview(seniorPwdDiscountLabel)
        bottomContainer.addSubview(totalLabel)
        bottomContainer.addSubview(cashTenderedLabel)
        bottomContainer.addSubview(changeLabel)
        
        bottomContainer.addSubview(subTotalValueLabel)
        bottomContainer.addSubview(vatableSalesValueLabel)
        bottomContainer.addSubview(vatExemptValueLabel)
        bottomContainer.addSubview(surchargeValueLabel)
        bottomContainer.addSubview(vatValueLabel)
        bottomContainer.addSubview(seniorPwdDiscountValueLabel)
        bottomContainer.addSubview(totalValueLabel)
        bottomContainer.addSubview(cashTenderedValueLabel)
        bottomContainer.addSubview(changeValueLabel)
        
        bottomContainer.addSubview(printBillsButton)
        bottomContainer.addSubview(voidOrderButton)
        voidOrderButton.isEnabled = !isCancelled ? true : false
        voidOrderButton.backgroundColor = !isCancelled ? .red : .lightGray
        
        voidOrderButton.addTarget(self, action: #selector(didTapVoidOrder), for: .touchUpInside)
        
        printBillsButton.addTarget(self, action: #selector(didTapPrintButton), for: .touchUpInside)
    }
    
    @objc private func didTapPrintButton() {
        print("================== Did tap Print ==================")
        print(orderReceipt ?? "Error Receipt")
        print("================== End of receipt =================")
        
//        voidOrderButton.isHidden = true
//        printBillsButton.isHidden = true
        
        guard let screenshot = UIApplication.shared.getScreenshot(),
              let orderReceipt = orderReceipt else { return }
        
        print("screenshot: \(screenshot)")
        
        let navVC = UINavigationController(rootViewController: ReceiptViewController(receipt: orderReceipt, orderID: "\(orderID)"))
//        navVC.modalPresentationStyle = .popover
        
        navVC.navigationBar.backgroundColor = Constants.drawerBackgroundColor
        navigationController?.present(navVC, animated: true)
        
        
//        let yPosition = (view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0) +  (navigationController?.navigationBar.frame.height ?? 44.0)
//
//        guard let croppedReceipt = screenshot.sd_croppedImage(
//            with: CGRect(
//                x: 0,
//                y: yPosition,
//                width: view.width,
//                height: view.height - yPosition)) else {
//            return
//        }
//
//        let vc = UIActivityViewController(activityItems: [croppedReceipt],
//                                          applicationActivities: [])
//
//        vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
//        present(vc, animated: true) {
//            self.voidOrderButton.isHidden = false
//            self.printBillsButton.isHidden = false
//        }
    }
    
    private func fetchReceipt() {
        APICaller.shared.getReceiptByOrderID(orderID: orderID) { [weak self] result in
            switch result {
            case .success(let model):
                self?.orderReceipt = model.data
            case .failure(let error):
                print("fetchReceipt: \(error.localizedDescription)")
            }
        }
    }
    
    
    private func getOrderData() {
        APICaller.shared.getHistoryItemByID(orderID: orderID) { [weak self] result in
            switch result {
            case .success(let model):
                self?.orders = model
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                    self?.configureBottomContainerData(with: model)
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func configureBottomContainerData(with orders: HistoryItemByIDResponse) {
//        let total: Double = Double(orders.totalAmount)
//        let cashTendered = orders.cashTendered
//
//        let twelveVatAmount = total * 0.12
//        subTotalValueLabel.text = "₱\(orders.totalAmount)"  //₱385.00"
//        vatableValueLabel.text = "₱0.00"
//        vatExepmtValueLabel.text = "₱0.00"
//        vatValueLabel.text = String(format:"₱%.2f", twelveVatAmount) //"₱0.00"
//        seniorPwdDiscountValueLabel.text = "₱0.00"
//        totalValueLabel.text = String(format:"₱%.2f", total) //"₱0.00"
//        cashTenderedValueLabel.text = String(format:"₱%.2f", cashTendered) //"₱0.00"
//        changeValueLabel.text = String(format:"₱%.2f", Double(cashTendered)-total) //"₱0.00"
        
        
//        let cashTendered = orders.data.cashTendered
//        let total = orders.data.totalAmount
        
//        let twelveVatAmount = total * 0.12
        
        let roundedTotalAmount = round(orders.data.totalAmount * 100) / 100
        print("cashTendered: ", orders.data.cashTendered)
        print("total: ", roundedTotalAmount)
        
        subTotalValueLabel.text = String(format:"₱%.2f", Double(orders.data.subtotal))
        
        vatableSalesValueLabel.text = String(format:"₱%.2f", Double(orders.data.vatable_sales))
        vatExemptValueLabel.text = String(format:"₱%.2f", Double(orders.data.vat_exempt_sales))
        
        surchargeValueLabel.text = String(format:"₱%.2f", Double(orders.data.surcharge)) //String(format:"₱%.2f", Double(orders.data.vat_exempt_sales))
        vatValueLabel.text = String(format:"₱%.2f", Double(orders.data.vat)) //"₱\(orders.data.vat)"
        seniorPwdDiscountValueLabel.text = String(format:"₱%.2f", Double(orders.data.amountDiscounted))
        totalValueLabel.text = String(format:"₱%.2f", roundedTotalAmount)
        cashTenderedValueLabel.text = String(format:"₱%.2f", Double(orders.data.cashTendered))
        changeValueLabel.text = String(format:"₱%.2f", Double(orders.data.cashTendered) - roundedTotalAmount)
    }
}

extension HistoryItemViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return orders.your_cart.count
        return orders?.data.cartItems.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let model = orders.your_cart[indexPath.row]
        let model = orders?.data.cartItems[indexPath.row]
        
        guard let cell = tableView.dequeueReusableCell(
                withIdentifier: OrdersTableViewCell.identifier,
                for: indexPath) as? OrdersTableViewCell else {
            return UITableViewCell()
        }
        
//        cell.configure(with: OrdersTableViewCellViewModel(
//                        image: model.image,
//                        name: model.name,
//                        quantity: "x\(model.quantity)",
//                        finalPrice: String(format:"₱%.2f", model.total),
//                        originalPrice:  String(format:"₱%.2f", model.total)))
        
        if let model = model {
            let doubledOrigPrice = Double(model.price) * Double(model.quantity)
            cell.isAddon = model.add_on
            cell.configure(with: OrdersTableViewCellViewModel(
                image: model.image,
                name: model.name,
                quantity: model.quantity,
                finalPrice: model.total,
                originalPrice:  doubledOrigPrice,
                discount: model.discount,
                itemPrice: model.price)
            )
        }
        
        return cell
    }
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
//        print(orders[indexPath.row].product_name)
//    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let headerString = "Items"
        return headerString
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40//UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = UIColor.red
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = Constants.darkGrayColor
    }
    
}

