//
//  OldQueueViewController.swift
//  Jeeves-dev
//
//  Created by Jervy Umandap on 2/4/22.
//

import UIKit
import CoreData


class OldQueueViewController: UIViewController {
    static let shared = CartViewController()
    
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    private var fetchedCoupons: [CouponData] = []
    
    private var timer = Timer()
    
//    var queue = [FakeQueueItems]()
    private var queue = [FakeQueueListItems]()
    private var queueItems = [Queue_Entity]()
    private var cartQueuedItems = [Cart_Entity]()
    private var cartEntity = [Cart_Entity]()
    
    private var storedSurcharges = [Surcharges_Entity]()
    
    private var surchargeArray: [SurchargeData] = []
    private var surchargeData: [SurchargeData]?
    
    private var updateCoupons = [UpdateCouponDataModel]()
    private var postOrderArray = [PostOrderModel]()
    private var updateCouponsIndex = 0
    private var postOrderArrayIndex = 0
    
    private var totalSurcharge: Double = 0
    
    lazy var isUpdateCouponFinished = false
    lazy var isPostingOrderFinished = false
    lazy var isFinishedSyncing = false
    
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.register(
            UITableViewCell.self,
            forCellReuseIdentifier: "cell")
        
        tableView.register(
            NoResultTableViewCell.self,
            forCellReuseIdentifier: NoResultTableViewCell.identifier)
        
        tableView.register(
            QueueTableViewCell.self,
            forCellReuseIdentifier: QueueTableViewCell.identifier)
        
        tableView.isHidden = true
        tableView.separatorStyle = .singleLine
        tableView.backgroundColor = Constants.whiteBackgroundColor
        tableView.isScrollEnabled = false
        return tableView
    }()
    
    private let noResultsLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = Constants.lightGrayColor
        label.font = .systemFont(ofSize: 16, weight: .light)
        label.text = "Empty Queue\nTransactions have been made offline will appear here."
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isHidden = true
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private let bottomContainer: UIView = {
        let container = UIView(frame: .zero)
        container.layer.masksToBounds = true
        container.clipsToBounds = true
        return container
    }()
    
    private let sendRequestButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = Constants.vcBackgroundColor
        button.setTitle("Send Request", for: .normal)
        button.setTitleColor(Constants.blackLabelColor, for: .normal)
        button.setTitleColor(Constants.lightGrayColor, for: .disabled)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.layer.cornerRadius = 8.0
        button.layer.masksToBounds = true
        button.setImage(UIImage(systemName: "arrow.clockwise.icloud.fill"), for: .normal)
        button.imageEdgeInsets.left = -25
        button.tintColor = Constants.blackLabelColor
        return button
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        isDeviceAuthorized()
        fetchQueue()
        fetchCoupons()
        fetchStoredSurcharges()
        createPostOrderArray()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchQueue()
        fetchCoupons()
        fetchStoredSurcharges()
        createPostOrderArray()
        
        title = "Queue"
        view.backgroundColor = Constants.whiteBackgroundColor
        
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        view.addSubview(bottomContainer)
        bottomContainer.addSubview(sendRequestButton)
        bottomContainer.addTopBorder(with: Constants.lightGrayBorderColor, andWidth: 0.5)
        sendRequestButton.addTarget(self, action: #selector(didTapSendRequest), for: .touchUpInside)
        
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(didPullDownToRefresh), for: .valueChanged)
        
        print("cartQueuedItems.isEmpty: \(cartQueuedItems.isEmpty)")
        
        print("fetchedCoupons from QueueVC: \(fetchedCoupons)")
        print("postOrderArray from QueueVC: \(postOrderArray)")
        print("updateCoupons from QueueVC: \(updateCoupons)")
        print("storedSurcharges from QueueVC: \(storedSurcharges)")
        
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let bottomContainerHeight: CGFloat = 75.0+view.safeAreaInsets.bottom
        tableView.frame = CGRect(
            x: 0,
            y: 0,
            width: view.width,
            height: view.height-bottomContainerHeight)
        
        bottomContainer.frame = CGRect(
            x: 0,
            y: tableView.bottom,
            width: view.width,
            height: bottomContainerHeight-view.safeAreaInsets.bottom)
