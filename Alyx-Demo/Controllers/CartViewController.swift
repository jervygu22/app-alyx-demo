//
//  CartViewController.swift
//  Jeeves-dev
//
//  Created by Jervy Umandap on 2/4/22.
//

import UIKit
import SwipeCellKit
import SDWebImage
import CoreData
import GMStepper


enum CartSection {
    case transactionType(viewModels: [TransactionTypeCellViewModel])
    case orders(viewModels: [OrderCellViewModel])

    var title: String {
        switch self {
        case .transactionType:
            return "Transaction Type"
        case .orders:
            return "Items"
        }
    }
}

protocol CartViewControllerDelegate {
    func shouldReloadDataFromCartVC()
}

protocol CartViewControllerCashierInfoDelegate: AnyObject {
    func cashierData(data: CashierInfoViewModel)
}

class CartViewController: UIViewController, CashMethodViewControllerDelegate, CartItemsCollectionViewCellDelegate {
    
    static let shared = CartViewController()
    
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    enum CoreDataError: Error {
        case noAppDelegate
    }
    
    var cartViewControllerDelegate: CartViewControllerDelegate?
    weak var cartViewControllerCashierInfoDelegate: CartViewControllerCashierInfoDelegate?
    
    private var fetchedAllUsers = [User]()
    private var usersEntity = [Users_Entity]()
    public var superVisor = Users_Entity()
    
    private var cartEntity = [Cart_Entity]()
    private var cart = [Cart_Entity]()
    private var coupons = [Coupons_Entity]()
//    public var coreDataArray: [NSManagedObject] = []
    public var cartSelectedItems = [Cart_Entity]()
    
    private var priceSum: Double = 0 // price sum of cart
    
    lazy var cartItemCount: Int? = 0
    
//    private var nsArrayOfCoreData: NSArray = []
    
    private var orders: [Order] = []
    private var transactionTypes: [TransactionType] = []
    
    static var transactionTypesCount: Int?

    private var sections = [CartSection]()
    private var selectedDiscountForAll: String = ""
    
    private var couponsData = [CouponData]()
    
    private var cashierName = UserDefaults.standard.string(forKey: "pin_entered_username")?.capitalized
    private var cashierInfo = UserDefaults.standard.stringArray(forKey: "pin_entered_user_roles")?.first
    private var cashierImage = UserDefaults.standard.string(forKey: "pin_entered_user_image")

    private var collectionView: UICollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewCompositionalLayout { (sectionIndex, _) -> NSCollectionLayoutSection? in
            return CartViewController.createSectionLayout(section: sectionIndex)
        })

    private let spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView()
        spinner.tintColor = .systemRed
        spinner.hidesWhenStopped = true
        return spinner
    }()

    private let bottomContainer: CartBottomView = {
        let container = CartBottomView()
        container.layer.masksToBounds = true
        container.clipsToBounds = true
        return container
    }()
    
    private let noResultsLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = Constants.lightGrayColor
        label.font = .systemFont(ofSize: 16, weight: .light)
        label.text = "No orders\nItems that you added will appear here."
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isHidden = true
        label.adjustsFontSizeToFitWidth = true
        return label
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
        title = "Cart"
        view.backgroundColor = Constants.whiteBackgroundColor
        configureNavItem()
        
        configureCollectionView()

        view.addSubview(spinner)
        view.addSubview(bottomContainer)
        bottomContainer.cartBottomViewDelegate = self
        
        fetchAllUsers()
        fetchUsers()
        fetchCoupons()
        fetchCart()
        fetchData()
        
        configureTransactionTypes()
//        print(coreDataArray)
        
        calculateTotal()
//        bottomContainer.totalValueLabel.text = String(format:"₱%.2f", priceSum)
        cartItemCount = cart.count
        
        print("cart: ", cart)
        
        print("cartSelectedItems: \(cartSelectedItems.count)")
        
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
        demoLabel.backgroundColor = .systemRed
