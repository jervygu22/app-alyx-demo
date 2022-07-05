//
//  OptionsViewController.swift
//  Jeeves-dev
//
//  Created by Jervy Umandap on 2/4/22.
//

import UIKit
import GMStepper
import CoreData


enum OptionsSectionType {
    case headerSection(viewModels: Product)                    // 0
    case variationSection(viewModels: [ProductOptionSection])   // 1
    case addOnsSections(viewModels: ProductOptionSection)   // 1
}

protocol OptionsViewControllerDelegate {
    func shouldReloadDataFromOptionsVC()
}

class OptionsViewController: UIViewController {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var optionsViewControllerDelegate: OptionsViewControllerDelegate?
    
    private var cartLastOrderEntity = [Cart_Last_OrderID_Entity]()
    private var lastOrderID: Int64?
    
    private var cartEntity = [Cart_Entity]()
    private var cart = [Cart_Entity]()
    private var queue = [Cart_Entity]()
//    private let product: FakeProductItems
    private let product: Product
    private let addOns: [AddOnsData]
//    private var addOnsChosed: [AddOnsData]?
    
    private var addOnsChosed = [AddOnsData]()
    
    private var addOnsPriceSum: Double = 0
    
    private var currentProductSubtotal: Double?
    
    private var productOptionSection = [ProductOptionSection]()
    private var sections = [OptionsSectionType]()
    
    private let settingsVC = SettingsViewController()
    private let cartVC = CartViewController()
    
    
    static var opionsSectionCount: Int = 0
    static var hasTaggedAddon: Bool = false
    
    init(product: Product, addOns: [AddOnsData]) {
        self.product = product
        self.addOns = addOns
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var chosenProduct: [String] = []
    private var expectedIds: [String: Any] = [String: Any]()
    private var expectingIds = [String: Any]()
    
    private var filteringProductCost: Double?
    
    private var variationID: Int?
    private var variationName: String?
    private var quantity: Int = 0
    private var productCost: Double = 0.0
    private var totalCost: Double = 0.0
    
//    private var cartBarButton = UIBarButtonItem()
    private var cartBarButton = CartBadgeBarButtonItem()
    
    private let badgedCartButton: UIButton = {
        let button = UIButton.init(frame: CGRect.init(x: 0, y: 5, width: 30, height: 25))
        let image = UIImage(systemName: "cart.fill")
        button.setImage(image, for: .normal)
        button.tintColor = Constants.whiteBackgroundColor
        return button
    }()
    
    private var collectionView: UICollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewCompositionalLayout { (sectionIndex, _) -> NSCollectionLayoutSection? in
            return OptionsViewController.createSectionLayout(section: sectionIndex)
        }
    )
    private let productImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "photo")
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 5.0
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let productLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .medium)
        label.textColor = Constants.blackLabelColor
        label.numberOfLines = 0
        label.textAlignment = .center
        label.text = "Product name"
        return label
    }()
    
    private let topContainer: UIView = {
        let container = UIView(frame: .zero)
        container.layer.masksToBounds = true
        container.clipsToBounds = true
        return container
    }()
    
    private let bottomContainer: UIView = {
        let container = UIView(frame: .zero)
        container.layer.masksToBounds = true
        container.clipsToBounds = true
        return container
    }()
        
    private let qtyStepper: GMStepper = {
        let stepper = GMStepper(frame: .zero)
        stepper.borderColor = .black
        stepper.buttonsBackgroundColor = Constants.blackBackgroundColor
        stepper.buttonsFont = .systemFont(ofSize: 22, weight: .medium)
        stepper.labelFont = .systemFont(ofSize: 20, weight: .medium)
        stepper.labelTextColor = Constants.blackLabelColor
        stepper.labelBackgroundColor = Constants.whiteBackgroundColor
        stepper.limitHitAnimationColor = Constants.secondaryLabelColor
        return stepper
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .medium)
        label.textColor = Constants.blackLabelColor
        label.numberOfLines = 0
        label.textAlignment = .right
//        label.text = "₱135.00"
        return label
    }()
    
    private let addToBillingButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = Constants.blackBackgroundColor
        button.setTitle("Add to Billing", for: .normal)
        button.setTitleColor(Constants.whiteLabelColor, for: .normal)
        button.setTitleColor(Constants.darkGrayColor, for: .disabled)
        button.titleLabel?.font = .boldSystemFont(ofSize: 16)
        button.layer.cornerRadius = 5.0
        button.layer.masksToBounds = true
        button.backgroundColor = Constants.drawerTableBackgroundColor
        
        return button
    }()
    
    private let addOnsButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.tintColor = Constants.secondaryDarkLabelColor
//        button.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
//        button.setImage(UIImage(systemName: "plus.circle"), for: .selected)
        button.setBackgroundImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
        button.setBackgroundImage(UIImage(systemName: "plus.circle"), for: .selected)
//        button.layer.masksToBounds = true
//        button.clipsToBounds = true
        button.contentMode = .scaleAspectFit
        return button
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
        