//        bottomContainer.backgroundColor = .red
        
        let sendRequestButtonWidth: CGFloat = 175.0
        sendRequestButton.frame = CGRect(
            x: bottomContainer.width-sendRequestButtonWidth-20-view.safeAreaInsets.right,
            y: 20,
            width: sendRequestButtonWidth,
            height: 44)
    }
    
    @objc private func didPullDownToRefresh() {
        // refetch data
        
        DispatchQueue.main.async {
            if self.tableView.refreshControl?.isRefreshing == true {
                print("refreshing queue...")
            } else {
                print("fetching queue..")
            }
        }
        fetchQueue()
        fetchStoredSurcharges()
        createPostOrderArray()
    }
    
    
    private func calculateTotal(with totalSurcharge: Double){
        var priceSum: Double = 0 // refresh to zero
        
        let cart = cartQueuedItems
        
        print("cart: ", cart)
        for item in cart {
            let finalCost = item.cart_final_cost
            priceSum += finalCost
        }
        
        print("priceSum: \(priceSum), totalSurcharges: \(totalSurcharge)")
        
        let costWithSurcharge = priceSum + totalSurcharge
        
//        print("priceSum = \(priceSum)")
//        DispatchQueue.main.async {
//            self.subTotalValueLabel.text = String(format:"₱%.2f", costWithSurcharge)//self.priceSum)
//            self.vatableValueLabel.text = String(format:"₱%.2f", self.priceSum)
//            self.vatExepmtValueLabel.text = String(format:"₱%.2f", self.priceSum - (self.priceSum * 0.12))
//            self.totalValueLabel.text = String(format:"₱%.2f", costWithSurcharge)//self.priceSum)
//            self.vatValueLabel.text = String(format:"₱%.2f", self.priceSum * 0.12)
//        }
        
    }
    
    private func fetchCoupons() {
        APICaller.shared.getCoupons { result in
            switch result {
            case .success(let model):
                self.fetchedCoupons = model
                print("getCoupons from cartVC: \(model)")
                break
            case .failure(let error):
                print("getCoupons error from cartVC: \(error.localizedDescription)")
                break
            }
        }
    }
    
    private func createPostOrderArray() {
        postOrderArray.removeAll()
        
        guard let userID = UserDefaults.standard.string(forKey: "pin_entered_user_id"),
              let shift = UserDefaults.standard.string(forKey: "pin_entered_employee_shift"),
              let deviceID = UserDefaults.standard.string(forKey: "generated_device_id") else {
            print("either userID or shift or deviceID is nil")
            return
        }
        
        for item in queueItems {
            let queued = cartQueuedItems.filter({ $0.cart_order_id == item.queue_order_id }).sorted(by: { $0.cart_created_at ?? Date() < $1.cart_created_at ?? Date() })
            
            var lineItems = [LineItem]()
            
            for cartItem in queued {
                lineItems.append(
                    LineItem(product_id: Int(cartItem.cart_product_id),
                             variation_id: Int(cartItem.cart_variation_id),
                             quantity: Int(cartItem.cart_quantity),
                             tax_class: cartItem.cart_tax_class ?? ""))
            }
            
            let pwds = queued.filter({ $0.cart_discount_key == "pwd" })
            var discountedPWD = [ValueElement]()
            
            for pwd in pwds {
                discountedPWD.append(
                    ValueElement(
                        product_id: Int(pwd.cart_product_id),
                        variation_id: Int(pwd.cart_variation_id),
                        quantity: Int(pwd.cart_quantity))
                )
            }
            
            
            let seniors = queued.filter({ $0.cart_discount_key == "senior" })
            var discountedSenior = [ValueElement]()
            
            for senior in seniors {
                discountedSenior.append(
                    ValueElement(
                        product_id: Int(senior.cart_product_id),
                        variation_id: Int(senior.cart_variation_id),
                        quantity: Int(senior.cart_quantity))
                )
            }
            
            if !seniors.isEmpty {
                updateCoupons.append(UpdateCouponDataModel(discount_name: "SENIOR", product_ids: seniors.compactMap({
                    return Int($0.cart_product_id)
                })))
            }
            
            if !pwds.isEmpty {
                updateCoupons.append(UpdateCouponDataModel(discount_name: "PWD", product_ids: pwds.compactMap({
                    return Int($0.cart_product_id)
                })))
            }
            
//            guard let surcharges = surchargeData else {
//                return print("error fetching surcharges")
//            }
            
            var couponLine = [CouponLine]()
//            couponLine.append(CouponLine(code: "SENIOR", product_ids: seniors.compactMap({
//                return Int($0.cart_product_id)
//            })))
            
            if !seniors.isEmpty {
                couponLine.append(CouponLine(code: "SENIOR"))
            }
            if !pwds.isEmpty {
                couponLine.append(CouponLine(code: "PWD"))
            }
            
            postOrderArray.append(
                PostOrderModel(
                    payment_method: "cod",
                    status: "completed",
                    line_items: lineItems,
                    fee_lines: storedSurcharges.compactMap({
                        return FeeLine(
                            name: $0.surcharge_name ?? "",
                            total: "\($0.surcharge_amount)",
                            tax_class: $0.surcharge_tax_class ?? "")
                    }),
                    coupon_lines: couponLine,
                    meta_data: [
                        MetaData(
                            key: "cashier_user_id",
                            value: .string(userID)),
                        MetaData(
                            key: "shift",
                            value: .string(shift)),
                        MetaData(
                            key: "operating_day",
                            value: .string(Date().operatingDay())),
                        MetaData(
                            key: "order_id",
                            value: .string(item.queue_order_id ?? "-")),
                        MetaData(
                            key: "device_id",
                            value: .string(deviceID)),
                        MetaData(
                            key: "cash_tendered",
                            value: .string("\(item.queue_cash_tendered)")),
                        MetaData(
                            key: "pwd",
                            value: .valueElementArray(discountedPWD)),
                        MetaData(
                            key: "senior",
                            value: .valueElementArray(discountedSenior)),
                        MetaData(
                            key: "date_created_local",
                            value: .string(item.queue_created_at?.createdAtLocal() ?? "-"))
                    ]))
        }
        
//        print("postOrderArray createPostOrderArray(): \(postOrderArray)")
//        print("updateCoupons createPostOrderArray(): \(updateCoupons)")
    }
    
    @objc private func didTapSendRequest() {
        sendRequestButton.isEnabled = false
        tableView.isScrollEnabled = false
        print("Send request tapped")
        
        postOrderArrayIndex = 0
        updateCouponsIndex = 0
        
        
        guard let staffUserID = UserDefaults.standard.string(forKey: "pin_entered_user_id"),
              let shift = UserDefaults.standard.string(forKey: "pin_entered_employee_shift") else {
            print("either userID or shift is nil")
            showAlertWith(title: "Error sending request", message: "Please time in first", style: .alert)
            return
        }
        
        print("userID: \(staffUserID), shift: \(shift)")
        
        // post loop
        
        
        var lineItems: [LineItem] = []
        
            
        for cartItem in cartQueuedItems {
            lineItems.append(
                LineItem(
                    product_id: Int(cartItem.cart_product_id),
                    variation_id: Int(cartItem.cart_variation_id),
                    quantity: Int(cartItem.cart_quantity),
                    tax_class: cartItem.cart_tax_class ?? ""))
        }
        
        
//        createPostOrderArray()
        
//        print("fetchedCoupons didTapSendRequest: \(fetchedCoupons)")
//        print("postOrderArray didTapSendRequest: \(postOrderArray)")
//        print("updateCoupons didTapSendRequest: \(updateCoupons)")
//        let mockMeta = MetaData(key: "Error", value: .string("error"))
        
        
        if postOrderArray.isEmpty {
            showAlertWith(title: "", message: "No Queue items", style: .actionSheet)
        } else {
            
//            print("postModel.count: \(postOrderArray.count)")
//            print("queueItems.count: \(queueItems.count)")
            
            for postModel in postOrderArray {
                if let metaOrderID = postModel.meta_data.first(where: { $0.key == "order_id" }) {
                    let orderID = metaOrderID.value.returnValue()
                    
                    let matchedQueue = queueItems.first(where: { $0.queue_order_id == orderID })
                    let titleCode = matchedQueue?.queue_coupon_title ?? ""
                        
                    let couponDataModel = UpdateCouponDataModel(
                        discount_name: titleCode,
                        product_ids: matchedQueue?.queue_product_ids ?? [])
                    
                    let couponID = self.fetchedCoupons.first(where: { $0.code == titleCode })?.id ?? 0
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        
                        if !couponDataModel.discount_name.isEmpty {
                            
                            APICaller.shared.updateCouponWithCode(with: orderID, with: couponID, with: couponDataModel) { success in
                                switch success {
                                case true:
                                    print("SUCCESS PUT COUPON WITH ID: \(couponID), CODE: \(titleCode), productIDS: \(matchedQueue?.queue_product_ids ?? []), FOR ORDER: \(orderID)")
                                    
                                    let postOrderModelId = postModel.meta_data.first(where: { $0.key == "order_id"})?.value.returnValue() ?? "-"
                                    
                                    APICaller.shared.postOrder(with: postModel) { success in
                                        switch success {
                                        case true:
                                            print("success from postOrderArray \(postOrderModelId) using couponmodel: \(couponDataModel)")
                                            
                                            self.postOrderArrayIndex += 1
                                            
                                            print("postOrderArray.count: \(self.postOrderArray.count) == postOrderArrayIndex: \(self.postOrderArrayIndex)")
                                            
                                            if self.postOrderArrayIndex == self.postOrderArray.count {
                                                self.isFinishedSyncing = true
                                                
                                                print("dispatch group notified! DELETE")
                                                
                                                let alert = UIAlertController(title: "Sync finished successfully", message: "", preferredStyle: .alert)
                                                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                                                    
//                                                    for item in self.cartQueuedItems {
//                                                        self.deleteCartQueuedItem(cartItem: item)
//                                                        print("deleting queued cart item: \(item.cart_order_id ?? "-")-\(item.cart_product_name ?? "-")")
//                                                    }
//                                                    for queue in self.queueItems {
//                                                        self.deleteQueue(queueItem: queue)
//                                                        print("deleting queue cart item: \(queue.queue_order_id ?? "-")")
//                                                    }
                                                }))
                                                
                                                DispatchQueue.main.async {
                                                    self.present(alert, animated: true, completion: nil)
                                                }
                                            }
                                            break
                                        case false:
                                            print("failed from postOrderArray: \(postOrderModelId)")
                                            break
                                        }
                                    }
                                    
                                    break
                                case false:
                                    print("failed PWD updateCoupon")
                                    self.isFinishedSyncing = false
                                    
                                    let alert = UIAlertController(title: "Sync Failed.", message: "No internet connection. Please check your connection and try again.", preferredStyle: .alert)
                                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
                                        self.fetchQueue()
                                        self.fetchStoredSurcharges()
                                        self.createPostOrderArray()
                                        self.sendRequestButton.isEnabled = true
                                        self.tableView.isScrollEnabled = true
                                    }))
                                    
                                    DispatchQueue.main.async{
                                        self.present(alert, animated: true, completion: nil)
                                    }
                                    break
                                }
                            }
                        } else {
                            
                            let postOrderModelId = postModel.meta_data.first(where: { $0.key == "order_id"})?.value.returnValue() ?? "-"
                            
                            APICaller.shared.postOrder(with: postModel) { success in
                                switch success {
                                case true:
                                    print("success from postOrderArray \(postOrderModelId) using couponmodel: \(couponDataModel)")
                                    
                                    self.postOrderArrayIndex += 1
                                    
                                    print("postOrderArray.count: \(self.postOrderArray.count) == postOrderArrayIndex: \(self.postOrderArrayIndex)")
                                    
                                    if self.postOrderArrayIndex == self.postOrderArray.count {
                                        self.isFinishedSyncing = true
                                        
                                        print("dispatch group notified! DELETE")
                                        
                                        let alert = UIAlertController(title: "Sync finished successfully", message: "", preferredStyle: .alert)
                                        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                                            
//                                            for item in self.cartQueuedItems {
//                                                self.deleteCartQueuedItem(cartItem: item)
//                                                print("deleting queued cart item: \(item.cart_order_id ?? "-")-\(item.cart_product_name ?? "-")")
//                                            }
//                                            for queue in self.queueItems {
//                                                self.deleteQueue(queueItem: queue)
//                                                print("deleting queue cart item: \(queue.queue_order_id ?? "-")")
//                                            }
                                        }))
                                        
                                        DispatchQueue.main.async {
                                            self.present(alert, animated: true, completion: nil)
                                        }
                                    }
                                    break
                                case false:
                                    print("failed from postOrderArray: \(postOrderModelId)")
                                    self.isFinishedSyncing = false
                                    
                                    let alert = UIAlertController(title: "Sync Failed.", message: "No internet connection. Please check your connection and try again.", preferredStyle: .alert)
                                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
                                        self.fetchQueue()
                                        self.createPostOrderArray()
                                        self.sendRequestButton.isEnabled = true
                                        self.tableView.isScrollEnabled = true
                                    }))
                                    
                                    DispatchQueue.main.async{
                                        self.present(alert, animated: true, completion: nil)
                                    }
                                    break
                                }
                            }
                        }
                    }
                }
            }
        }
        
    }
    
    private func postOrderFromArray(with postModel: PostOrderModel) {
        
        let postOrderModelId = postModel.meta_data.first(where: { $0.key == "order_id"})?.value.returnValue() ?? "-"
        
        APICaller.shared.postOrder(with: postModel) { [weak self] success in
            guard let strongSelf = self else { return }
            switch success {
            case true:
                print("success from postOrderArray \(postOrderModelId)")
                strongSelf.postOrderArrayIndex += 1
                
                print("postOrderArray.count: \(strongSelf.postOrderArray.count) == postOrderArrayIndex: \(strongSelf.postOrderArrayIndex)")
                
                if strongSelf.postOrderArrayIndex == strongSelf.postOrderArray.count {
                    strongSelf.isFinishedSyncing = true
                    
                    let alert = UIAlertController(title: "Sync finished successfully", message: "", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                        
                        // 4909-4913 - check orders
                        // 5105 - 5110
                        // 5111 - 5116
                        // 5117 - 5122: 5117 is
//                        for item in strongSelf.cartQueuedItems {
//                            strongSelf.deleteCartQueuedItem(cartItem: item)
//                            print("deleting queued cart item: \(item.cart_order_id ?? "-")-\(item.cart_product_name ?? "-")")
//                        }
//                        for queue in strongSelf.queueItems {
//                            strongSelf.deleteQueue(queueItem: queue)
//                            print("deleting queue cart item: \(queue.queue_order_id ?? "-")")
//                        }
                        
                    }))
                    
                    DispatchQueue.main.async {
                        strongSelf.present(alert, animated: true, completion: nil)
                    }
                }
                break
            case false:
                print("failed from postOrderArray: \(postOrderModelId)")
                break
            }
        }
    }
    
    private func putUpdateCoupon(with code: String?, with postModel: PostOrderModel, with productIds: [Int]) {
        
        let metaOrderID = postModel.meta_data.first(where: { $0.key == "order_id" })?.value.returnValue() ?? "-"
        let couponDataModel = UpdateCouponDataModel(discount_name: code ?? "", product_ids: productIds)
        let couponID = fetchedCoupons.first(where: { $0.code == code })?.id ?? 0
        
//        print("PUT couponTitle: \(code ?? "")")
//        print("PUT couponID: \(couponID)")
//        print("PUT couponDataModel: \(couponDataModel)")
        
//        print("putUpdateCouponOrderModel: \(postModel)")
        
        
        // 4959
        APICaller.shared.updateCouponWithCode(with: "order id", with: couponID, with: couponDataModel) { success in
            switch success {
            case true:
                print("SUCCESS PUT COUPON WITH ID: \(couponID), CODE: \(code ?? ""), productIDS: \(productIds), FOR ORDER: \(metaOrderID)")
                
//                DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
//                DispatchQueue.main.async {
//                    self?.postOrderFromArray(with: postModel)
//                }
                
                let postOrderModelId = postModel.meta_data.first(where: { $0.key == "order_id"})?.value.returnValue() ?? "-"
                
                APICaller.shared.postOrder(with: postModel) { updateSuccess in
                    switch updateSuccess {
                    case true:
                        print("success from postOrderArray \(postOrderModelId)")
                        self.postOrderArrayIndex += 1
                        
                        print("postOrderArray.count: \(self.postOrderArray.count) == postOrderArrayIndex: \(self.postOrderArrayIndex)")
                        
                        if self.postOrderArrayIndex == self.postOrderArray.count {
                            self.isFinishedSyncing = true
                            
                            let alert = UIAlertController(title: "Sync finished successfully", message: "", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                                
                                // 4909-4913 - check orders
                                // 5105 - 5110
                                // 5111 - 5116
                                // 5117 - 5122: 5117 is
        //                        for item in strongSelf.cartQueuedItems {
        //                            strongSelf.deleteCartQueuedItem(cartItem: item)
        //                            print("deleting queued cart item: \(item.cart_order_id ?? "-")-\(item.cart_product_name ?? "-")")
        //                        }
        //                        for queue in strongSelf.queueItems {
        //                            strongSelf.deleteQueue(queueItem: queue)
        //                            print("deleting queue cart item: \(queue.queue_order_id ?? "-")")
        //                        }
                            }))
                            
                            DispatchQueue.main.async {
                                self.present(alert, animated: true, completion: nil)
                            }
                        }
                        break
                    case false:
                        print("failed from postOrderArray: \(postOrderModelId)")
                        break
                    }
                }
                
//                break
            case false:
                print("failed PWD updateCoupon")
                self.isFinishedSyncing = false
                
                let alert = UIAlertController(title: "Sync Failed.", message: "No internet connection. Please check your connection and try again.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
                    self.fetchQueue()
                    self.createPostOrderArray()
                    self.sendRequestButton.isEnabled = true
                    self.tableView.isScrollEnabled = true
                }))
                
                DispatchQueue.main.async{
                    self.present(alert, animated: true, completion: nil)
                }
                break
            }
        }
    }
    
    
    private func showAlertWith(title: String, message: String, style: UIAlertController.Style = .alert) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: style)