//        demoLabel.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        demoLabel.backgroundColor = UIColor.red.withAlphaComponent(0.75)
    }
    
    public func defaultEmptyView(with message: String) {
        noResultsLabel.sizeToFit()
        noResultsLabel.text = message
        noResultsLabel.isHidden = false
        noResultsLabel.center = view.center
        view.addSubview(noResultsLabel)
    }
    
    private func fetchAllUsers() {
        APICaller.shared.getAllUsers2 { [weak self] result in
            switch result {
            case .success(let model):
                self?.fetchedAllUsers = model.data
                break
            case .failure(let error):
                print("fetchAllUsers error: \(error.localizedDescription)")
                break
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
    
    var hasCartItems: Bool {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<Cart_Entity>(entityName: "Cart_Entity")
        do {
            let count = try context.count(for: fetchRequest)
            
            if count > 0 {
                return true
            } else {
                return false
            }
        } catch {
            print("Coredata error")
            return false
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let bottomContainerHeight: CGFloat = 220.0

        collectionView.frame = CGRect(
            x: 0,
            y: 0,
            width: view.width,
            height: view.height-bottomContainerHeight)

        bottomContainer.frame = CGRect(
            x: 20,
            y: collectionView.bottom,
            width: view.width-40,
            height: bottomContainerHeight-view.safeAreaInsets.bottom)
        bottomContainer.addTopBorder(with: Constants.lightGrayBorderColor, andWidth: 0.5)
//        bottomContainer.backgroundColor = .systemGreen
        
        layoutDemoLabel()
    }
    
    private func configureTransactionTypes() {
//        self.transactionTypes.append(
//            TransactionType(
//                id: 1,
//                transaction_name: "regular",
//                percent: 0,
//                key: "",
//                tax_class: ""))
        
//        for cou in coupons {
//            transactionTypes.append(
//                TransactionType(
//                    id: Int(cou.coupon_id),
//                    transaction_name: cou.coupon_title ?? "-",
//                    percent: cou.coupon_amount_percent,
//                    key: cou.coupon_code ?? "-",
//                    tax_class: "reduced-rate"))
//        }
        
//        self.transactionTypes.append(
//            TransactionType(
//                id: 2,
//                transaction_name: "senior",
//                percent: 0.2,
//                key: "senior",
//                tax_class: "reduced-rate")) //vat-exempt
//        self.transactionTypes.append(
//            TransactionType(
//                id: 3,
//                transaction_name: "pwd",
//                percent: 0.2,
//                key: "pwd",
//                tax_class: "reduced-rate")) //vat-exempt
        
        /// populate transactionTypes with this
//        couponsData.forEach({ coup in
//            self.transactionTypes.append(
//                TransactionType(
//                    id: coup.id,
//                    transaction_name: coup.title.uppercased(),
//                    percent: coup.amount_per_cent,
//                    key: coup.code,
//                    tax_class: "reduced-rate")
//            )
//        })
        
    }
    
    private func configureCartItems(with indexPath: IndexPath) {
        
    }
    
    private func fetchData() {
        self.configureModels(transactionTypes: transactionTypes, orders: orders)
    }
    
    private func fetchCoupons() {
//        APICaller.shared.getCoupons { result in
//            switch result {
//            case .success(let model):
//                self.couponsData = model
//                print("getCoupons from cartVC: \(model)")
//            case .failure(let error):
//                print("getCoupons error from cartVC: \(error.localizedDescription)")
//            }
//        }
        
        
        do {
            // let items = try context.fetch(ToDoListItem.fetchRequest())
            let couponsEntity = try context.fetch(Coupons_Entity.fetchRequest())
            coupons = couponsEntity.sorted(by: { $0.coupon_id < $1.coupon_id })
            print("fetchedCoupons: \(coupons)")
            
            for cou in coupons {
                transactionTypes.append(
                    TransactionType(
                        id: Int(cou.coupon_id),
                        transaction_name: cou.coupon_title?.uppercased() ?? "-",
                        percent: cou.coupon_amount_percent,
                        key: cou.coupon_code ?? "-",
                        tax_class: "reduced-rate"))
            }
            
            CartViewController.transactionTypesCount = coupons.count
            
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        } catch {
            print(error.localizedDescription)
        }
    }

    private func configureModels(transactionTypes: [TransactionType], orders: [Order]) {
        self.orders = orders
        
        if !transactionTypes.isEmpty {
            sections.append(.transactionType(viewModels: transactionTypes.compactMap({
                return TransactionTypeCellViewModel(
                    id: $0.id,
                    name: $0.transaction_name,
                    percent: $0.percent,
                    key: $0.key,
                    tax_class: $0.tax_class)
            })))
        } else {
            
//            sections.append(.transactionType(viewModels: [
//                TransactionTypeCellViewModel(
//                    id: 0,
//                    name: "Regular",
//                    percent: 0,
//                    key: "regular",
//                    tax_class: "")
//            ]))
            
        }
        
        sections.append(.orders(viewModels: orders.compactMap({
            return OrderCellViewModel(
                id: $0.order_id,
                name: $0.product_name,
                quantity: $0.qty,
                subTotal: $0.sub_total,
                originalPrice: 270.75,
                image: $0.image,
                isChecked: false,
                discountKey: "")
        })))

        collectionView.reloadData()
    }

    private func configureCollectionView() {
        view.addSubview(collectionView)
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.register(TransactionTypeCollectionViewCell.self, forCellWithReuseIdentifier: TransactionTypeCollectionViewCell.identifier)
        collectionView.register(CartItemsCollectionViewCell.self, forCellWithReuseIdentifier: CartItemsCollectionViewCell.identifier)
        
        
        collectionView.register(
            TransactionCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: TransactionCollectionReusableView.identifier)
        collectionView.register(
            CartItemsCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: CartItemsCollectionReusableView.identifier)

        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = Constants.whiteBackgroundColor
    }
    
    private func showAlertWith(title: String, message: String, style: UIAlertController.Style = .alert) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: style)
//        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: { (action) in
//            self.dismiss(animated: true, completion: nil)
//            /// popToRootViewController
//            DispatchQueue.main.async {
//                self.navigationController?.popToRootViewController(animated: true)
//            }
//        }))
//        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: { action in
//            _ = self.navigationController?.popViewController(animated: true)
//        }))
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func configureNavItem() {
        let cashierInfoContainer = UIView(frame: .zero)
        cashierInfoContainer.frame = CGRect(x: 0, y: 0, width: 100, height: 20)
        
        let imageContainer: UIView = {
            let container = UIView(frame: .zero)
            container.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
            container.layer.cornerRadius = 5.0
            container.layer.masksToBounds = true
            container.clipsToBounds = true
            container.backgroundColor = .red
            return container
        }()
        
        let infoLabelLabel: UILabel = {
            let label = UILabel()
            label.numberOfLines = 0
            label.textColor = Constants.whiteLabelColor
            label.font = .systemFont(ofSize: 10, weight: .regular)
//            label.text = "I'am a \(UserDefaults.standard.stringArray(forKey: "pin_entered_user_roles")?.first ?? "cashier")"
            
            label.text = "I'm a \(cashierInfo ?? "cashier")"
            
            
            label.textAlignment = .right
            return label
        }()
        
        let nameLabel: UILabel = {
            let label = UILabel()
            label.numberOfLines = 0
            label.textColor = Constants.whiteLabelColor
            label.font = .systemFont(ofSize: 10, weight: .semibold)
//            let name = UserDefaults.standard.string(forKey: "pin_entered_username")?.capitalized ?? "Unknown" // Maria Leonara Teresa
            let name = cashierName ?? "Unknown" // Maria Leonara Teresa
            label.text = name
            label.textAlignment = .right
            return label
        }()
        
        let userImage: UIImageView = {
            let imageView = UIImageView(frame: .zero)
//            imageView.image = UIImage(named: "test_userImage")
            let placeholder = "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS_WEqNwRZ9L1xbFOkr-cAzDswZEEEcwgdLODnPRdavrEna-3NlcTV2SKcGoDktLZiEqNk&usqp=CAU"
            
            imageView.sd_setImage(with: URL(string: cashierImage ?? placeholder), completed: nil)
            imageView.contentMode = .scaleAspectFill
            imageView.layer.masksToBounds = true
            imageView.clipsToBounds = true
            imageView.tintColor = Constants.whiteLabelColor
            imageView.backgroundColor = Constants.blackBackgroundColor
            return imageView
        }()
        
        infoLabelLabel.frame = CGRect(x: 0, y: 0, width: cashierInfoContainer.width, height: cashierInfoContainer.height/2)
        nameLabel.frame = CGRect(x: 0, y: infoLabelLabel.bottom, width: cashierInfoContainer.width, height: cashierInfoContainer.height/2)
        cashierInfoContainer.addSubview(infoLabelLabel)
        cashierInfoContainer.addSubview(nameLabel)
        
        userImage.frame = imageContainer.bounds
        imageContainer.addSubview(userImage)
        
        navigationItem.rightBarButtonItems = [
//            UIBarButtonItem(
//                image: UIImage(systemName: "person.fill"),
//                style: .done,
//                target: self,
//                action: #selector(didTapImage)),
            UIBarButtonItem(customView: imageContainer),
            UIBarButtonItem(customView: cashierInfoContainer)
        ]
        
        cashierInfoContainer.isHidden = cashierName == nil
        imageContainer.isHidden = cashierName == nil
        
        let imageTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapUserImage))
        imageTapGesture.numberOfTapsRequired = 1
        
        let containerTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapUserImage))
        containerTapGesture.numberOfTapsRequired = 1
        
        imageContainer.isUserInteractionEnabled = true
        imageContainer.addGestureRecognizer(imageTapGesture)
        
        cashierInfoContainer.isUserInteractionEnabled = true
        cashierInfoContainer.addGestureRecognizer(containerTapGesture)
        
        
    }
    
    @objc func didTapUserImage() {
        print("did tap user image")
        
        if let currentCashier = UserDefaults.standard.string(forKey: Constants.pin_entered_username) {
            
            let alert = UIAlertController(title: "Cashier", message: "\(currentCashier) is currently logged in as cashier, enter your passcode and replace if you wish.", preferredStyle: .alert)
            alert.addTextField { field in
                field.isSecureTextEntry = true
                field.placeholder = "Your passcode"
                field.returnKeyType = .next
                field.keyboardType = .numberPad
            }
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            let replaceAction = UIAlertAction(title: "Replace", style: .destructive, handler: { [weak self] action in
                guard let code = alert.textFields?.first?.text, !code.isEmpty else {
                    print("code field is empty")
                    self?.showAlertWith(title: "Couldn't proceed", message: "Invalid passcode", style: .alert)
                    return
                }
                if let userEnteringCode = self?.fetchedAllUsers.first(where: { $0.user_pin == code && $0.user_handles_cash }) {
                    UserDefaults.standard.setValue(userEnteringCode.user_pin, forKey: Constants.pin_code_entered)
                    UserDefaults.standard.setValue(userEnteringCode.user_name, forKey: Constants.pin_entered_username)
                    UserDefaults.standard.setValue(userEnteringCode.user_id, forKey: Constants.pin_entered_user_id)
                    UserDefaults.standard.setValue(userEnteringCode.user_image, forKey: Constants.pin_entered_user_image)
                    UserDefaults.standard.setValue(userEnteringCode.user_roles, forKey: Constants.pin_entered_user_roles)
                    
                    self?.cartViewControllerCashierInfoDelegate?.cashierData(
                        data: CashierInfoViewModel(
                            name: userEnteringCode.user_name,
                            userRole: userEnteringCode.user_roles.first ?? "-",
                            userImageUrl: URL(string: userEnteringCode.user_image)))
                    
                    
                    self?.navigationController?.popViewController(animated: true)
                } else {
                    self?.showAlertWith(title: "Couldn't Proceed", message: "Invalid credentials", style: .alert)
                }
            })
            
            alert.addAction(replaceAction)
            present(alert, animated: true, completion: nil)
            
        } else {
            
            let alert = UIAlertController(title: "Cashier", message: "Enter your passcode", preferredStyle: .alert)
            alert.addTextField { field in
                field.isSecureTextEntry = true
                field.placeholder = "Your passcode"
                field.returnKeyType = .next
                field.keyboardType = .numberPad
            }
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            alert.addAction(UIAlertAction(title: "Proceed", style: .destructive, handler: { [weak self] action in
                guard let code = alert.textFields?.first?.text, !code.isEmpty else {
                    print("code field is empty")
                    self?.showAlertWith(title: "Couldn't proceed", message: "Invalid passcode", style: .alert)
                    return
                }
                if let userEnteringCode = self?.fetchedAllUsers.first(where: { $0.user_pin == code }) {
                    UserDefaults.standard.setValue(userEnteringCode.user_pin, forKey: Constants.pin_code_entered)
                    UserDefaults.standard.setValue(userEnteringCode.user_name, forKey: Constants.pin_entered_username)
                    UserDefaults.standard.setValue(userEnteringCode.user_id, forKey: Constants.pin_entered_user_id)
                    UserDefaults.standard.setValue(userEnteringCode.user_image, forKey: Constants.pin_entered_user_image)
                    UserDefaults.standard.setValue(userEnteringCode.user_roles, forKey: Constants.pin_entered_user_roles)
                    self?.navigationController?.popViewController(animated: true)
                } else {
                    self?.showAlertWith(title: "Couldn't Proceed", message: "Invalid credentials", style: .alert)
                }
            }))
//            alert.addAction(UIAlertAction(title: "Force login", style: .destructive))
            present(alert, animated: true, completion: nil)
            
        }
    }
    
    func showAlertFromCartBottomView() {
        let alert = UIAlertController(title: "", message: "There's no item selected yet, please select an item to proceed.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: { (_) in
            self.dismiss(animated: true, completion: nil)
        }))
        present(alert, animated: true, completion: nil)
    }
    
    
    @objc func didTapImage() {
        print("Did tap image")
    }
    
    private func calculateTotal(){
        priceSum = 0 // refresh to zeto
        
        for item in cart {
//            let discountedCost = item.cart_discounted_product_cost * Double(item.cart_quantity)
            
            let inclusiveVatRate = 1.12
            let vatRate = item.cart_tax_class == "" ? 0.12 : 0
            let vatableSales = (item.cart_product_cost / inclusiveVatRate) * Double(item.cart_quantity)
            let vat12Amount = vatableSales * vatRate
            let discountAmount = vatableSales * item.cart_discount
            let cartTotal = (vatableSales + vat12Amount) - discountAmount
            let roundedSubTotal = Double(round(100 * cartTotal) / 100)
            
//            priceSum += Double(round(100 * discountedCost) / 100)
            priceSum += roundedSubTotal
        }
        bottomContainer.totalValueLabel.text = String(format:"₱%.2f", priceSum)
    }
    
    func didPostOrder() {
        print("didPostOrder")
        deleteAllItems(items: cart)
        cartViewControllerDelegate?.shouldReloadDataFromCartVC()
    }
    
    func shouldDeleteCartItems(with cartItems: [Cart_Entity]) {
        print("shouldClearCartEntity")
        deleteAllItems(items: cartItems)
    }
    
    func shouldReloadCollectionView() {
        print("collectionview reloaded from cartVC")
        fetchCart()
    }
    
    func shouldReloadBottomView() {
        calculateTotal()
    }
    

}

