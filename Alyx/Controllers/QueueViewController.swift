//
//  QueueViewController.swift
//  Jeeves-dev
//
//  Created by Jervy Umandap on 2/4/22.
//

import UIKit
import CoreData


class QueueViewController: UIViewController {
    static let shared = CartViewController()
    
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    private var fetchedCoupons: [CouponData] = []
    
    private var timer = Timer()
    
//    var queue = [FakeQueueItems]()
    private var queue = [FakeQueueListItems]()
    private var queueItems = [Queue_Entity]()
    private var cartQueuedItems = [Cart_Entity]()
    
    private var couponsEntity = [Coupons_Entity]()
    
    // for new process
    private var queuedOldestItem: Queue_Entity?
    private var cartQueuedOldestItem: [Cart_Entity]?
    
    private var updateCouponModel: UpdateCouponDataModel?
    private var postOrderModel: PostOrderModel?
    
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
    lazy var isSyncingFinished = false
    lazy var hasStartedSyncing = false
    
    
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
        button.setTitle("Processing...", for: .disabled)
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
        createPostOrder()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchQueue()
        fetchCoupons()
        getCouponsEntity()
        fetchStoredSurcharges()
        createPostOrder()
        
        
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
//        createPostOrder()
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
    
    private func getCouponsEntity() {
        do {
            couponsEntity.removeAll()
            couponsEntity = try context.fetch(Coupons_Entity.fetchRequest())
        } catch {
            // error
            print("failed to getCouponsEntity: ", error.localizedDescription)
        }
    }
    