//        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: { (action) in
//            self.dismiss(animated: true, completion: nil)
//        }))
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
}

extension OldQueueViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  queueItems.count//queue.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
//        let model = queue[indexPath.row]
//        cell.textLabel?.text = model.transaction_id
//        return cell
        
        guard let cell = tableView.dequeueReusableCell(
                withIdentifier: QueueTableViewCell.identifier,
                for: indexPath) as? QueueTableViewCell else {
            return UITableViewCell()
        }
        
        cell.printImageView.isHidden = true
        
        let sortedQueue = queueItems.sorted(by: { $0.queue_created_at ?? Date() > $1.queue_created_at ?? Date()} )
        let model = sortedQueue[indexPath.row]//queue[indexPath.row]
        
        
        
//        cell.configure(
//            withViewModel: QueueTableViewCellViewModel(
//                name: model.transaction_id,
//                date: model.date_time,
//                info: model.cashier_info,
//                items: model.items,
//                status: model.status))
        
        let cartQueue = cartQueuedItems.filter({ $0.cart_order_id == model.queue_order_id })
        var totalQty = 0
        cartQueue.forEach({ item in
            totalQty += Int(item.cart_quantity)
        })
        
        cell.configure(withViewModel: QueueTableViewCellViewModel(
            name: model.queue_order_id ?? "-",
            date: model.queue_created_at?.queueDatetimeFormat() ?? "-", // "\(model.queue_created_at ?? Date())"
            info: UserDefaults.standard.string(forKey: "pin_entered_username") ?? "-",
            items: totalQty, //cartQueue.count,
            status: cartQueue.first?.cart_status?.firstCapitalized ?? ""
        ))
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90.0
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let sortedQueue = queueItems.sorted(by: { $0.queue_created_at ?? Date() > $1.queue_created_at ?? Date()} )
        let model = sortedQueue[indexPath.row]//queue[indexPath.row]
        let cartQueue = cartQueuedItems.filter({ $0.cart_order_id == model.queue_order_id })
        
        let testQueue = FakeQueueListItems(
            id: 0,
            transaction_id: model.queue_order_id ?? "-",
            date_time: "\(model.queue_created_at ?? Date())",
            orders: cartQueue.compactMap({
                FakeOrders(
                    product_name: $0.cart_variation_name ?? "-",
                    qty: Int($0.cart_quantity),
                    sub_total: $0.cart_final_cost,
                    image: $0.cart_product_image ?? "-",
                    price: $0.cart_product_cost,
                    discounted_price: $0.cart_discounted_product_cost)
            }),
            cashier_info: AuthManager.shared.pinEnteredUsername ?? "-",
            transaction_type: "cod",
            items: cartQueue.count,
            status: cartQueue.first?.cart_status ?? "-",
            cash_tendered: model.queue_cash_tendered,
            total_surcharge: totalSurcharge)
        
        print("Product IDS with Discount: \(model.queue_product_ids)")
        