extension CartViewController: CartBottomViewDelegate {
    func didTapCheckAll(isChecked: Bool) {
        print("didtap check all: \(isChecked)")
        checkAllItems(isChecked: isChecked)
    }
    
    internal func navigatePushViewController(data: String, remarks: String?) {
        print("navigatePushViewController: \(data)-\(remarks)")
        if !cart.isEmpty {
            let vc = CashMethodViewController()
            vc.cashMethodViewControllerDelegate = self
            vc.title = "\(data)"
            vc.remarks = remarks
            navigationController?.pushViewController(vc, animated: true)
        } else {
            print("No items")
            showAlertWith(title: "Couldn't proceed", message: "Cart is empty", style: .alert)
        }
    }
    
}


extension CartViewController: UICollectionViewDelegate, UICollectionViewDataSource, SwipeCollectionViewCellDelegate, CartItemsCollectionReusableViewDelegate {
    
    func deleteTapped(with cartItems: [Cart_Entity]) {
        print("Tapped delete from cartVC")
        
        
        let alert = UIAlertController(
            title: "",
            message: !cartItems.isEmpty ? "Are you sure you want to delete selected items in the cart?" : "Please select an item to delete",
            preferredStyle: .alert)
        
        let cancel = UIAlertAction(
            title: "Cancel",
            style: .cancel,
            handler: nil)
        
        
        let proceed = UIAlertAction(
            title: "Proceed",
            style: .destructive,
            handler: { [weak self] success in
                // Proceed
                self?.shouldDeleteCartItems(with: cartItems)
                print("cart.count: \(self?.cart.count)")
                
                if let cartCount = self?.cart.count {
                    if cartCount < 1 {
                        self?.navigationController?.popToRootViewController(animated: true)
                        self?.cartViewControllerDelegate?.shouldReloadDataFromCartVC()
                    }
                }
            })
        
        if !cartItems.isEmpty {
            alert.addAction(cancel)
            alert.addAction(proceed)
        } else {
            alert.addAction(UIAlertAction(title: "ok", style: .default, handler: nil))
        }
        
        present(alert, animated: true, completion: nil)
    }
    