    private func createPostOrder() {
        
        guard let userID = UserDefaults.standard.string(forKey: "pin_entered_user_id"),
              let shift = UserDefaults.standard.string(forKey: "pin_entered_employee_shift"),
              let deviceID = UserDefaults.standard.string(forKey: "generated_device_id") else {
            print("either userID or shift or deviceID is nil")
            return
        }
        
        guard let queuedOldestItem = queuedOldestItem,
              let cartQueuedOldestItem = cartQueuedOldestItem else {
            return
        }
        
        updateCouponModel = UpdateCouponDataModel(
            discount_name: queuedOldestItem.queue_coupon_title ?? "",
            product_ids: queuedOldestItem.queue_product_ids)
        
        if !cartQueuedOldestItem.isEmpty {
            var lineItems = [LineItem]()
            var discounted = [ValueElement]()
            var couponLines = [CouponLine]()
            
            if !queuedOldestItem.queue_product_ids.isEmpty {
                couponLines.append(CouponLine(code: queuedOldestItem.queue_coupon_title?.uppercased() ?? ""))
            }
            //orderJSONtoString
            
            for cartItem in cartQueuedOldestItem {
                lineItems.append(
                    LineItem(product_id: Int(cartItem.cart_product_id),
                             variation_id: Int(cartItem.cart_variation_id),
                             quantity: Int(cartItem.cart_quantity),
                             tax_class: cartItem.cart_tax_class ?? ""))
                
                if cartItem.cart_discount_key != "" {
                    discounted.append(ValueElement(
                        product_id: Int(cartItem.cart_product_id),
                        variation_id: Int(cartItem.cart_variation_id),
                        quantity: Int(cartItem.cart_quantity)))
                }
                
                postOrderModel = PostOrderModel(
                    payment_method: "cod",
                    status: "completed",
                    line_items: lineItems,
                    fee_lines: storedSurcharges.compactMap({
                        return FeeLine(
                            name: $0.surcharge_name ?? "",
                            total: "\($0.surcharge_amount)",
                            tax_class: $0.surcharge_tax_class ?? "")
                    }),
                    coupon_lines: couponLines,
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
                            value: .string(queuedOldestItem.queue_order_id ?? "-")),
                        MetaData(
                            key: "device_id",
                            value: .string(deviceID)),
                        MetaData(
                            key: "cash_tendered",
                            value: .string("\(queuedOldestItem.queue_cash_tendered)")),
                        MetaData(
                            key: "remarks",
                            value: .string(queuedOldestItem.queue_remarks ?? "No remarks added")),
                        MetaData(
                            key: "date_created_local",
                            value: .string(queuedOldestItem.queue_created_at?.createdAtLocal() ?? "-")),
                        MetaData(
                            key: "line_items_count",
                            value: .string("\(lineItems.count)")),
                        MetaData(
                            key: queuedOldestItem.queue_coupon_title ?? "discount",
                            value: .valueElementArray(discounted))
                    ])
            }
        }
        
        do {
            
            let orderJson = try JSONEncoder().encode(postOrderModel)
            let orderJSONtoString = String(data: orderJson, encoding: .utf8)!
            print("postOrderModel \(queuedOldestItem.queue_order_id ?? ""): \(orderJSONtoString)")
            
            
            let couponJson = try JSONEncoder().encode(updateCouponModel)
            let couponJSONtoString = String(data: couponJson, encoding: .utf8)!
            print("updateCouponModel \(queuedOldestItem.queue_order_id ?? ""): \(couponJSONtoString)")
            
        } catch {
            print("error decoding coupon and order model \(error.localizedDescription)")
        }
        
        // trigger send request
        if hasStartedSyncing {
            DispatchQueue.main.async {
                self.sendRequestButton.sendActions(for: .touchUpInside)
            }
        }
    }
    
    
    func displayToastMessage(_ message : String) {
        
        let toastView = UILabel()
        toastView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        toastView.textColor = UIColor.white
        toastView.textAlignment = .center
        toastView.font = UIFont.preferredFont(forTextStyle: .caption1)
        toastView.layer.cornerRadius = 8.0 // 25
        toastView.layer.masksToBounds = true
        toastView.text = message
        toastView.numberOfLines = 0
        toastView.alpha = 0
        toastView.translatesAutoresizingMaskIntoConstraints = false
        
        guard let window = UIApplication.shared.mainKeyWindow else {
            return
        }
        window.addSubview(toastView)
        
        let horizontalCenterContraint: NSLayoutConstraint = NSLayoutConstraint(item: toastView, attribute: .centerX, relatedBy: .equal, toItem: window, attribute: .centerX, multiplier: 1, constant: 0)
        
        let widthContraint: NSLayoutConstraint = NSLayoutConstraint(item: toastView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 275)
        
        let verticalContraint: [NSLayoutConstraint] = NSLayoutConstraint.constraints(withVisualFormat: "V:|-(>=200)-[loginView(==50)]-68-|", options: [.alignAllCenterX, .alignAllCenterY], metrics: nil, views: ["loginView": toastView])
        
        NSLayoutConstraint.activate([horizontalCenterContraint, widthContraint])
        NSLayoutConstraint.activate(verticalContraint)
        
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn, animations: {
            toastView.alpha = 1
        }, completion: nil)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double((Int64)(2 * NSEC_PER_SEC)) / Double(NSEC_PER_SEC), execute: {
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn, animations: {
                toastView.alpha = 0
            }, completion: { finished in
                toastView.removeFromSuperview()
            })
        })
    }
    
    @objc private func didTapSendRequest() {
        
        DispatchQueue.main.async {
            self.sendRequestButton.isEnabled = false
        }
        
        guard let updateCouponModel = updateCouponModel,
              let postOrderModel = postOrderModel,
              let queuedOldestItem = queuedOldestItem,
              let cartQueuedOldestItem = cartQueuedOldestItem else {
            return
        }
        
        if let couponID = couponsEntity.first(where: { $0.coupon_title?.lowercased() == queuedOldestItem.queue_coupon_title?.lowercased() })?.coupon_id {
            
            APICaller.shared.updateCouponWithCode(with: queuedOldestItem.queue_order_id ?? "", with: Int(couponID), with: updateCouponModel) { success in
                switch success {
                case true:
                    
                    APICaller.shared.postOrder(with: postOrderModel) { successPost in
                        switch success {
                        case true:
                            self.hasStartedSyncing = true
                            // delete cart item and queue
                            print("Success updating coupon and posting order for: \(queuedOldestItem.queue_order_id ?? "-")")
                            
                            print("to delete: \(queuedOldestItem.queue_order_id ?? "") - \(cartQueuedOldestItem.count)")
                            DispatchQueue.main.async {
                                self.sendRequestButton.isEnabled = true
                                self.deleteCartQueuedItem(cartItems: cartQueuedOldestItem, queueItem: queuedOldestItem)
                                self.displayToastMessage("Order queue sent successfully!")
                                
//                                if let orderId = postOrderModel.meta_data.first(where: { $0.key == "order_id" })?.value {
//                                    self.displayToastMessage("Order \(orderId.returnValue()) sent successfully!")
//                                }
                                
                            }
                            
                            break
                        case false:
                            break
                        }
                    }
                    
                    break
                case false:
                    print("failed PWD updateCoupon")
                    self.hasStartedSyncing = false
                    self.isSyncingFinished = false
                    
                    let alert = UIAlertController(title: "Sync Failed.", message: "No internet connection. Please check your connection and try again.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
                        self.fetchQueue()
                        self.fetchStoredSurcharges()
                        self.createPostOrder()
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
            APICaller.shared.postOrder(with: postOrderModel) { successPost in
                switch successPost {
                case true:
                    self.hasStartedSyncing = true
                    // delete cart item and queue
                    print("Success posting order for: \(queuedOldestItem.queue_order_id ?? "-")")
                    
                    print("to delete: \(queuedOldestItem.queue_order_id ?? "") - \(cartQueuedOldestItem.count)")
                    DispatchQueue.main.async {
                        self.sendRequestButton.isEnabled = true
                        self.deleteCartQueuedItem(cartItems: cartQueuedOldestItem, queueItem: queuedOldestItem)
                        self.displayToastMessage("Order queue sent successfully!")
                        
//                        if let orderId = postOrderModel.meta_data.first(where: { $0.key == "order_id" })?.value {
//                            self.displayToastMessage("Order \(orderId.returnValue()) sent successfully!")
//                        }
                    }
                    break
                case false:
                    print("failed PWD updateCoupon")
                    self.hasStartedSyncing = false
                    
                    let alert = UIAlertController(title: "Sync Failed.", message: "No internet connection. Please check your connection and try again.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
                        self.fetchQueue()
                        self.fetchStoredSurcharges()
                        self.createPostOrder()
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
    
    
    private func showAlertWith(title: String, message: String, style: UIAlertController.Style = .alert) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: style)
//        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: { (action) in
//            self.dismiss(animated: true, completion: nil)
//        }))
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
}

extension QueueViewController: UITableViewDelegate, UITableViewDataSource {
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

extension QueueViewController {
    
    public func fetchQueue() {
        do {
            // let items = try context.fetch(ToDoListItem.fetchRequest())
            
            let queueItemsFetched = try context.fetch(Queue_Entity.fetchRequest())
            queueItems = queueItemsFetched.filter({ $0.queue_order_id != nil })
            let descendingQueueItems = queueItems.sorted(by: { $0.queue_created_at ?? Date() > $1.queue_created_at ?? Date() })
            
//            print("descendingQueueItems: \(descendingQueueItems)")
            
            let cart: [Cart_Entity] = try context.fetch(Cart_Entity.fetchRequest())
            let sortedCart = cart.sorted(by: { $0.cart_created_at ?? Date() < $1.cart_created_at ?? Date()})
            cartQueuedItems = sortedCart.filter({ $0.cart_status == "queue"})
            
            queuedOldestItem = descendingQueueItems.last
            cartQueuedOldestItem = cartQueuedItems.filter({ $0.cart_order_id ==  queuedOldestItem?.queue_order_id })
            
            print("fetchQueue: \(queuedOldestItem?.queue_order_id ?? "-") == \(cartQueuedOldestItem?.count)")
            
            
            guard let cartQueuedOldestItem = cartQueuedOldestItem else { return }
            
            if !cartQueuedOldestItem.isEmpty {
                DispatchQueue.main.async {
                    self.sendRequestButton.isEnabled = true
                    self.tableView.isHidden = false
                    self.bottomContainer.isHidden = false
                    self.noResultsLabel.isHidden = true
                    self.tableView.isScrollEnabled = true
                }
                
                self.createPostOrder()
            } else {
                DispatchQueue.main.async {
                    self.hasStartedSyncing = false
                    self.isSyncingFinished = true
                    
                    self.sendRequestButton.isEnabled = false
                    self.tableView.isHidden = true
                    
                    self.bottomContainer.isHidden = true
                    self.shouldShowNoResultsLabel()
                }
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
    
    public func deleteCartQueuedItem(cartItems: [Cart_Entity], queueItem: Queue_Entity) {
        
        do {
            for item in cartItems {
                context.delete(item)
            }
            context.delete(queueItem)
            
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