//        let vc = QueueItemViewController(queueItem: testQueue)
        let vc = QueueItemViewController(queueItem: model, orders: cartQueue)
        vc.title = model.queue_order_id
        navigationController?.pushViewController(vc, animated: true)
        
//        let model = queue[indexPath.row]
////        print("Did tap", model.transaction_id)
//        let vc = QueueItemViewController(queueItem: model)
//        vc.title = model.transaction_id
//        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func shouldShowNoResultsLabel() {
        view.addSubview(noResultsLabel)
        noResultsLabel.sizeToFit()
        noResultsLabel.isHidden = false
        noResultsLabel.center = view.center
    }
    
    
}

extension OldQueueViewController {
    
    public func fetchQueue() {
        do {
            // let items = try context.fetch(ToDoListItem.fetchRequest())
            
            queueItems = try context.fetch(Queue_Entity.fetchRequest())
            
            let cart: [Cart_Entity] = try context.fetch(Cart_Entity.fetchRequest())
            let sortedCart = cart.sorted(by: { $0.id < $1.id })
            cartQueuedItems = sortedCart.filter({ $0.cart_status == "queue"})
            
            if !cartQueuedItems.isEmpty {
                self.sendRequestButton.isEnabled = true
                self.tableView.isHidden = false
                self.bottomContainer.isHidden = false
                self.noResultsLabel.isHidden = true
                self.tableView.isScrollEnabled = true
            } else {
                self.sendRequestButton.isEnabled = false
                self.tableView.isHidden = true
                
                self.bottomContainer.isHidden = true
                self.shouldShowNoResultsLabel()
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.tableView.refreshControl?.endRefreshing()
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    
    public func fetchStoredSurcharges() {
        storedSurcharges.removeAll()
        do {
            storedSurcharges = try context.fetch(Surcharges_Entity.fetchRequest())
            print("fetchStoredSurcharges: ", storedSurcharges.first?.surcharge_name ?? "no surcharges")
        } catch {
            print(error.localizedDescription)
        }
    }
    
    // delete cart and queue
    
    public func deleteCartQueuedItem(cartItem: Cart_Entity) {
        context.delete(cartItem)
        
        do {
            try context.save()
            fetchQueue()
        } catch {
            // error
        }
    }
    
    public func deleteQueue(queueItem: Queue_Entity) {
        context.delete(queueItem)
        
        do {
            try context.save()
            fetchQueue()
        } catch {
            // error
        }
    }
    
}