    func deleteData(at indexPath: IndexPath) {
        let item = cart[indexPath.row]
        print("deleting... ", item)
        self.deleteItem(item: item)
        
        // reload view
        calculateTotal()
    }
    
    func updateQuantity(at indexPath: IndexPath, qty: Int) {
        let item = cart[indexPath.row]
        print("updating... ", item)
        
        self.updateQty(item: item, qty: qty)
        
        // reload view
        calculateTotal()
    }
    
    func collectionView(_ collectionView: UICollectionView, editActionsForItemAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        
        let cartItem = cart[indexPath.row]
        var taggedAddons = [Cart_Entity]()
        
        if cartItem.cart_variation_id == 0 {
            taggedAddons = cart.filter({ $0.cart_tagged_product == cartItem.cart_product_id })
        } else {
            taggedAddons = cart.filter({ $0.cart_tagged_product == cartItem.cart_variation_id })
        }
        
        print("taggedAddons: \(taggedAddons.count)")
        
        guard orientation == .right else { return nil }

        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            // handle action by updating model with deletion
            self.deleteItem(item: cartItem)
            if !taggedAddons.isEmpty {
                for addOn in taggedAddons {
                    self.deleteItem(item: addOn)
                }
            }
            self.calculateTotal()
        }
        
        let regular = SwipeAction(style: .default, title: "Regular") { action, indexPath in
            // handle action by updating model with 20% discount
            self.updateDiscount(item: cartItem, discountKey: "", discountPercent: 0, taxClass: "")
            self.calculateTotal()
        }
        
        let seniorDiscount = SwipeAction(style: .default, title: "Senior") { action, indexPath in
            // handle action by updating model with 20% discount
            self.updateDiscount(item: cartItem, discountKey: "senior", discountPercent: 0.20, taxClass: "reduced-rate") //vat-exempt
            self.calculateTotal()
        }
        
        let pwdDiscount = SwipeAction(style: .default, title: "PWD") { action, indexPath in
            // handle action by updating model with 20% discount
            self.updateDiscount(item: cartItem, discountKey: "pwd", discountPercent: 0.20, taxClass: "reduced-rate") //vat-exempt
            self.calculateTotal()
        }
        
        // customize the action appearance
        deleteAction.image = UIImage(systemName: "trash")
        regular.image = UIImage(systemName: "tag")
        regular.backgroundColor = Constants.darkGrayColor
        seniorDiscount.image = UIImage(systemName: "tag")
        seniorDiscount.backgroundColor = .brown
        pwdDiscount.image = UIImage(systemName: "tag")
        pwdDiscount.backgroundColor = .orange
        
        var actionsArray = [deleteAction] //[deleteAction, pwdDiscount, seniorDiscount, regular]
        let actionDeleteOnly = [deleteAction]
        
//        if let testDiscountAction = coupons.first(where: { $0.coupon_amount_percent != 0.2 }) {
//
//            let testDiscount = SwipeAction(style: .default, title: testDiscountAction.coupon_code?.uppercased()) { action, indexPath in
//                // handle action by updating model with 20% discount
//                self.updateDiscount(item: cartItem, discountKey: testDiscountAction.coupon_code?.uppercased() ?? "", discountPercent: testDiscountAction.coupon_amount_percent, taxClass: "reduced-rate") //vat-exempt
//                self.calculateTotal()
//            }
//            testDiscount.image = UIImage(systemName: "tag")
//            testDiscount.backgroundColor = Constants.lightGrayColor
//            actionsArray.append(testDiscount)
//        }
        
//        let fetchedDiscountAction = coupons.filter({ $0.coupon_title != "pwd" && $0.coupon_title != "senior" })
        let fetchedDiscountAction = coupons
        for testCoup in fetchedDiscountAction {
            let testDiscount = SwipeAction(style: .default, title: testCoup.coupon_code?.uppercased()) { action, indexPath in
                // handle action by updating model with 20% discount
                self.updateDiscount(item: cartItem, discountKey: testCoup.coupon_code?.uppercased() ?? "", discountPercent: testCoup.coupon_amount_percent, taxClass: "reduced-rate") //vat-exempt
                self.calculateTotal()
            }
            testDiscount.image = UIImage(systemName: "tag")
            testDiscount.backgroundColor = Constants.lightGrayColor
//            actionsArray.append(testDiscount)
        }
        if !fetchedDiscountAction.isEmpty {
            actionsArray.append(regular)
        }
        
//        if cartItem.cart_tagged_product == 0 {
//            return actionsArray
//        } else {
//            return actionDeleteOnly
//        }
        
        return actionDeleteOnly
    }
    
    func collectionView(_ collectionView: UICollectionView, editActionsOptionsForItemAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .destructive
        options.transitionStyle = .border
        return options
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let type = sections[section]
        switch type {
        case .transactionType(let viewModels):
            return viewModels.count
        case .orders: // (let viewModels):
            
//            let cartProducts = cart.filter({ $0.cart_tagged_product == 0 })
            return cart.count //coreDataArray.count
        }
    }
    
//    func stepper(_ stepper: GMStepper, at index: Int, didChangeValueTo newValue: Double) {
//
//        let cartItem = cart[index]
//
//        let indexPath = IndexPath(item: index, section: 1)
//
//        print("Value changed in \(indexPath.row): \(newValue)")
//
//        updateQty(item: cartItem, qty: Int(newValue))
//    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let type = sections[indexPath.section]
        
        switch type {
        case .transactionType(viewModels: let viewModels):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TransactionTypeCollectionViewCell.identifier, for: indexPath) as? TransactionTypeCollectionViewCell else {
                return UICollectionViewCell()
            }
            