//        fetchAddOns()
        
        
        getAllItems()
        configureCartButton()
        getLastOrderEntity()
        
        view.backgroundColor = Constants.whiteBackgroundColor
        
        view.addSubview(topContainer)
        view.addSubview(collectionView)
        view.addSubview(bottomContainer)
    
        
        configureCollectionView()
//        configureModels()
        configureProductOptionModel()
        
        topContainer.addSubview(productImage)
        topContainer.addSubview(productLabel)
        
        bottomContainer.addSubview(addToBillingButton)
        bottomContainer.addSubview(qtyStepper)
        bottomContainer.addSubview(priceLabel)
        
        // to delete addOnsButton Button
//        view.addSubview(addOnsButton)
        
//        collectionView.bringSubviewToFront(addOnsButton)
        
        collectionView.delegate = self
        collectionView.dataSource = self
//        print(product)
        
        addToBillingButton.addTarget(self, action: #selector(didTapAddtoBilling), for: .touchUpInside)
        
        qtyStepper.addTarget(self, action: #selector(stepperValueChanged), for: .valueChanged)
        
        updateUI(with: product)
        
        showAddOnsButton()
        
        isDeviceAuthorized()
        
//        filteringProductCost = product.price
//        currentProductSubtotal = product.price
        
        DispatchQueue.main.async {
            self.priceLabel.text = String(format:"₱%.2f", Double(self.product.attributes.isEmpty ? self.product.price : 0))
        }
        
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
    
    
    
    private func configureCartButton() {
        let customButton = UIButton(type: UIButton.ButtonType.custom)
        customButton.frame = CGRect(x: 0, y: 0, width: 35.0, height: 35.0)
        customButton.addTarget(self, action: #selector(didTapCart), for: .touchUpInside)
        customButton.setImage(UIImage(named: "Cart"), for: .normal)
//        customButton.setImage(UIImage(systemName: "cart"), for: .normal)
        
        cartBarButton = CartBadgeBarButtonItem()
        cartBarButton.setup(customButton: customButton)
        
//         self.btnBarBadge.shouldHideBadgeAtZero = true
//         self.btnBarBadge.shouldAnimateBadge = false
        
        var cartBadgeCount = 0
        for item in cart {
            cartBadgeCount += Int(item.cart_quantity)
        }
        
        
//        self.cartBarButton.badgeValue = "0"
        cartBarButton.badgeValue = "\(cartBadgeCount)"
        cartBarButton.badgeOriginX = 20.0
        cartBarButton.badgeOriginY = -4
        
        navigationItem.rightBarButtonItem = self.cartBarButton
    }
    
    func calculateAddedOnsTotalPrice() {
        var totalAddOnsPrice: Double = 0
        addOnsPriceSum = 0
        
        addOnsChosed.forEach({ addon in
            totalAddOnsPrice += addon.price
            addOnsPriceSum += addon.price
        })
        
        print("totalAddOnsPrice: \(totalAddOnsPrice)")
        
        if let currentProductSubtotal = currentProductSubtotal {
            print("current product total cost: \(currentProductSubtotal + totalAddOnsPrice)")
            DispatchQueue.main.async {
                self.priceLabel.text = String(format:"₱%.2f", Double(currentProductSubtotal + totalAddOnsPrice))
            }
        }
    }
    
    
    private func showAddOnsButton() {
        
        if addOns.contains(where: {
            $0.finished_product_ids.contains(where: { id in
                id == product.product_id
            })
            
        }) {
            addOnsButton.isHidden = false
        } else {
            addOnsButton.isHidden = true
        }
    }
    
    func configureBadgedCartButton() {
        let lblBadge = UILabel.init(frame: CGRect.init(x: 15, y: 0, width: 15, height: 15))
        lblBadge.backgroundColor = Constants.systemRedColor
        lblBadge.clipsToBounds = true
        lblBadge.layer.cornerRadius = lblBadge.width/2
        lblBadge.textColor = UIColor.white
        lblBadge.font = .systemFont(ofSize: 10, weight: .bold)
        lblBadge.textAlignment = .center
        lblBadge.isHidden = true
        
        let count = cart.count
        
        if count < 1 {
            lblBadge.isHidden = true
        } else {
            lblBadge.isHidden = false
            lblBadge.text = "\(count)"
        }

        badgedCartButton.addSubview(lblBadge)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: badgedCartButton)
        badgedCartButton.addTarget(self, action: #selector(didTapCart), for: .touchUpInside)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let topContainerHeight: CGFloat = 200.0
        let productImageSize = topContainerHeight*0.70
        let productLabelHeight = topContainerHeight-productImageSize-20
        
        let bottomContainerHeight: CGFloat = 160.0
        
        topContainer.frame = CGRect(
            x: 20,
            y: 0,
            width: view.width-40,
            height: topContainerHeight)
        topContainer.addBottomBorder(with: Constants.lightGrayBorderColor, andWidth: 0.5)
//        topContainer.backgroundColor = .systemGreen
        
        
        productImage.frame = CGRect(
            x: (topContainer.width-productImageSize)/2,
            y: 20,
            width: productImageSize,
            height: productImageSize)
//        productImage.backgroundColor = .darkGray
        
        productLabel.frame = CGRect(
            x: 0,
            y: productImage.bottom,
            width: topContainer.width,
            height: productLabelHeight)
//        productLabel.backgroundColor = .blue
        

        collectionView.frame = CGRect(
            x: 0,
            y: topContainer.bottom,
            width: view.width,
            height: view.height-bottomContainerHeight-topContainer.height)
//        collectionView.backgroundColor = .blue
        
        bottomContainer.frame = CGRect(
            x: 0,
            y: collectionView.bottom,
            width: view.width,
            height: bottomContainerHeight-view.safeAreaInsets.bottom)
//        bottomContainer.backgroundColor = .red
        bottomContainer.addTopBorder(with: Constants.lightGrayBorderColor, andWidth: 0.5)
        
        qtyStepper.frame = CGRect(
            x: 20,
            y: 15,
            width: 170.0,// (bottomContainer.width/2)-20-5,
            height: (bottomContainer.height/2)-20-5)
//        stepper.backgroundColor = .systemPink
        
        priceLabel.sizeToFit()
        priceLabel.frame = CGRect(
            x: qtyStepper.right+10,
            y: 15,
            width: bottomContainer.width-qtyStepper.width-10-40-view.safeAreaInsets.right,// (bottomContainer.width/2)-20-5,
            height: (bottomContainer.height/2)-20-5)
//        priceLabel.backgroundColor = .systemGreen
        
        addToBillingButton.frame = CGRect(
            x: 20,
            y: qtyStepper.bottom+15,
            width: bottomContainer.width-40,
            height: 44)
        
        
        let addOnsButtonSize: CGFloat = 40
        addOnsButton.frame = CGRect(
            x: view.width - addOnsButtonSize - 20 - view.safeAreaInsets.right,
            y: view.height - bottomContainer.height - addOnsButtonSize - 10 - view.safeAreaInsets.bottom,
            width: addOnsButtonSize+2,
            height: addOnsButtonSize)
//        addOnsButton.backgroundColor = .red
        
        layoutDemoLabel()
    }
    
    @objc func didTapCart() {
        print("Did tap cart")
        let vc = CartViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func stepperValueChanged() {
//        let totalPrice = qtyStepper.value * product.price
        let filteringTotalPrice = qtyStepper.value * (product.attributes.isEmpty ? product.price : filteringProductCost ?? 0)
        currentProductSubtotal = filteringTotalPrice
        print("currentProductSubtotal: \((currentProductSubtotal ?? 0) + self.addOnsPriceSum)")
        DispatchQueue.main.async {
//            self.priceLabel.text = String(format:"₱%.2f", Double(totalPrice))
            self.priceLabel.text = String(format:"₱%.2f", Double(filteringTotalPrice + self.addOnsPriceSum))
        }
    }
    
    private func updateUI(with model: Product) {
        qtyStepper.value = 1
        qtyStepper.minimumValue = 1
//        qtyStepper.maximumValue = 12 // available stock
        
        productImage.sd_setImage(with: URL(string: model.guid), completed: nil)
        productLabel.text = model.name
        priceLabel.text = String(format:"₱%.2f", Double(product.price + self.addOnsPriceSum))
    }
    
    private func showAlert() {
        let alert = UIAlertController(title: "Item added!", message: "Go to Menu.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
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
    
    @objc private func didTapAddtoBilling() {
        print("Did tap Add to Billing")
        print(chosenProduct)
        
        if chosenProduct.count == product.attributes.count {
            filterVariation(with: product.attributes.count)
            
            if !expectedIds.isEmpty {
                
                addToBillingButton.isEnabled = false
                
                // wait two seconds to simulate some work happening
                DispatchQueue.main.async {
                    // go back to cart
                    self.displayToastMessage("\(self.product.name.capitalized) added to Cart!")
                    self.optionsViewControllerDelegate?.shouldReloadDataFromOptionsVC()
                    self.refreshNavigationBar()
                    self.navigationController?.popViewController(animated: true)
                }
            }
        } else {
            let alert = UIAlertController(title: "", message: "Please select your option\(product.attributes.count > 1 ? "s" : "") for \(product.name).", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
        }
        getAllItems()
    }
    
    private func refreshNavigationBar() {
        /// refresh navigation bar to reflect cart badge count update
        print("NAVIGATION REFRESHED from option")
        _ = navigationController?.view.snapshotView(afterScreenUpdates: true)
    }
    
    private func filterVariation(with count: Int) {
        print("Variation Count: ", count)
        
        print("chosenProduct: \(chosenProduct)")
        
        let chosenProductTrimmed = chosenProduct.map({ $0.trimmingCharacters(in: .whitespaces) })
        
        print("chosenProductTrimmed: \(chosenProductTrimmed)")
        
        if count > 0 {
            if let prodVariations = product.variations {
                
                print("prodVariations: \(prodVariations)")
                
                for vtn in prodVariations {
                    
                    print("variations: \(vtn)")
                    
                    for _ in vtn.attribute {
                        
                        let filtered = vtn.attribute.enumerated().filter({ chosenProductTrimmed.contains($0.element.option.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)) })
                        
                        print("filtered: \(filtered)")

                        if filtered.count == chosenProductTrimmed.count {
                            expectedIds["product_id"] = product.product_id
                            expectedIds["variation_id"] = vtn.variation_id
                            expectedIds["quantity"] = qtyStepper.value
                            expectedIds["product_cost"] = vtn.price
                            expectedIds["variation_name"] = vtn.name

                            variationID = vtn.variation_id
                            variationName = vtn.name
                            quantity = Int(qtyStepper.value)
                            productCost = vtn.price
                            totalCost = vtn.price * qtyStepper.value
                        }
                    }
                }
            }
        } else {
            expectedIds["product_id"] = product.product_id
//            expectedIds["variation_id"] = nil
            expectedIds["quantity"] = qtyStepper.value
            expectedIds["product_cost"] = product.price //product.price*qtyStepper.value
//            expectedIds["variation_name"] = vtn.name
            
            variationID = 0
//            variationName = vtn.name
            quantity = Int(qtyStepper.value)
            productCost = product.price
            totalCost = productCost*qtyStepper.value
        }
        
        
        if !expectedIds.isEmpty {
            
            print("expected variant: ", expectedIds)
            print("adding item to billing...")
            
            if cartEntity.contains(where: { $0.cart_status == "added" }) {
                let cartLastAdded = cartEntity.last(where: { $0.cart_status == "added" })
                let cartLastAddedOrderID = cartLastAdded?.cart_order_id
                
                let cartLastAddedOrderIDNumbers = cartLastAddedOrderID?.split(separator: "-")
                
                let numbers = cartLastAddedOrderIDNumbers?.last ?? ""
                
                if let intLast = Int(numbers) {
                    print("intLast: ",intLast)
                    
                    
                    /// if the item exist
                    if let updatingCartItem = cartEntity.first(where: { $0.cart_product_id == product.product_id && $0.cart_variation_id == variationID ?? 0 && $0.cart_status == "added" }) {
                        
                        // update cart item quantity
                        print("updatingCartItem: \(updatingCartItem.cart_variation_name ?? "")")
                        CartViewController.shared.updateQty(
                            item: updatingCartItem,
                            qty: Int(updatingCartItem.cart_quantity) + quantity)
                        
                        addOnsChosed.forEach{ item in
                            cartVC.addToBilling(
                                productID: item.product_id,
                                variationID: 0,
                                variationName: item.name,// "\(item.name)-\(product.name)", //"\(item.name)", // "\(item.name)-\(product.name)"
                                productCost: item.price,
                                quantity: 1,
                                image: item.guid,
                                name: "\(item.name)", // "\(item.name)-\(product.name)"
                                discount: 0,
                                originalCost: item.price,
                                finalCost: item.price,
                                remarks: "\(item.name)-\(product.name)",
                                isChecked: false,
                                queue: queue,
                                fetchedLastOrderID: Int64(intLast),
                                taggedProduct: variationID != 0 ? variationID: product.product_id, //product.product_id
                                cartLastOrderEntity: cartLastOrderEntity)
                        }
                        
                    } else {
                        cartVC.addToBilling(
                            productID: product.product_id,
                            variationID: variationID,
                            variationName: variationName,
                            productCost: productCost,
                            quantity: quantity,
                            image: product.guid,
                            name: product.name,
                            discount: 0, //1-0.20, // 20%
                            originalCost: totalCost,
                            finalCost: totalCost,
                            remarks: "Added to cart",
                            isChecked: false,
                            queue: queue,
                            fetchedLastOrderID: Int64(intLast),
                            taggedProduct: nil,
                            cartLastOrderEntity: cartLastOrderEntity)
                        
                        addOnsChosed.forEach{ item in
                            cartVC.addToBilling(
                                productID: item.product_id,
                                variationID: 0,
                                variationName: item.name,// "\(item.name)-\(product.name)", //"\(item.name)", // "\(item.name)-\(product.name)"
                                productCost: item.price,
                                quantity: 1,
                                image: item.guid,
                                name: "\(item.name)", // "\(item.name)-\(product.name)"
                                discount: 0,
                                originalCost: item.price,
                                finalCost: item.price,
                                remarks: "\(item.name)-\(product.name)",
                                isChecked: false,
                                queue: queue,
                                fetchedLastOrderID: Int64(intLast),
                                taggedProduct: variationID != 0 ? variationID: product.product_id, //product.product_id
                                cartLastOrderEntity: cartLastOrderEntity)
                        }
                    }
                }
            } else {
                if let lastOrderID = lastOrderID {
                    cartVC.addToBilling(
                        productID: product.product_id,
                        variationID: variationID,
                        variationName: variationName,
                        productCost: productCost,
                        quantity: quantity,
                        image: product.guid,
                        name: product.name,
                        discount: 0, //1-0.20, // 20%
                        originalCost: totalCost,
                        finalCost: totalCost,
                        remarks: "",
                        isChecked: false,
                        queue: queue,
                        fetchedLastOrderID: lastOrderID + Int64(1),
                        taggedProduct: nil,
                        cartLastOrderEntity: cartLastOrderEntity)
                    
                
                    addOnsChosed.forEach{ item in
                        cartVC.addToBilling(
                            productID: item.product_id,
                            variationID: 0,
                            variationName: item.name,// "\(item.name)-\(product.name)", //"\(item.name)", // "\(item.name)-\(product.name)"
                            productCost: item.price,
                            quantity: 1,
                            image: item.guid,
                            name: "\(item.name)", // "\(item.name)-\(product.name)"
                            discount: 0,
                            originalCost: item.price,
                            finalCost: item.price,
                            remarks: "\(item.name)-\(product.name)",
                            isChecked: false,
                            queue: queue,
                            fetchedLastOrderID: lastOrderID + Int64(1),
                            taggedProduct: variationID != 0 ? variationID: product.product_id, //product.product_id
                            cartLastOrderEntity: cartLastOrderEntity)
                    }
                }
            }
        } else {
            print("No variant available for selected options: ", chosenProduct)
            
            let alert = UIAlertController(title: "", message: "No variant available for \(chosenProduct)", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            
        }
        
    }
    
    private func filteringVariation() {
        
        let chosenProductTrimmed = chosenProduct.map({ $0.trimmingCharacters(in: .whitespaces) })
        
        print("chosenProductTrimmed: \(chosenProductTrimmed)")
        if let prodVariations = product.variations {
            
            for vtn in prodVariations {
                
                for _ in vtn.attribute {
                    
                    let filtered = vtn.attribute.enumerated().filter({ chosenProductTrimmed.contains($0.element.option.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)) })
                    
                    print("filtered: \(filtered)")
                    
                    if filtered.count == chosenProductTrimmed.count {
                        expectingIds["product_id"] = product.product_id
                        expectingIds["variation_id"] = vtn.variation_id
                        expectingIds["quantity"] = qtyStepper.value
                        expectingIds["product_cost"] = vtn.price
                        expectingIds["variation_name"] = vtn.name
                        
                        filteringProductCost = vtn.price
                        currentProductSubtotal = vtn.price * qtyStepper.value
                    }
                }
            }
        }
        
//        print("expectingIds: \(expectingIds)")
        if let expectingPrice = expectingIds["product_cost"] as? Double {
            filteringProductCost = expectingPrice
            DispatchQueue.main.async {
                self.priceLabel.text = String(format:"₱%.2f", expectingPrice * self.qtyStepper.value + self.addOnsPriceSum)
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
    
    private func configureProductOptionModel() {
        OptionsViewController.opionsSectionCount = 0
        
        let sortedProdAttribs = product.attributes.sorted(by: { $0.attribute_key < $1.attribute_key })
//        let sortedProdAttribs = product.attributes
        
        let prodAttribs = sortedProdAttribs.compactMap({ att in
            ProductOptionSection(
                title: att.name,
                options: att.options.compactMap({
                    ProductOption(title: $0, image: nil, addOnPrice: nil)
                })
            )
        })
        OptionsViewController.opionsSectionCount += prodAttribs.count
        
        let prodVariations = product.variations?.compactMap({ vtn in
            ProductOptionSection(
                title: vtn.name,
                options: vtn.attribute.compactMap({
                    ProductOption(title: $0.option, image: nil, addOnPrice: nil)
            }))
        }) ?? prodAttribs
            
        
        print("prodVariations: ", prodVariations)
        
        productOptionSection.append(contentsOf: prodAttribs)
        
        if !addOns.isEmpty {
            let appendingAddons = [ProductOptionSection(title: "Add Ons", options: addOns.compactMap({ addOn in
                ProductOption(title: addOn.name, image: URL(string: addOn.guid), addOnPrice: addOn.price)
            }))]
            
            OptionsViewController.opionsSectionCount += appendingAddons.count
            productOptionSection.append(contentsOf: appendingAddons)
        }
        
        OptionsViewController.hasTaggedAddon = !addOns.isEmpty
        
        print("opionsSectionCount: \(OptionsViewController.opionsSectionCount)")
        print("hasTaggedAddon: \(OptionsViewController.hasTaggedAddon)")
        print("addOns COUNT: \(addOns.count)")
    }
    
    private func configureModels() {
        
        sections.append(.headerSection(
                            viewModels: Product(
                                product_id: product.product_id,
                                name: product.name,
                                type: product.type,
                                attributes: product.attributes,
                                guid: product.guid,
                                price: product.price,
                                category: product.category,
                                variations: product.variations,
                                post_modified: product.post_modified,
                                tax_class: product.tax_class
                            )))
        
        sections.append(.variationSection(viewModels: productOptionSection.compactMap({
            return ProductOptionSection(title: $0.title, options: productOptionSection.compactMap({
                return ProductOption(title: $0.title, image: nil, addOnPrice: nil)
            }))
        })))
        
        sections.append(.addOnsSections(
            viewModels: ProductOptionSection(
                title: "Add Ons",
                options: addOns.compactMap({
                    return ProductOption(title: $0.name, image: URL(string: $0.guid), addOnPrice: $0.price)
                }))
        ))
        
    }
    
    private func didTapVariation(with name: String) {
        print("Did tap ", name)
    }
    
    private func configureCollectionView() {
        view.addSubview(collectionView)
        
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        
        collectionView.register(OptionsCollectionViewCell.self, forCellWithReuseIdentifier: OptionsCollectionViewCell.identifier)
        collectionView.register(AddOnsCollectionViewCell.self, forCellWithReuseIdentifier: AddOnsCollectionViewCell.identifier)
        
        collectionView.register(
            TitleHeaderCollectionReusableView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: TitleHeaderCollectionReusableView.identifier)
        
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = Constants.whiteBackgroundColor
        
        collectionView.allowsMultipleSelection = true
    }
    
    func createSpinnerView() {
        let child = SpinnerViewController()

        // add the spinner view controller
        addChild(child)
        child.view.frame = view.bounds
        view.addSubview(child.view)
        child.didMove(toParent: self)

        // wait two seconds to simulate some work happening
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // then remove the spinner view controller
            child.willMove(toParent: nil)
            child.view.removeFromSuperview()
            child.removeFromParent()
        }
    }
    
    
    public func getAllItems() {
        do {
            // let items = try context.fetch(ToDoListItem.fetchRequest())
            cartEntity = try context.fetch(Cart_Entity.fetchRequest())
            cart = cartEntity.filter({ $0.cart_status == "added" })
            queue = cartEntity.filter({ $0.cart_status == "queue" })
            
            var cartBadgeCount = 0
            for item in cart {
                cartBadgeCount += Int(item.cart_quantity)
            }
            
            cartBarButton.badgeValue = "\(cartBadgeCount)"
        } catch {
            // error
        }
    }
    
    private func appendAddOn(with addOn: AddOnsData) {
        addOnsChosed.append(addOn)
        print("addOnsChosedCount after appending: \(addOnsChosed.count)")
    }
    
    private func removeAddOn(with addOn: AddOnsData) {
        addOnsChosed.removeAll(where: { $0.product_id == addOn.product_id })
        print("addOnsChosedCount after removing: \(addOnsChosed.count)")
    }
    
    public func showSnackBar(snackBar: SnackBarView) {
        let wid = view.width-40
        snackBar.frame = CGRect(
            x: (view.width-wid)/2,
            y: view.height-40,
            width: wid,
            height: 40)
        
        view.addSubview(snackBar)
        
        UIView.animate(withDuration: 0.3) {
            snackBar.frame = CGRect(
                x: (self.view.width-wid)/2,
                y: self.view.height - 56 - self.view.safeAreaInsets.bottom,
                width: wid,
                height: 40)
        } completion: { done in
            if done {
                DispatchQueue.main.asyncAfter(deadline: .now()+0.6) {
                    UIView.animate(withDuration: 0.3) {
                        snackBar.frame = CGRect(
                            x: (self.view.width-wid)/2,
                            y: self.view.height,
                            width: wid,
                            height: 40)
                    } completion: { finished in
                        if finished {
                            snackBar.removeFromSuperview()
                        }
                    }
                }
            }
        }
        
    }
    
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource

extension OptionsViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return productOptionSection.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return productOptionSection[section].options.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if addOns.isEmpty {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OptionsCollectionViewCell.identifier, for: indexPath) as? OptionsCollectionViewCell else {
                return UICollectionViewCell()
            }
            
            let model = productOptionSection[indexPath.section].options[indexPath.row]
            cell.configure(withModel: OptionsCollectionViewCellViewModel(id: 1, data: model.title, image: model.image, addOnPrice: nil))
            return cell
        } else {
            if indexPath.section < productOptionSection.count-1 {
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OptionsCollectionViewCell.identifier, for: indexPath) as? OptionsCollectionViewCell else {
                    return UICollectionViewCell()
                }
                
                let model = productOptionSection[indexPath.section].options[indexPath.row]
                cell.configure(withModel: OptionsCollectionViewCellViewModel(id: 1, data: model.title, image: model.image, addOnPrice: nil))
                return cell
            } else {
                
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AddOnsCollectionViewCell.identifier, for: indexPath) as? AddOnsCollectionViewCell else {
                    return UICollectionViewCell()
                }
                let model = productOptionSection[indexPath.section].options[indexPath.row]
                cell.configure(withModel: OptionsCollectionViewCellViewModel(id: 1, data: model.title, image: model.image, addOnPrice: model.addOnPrice))
                return cell
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        
//        collectionView.indexPathsForSelectedItems?.filter({ $0.section == indexPath.section }).forEach({
//            collectionView.deselectItem(at: $0, animated: false)
//
//            let model = productOptionSection[indexPath.section].options[$0.row]
//            let chosenAttribute = model.title.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
//            if let attribToRemove = chosenProduct.first(where: { $0 == chosenAttribute }) {
//                chosenProduct.removeAll(where: { $0 ==  attribToRemove})
//            }
//        })
//
//        print(chosenProduct)
//        return true
        
        
        if addOns.isEmpty {
            
            collectionView.indexPathsForSelectedItems?.filter({ $0.section == indexPath.section }).forEach({
                collectionView.deselectItem(at: $0, animated: false)
                
                let model = productOptionSection[indexPath.section].options[$0.row]
                let chosenAttribute = model.title.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
                if let attribToRemove = chosenProduct.first(where: { $0 == chosenAttribute }) {
                    chosenProduct.removeAll(where: { $0 ==  attribToRemove})
                }
            })
            
        } else {
            if indexPath.section < productOptionSection.count-1 {
                
                collectionView.indexPathsForSelectedItems?.filter({ $0.section == indexPath.section }).forEach({
                    collectionView.deselectItem(at: $0, animated: false)
                    
                    let model = productOptionSection[indexPath.section].options[$0.row]
                    let chosenAttribute = model.title.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
                    if let attribToRemove = chosenProduct.first(where: { $0 == chosenAttribute }) {
                        chosenProduct.removeAll(where: { $0 ==  attribToRemove})
                    }
                })
            } else {
                let model = productOptionSection[indexPath.section].options[indexPath.row]
                print("addOn shouldSelectItemAt!: \(model)")
            }
        }
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
//        let model = productOptionSection[indexPath.section].options[indexPath.row]
//        let chosenAttribute = model.title.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
//        chosenProduct.removeAll(where: { $0 == chosenAttribute })
//        print(chosenProduct)
        
        
        if addOns.isEmpty {
            let model = productOptionSection[indexPath.section].options[indexPath.row]
            let chosenAttribute = model.title.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
            chosenProduct.removeAll(where: { $0 == chosenAttribute })
            print(chosenProduct)
            
        } else {
            if indexPath.section < productOptionSection.count-1 {
                let model = productOptionSection[indexPath.section].options[indexPath.row]
                let chosenAttribute = model.title.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
                chosenProduct.removeAll(where: { $0 == chosenAttribute })
                print(chosenProduct)
            } else {
                let model = productOptionSection[indexPath.section].options[indexPath.row]
                print("addOn didDeselectItemAt!: \(model)")
                
                if let chosenAddon = addOns.first(where: { $0.name.lowercased() == model.title.lowercased()}) {
                    removeAddOn(with: chosenAddon)
                    print("removing addOn: \(chosenAddon)")
                }
            }
        }
        
        print("addOnsChosed after didDeselectItemAt: \(addOnsChosed)")
        calculateAddedOnsTotalPrice()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let model = productOptionSection[indexPath.section].options[indexPath.row]
//        let chosenAttribute = model.title.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
//        chosenProduct.append(chosenAttribute)
//
//        print(chosenProduct)
        // filter variation
        
        if addOns.isEmpty {
            let model = productOptionSection[indexPath.section].options[indexPath.row]
            let chosenAttribute = model.title.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
            chosenProduct.append(chosenAttribute)
            filteringVariation()
            
        } else {
            if indexPath.section < productOptionSection.count-1 {
                let model = productOptionSection[indexPath.section].options[indexPath.row]
                let chosenAttribute = model.title.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
                chosenProduct.append(chosenAttribute)
                filteringVariation()
            } else {
                let model = productOptionSection[indexPath.section].options[indexPath.row]
                print("addOn didSelectItemAt!: \(model)")
                
                if let chosenAddon = addOns.first(where: { $0.name.lowercased() == model.title.lowercased()}) {
                    appendAddOn(with: chosenAddon)
                    print("inserting addOn: \(chosenAddon)")
                }
            }
        }
        print("addOnsChosed after didSelectItemAt: \(addOnsChosed)")
        calculateAddedOnsTotalPrice()
    }
    
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: TitleHeaderCollectionReusableView.identifier,
                for: indexPath) as? TitleHeaderCollectionReusableView, kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }
        
        let section = indexPath.section
        let modelTitle = productOptionSection[section].title
        
        header.configure(withTitle: modelTitle)
        return header
    }
}


extension OptionsViewController {
    public func getLastOrderEntity() {
        do {
            // let items = try context.fetch(ToDoListItem.fetchRequest())
            cartLastOrderEntity = try context.fetch(Cart_Last_OrderID_Entity.fetchRequest())
            lastOrderID = cartLastOrderEntity.last?.cart_last_order_id
            
        } catch {
            print(error.localizedDescription)
        }
    }
}

// MARK:- CollectionView Sections Layout
extension OptionsViewController {
    static func createSectionLayout(section: Int) -> NSCollectionLayoutSection? {
        
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
        print("hasTaggedAddon: \(hasTaggedAddon), opionsSectionCount: \(opionsSectionCount)")
        
        if hasTaggedAddon {
            
            if opionsSectionCount > 1 {
                
                switch section {
                case 0..<opionsSectionCount-1:
                    print("hasTaggedAddon: \(0..<opionsSectionCount-1)")
                    // Item
                    let item = NSCollectionLayoutItem(
                        layoutSize: NSCollectionLayoutSize(
                            widthDimension: .fractionalWidth(1.0),
                            heightDimension: .fractionalHeight(1.0)
                        )
                    )
                    item.contentInsets = NSDirectionalEdgeInsets(
                        top: 0,
                        leading: 10,
                        bottom: 20,
                        trailing: 10)
                    
                    // Group
                    // vertical group inside horizontal group
                    let hGroup = NSCollectionLayoutGroup.horizontal(
                        layoutSize: NSCollectionLayoutSize(
                            widthDimension: .fractionalWidth(1.0),
                            heightDimension: .absolute(60.0)
                        ),
                        subitem: item,
                        count: 3)
                    
                    let vGroup = NSCollectionLayoutGroup.vertical(
                        layoutSize: NSCollectionLayoutSize(
                            widthDimension: .fractionalWidth(1.0),
                            heightDimension: .absolute(60.0)
                        ),
                        subitem: hGroup,
                        count: 1)
                    
                    // Section
                    let section = NSCollectionLayoutSection(group: vGroup)
                    section.contentInsets = NSDirectionalEdgeInsets(
                        top: 0,
                        leading: 20,
                        bottom: 0,
                        trailing: 20)
                    
                    section.boundarySupplementaryItems = supplementaryViews
                    //        section.orthogonalScrollingBehavior = .continuous
                    return section
                default:
                    // Item addons section
                    let item = NSCollectionLayoutItem(
                        layoutSize: NSCollectionLayoutSize(
                            widthDimension: .fractionalWidth(1.0),
                            heightDimension: .fractionalHeight(1.0)
                        )
                    )
                    item.contentInsets = NSDirectionalEdgeInsets(
                        top: 0,
                        leading: 10,
                        bottom: 20,
                        trailing: 10)
                    
                    // Group
                    
                    let vGroup = NSCollectionLayoutGroup.vertical(
                        layoutSize: NSCollectionLayoutSize(
                            widthDimension: .fractionalWidth(1.0),
                            heightDimension: .absolute(80.0)
                        ),
                        subitem: item,
                        count: 1)
                    
                    // Section
                    let section = NSCollectionLayoutSection(group: vGroup)
                    section.contentInsets = NSDirectionalEdgeInsets(
                        top: 0,
                        leading: 20,
                        bottom: 0,
                        trailing: 20)
                    
                    section.boundarySupplementaryItems = supplementaryViews
                    //        section.orthogonalScrollingBehavior = .continuous
                    return section
                }
            } else {
                // Item addons section
                let item = NSCollectionLayoutItem(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1.0),
                        heightDimension: .fractionalHeight(1.0)
                    )
                )
                item.contentInsets = NSDirectionalEdgeInsets(
                    top: 0,
                    leading: 10,
                    bottom: 20,
                    trailing: 10)
                
                // Group
                
                let vGroup = NSCollectionLayoutGroup.vertical(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1.0),
                        heightDimension: .absolute(80.0)
                    ),
                    subitem: item,
                    count: 1)
                
                // Section
                let section = NSCollectionLayoutSection(group: vGroup)
                section.contentInsets = NSDirectionalEdgeInsets(
                    top: 0,
                    leading: 20,
                    bottom: 0,
                    trailing: 20)
                
                section.boundarySupplementaryItems = supplementaryViews
                //        section.orthogonalScrollingBehavior = .continuous
                return section
            }
            
        } else {
            // Item - attributes sections
            let item = NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .fractionalHeight(1.0)
                )
            )
            item.contentInsets = NSDirectionalEdgeInsets(
                top: 0,
                leading: 10,
                bottom: 20,
                trailing: 10)
            
            // Group
            // vertical group inside horizontal group
            let hGroup = NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .absolute(60.0)
                ),
                subitem: item,
                count: 3)
            
            let vGroup = NSCollectionLayoutGroup.vertical(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .absolute(60.0)
                ),
                subitem: hGroup,
                count: 1)
            
            // Section
            let section = NSCollectionLayoutSection(group: vGroup)
            section.contentInsets = NSDirectionalEdgeInsets(
                top: 0,
                leading: 20,
                bottom: 0,
                trailing: 20)
            
            section.boundarySupplementaryItems = supplementaryViews
            //        section.orthogonalScrollingBehavior = .continuous
            return section
        }
        
    }
}





//$choose_this = array("L", "Banana");
//
//foreach($variations as $variation_object){
//  $variation_id = $variation_object['variation_id'];
//  $attributes = $variation_object['attributes'];
//
//  $this_is_it = true;
//
//  foreach($attributes as $attribute){
//
//    if(!in_array($attribute['option'], $choose_this)){
//      $this_is_it = false;
//      break;
//    }
//
//  }
//
//  if($this_is_it){
//    return $variation_id;
//  }
//
//}