//            cell.isSelected = indexPath.row == 0 ? true : false // default selected is regular
            
            let models = viewModels[indexPath.row]
            cell.configure(with: TransactionTypeCollectionViewCellViewModel(
                            id: models.id,
                            name: models.name,
                            percent: models.percent))
            return cell
            
        case .orders:
//            let coreDataModels = coreDataArray[indexPath.row]
            
            let cartAddOns = cart.filter({ $0.cart_tagged_product != 0 })
//            let cartProducts = cart.filter({ $0.cart_tagged_product == 0 })
            let cartItem = cart[indexPath.row]
            
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CartItemsCollectionViewCell.identifier, for: indexPath) as? CartItemsCollectionViewCell else {
                return UICollectionViewCell()
            }
            
            cell.delegate = self
//            cell.cartItemsCollectionViewCellDelegate = self
            cell.qtyStepper.tag = indexPath.row
            cell.checkBoxButton.tag = indexPath.row
            cell.cartItemsCollectionViewCellDelegate = self
            
            if cartItem.cart_discount_key == "pwd" {
                cell.originalPriceLabel.isHidden = false
//                cell.originalPriceLabel.backgroundColor = .orange
            } else if cartItem.cart_discount_key == "senior" {
                cell.originalPriceLabel.isHidden = false
//                cell.originalPriceLabel.backgroundColor = .brown
            } else if cartItem.cart_discount_key != "" {
                cell.originalPriceLabel.isHidden = false
//                cell.originalPriceLabel.backgroundColor = .brown
            } else {
//                cell.originalPriceLabel.backgroundColor = Constants.whiteBackgroundColor
                cell.originalPriceLabel.isHidden = true
            }
            var addOns = ""
            
            let addedOns = cartAddOns.filter({ $0.cart_tagged_product == cartItem.cart_product_id })
            addedOns.forEach({ item in
                addOns += "\(item.cart_product_name ?? ""), "
            })
            // 1000000090
//            if cartItem.cart_tagged_product != 0 {
//                cell.checkBoxButton.isHidden = true
//            }
            
            cell.contentView.backgroundColor = cartItem.cart_tagged_product != 0 ? Constants.vcBackgroundColor : Constants.whiteBackgroundColor

            cell.qtyStepper.labelBackgroundColor = cartItem.cart_tagged_product != 0 ? Constants.vcBackgroundColor : Constants.whiteBackgroundColor
            
            cell.configure(
                with: CartItemsCollectionViewCellViewModel(
                    id: Int(cartItem.cart_product_id),
                    name: "\(cartItem.cart_variation_name ?? cartItem.cart_product_name ?? "-")", //\(addOns != "" ? "\n\(addOns)" : "")"
                    quantity: Int(cartItem.cart_quantity),
                    subTotal: cartItem.cart_discounted_product_cost,
                    originalPrice: cartItem.cart_product_cost, //cart_original_cost
                    image: cartItem.cart_product_image ?? "-",
                    isChecked: cartItem.cart_isChecked,
                    discountKey: cartItem.cart_discount_key ?? "-",
                    index: indexPath.row,
                    addOns: nil, // addOns
                    isCheckBoxHidden: cartItem.cart_tagged_product == 0 ? false : true))
            
            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let section = sections[indexPath.section]
        
        switch section {
        case .transactionType(let viewModels):
            let selectedDiscount = viewModels[indexPath.row]
            
            
            print("cartSelectedItems: \(cartSelectedItems.count)")
            if !cartSelectedItems.isEmpty {
                
                if selectedDiscount.key == selectedDiscountForAll {
                    collectionView.deselectItem(at: indexPath, animated: true)
                    applyToAllDiscount(
                        items: cartSelectedItems,
                        discountKey: "",
                        discountPercent: 0,
                        taxClass: "")
                    DispatchQueue.main.async {
                        self.collectionView.reloadSections(IndexSet(integer: 1))
                    }
                    selectedDiscountForAll = ""
                    
                } else {
                    
                    let alert = UIAlertController(title: "Discount Confirmation", message: "Are you sure you want to apply \(selectedDiscount.key.uppercased()) discount on selected \(cartSelectedItems.count > 1 ? "products" : "product")?", preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { [weak self] action in
                        self?.collectionView.deselectItem(at: indexPath, animated: false)
                    }))
                    alert.addAction(UIAlertAction(title: "Proceed", style: .default, handler: { [weak self] action in
                        guard let strongSelf = self else { return }
                        
                        strongSelf.selectedDiscountForAll = selectedDiscount.key
                        print("selectedDiscountForAll: ", strongSelf.selectedDiscountForAll)
                        
                        strongSelf.applyToAllDiscount(
                            items: strongSelf.cartSelectedItems,
                            discountKey: strongSelf.selectedDiscountForAll,
                            discountPercent: selectedDiscount.percent,
                            taxClass: selectedDiscount.tax_class)
                        
                        DispatchQueue.main.async {
                            strongSelf.collectionView.reloadSections(IndexSet(integer: 1))
                        }
                        
                    }))
                    DispatchQueue.main.async {
                        self.present(alert, animated: true, completion: nil)
                    }
                }
                
            } else {
                let alert = UIAlertController(title: "Can't apply discount", message: "Please select an item to apply discount", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: { [weak self] action in
                    self?.collectionView.deselectItem(at: indexPath, animated: true)
                }))
                DispatchQueue.main.async {
                    self.present(alert, animated: true, completion: nil)
                }
            }
            
            
            
            break
        case .orders:
            
//            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CartItemsCollectionViewCell.identifier, for: indexPath) as! CartItemsCollectionViewCell
//            cell.cartItemsCollectionViewCellDelegate = self
            
            let cartItem = cart[indexPath.row]//coreDataArray[indexPath.row]
            
            print("did tap cell: \(cartItem.cart_variation_name ?? "-")")
            
            /// go to update item
//            let vc = CartItemUpdateOptionViewController(
//                product: FakeProductItems(
//                    id: Int(cartItem.cart_product_id),
//                    product_name: cartItem.cart_product_name ?? "-",
//                    product_img: cartItem.cart_product_image ?? "-",
//                    order_qty: Int(cartItem.cart_quantity),
//                    cart_qty: Int(cartItem.cart_quantity),
//                    product_price: cartItem.cart_final_cost))
//
//            vc.title = "Update - \(cartItem.cart_product_name ?? "-")"
//            navigationController?.pushViewController(vc, animated: true)
            break
        }
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let section = sections[indexPath.section]

        switch section {
        case .transactionType:
            guard let header = collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: TransactionCollectionReusableView.identifier,
                    for: indexPath) as? TransactionCollectionReusableView, kind == UICollectionView.elementKindSectionHeader else {
                return UICollectionReusableView()
            }
            let section = indexPath.section
            let modelTitle = sections[section].title
            
            header.configure(with: modelTitle)
            return header
        case .orders:
            guard let header = collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: CartItemsCollectionReusableView.identifier,
                    for: indexPath) as? CartItemsCollectionReusableView, kind == UICollectionView.elementKindSectionHeader else {
                return UICollectionReusableView()
            }
            
            if hasCartItems {
                header.deleteButton.isHidden = false
            } else {
                header.deleteButton.isHidden = true
            }
            
            let section = indexPath.section
            let modelTitle = sections[section].title
            
            header.cartItemsCollectionReusableViewDelegate = self // make delegate
            header.configure(with: modelTitle)
            return header
        }
    }
}


extension CartViewController {
    public func returnStoredToken() -> String {
        var tokenValue = ""
        do {
            // let items = try context.fetch(ToDoListItem.fetchRequest())
            let tokenEntity: [Token_Entity] = try context.fetch(Token_Entity.fetchRequest())
            if let lastToken = tokenEntity.last?.token_value {
                tokenValue = lastToken
            }
        } catch {
            print(error.localizedDescription)
            tokenValue = "no stored token"
        }
        return tokenValue
    }
    
    public func fetchCart() {
        do {
            // let items = try context.fetch(ToDoListItem.fetchRequest())
            cartEntity = try context.fetch(Cart_Entity.fetchRequest())
            cart = cartEntity.filter({ $0.cart_status == "added" })
            cartSelectedItems = cart.filter({ $0.cart_isChecked == true })
            
            postCartCountNotification(count: cart.count)
            
            if !cart.isEmpty {
                DispatchQueue.main.async {
                    self.noResultsLabel.isHidden = true
                    self.collectionView.isHidden = false
                    self.bottomContainer.isHidden = false
                    self.collectionView.reloadData()
                }
            } else {
                DispatchQueue.main.async {
                    self.defaultEmptyView(with: "No orders\nItems that you added will appear here.")
                    self.collectionView.isHidden = true
                    self.bottomContainer.isHidden = true
                    self.collectionView.reloadData()
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    public func postCartCountNotification(count: Int) {
        NotificationCenter.default.post(name: .cartCount, object: count, userInfo: ["cartCount" : count])
    }
    
    public func fetchUsers() {
        do {
            usersEntity = try context.fetch(Users_Entity.fetchRequest())
            if let fetchedSuperVisor = usersEntity.filter({ $0.user_access_level == "supervisor" }).first {
                superVisor = fetchedSuperVisor
            }
        } catch {
            print("failed to fetchUsers: \(error.localizedDescription)")
        }
    }
    
    public func storeUserCredentials(with user: UserCredentials) {
        
        print("with user: \(user.user_id)")
        print("usersEntity: \(usersEntity)")
        let storedFilteredUsers = usersEntity.filter({ String($0.user_id) == user.user_id })
        print("storedFilteredUsers: \(storedFilteredUsers)")
        shouldDeleteStoredUser(users: storedFilteredUsers)
        
        let userEntity = Users_Entity(context: context)
        
        userEntity.user_id = Int64(user.user_id) ?? 0
        userEntity.user_name = user.user_name
        userEntity.user_image = user.user_image
        userEntity.user_login = user.user_login
        userEntity.user_email = user.user_email
        userEntity.user_pass = user.user_pass
        userEntity.user_emp_id = user.user_emp_id
        userEntity.user_pin = Int64(user.user_pin) ?? 0
        userEntity.user_handles_cash = user.user_handles_cash
        
        userEntity.user_roles = user.user_roles
        userEntity.user_access_level = user.user_access_level
        print("Success stored userEntity: \(userEntity)")
        
        
        do {
            try context.save()
        } catch {
            // error
        }
    }
    
    public func shouldDeleteStoredUser(users: [Users_Entity]) {
        do {
            for user in users {
                context.delete(user)
                print("Success shouldDeleteStoredUser: \(user)")
            }
            try context.save() //don't forget
        } catch {
            // error
        }
    }
    
    public func createItem(name: String, qty: Int) {
        let newItem = Cart_Entity(context: context)
//        newItem.name = name
        newItem.cart_product_id = 1
        newItem.cart_quantity = 1
        newItem.cart_created_at = Date()
        
        do {
            try context.save()
            fetchCart()
        } catch {
            // error
        }
    }
    
    // addtoBilling/ cart
    public func addToBilling(productID: Int,
                             variationID: Int?,
                             variationName: String?,
                             productCost: Double,
                             quantity: Int,
                             image: String,
                             name: String,
                             discount: Double,
                             originalCost: Double,
                             finalCost: Double,
                             remarks: String?,
                             isChecked: Bool,
                             queue: [Cart_Entity]?,
                             fetchedLastOrderID: Int64?,
                             taggedProduct: Int?,
                             cartLastOrderEntity: [Cart_Last_OrderID_Entity]?) {
        
        let newItem = Cart_Entity(context: context)
        
        let deviceID = UserDefaults.standard.string(forKey: Constants.generated_device_id) ?? "-"
        let machineID = UserDefaults.standard.string(forKey: Constants.machine_id)
        
//        var withOrderIDSortedCart = [Cart_Entity]()
        
        var intLastOrderIDNumbers = 100000001
        
        intLastOrderIDNumbers = Int(fetchedLastOrderID ?? 0)
        
        let fetchRequest = Cart_Entity.fetchRequest() as NSFetchRequest
        let sort = NSSortDescriptor(key: "cart_created_at", ascending: false)
        fetchRequest.sortDescriptors = [sort]
        
//        let pred = NSPredicate(format: "cart_product_id == \(productID)")
//        fetchRequest.predicate = pred
//
//        do {
//            let result = try context.fetch(fetchRequest)
//            if result.count > 0 {
//                result[0].cart_quantity = Int64(quantity)
//            }else {
//                newItem.cart_order_id = "\(deviceID.suffix(4))-\(intLastOrderIDNumbers)" //"orderID+1"
//        //        newItem.cart_order_id = "\(deviceID.suffix(4))-000001"
//
//                newItem.cart_created_at = Date()
//                newItem.cart_product_id = Int64(productID)
//                newItem.cart_variation_name = variationName ?? name
//                newItem.cart_variation_id = Int64(variationID ?? 0) // zero to no variation
//                newItem.cart_quantity = Int64(quantity)
//                newItem.cart_discount_key = ""
//                newItem.cart_product_image = "\(image)"
//                newItem.cart_product_name = "\(name)"
//                newItem.cart_discount = discount
//                newItem.cart_original_cost = originalCost
//                newItem.cart_final_cost = productCost - (productCost * discount) //originalCost //originalCost * discount
//                newItem.cart_product_cost = productCost
//                newItem.cart_discounted_product_cost = productCost - (productCost * discount)
//                newItem.cart_status = "added"
//                newItem.cart_isChecked = true
//                newItem.cart_tax_class = ""
//                newItem.cart_remarks = remarks
//
//                //newItem.queue
//
//                // cached last OR#
//
//                print("\(fetchedLastOrderID ?? 0) isEqual to? = \(queue?.last?.cart_order_id ?? "no last queue")")
//
//                if fetchedLastOrderID != cartLastOrderEntity?.last?.cart_last_order_id {
//                    let lastOrderEntity = Cart_Last_OrderID_Entity(context: context)
//                    lastOrderEntity.cart_last_order_id = Int64(intLastOrderIDNumbers)
//                }
//
//                print("intLastOrderIDNumbers: ", intLastOrderIDNumbers)
//            }
//            print("successfully added \(variationName ?? name) to billing...")
//            try context.save()
//        }catch{
//
//        }
        
//        if let lastCartItem = queue.last { // need fetch last orderid entity
//            print("lastCartItem: ",lastCartItem)
//            if let lastOrderID = lastCartItem.cart_order_id {
//                print("lastOrderID: ",lastOrderID)
//                let lastOrderIDNumbers = lastOrderID.split(separator: "-")
//                let last = lastOrderIDNumbers.last ?? ""
//                print("last: ",last)
//                if let intLast = Int(last) {
//                    print("intLast: ",intLast)
//
//                    if Int(fetchedLastOrderID) > intLast {
//                        intLastOrderIDNumbers = Int(fetchedLastOrderID)
//                    } else {
//                        intLastOrderIDNumbers = intLast + 1 // for new cart order id
//                    }
//                }
//            }
//        }
//        else {
//            intLastOrderIDNumbers += 1
//        }
        
//        do {
//            var sortedCart = [Cart_Entity]()
//            sortedCart = try context.fetch(fetchRequest)
//            sortedCart = sortedCart.filter({ $0.cart_status == "completed" })
//
//            withOrderIDSortedCart = sortedCart.filter({ $0.cart_order_id != nil })
//
//        } catch {
//            print("error fetching sorted cart items: \(error.localizedDescription)")
//        }
        
//        print("withOrderIDSortedCart: ",withOrderIDSortedCart)
//        if let lastOrderID = withOrderIDSortedCart.first?.cart_order_id {
//            print("lastOrderID: ",lastOrderID)
//
//            let lastOrderIDNumbers = lastOrderID.suffix(6)
//            print("lastOrderIDNumbers: ",lastOrderIDNumbers)
//
//            if let newNumbers = Int(lastOrderIDNumbers) {
//                intLastOrderIDNumbers = newNumbers // +1
//                print("newNumbers: ",intLastOrderIDNumbers)
//            }
//        }
        
        let deviceIdLast4 = deviceID.suffix(4)
        newItem.cart_order_id = "\(machineID ?? String(deviceIdLast4))-\(intLastOrderIDNumbers)" //"orderID+1"
//        newItem.cart_order_id = "\(deviceID.suffix(4))-\(intLastOrderIDNumbers)" //"orderID+1"
//        newItem.cart_order_id = "\(deviceID.suffix(4))-000001"
        
        
        newItem.cart_created_at = Date()
        newItem.cart_product_id = Int64(productID)
        newItem.cart_variation_name = variationName ?? name
        newItem.cart_variation_id = Int64(variationID ?? 0) // zero to no variation
        newItem.cart_quantity = Int64(quantity)
        newItem.cart_discount_key = ""
        newItem.cart_product_image = "\(image)"
        newItem.cart_product_name = "\(name)"
        newItem.cart_discount = discount
        newItem.cart_original_cost = originalCost
        newItem.cart_final_cost = productCost - (productCost * discount) //originalCost //originalCost * discount
        newItem.cart_product_cost = productCost
        newItem.cart_discounted_product_cost = productCost - (productCost * discount)
        newItem.cart_status = "added"
        newItem.cart_isChecked = isChecked //true
        newItem.cart_tax_class = ""
        newItem.cart_remarks = remarks
        newItem.cart_tagged_product = Int64(taggedProduct ?? 0)
        
        //newItem.queue
        
        
        // cached last OR#
        
        print("\(fetchedLastOrderID ?? 0) isEqual to? = \(queue?.last?.cart_order_id ?? "no last queue")")
        
        if fetchedLastOrderID != cartLastOrderEntity?.last?.cart_last_order_id {
            let lastOrderEntity = Cart_Last_OrderID_Entity(context: context)
            lastOrderEntity.cart_last_order_id = Int64(intLastOrderIDNumbers)
        }
        
        print("intLastOrderIDNumbers: ", intLastOrderIDNumbers)
        
        do {
            try context.save()
            fetchCart()
            print("successfully added \(variationName ?? name) to billing...")
        } catch {
            // error
        }
        
    }
    
    public func deleteItem(item: Cart_Entity) {
        context.delete(item)
        
        do {
            try context.save()
            fetchCart()
        } catch {
            // error
        }
    }
    
    
    public func applyToAllDiscount(items: [Cart_Entity], discountKey: String, discountPercent: Double, taxClass: String) {
        
        for item in items {
            item.cart_discount_key = discountKey
            item.cart_discount = discountPercent
            item.cart_final_cost = item.cart_discounted_product_cost * Double(item.cart_quantity)
            
            if taxClass != "" {
                let vatableSales = (item.cart_product_cost / 1.12)
                let roundedVatableSales = Double(round(100 * vatableSales) / 100)
                
                let vat12Ammount = vatableSales * 0
                let roundedVat12Amount = Double(round(100 * vat12Ammount) / 100)
                
                
                let discountAmount = roundedVatableSales * item.cart_discount
                let roundedDiscountAmount = Double(round(100 * discountAmount) / 100)
                
                let discountedCost = (roundedVatableSales + roundedVat12Amount) - roundedDiscountAmount
                let roundedDiscountedCost = Double(round(100 * discountedCost) / 100)
                
                item.cart_discounted_product_cost = roundedDiscountedCost
                
                print("vatableSales-",roundedVatableSales)
                print("vat12Ammount-",vat12Ammount)
                print("discountAmount-",roundedDiscountAmount)
                
            } else {
                item.cart_discounted_product_cost = item.cart_product_cost - (item.cart_product_cost * discountPercent)
            }
            
            item.cart_tax_class = taxClass
            
            calculateTotal()
        }
        
        do {
            try context.save()
        } catch {
            // error
        }
    }
    
    public func updateDiscount(item: Cart_Entity, discountKey: String, discountPercent: Double, taxClass: String) {
        
        item.cart_discount_key = discountKey
        item.cart_discount = discountPercent
        item.cart_final_cost = item.cart_discounted_product_cost * Double(item.cart_quantity)
        
        if taxClass != "" {
            let vatableSales = (item.cart_product_cost / 1.12)
            let vat12Ammount = vatableSales * 0
            let discountAmount = vatableSales * item.cart_discount
            item.cart_discounted_product_cost = (vatableSales + vat12Ammount) - discountAmount
            
            print("vatableSales-",vatableSales)
            print("vat12Ammount-",vat12Ammount)
            print("discountAmount-",discountAmount)
            
        } else {
            item.cart_discounted_product_cost = item.cart_product_cost - (item.cart_product_cost * discountPercent)
        }
        
        item.cart_tax_class = taxClass
        
        do {
            try context.save()
            fetchCart()
        } catch {
            // error
        }
    }
    
    public func checkItem(item: Cart_Entity, isChecked: Bool) {
        item.cart_isChecked = isChecked
        do {
            try context.save()
            fetchCart()
        } catch {
            // error
        }
    }
    
    
    public func checkAllItems(isChecked: Bool) {
        do {
            let cartItems = try context.fetch(Cart_Entity.fetchRequest())
            let cartMainItems = cartItems.filter({ $0.cart_tagged_product == 0 && $0.cart_status == "added" })
            for item in cartMainItems {
                item.cart_isChecked = isChecked
            }
            try context.save()
            fetchCart()
        } catch {
            print("error checkAllItems: \(error.localizedDescription)")
        }
    }
    
    public func deleteAllItems(items: [Cart_Entity]) {
        var taggedAddons = [Cart_Entity]()
        
        do {
            for item in items {
                
                if item.cart_variation_id == 0 {
                    taggedAddons = cart.filter({ $0.cart_tagged_product == item.cart_product_id })
                } else {
                    taggedAddons = cart.filter({ $0.cart_tagged_product == item.cart_variation_id })
                }
                context.delete(item)
            }
            for addon in taggedAddons {
                context.delete(addon)
            }
            
            //            for item in items {
            //                context.delete(item)
            //            }
            
            try context.save() //don't forget
            DispatchQueue.main.async {
                self.fetchCart()
                self.calculateTotal()
                self.collectionView.reloadData()
            }
        } catch {
            print("delete fail--", error.localizedDescription)
        }
    }
    
    public func updateQty(item: Cart_Entity, qty: Int) {
        
        item.cart_quantity = Int64(qty)
        item.cart_original_cost = item.cart_product_cost * Double(qty)
//        item.cart_final_cost = (item.cart_product_cost * item.cart_discount) * Double(qty)
        item.cart_final_cost = item.cart_discounted_product_cost * Double(qty)
        
        do {
            try context.save()
            fetchCart()
        } catch {
            // error
        }
    }
    
    public func updateCartStatus(items: [Cart_Entity], status: String) {
        do {
            for item in items {
                item.cart_status = status
            }
            try context.save()
            fetchCart()
        } catch {
            // error
        }
    }
    
    public func initLastOrderID(with lastOrderID: Int64) {
        let newItem = Cart_Last_OrderID_Entity(context: context)
        newItem.cart_last_order_id = lastOrderID
        do {
            try context.save()
        } catch {
            // error
            print("Error initializing lastOrder ID \(error.localizedDescription)")
        }
    }
}


// MARK:- CreateSectionLayout Cart and Payment methods
extension CartViewController {
    static func createSectionLayout(section: Int) -> NSCollectionLayoutSection {
        let supplementaryViews = [
            NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .absolute(40)
                ),
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top
            )
        ]
        
        print("transactionTypesCount: \(transactionTypesCount)")
        
        if transactionTypesCount ?? 1 > 0 {
            switch section {
            case 0:
                // Item
                let item = NSCollectionLayoutItem.init(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1.0),
                        heightDimension: .fractionalHeight(1.0)))
                item.contentInsets = NSDirectionalEdgeInsets(
                    top: 0,
                    leading: 10,
                    bottom: 0,
                    trailing: 10)

                // vertical Group
                let vGroup = NSCollectionLayoutGroup.vertical(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1.0),
                        heightDimension: .absolute(60.0)),
                    subitem: item,
                    count: 1)
                vGroup.contentInsets = NSDirectionalEdgeInsets(
                    top: 10,
                    leading: 0,
                    bottom: 10,
                    trailing: 0)

                // horizontal Group
                let hGroup = NSCollectionLayoutGroup.horizontal(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1.0),
                        heightDimension: .absolute(60.0)),
                    subitem: vGroup,
                    count: 4)
                hGroup.contentInsets = NSDirectionalEdgeInsets(
                    top: 0,
                    leading: 10,
                    bottom: 0,
                    trailing: 10)

                // Section
                let section = NSCollectionLayoutSection(group: hGroup)
    //            section.orthogonalScrollingBehavior = .continuous
                
                // section header
                section.boundarySupplementaryItems = supplementaryViews

                return section

            case 1:
                // Item
                let item = NSCollectionLayoutItem.init(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1.0),
                        heightDimension: .fractionalHeight(1.0)))
                item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)

                // Group
                let group = NSCollectionLayoutGroup.vertical(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1.0),
                        heightDimension: .absolute(80.0)),
                    subitem: item,
                    count: 1)

                // Section
                let section = NSCollectionLayoutSection(group: group)
                //        section.orthogonalScrollingBehavior = .continuous
                
                // section header
                section.boundarySupplementaryItems = supplementaryViews

                return section

            default:
                // Item
                let item = NSCollectionLayoutItem.init(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1.0),
                        heightDimension: .fractionalHeight(1.0)))
                item.contentInsets = NSDirectionalEdgeInsets(top: 1, leading: 0, bottom: 1, trailing: 0)

                // Group
                let group = NSCollectionLayoutGroup.vertical(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1.0),
                        heightDimension: .absolute(80.0)),
                    subitem: item,
                    count: 1)

                // Section
                let section = NSCollectionLayoutSection(group: group)
                //        section.orthogonalScrollingBehavior = .continuous
                
                // section header
                section.boundarySupplementaryItems = supplementaryViews

                return section
            }
        } else {
            // Item
            let item = NSCollectionLayoutItem.init(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .fractionalHeight(1.0)))
            item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)

            // Group
            let group = NSCollectionLayoutGroup.vertical(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .absolute(80.0)),
                subitem: item,
                count: 1)

            // Section
            let section = NSCollectionLayoutSection(group: group)
            //        section.orthogonalScrollingBehavior = .continuous
            
            // section header
            section.boundarySupplementaryItems = supplementaryViews

            return section
        }
        
    }

    static func createBottomContainerCollectionLayout(section: Int) -> NSCollectionLayoutSection {
        // item
        let item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(1.0)))
        
        item.contentInsets = NSDirectionalEdgeInsets(
            top: 0,
            leading: 10,
            bottom: 10,
            trailing: 10)
        
        // horizontal group inside horizontal group
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .absolute(105.0),
                heightDimension: .fractionalHeight(0.9)),
            subitem: item,
            count: 1)
        
        // section
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
        
        return section
    }
}
