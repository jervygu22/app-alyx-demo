//
//  MenuViewController.swift
//  Jeeves-dev
//
//  Created by Jervy Umandap on 2/4/22.
//

import UIKit
import SideMenu
import SDWebImage
import CoreData

enum MenuSectionType {
    case categorySection(viewModels: [CategoryCellViewModel])           // 0
    case productSection(viewModels: [CategoryItemsCellViewModel])       // 1
    
    var title: String {
        switch self {
        case .categorySection:
            return "Categories"
        case .productSection:
            if MenuViewController.categoryName == nil {
                return "All" //"All Menu"
            } else {
                let name = MenuViewController.categoryName ?? "category name not found"
                return "\(name)" //"\(name) Menu"
            }
        }
    }
}

class MenuViewController: UIViewController, DrawerControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate {
    
    static let shared = MenuViewController()
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private var isFinishedFetchingData = false
    
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    private var cartEntityModels = [Cart_Entity]()
    
    private var drawer: SideMenuNavigationController?
    
    public let historyVC = HistoryViewController()
    public let accountVC = AccountViewController()
    public let queueVC = QueueViewController()
    public let notifVC = NotificationViewController()
    public let settingsVC = SettingsViewController()
    public let contactUs = ContactUsViewController()
    public let termsCondition = WebViewController()
    
    private var fetchCategories: [Category] = []
    private var fetchedProducts: [Product] = []
    
    private var categoryArray: [Category] = []
    private var productsArray: [Product] = []
    
    private var surchargeData: [SurchargeData]?
    private var surchargeEntity = [Surcharges_Entity]()
    private var couponsEntity = [Coupons_Entity]()
    
    /// CoreData
    private var coredataCategories: [Category]?
    private var coredataProducts: [Product]?
    
    private var addOns = [AddOnsData]()
    private var couponsData = [CouponData]()
    
//    private var coreDataArray: [NSManagedObject] = []
    private var cart = [Cart_Entity]()
    private var categoryEntity = [Categories_Entity]()
    private var productEntity = [Products_Entity]()
    private var productAttributesEntity = [Product_Attributes_Entity]()
    private var productVariationsEntity = [Product_Variations_Entity]()
    private var variationAttributesEntity = [Variation_Attributes_Entity]()
    
    private var addOnsEntity = [AddOns_Entity]()
    
    private var productsObject = [Product]()
    
    private var filteringProductsArray: [Product] = []
//    private var filteringArray: [NSManagedObject] = []
    
    private var allisSelected = true
    
    private var categorizedProducts: [Product]?
    static var categoryName: String?
    
    public var searchString: String?
    public var didPullToRefreshData: Bool = false
    
    var isHaveTimeInPinEntered: Bool {
        return UserDefaults.standard.string(forKey: "pin_code_entered") != nil
    }
    
    enum MenuOptions: String, CaseIterable {
        case Menu = "Menu"
        case History = "History"
        case Account = "Account"
        case Queue = "Queue"
        case Notification = "Notification"
        case TermsCondition = "Terms & Condition"
        case Settings = "Settings"
        case Logout = "Logout"
        
        var imageName: String {
            switch self {
            case .Menu:
                return "fork.knife" // "house.fill"
            case .History:
                return "clock.arrow.circlepath"
            case .Account:
                return "person.fill"
            case .Queue:
                return "arrow.clockwise.icloud.fill"
            case .Notification:
                return "bell.fill"
            case .TermsCondition:
                return "checkmark.shield.fill"
            case .Settings:
                return "gearshape.fill"
            case .Logout:
                return "power"
            }
        }
    }
    
    
    let menuSearchController: UISearchController = {
        let vc = MenuSearchResultsViewController()
        let searchController = UISearchController(searchResultsController: vc)
        searchController.searchBar.placeholder = "Search item"
        searchController.searchBar.searchBarStyle = .default
        searchController.definesPresentationContext = true
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.keyboardAppearance = .default
        return searchController
    }()
    
    let historySearchController: UISearchController = {
        let vc = HistorySearchResultsViewController()
        let searchController = UISearchController(searchResultsController: vc)
        searchController.searchBar.placeholder = "Search"
        searchController.searchBar.searchBarStyle = .default
        searchController.definesPresentationContext = true
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.keyboardAppearance = .default
        return searchController
    }()
    
    // _ is for environment (iPad, iPhone)
    private var collectionView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewCompositionalLayout { (sectionIndex, _) -> NSCollectionLayoutSection? in
        return MenuViewController.createSectionLayout(section: sectionIndex)
    })
    
    private let spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView()
        spinner.tintColor = Constants.drawerLabelColor
        spinner.hidesWhenStopped = true
        return spinner
    }()
    
    private let menuErrorFetchingDataLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.text = """
                    Failed to load menu.
                    Something went wrong with the server.
                    """
        label.numberOfLines = 0
        label.sizeToFit()
        label.textAlignment = .center
        label.textColor = Constants.secondaryLabelColor
        label.isHidden = true
        return label
    }()
    
    private var sections = [MenuSectionType]()
    
    private var cartBarButton = CartBadgeBarButtonItem()
    private var userInfoBarButton = UIBarButtonItem()
    private var plusBarButton = UIBarButtonItem()
    private var checkDomainBarButton = UIBarButtonItem()
    
    private var cashierNavBarButton = [UIBarButtonItem]()
    
    override func loadView() {
        super.loadView()
//        fetchData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // APICALLS
//        fetchData()
        
        fetchUpdatedProducts()
        
        getCouponsEntity()
        getSurchargesEntity()
        
        
        getCartEntityItems()
        getCategoryEntity()
        getProductEntity()
        getProductAttribs()
        getProductVariations()
        getVariationsAttribs()
        
        getAddOnsEntity()
        
        
        fetchData()
        fetchAddons()
        fetchSurcharges()
        fetchCoupons()
        
//        getCategoryAndProductsEntity()
        
        
        // store to coredata the fetcheddata
//        if categoryEntity.isEmpty || productEntity.isEmpty {
//            storeToCoreData(with: fetchCategories, with: fetchedProducts)
//        }
        
        createCoreDataToDisplay()
        
        title = "Menu"
        view.backgroundColor = Constants.vcBackgroundColor
        
        
//        drawer = SideMenuNavigationController(rootViewController: DrawerController())
        let drawerItems = DrawerController(with: DrawerItems.allCases)
        drawerItems.drawerControllerDelegate = self
        
        drawer = SideMenuNavigationController(
            rootViewController: drawerItems)
        
        
        drawer?.leftSide = true
        drawer?.setNavigationBarHidden(true, animated: false)
        drawer?.menuWidth = CGFloat(300.0)// CGFloat(view.width * 0.70)
        drawer?.presentationStyle = .menuSlideIn //.viewSlideOutMenuIn
        drawer?.presentationStyle.presentingEndAlpha = 0.5 // dim background
        
        SideMenuManager.default.leftMenuNavigationController = drawer
        SideMenuManager.default.addPanGestureToPresent(toView: self.view)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "line.horizontal.3"),
            style: .done,
            target: self,
            action: #selector(didTapSettings))
        
        configureCartButton()
        
        //        cartBarButton = UIBarButtonItem(
        //            image: UIImage(systemName: "cart.fill"),
        //            style: .done,
        //            target: self,
        //            action: #selector(didTapCart))
        
        userInfoBarButton = UIBarButtonItem(
            image: UIImage(systemName: "person.fill"),
            style: .done,
            target: self,
            action: #selector(didTapUserImage))
        
        checkDomainBarButton = UIBarButtonItem(
            image: UIImage(systemName: "at.badge.plus"),
            style: .done,
            target: self,
            action: #selector(didTapDomainCheck))
        
        plusBarButton = UIBarButtonItem(
            image: UIImage(systemName: "plus"),
            style: .done,
            target: self,
            action: #selector(didTapPlus))
        
//        navigationItem.rightBarButtonItem = cartBarButton
        
        configureCollectionView()
        view.addSubview(spinner)
        addChildControllers()
        
        menuSearchController.searchResultsUpdater = self
        menuSearchController.searchBar.delegate = self
        menuSearchController.hidesNavigationBarDuringPresentation = false
        
        navigationItem.searchController = isHaveTimeInPinEntered ? menuSearchController : nil // menuSearchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
//        failedToGetData()
        
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .lightGray
        refreshControl.accessibilityNavigationStyle = .separate
        collectionView.refreshControl = refreshControl
        collectionView.refreshControl?.addTarget(self, action: #selector(didPullDownToRefresh), for: .valueChanged)
        
        print("cart count ", cart.count)
        
        print("isHaveTimeInPinEntered: ", isHaveTimeInPinEntered)
        
//        print("categorieEntity \(categoryEntity.count): \(categoryEntity)")
//        print("productEntity \(productEntity.count):  \(productEntity)")
//        print("productAttributesEntity \(productAttributesEntity.count): \(productAttributesEntity)")
//        print("productVariationsEntity \(productVariationsEntity.count): \(productVariationsEntity)")
//        print("variationAttributesEntity \(variationAttributesEntity.count): \(variationAttributesEntity)")
        
        readCartLastOrderEntity()
        
//        print("isFinishedFetchingData: \(isFinishedFetchingData)")
//        if isFinishedFetchingData {
//            populateFromCoreData()
//        }
        
        
        
        print("surchargeData: \(surchargeData)")
        
        
        configCashierBarButton(
            with: UserDefaults.standard.string(forKey: "pin_entered_username")?.capitalized ?? "-",
            with: URL(string: UserDefaults.standard.string(forKey: "pin_entered_user_image") ?? "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS_WEqNwRZ9L1xbFOkr-cAzDswZEEEcwgdLODnPRdavrEna-3NlcTV2SKcGoDktLZiEqNk&usqp=CAU"),
            with: UserDefaults.standard.stringArray(forKey: "pin_entered_user_roles")?.first ?? "-")
        
        
        let isInitialSent = UserDefaults.standard.bool(forKey: Constants.is_initial_sent)
        print("isInitialSent: \(isInitialSent)")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshNavigationBar()
        getCartEntityItems()

        getAddOnsEntity()

        isDeviceAuthorized()

        populateFromCoreData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !(self.coredataCategories?.isEmpty ?? false) {
//            shouldSelectCategoryAll()
        }
    }
    
    private func refreshNavigationBar() {
        /// refresh navigation bar to reflect cart badge count update
        print("NAVIGATION REFRESHED")
        _ = navigationController?.view.snapshotView(afterScreenUpdates: true)
    }
    
    private func configureCartButton() {
        let customButton = UIButton(type: UIButton.ButtonType.custom)
        customButton.frame = CGRect(x: 0, y: 0, width: 35.0, height: 35.0)
        customButton.addTarget(self, action: #selector(didTapCart), for: .touchUpInside)
        customButton.setImage(UIImage(named: "Cart"), for: .normal)
        
//        cartBarButton = CartBadgeBarButtonItem()
        cartBarButton.setup(customButton: customButton)
        
        // self.btnBarBadge.shouldHideBadgeAtZero = true
        // self.btnBarBadge.shouldAnimateBadge = false
        
        
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
    
    
    
    @objc private func didPullDownToRefresh() {
        didPullToRefreshData = true
        
        // fetch newCategories, surcharges,
        fetchUpdatedCategories()
        
        fetchUpdatedProducts()
        getAddOnsEntity()
        
        fetchAddons()
        
        fetchSurcharges()
        
        getCouponsEntity()
        fetchCoupons()
        
        refetchCatsProducts()
        isDeviceAuthorized()
        
//        if let coredataCategories = coredataCategories,
//           let coredataProducts = coredataProducts {
//            if coredataCategories.isEmpty || coredataProducts.isEmpty {
//                createCoreDataToDisplay()
//                populateFromCoreData()
//            }
//        }
        
        coredataCategories?.removeAll()
        coredataProducts?.removeAll()
        
        createCoreDataToDisplay()
        populateFromCoreData()
        passCategoryName(with: "All")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
        collectionView.backgroundColor = Constants.vcBackgroundColor
    }
    
    private func fetchAddons() {
        APICaller.shared.getAddOns { [weak self] (result) in
            guard let strongSelf = self else { return }
            switch result {
            case .success(let model):
                
                /// test addOns
//                var fetchEdAddOns = model
//                fetchEdAddOns.append(AddOnsData(
//                    finished_product_ids: [1560,946,1561],
//                    product_id: 1621,
//                    name: "Nata de Coco",
//                    type: "simple",
//                    guid: "https://alyx.codedisruptors.com/demofranchise/wp-content/uploads/sites/6/2022/05/black-pearl-milk-tea-3-1.jpg",
//                    price: 10,
//                    category: 44))
//
//                fetchEdAddOns.append(AddOnsData(
//                    finished_product_ids: [1560,946,1561],
//                    product_id: 1622,
//                    name: "Gulaman",
//                    type: "simple",
//                    guid: "https://alyx.codedisruptors.com/demofranchise/wp-content/uploads/sites/6/2022/05/black-pearl-milk-tea-3-1.jpg",
//                    price: 10,
//                    category: 44))
//
//                fetchEdAddOns.append(AddOnsData(
//                    finished_product_ids: [1560,946,1561],
//                    product_id: 1623,
//                    name: "Corn",
//                    type: "simple",
//                    guid: "https://alyx.codedisruptors.com/demofranchise/wp-content/uploads/sites/6/2022/05/black-pearl-milk-tea-3-1.jpg",
//                    price: 10,
//                    category: 44))
//
//                fetchEdAddOns.append(AddOnsData(
//                    finished_product_ids: [1560,946,1561],
//                    product_id: 1624,
//                    name: "Beans",
//                    type: "simple",
//                    guid: "https://alyx.codedisruptors.com/demofranchise/wp-content/uploads/sites/6/2022/05/black-pearl-milk-tea-3-1.jpg",
//                    price: 10,
//                    category: 44))
//                print("addOnsEntity: \(strongSelf.addOnsEntity.count) ?= model: \(fetchEdAddOns.count)")
//                if strongSelf.addOnsEntity.count != fetchEdAddOns.count {
//                    strongSelf.removeAddOns(with: fetchEdAddOns)
//                    strongSelf.storeAddOns(with: fetchEdAddOns)
//                }
                
                
                print("addOnsEntity: \(strongSelf.addOnsEntity.count) ?= model: \(model.count)")
                if strongSelf.addOnsEntity.count != model.count {
                    strongSelf.removeAddOns(with: model)
                    strongSelf.storeAddOns(with: model)
                }
                break
            case .failure(let error):
                print("fetchAddons error: \(error.localizedDescription)")
                break
            }
        }
    }
    
    private func fetchData() {
        print("fetchData() called!")
        
        DispatchQueue.main.async {
            if self.collectionView.refreshControl?.isRefreshing == true {
                print("refreshing categories and products")
            } else {
                print("fetching categories and products..")
            }
        }
        
        let dispatchGroup = DispatchGroup()
        
        
        var categories: [Category]?
        var products: [Product]?
        
        
        dispatchGroup.enter()
        APICaller.shared.getMenuCategories { [weak self] result in
            // defer, whenever this ApiCall is completed, decrement the number of dispatchGroup entries
            defer {
                dispatchGroup.leave()
            }
            switch result{
            case .success(let model):
                self?.fetchCategories = model.data
                categories = model.data
                let all = Category(
                    id: 0,
                    name: "All",
                    slug: "all",
                    parent_id: 0,
                    guid: "https://jeeves-reboot.codedisruptors.com/wp-content/uploads/2021/12/all_meal-1.png")
                
                self?.fetchCategories.insert(all, at: 0)
//                print("fetchCategories Response: \(self?.fetchCategories)")
                categories?.insert(all, at: 0)
                
                var scategories = model.data
                scategories.insert(all, at: 0)
                
                dispatchGroup.enter()
                APICaller.shared.getMenuProducts(completion: { result in
                    
                    print("fetchData-categories and products APICALL called!")
                    // defer, whenever this ApiCall is completed, decrement the number of dispatchGroup entries
                    defer {
                        dispatchGroup.leave()
                    }
                    switch result{
                    case .success(let productsModel):
                        self?.fetchedProducts = productsModel.data
//                        print("fetchedProducts Response: \(model.data)")
                        products = productsModel.data
//                        products = self?.coredataProducts
                        
                        if let coreDataCats = self?.coredataCategories,
                           let coreDataProds = self?.coredataProducts,
                           let coreDataCatsEntity = self?.categoryEntity,
                           let coreDataProdEntity = self?.productEntity,
                           let coreDataProdAttsEntity = self?.productAttributesEntity,
                           let coreDataProdVarsEntity = self?.productVariationsEntity,
                           let coreDataVarAttsEntity = self?.variationAttributesEntity {
                            
                            if coreDataCatsEntity.count != scategories.count || coreDataProdEntity.count != productsModel.data.count {
                                
                                print("coreDataCats", coreDataCats.count)
                                print("coreDataProds",coreDataProds.count)
                                print("scategories",scategories.count)
                                print("sprods",productsModel.data.count)
                                print("coreDataProdAttsEntity",coreDataProdAttsEntity.count)
                                print("coreDataProdVarsEntity",coreDataProdVarsEntity.count)
                                print("coreDataVarAttsEntity",coreDataVarAttsEntity.count)
                                
                                // clear entities data first
                                self?.clearEntities(with: coreDataCatsEntity,
                                                    with: coreDataProdEntity,
                                                    with: coreDataProdAttsEntity,
                                                    with: coreDataProdVarsEntity,
                                                    with: coreDataVarAttsEntity)
                                
                                // then store to entities
                                self?.storeToCoreData(with: scategories, with: productsModel.data)
                                print("storeToCoreData if called!")
                                
                                self?.isFinishedFetchingData = true
                            }
                        }
                        
                        break
                    case .failure(let error):
                        print("getProducts: ", error.localizedDescription)
                        break
                    }
                })
                
                
//                DispatchQueue.main.async {
//                    self?.showAlertWith(title: "Saved successfully", message: "Categories and products is now available for orders, please continue", hasFetchedData: true)
//                }
                break
                
            case .failure(let error):
                
                print("getCategory: ", error.localizedDescription)
                
                
                categories = self?.coredataCategories
                products = self?.coredataProducts
//                print("categories from failure: ",categories)
//                print("products from failure: ",products)
                
//                DispatchQueue.main.async {
//                    self?.showAlertWith(title: "Could not connect!", message: "Fetching saved categories and products", hasFetchedData: false)
//                }
                break
            }
        }
        
//
//        dispatchGroup.notify(queue: .main) {
//
//            guard let categories = categories,
//                  let products = products
//            else {
//                return
//            }
//
//            DispatchQueue.main.async { [weak self] in
//                self?.collectionView.refreshControl?.endRefreshing()
////                self?.configureModels(categories: categories, products: products)
//            }
//        }
    }
    
    
    private func clearEntities(with categEntity: [Categories_Entity], with prodEntity: [Products_Entity], with prodAttEntity: [Product_Attributes_Entity], with prodVarEntity: [Product_Variations_Entity], with varAttEntity: [Variation_Attributes_Entity]) {
        do {
            
            for cat in categEntity {
                context.delete(cat)
            }
            
            for prod in prodEntity {
                context.delete(prod)
            }
            
            for att in prodAttEntity {
                context.delete(att)
            }

            for vari in prodVarEntity {
                context.delete(vari)
            }

            for variAtt in varAttEntity {
                context.delete(variAtt)
            }
            
            try context.save() //don't forget
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
            
        } catch let error as NSError {
            print("delete fail--",error)
        }
    }
    
    
    private func updateProduct(with products: [Product]) {
        var productToUpdate = [Products_Entity]()
        var productAttributesToUpdate = [Product_Attributes_Entity]()
        var productVariationsToUpdate = [Product_Variations_Entity]()
        var variationAttributesToUpdate = [Variation_Attributes_Entity]()
        
        context.perform {
            /// products
            let sortedProducts = products.sorted(by: { $0.product_id < $1.product_id })
            print("updated sortedProducts: \(sortedProducts)")
            sortedProducts.forEach({ prod in
                let productEntityToUpdate = Products_Entity(context: self.context)
//                prodEntity = productEntity
                
                productEntityToUpdate.product_category = Int64(prod.category)
                productEntityToUpdate.product_guid = prod.guid
                productEntityToUpdate.product_id = Int64(prod.product_id)
                productEntityToUpdate.product_name = prod.name
                productEntityToUpdate.product_price = prod.price
                productEntityToUpdate.product_type = prod.type
                
                
                print("successfully saved \(prod.name) to productEntity")
                
                /// ProductAttribute
                prod.attributes.forEach({att in
                    let prodAttributesEntity = Product_Attributes_Entity(context: self.context)
                    prodAttributesEntity.product_attribute_key = att.attribute_key
                    prodAttributesEntity.product_attribute_name = att.name
                    prodAttributesEntity.product_attribute_options = att.options
                    
                    prodAttributesEntity.product = productEntityToUpdate
                    
                    print("successfully saved \(att.name) to prodAttributesEntity")
                })
                
                /// Variation
                if let variations = prod.variations {
                    variations.forEach({ prodVar in
                        let productVariesEntity = Product_Variations_Entity(context: self.context)
                        productVariesEntity.product_variation_id = Int64(prodVar.variation_id)
                        productVariesEntity.product_variation_name = prodVar.name
                        productVariesEntity.product_variation_price = prodVar.price
                        
                        /// VariationAttribute
                        prodVar.attribute.forEach({ varAttrib in
                            let variationAttributesEntity = Variation_Attributes_Entity(context: self.context)
                            variationAttributesEntity.variation_attribute_key = varAttrib.attribute_key
                            variationAttributesEntity.variation_attribute_name = varAttrib.name
                            variationAttributesEntity.variation_attribute_option = varAttrib.option
                            
                            variationAttributesEntity.product_variation = productVariesEntity
                            print("successfully saved \(varAttrib.name ?? "no var attrib") to variationAttributesEntity")
                        })
                        
                        productVariesEntity.product = productEntityToUpdate
                        print("successfully saved \(prodVar.name) to productVariesEntity")
                    })
                }
                
//                productEntityToUpdate.category = catEntity
            })
            
            do {
                try self.context.save()
            } catch {
                print("Failed to save context: \(error.localizedDescription)")
            }
        }
        
        
//        for item in products {
//            if let product = productEntity.first(where: { $0.product_id == Int64(item.product_id) }) {
//                product.product_category = Int64(item.category)
//                product.product_price = item.price
//                product.product_guid = item.guid
//                product.product_name = item.name
//                product.product_type = item.type
//                product.product_id = Int64(item.product_id)
//                productToUpdate.append(product)
//
//                let productAttributes = productAttributesEntity.filter({ $0.product == product.objectID })
//                for att in productAttributes {
//                    if let attrib = productAttributes.first(where: { $0.product == product.objectID }) {
//                        att.product = product
//                        att.product_attribute_key = attrib.product_attribute_key
//                        att.product_attribute_name = attrib.product_attribute_name
//                        att.product_attribute_options = attrib.product_attribute_options
//                        productAttributesToUpdate.append(att)
//                    }
//                }
//
//                let productVariations = productVariationsEntity.filter({ $0.product == product.objectID })
//                for vari in productVariations {
//                    if let prodVari = productVariations.first(where: { $0.product == product.objectID }) {
//                        vari.product = product
//                        vari.product_variation_price = prodVari.product_variation_price
//                        vari.product_variation_name = prodVari.product_variation_name
//                        productVariationsToUpdate.append(vari)
//
//                        let varAttribs = variationAttributesEntity.filter( { $0.product_variation == vari.objectID })
//                        for varAtt in varAttribs {
//                            varAtt.product_variation = vari
////                            varAtt.variation_attribute_key = vari.variation_attributes.f
//                        }
//
//                    }
//                }
//            }
//        }
    }
    
    private func deleteProduct(with products: [Product]) {
        
        var productToDelete = [Products_Entity]()
        var productAttributesToDelete = [Product_Attributes_Entity]()
        var productVariationsToDelete = [Product_Variations_Entity]()
        var variationAttributesToDelete = [Variation_Attributes_Entity]()
        
        for item in products {
            if let product = productEntity.first(where: { $0.product_id == Int64(item.product_id) }) {
                productToDelete.append(product)
                
                let productAttributes = productAttributesEntity.filter({ $0.product == product.objectID })
                for att in productAttributes {
                    productAttributesToDelete.append(att)
                }
                
                let productVariations = productVariationsEntity.filter({ $0.product == product.objectID })
                for vari in productVariations {
                    productVariationsToDelete.append(vari)
                    
                    let varAttribs = variationAttributesEntity.filter({ $0.product_variation == vari.objectID })
                    
                    for varAtt in varAttribs {
                        variationAttributesToDelete.append(varAtt)
                    }
                }
            }
        }
        
        deleteToUpdateProduct(
            products: productToDelete,
            attribs: productAttributesToDelete,
            varis: productVariationsToDelete,
            varAttribs: variationAttributesToDelete)
        
//        var productToUpdate = [Products_Entity]()
//        var productAttributesToUpdate = [Product_Attributes_Entity]()
//        var productVariationsToUpdate = [Product_Variations_Entity]()
//        var variationAttributesToUpdate = [Variation_Attributes_Entity]()
    }
    
    public func refetchCatsProducts() {
        getCartEntityItems()
        getCategoryEntity()
        getProductEntity()
        getProductAttribs()
        getProductVariations()
        getVariationsAttribs()
        
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    private func deleteToUpdateProduct(products: [Products_Entity], attribs: [Product_Attributes_Entity], varis: [Product_Variations_Entity], varAttribs: [Variation_Attributes_Entity]) {
        
        do {
            for prod in products {
                context.delete(prod)
                print("success deleting product: \(prod)")
            }
            
            for att in attribs {
                context.delete(att)
                print("success deleting att: \(att)")
            }
            
            for vari in varis {
                context.delete(vari)
                print("success vari att: \(vari)")
            }
            
            for variAtt in varAttribs {
                context.delete(variAtt)
                print("success variAtt att: \(variAtt)")
            }
            
            try context.save() //don't forget
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
            
        } catch let error as NSError {
            print("deleteToUpdateProduct fail--",error)
        }
    }
    
    private func storeAddOns(with addons: [AddOnsData]) {
        
        addOns = addons
        
        context.perform {
            addons.forEach({ addOn in
                let addonsEntity = AddOns_Entity(context: self.context)
                addonsEntity.addOn_finished_product_ids = addOn.finished_product_ids
                addonsEntity.addOn_product_id = Int64(addOn.product_id)
                addonsEntity.addOn_name = addOn.name
                addonsEntity.addOn_type = addOn.type
                addonsEntity.addOn_guid = addOn.guid
                addonsEntity.addOn_price = addOn.price
                addonsEntity.addOn_category = Int64(addOn.category)
                print("successfully saved \(addOn.name) to categoryEntity")
            })
            
            do {
                try self.context.save()
            } catch {
                print("Failed to save context: \(error.localizedDescription)")
            }
        }
    }
    
    private func removeAddOns(with addons: [AddOnsData]) {
        context.perform {
            do {
                let storedAddons = try self.context.fetch(AddOns_Entity.fetchRequest())
                for addon in storedAddons {
                    self.context.delete(addon)
                }
                try self.context.save()
            } catch {
                print("Failed to save context: \(error.localizedDescription)")
            }
        }
    }
    
    
    private func storeToCoreData(with categories: [Category], with products: [Product]) {
        
        self.configureModels(categories: categories, products: products)
        
        context.perform {
            /// categories
            var catEntity: Categories_Entity?
            
            print("storing categories: \(categories)")
            
            categories.forEach({ cat in
                let categoryEntity = Categories_Entity(context: self.context)
                catEntity = categoryEntity
                
                categoryEntity.category_id = Int64(cat.id)
                categoryEntity.category_name = cat.name
                categoryEntity.category_parent_id = Int64(cat.parent_id)
                categoryEntity.category_guid = cat.guid
                print("successfully saved \(cat.name) to categoryEntity")
            })
            
            /// products
            
            print("storing products: \(products)")
            products.forEach({ prod in
                let productEntity = Products_Entity(context: self.context)
//                prodEntity = productEntity
                
                productEntity.product_category = Int64(prod.category)
                productEntity.product_guid = prod.guid
                productEntity.product_id = Int64(prod.product_id)
                productEntity.product_name = prod.name
                productEntity.product_price = prod.price
                productEntity.product_type = prod.type
                
                
                print("successfully saved \(prod.name) to productEntity")
                
                /// ProductAttribute
//                prod.attributes.forEach({att in
//                    let prodAttributesEntity = Product_Attributes_Entity(context: self.context)
//                    prodAttributesEntity.product_attribute_key = att.attribute_key
//                    prodAttributesEntity.product_attribute_name = att.name
//                    prodAttributesEntity.product_attribute_options = att.options
//
//                    prodAttributesEntity.product = productEntity
//
//                    print("successfully saved \(att.name) to prodAttributesEntity")
//                })
                
                _ = prod.attributes.map({ att in
                    let prodAttributesEntity = Product_Attributes_Entity(context: self.context)
                    prodAttributesEntity.product_attribute_key = att.attribute_key
                    prodAttributesEntity.product_attribute_name = att.name
                    prodAttributesEntity.product_attribute_options = att.options
                    
                    prodAttributesEntity.product = productEntity
                    
                    print("successfully saved \(att.name) to prodAttributesEntity")
                })
                
                /// Variation
                if let variations = prod.variations {
                    variations.forEach({ prodVar in
                        let productVariesEntity = Product_Variations_Entity(context: self.context)
                        productVariesEntity.product_variation_id = Int64(prodVar.variation_id)
                        productVariesEntity.product_variation_name = prodVar.name
                        productVariesEntity.product_variation_price = prodVar.price
                        
                        /// VariationAttribute
                        prodVar.attribute.forEach({ varAttrib in
                            let variationAttributesEntity = Variation_Attributes_Entity(context: self.context)
                            variationAttributesEntity.variation_attribute_key = varAttrib.attribute_key
                            variationAttributesEntity.variation_attribute_name = varAttrib.name
                            variationAttributesEntity.variation_attribute_option = varAttrib.option
                            
                            variationAttributesEntity.product_variation = productVariesEntity
                            print("successfully saved \(varAttrib.name ?? "no var attrib") to variationAttributesEntity")
                        })
                        
                        productVariesEntity.product = productEntity
                        print("successfully saved \(prodVar.name) to productVariesEntity")
                    })
                }
                
                productEntity.category = catEntity
            })
            
            do {
                try self.context.save()
            } catch {
                print("Failed to save context: \(error.localizedDescription)")
            }
        }
    }
    
    private func readCartLastOrderEntity() {
        do {
            // let items = try context.fetch(ToDoListItem.fetchRequest())
            let cartLastOrderEntity: [Cart_Last_OrderID_Entity] = try context.fetch(Cart_Last_OrderID_Entity.fetchRequest())
//            cart = cartEntity.filter({ $0.cart_status == "added" })
//            cartSelectedItems = cart.filter({ $0.cart_isChecked == true })
            
            if cartLastOrderEntity.isEmpty {
                shouldInitializeLastOrderID()
            }
            
            
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func createCoreDataToDisplay() {
        
        print("variationAttributesEntity: \(variationAttributesEntity)")
        
        coredataCategories = categoryEntity.map({ cat in
            Category(
                id: Int(cat.category_id),
                name: cat.category_name ?? "-",
                slug: cat.category_name ?? "-",
                parent_id: Int(cat.category_parent_id),
                guid: cat.category_guid ?? "-")
        })
        
        var scoredataProducts = [Product]()
        
        //_ = productEntity.compactMap({ prod in
        productEntity.forEach{ prod in
//            let productAttributes = productAttributesEntity.filter({ $0.product == prod })
            let sproductAttributes = productAttributesEntity.filter({ $0.product == prod })// productAttributes.sorted(by: { $0.id < $1.id })
            
            let prodVaris = productVariationsEntity.filter({ $0.product == prod })
            let sprodVaris = prodVaris.sorted(by: { $0.id < $1.id })
            
            var sVaris = [Variation_Attributes_Entity]()
            
//            print("sproductAttributes: \(prod.product_name) \(sproductAttributes)")
//            print("sprodVaris: \(prod.product_name) \(sprodVaris)")
//            print("sVaris: \(prod.product_name) \(sVaris)")
            
            for vari in sprodVaris {
                sVaris = variationAttributesEntity.filter({ $0.product_variation == vari })
//                if let filteredVari = variationAttributesEntity.first(where: { $0.product_variation == vari }) {
//                    sVaris.append(filteredVari)
//                }
                print("sprodVaris vari: \(prod.product_name!) \(vari)")
            }
            
            let prooo = Product(
                product_id: Int(prod.product_id),
                name: prod.product_name ?? "-",
                type: prod.product_type ?? "-",
                attributes: sproductAttributes.map({ att in
                    ProductAttribute(
                        attribute_key: att.product_attribute_key ?? "-",
                        name: att.product_attribute_name ?? "-",
                        options: att.product_attribute_options?.map({ opt in
                            opt
                        }) ?? ["-"])
                }),
                guid: prod.product_guid ?? "-",
                price: prod.product_price,
                category: Int(prod.product_category),
                variations:
                    sprodVaris.map({ vari in
                        
                        let variAttsArray = vari.variation_attributes?.allObjects as! [Variation_Attributes_Entity]
                        
                        return Variation(
                            variation_id: Int(vari.product_variation_id),
                            name: vari.product_variation_name ?? "-",
                            price: vari.product_variation_price,
                            attribute: variAttsArray.map({ vary in
                                VariationAttribute(
                                    attribute_key: vary.variation_attribute_key ?? "-",
                                    name: vary.variation_attribute_name,
                                    option: vary.variation_attribute_option ?? "-")
                            })
                        )
                    }),
                post_modified: nil,
                tax_class: nil
            )
            scoredataProducts.append(prooo)
        }
        coredataProducts = scoredataProducts
        
//        print("scoredataProducts ", scoredataProducts)
        
//        print("coredataCategories from createCoreDataToDisplay: ", coredataCategories ?? "no cats")
//        print("coreDataProducts createCoreDataToDisplay: ", coredataProducts ?? "no prods")
    }
    
    private func configureModels(categories: [Category], products: [Product]) {
        self.categoryArray = categories
        self.productsArray = products
        self.filteringProductsArray = products
        
        // clear sections first then append
        sections.removeAll()
        
        sections.append(.categorySection(viewModels: categories.compactMap({
            return CategoryCellViewModel(
                name: $0.name,
                artworkUrl: URL(string: $0.guid))
        })))
        
        sections.append(.productSection(viewModels: products.compactMap({
            return CategoryItemsCellViewModel(
                image: URL(string: $0.guid),
                name: $0.name,
                price: $0.price,
                productID: $0.product_id)
        })))
        
        didPullToRefreshData = false
        DispatchQueue.main.async {
            self.collectionView.reloadData()
            self.shouldSelectCategoryAll()
        }
    }
    
    private func shouldSelectCategoryAll() {
        let selectedIndexPath = IndexPath(item: 0, section: 0)
        self.collectionView.selectItem(at: selectedIndexPath, animated: false, scrollPosition: .left)
    }
    
    private func populateFromCoreData() {
        if let coredataCategories = coredataCategories?.sorted(by: { $0.id < $1.id}),
           let coredataProducts = coredataProducts?.sorted(by: { $0.product_id > $1.product_id}) {
            configureModels(categories: coredataCategories, products: coredataProducts)
        }
    }
    
    
    func updateSearchResults(for searchController: UISearchController) {
        
    }
    
    public func showAlertWith(title: String, message: String, style: UIAlertController.Style = .alert, hasFetchedData: Bool) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: style)
        alert.addAction(UIAlertAction(title: hasFetchedData ? "Continue" : "Dismiss", style: .default, handler: { (action) in
            
            self.populateFromCoreData()
            self.getCartEntityItems()
            self.getCouponsEntity()
            self.collectionView.refreshControl?.endRefreshing()
            
            
        }))
        present(alert, animated: true, completion: nil)
    }
    
    private func failedToGetData() {
        if productsArray.isEmpty || categoryArray.isEmpty {
            menuErrorFetchingDataLabel.isHidden = false
            collectionView.isHidden = true
            view.backgroundColor = .systemBackground
            view.addSubview(menuErrorFetchingDataLabel)
            menuErrorFetchingDataLabel.center = view.center
        }
    }
    
    private func fetchSurcharges() {
        APICaller.shared.getSurcharges { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let model):
                self.surchargeData = model
                
                print("fetchSurcharges: \(model.count) ?= \(self.surchargeEntity.count)")
                
                if self.surchargeEntity.count != model.count {
                    self.clearSurcharges()
                    self.cacheSurcharges(data: model)
                }
                
                break
            case .failure(let error):
                
                print("failure APICaller getSurcharges...")
                
                print("saveSurcharges: \(error.localizedDescription)")
                break
            }
        }
    }
    
    private func fetchCoupons() {
        APICaller.shared.getCoupons { [weak self] result in
            switch result {
            case .success(let model):
                self?.couponsData = model
                
                ///test coupons
//                var fetchCoupons = model
//                fetchCoupons.append(CouponData(
//                    id: 2040,
//                    title: "Senior",
//                    code: "senior",
//                    type: "percent",
//                    amount: 20,
//                    amount_per_cent: 0.2))
//                fetchCoupons.append(CouponData(
//                    id: 774,
//                    title: "Pwd",
//                    code: "pwd",
//                    type: "percent",
//                    amount: 20,
//                    amount_per_cent: 0.2))
//                fetchCoupons.append(CouponData(
//                    id: 2041,
//                    title: "TestA",
//                    code: "TestA",
//                    type: "percent",
//                    amount: 50,
//                    amount_per_cent: 0.5))
//                fetchCoupons.append(CouponData(
//                    id: 2041,
//                    title: "VIP Voucher",
//                    code: "vip",
//                    type: "percent",
//                    amount: 50,
//                    amount_per_cent: 0.5))
                
                if let couponsEntity = self?.couponsEntity {
                    if couponsEntity.count != model.count {
                        self?.clearCoupons(items: couponsEntity)
                        self?.cacheCoupons(data: model)
                    }
                }
                break
                
            case .failure(let error):
                print("fetchCoupons error: \(error.localizedDescription)")
                break
            }
        }
    }
    
    
    public func cacheCoupons(data: [CouponData]) {
        data.forEach({
            let coupon = Coupons_Entity(context: context)
            coupon.coupon_id = Int64($0.id)
            coupon.coupon_title = $0.title
            coupon.coupon_code = $0.code
            coupon.coupon_amount = Int64($0.amount)
            coupon.coupon_amount_percent = $0.amount_per_cent
            coupon.coupon_type = $0.type
        })
        
        do {
            try context.save()
            print("successfully saved cacheCoupons to coredata...")
        } catch {
            // error
            print("error saving cacheCoupons: \(error.localizedDescription)")
        }
    }
    
    public func cacheSurcharges(data: [SurchargeData]) {
        data.forEach({
            let surcharge = Surcharges_Entity(context: context)
            surcharge.surcharge_id = Int64($0.id)
            surcharge.surcharge_name = $0.name
            surcharge.surcharge_type = $0.type
            let doubleAmount: Double = Double($0.amount)
            surcharge.surcharge_amount = doubleAmount
            surcharge.surcharge_tax_class = $0.tax_class
        })
        
        do {
            try context.save()
            print("successfully saved surcharges to coredata...")
        } catch {
            // error
            print("error saving surcharges: \(error.localizedDescription)")
        }
    }
    
    public func clearSurcharges() {
        do {
            let storedSurcharges = try context.fetch(Surcharges_Entity.fetchRequest())
            for item in storedSurcharges {
                context.delete(item)
            }
            try context.save()
        } catch let error as NSError {
            print("clear surcharges fail \(error.localizedDescription)")
        }
    }
    
    public func storeCategories(data: [Category]) {
        data.forEach({
            let category = Categories_Entity(context: context)
            category.category_id = Int64($0.id)
            category.category_guid = $0.guid
            category.category_name = $0.name
            category.category_parent_id = Int64($0.parent_id)
        })
        
        do {
            try context.save()
            print("successfully saved categories to coredata...")
        } catch {
            // error
            print("error saving categories: \(error.localizedDescription)")
        }
    }
    
    
    public func clearCategories() {
        do {
            let storedCategories = try context.fetch(Categories_Entity.fetchRequest())
            for item in storedCategories {
                context.delete(item)
            }
            try context.save()
        } catch let error as NSError {
            print("clearCategories fail \(error.localizedDescription)")
        }
    }
    
    public func clearCoupons(items: [Coupons_Entity]) {
        do {
            for coupon in items {
                context.delete(coupon)
            }
            try context.save()
        } catch let error as NSError {
            print("clear clearCoupons fail \(error.localizedDescription)")
        }
    }
    
    private func getSurchargesEntity() {
        do {
            surchargeEntity.removeAll()
            surchargeEntity = try context.fetch(Surcharges_Entity.fetchRequest())
        } catch {
            // error
            print("failed to getSurchargesEntity: ", error.localizedDescription)
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
    
    private func getCartEntityItems() {
        DispatchQueue.main.async {
            if self.collectionView.refreshControl?.isRefreshing == true {
                print("refreshing getCartEntityItems...")
            } else {
                print("fetching getCartEntityItems..")
            }
        }
        
        do {
//            cartEntityModels.removeAll()
//            coreDataArray.removeAll()
            
            cart.removeAll()
            
            let cartEntity: [Cart_Entity] = try context.fetch(Cart_Entity.fetchRequest())
            cart = cartEntity.filter({ $0.cart_status == "added"})
            var cartBadgeCount = 0
            for item in cart {
                cartBadgeCount += Int(item.cart_quantity)
            }
            
            // post notification
            cartBarButton.badgeValue = "\(cartBadgeCount)"
            
            
//            coreDataArray = cartEntityModels
            DispatchQueue.main.async {
                self.collectionView.refreshControl?.endRefreshing()
                self.collectionView.reloadData()
                self.postCartCountNotification(with: self.cart.count)
                self.passCategoryName(with: "All")
            }
        } catch {
            // error
            print("failed to get Cart: ", error.localizedDescription)
        }
    }
    
    private func getCategoryAndProductsEntity() {
        print("getCategoryEntity called")
        
        var storedCategory = [Category]()
        var storedProduct = [Product]()
        
        
        do {
            categoryEntity.removeAll()
            let sCategoryEntity = try context.fetch(Categories_Entity.fetchRequest())
            let sProductEntity = try context.fetch(Products_Entity.fetchRequest())
            let sProductAttributesEntity = try context.fetch(Product_Attributes_Entity.fetchRequest())
            let sProductVariationsEntity = try context.fetch(Product_Variations_Entity.fetchRequest())
            let sVariationAttributesEntity = try context.fetch(Variation_Attributes_Entity.fetchRequest())
            
            for cat in sCategoryEntity {
                storedCategory.append(Category(
                    id: Int(cat.category_id),
                    name: cat.category_name ?? "-",
                    slug: cat.category_name ?? "-",
                    parent_id: Int(cat.category_parent_id),
                    guid: cat.category_guid ?? "-"))
            }
            
            sProductEntity.forEach{ prod in
                let storedProductAttributes = sProductAttributesEntity.filter({ $0.product == prod })
                let storedProdVaris = sProductVariationsEntity.filter({ $0.product == prod })
                
                var instVarisAttrib = [Variation_Attributes_Entity]()
                
                print("storedProductAttributes: \(prod.product_name ?? "-") \(storedProductAttributes)")
                print("storedProdVaris: \(prod.product_name ?? "-") \(storedProdVaris)")
                print("instVarisAttrib: \(prod.product_name ?? "-") \(instVarisAttrib)")
                
                for vari in sVariationAttributesEntity {
                    instVarisAttrib = sVariationAttributesEntity.filter({ $0.product_variation == vari })
                    print("sprodVaris vari: \(prod.product_name ?? "-") \(vari)")
                }
                
                let prooo = Product(
                    product_id: Int(prod.product_id),
                    name: prod.product_name ?? "-",
                    type: prod.product_type ?? "-",
                    attributes: storedProductAttributes.map({ att in
                        ProductAttribute(
                            attribute_key: att.product_attribute_key ?? "-",
                            name: att.product_attribute_name ?? "-",
                            options: att.product_attribute_options?.map({ opt in
                                opt
                            }) ?? ["-"])
                    }),
                    guid: prod.product_guid ?? "-",
                    price: prod.product_price,
                    category: Int(prod.product_category),
                    variations:
                        storedProdVaris.map({ vari in
//                            let variAttsArray = vari.variation_attributes?.allObjects as! [Variation_Attributes_Entity]
                            return Variation(
                                variation_id: Int(vari.product_variation_id),
                                name: vari.product_variation_name ?? "-",
                                price: vari.product_variation_price,
                                attribute: instVarisAttrib.map({ vary in
                                    VariationAttribute(
                                        attribute_key: vary.variation_attribute_key ?? "-",
                                        name: vary.variation_attribute_name,
                                        option: vary.variation_attribute_option ?? "-")
                                })
                            )
                        }),
                    post_modified: nil,
                    tax_class: nil
                )
                storedProduct.append(prooo)
            }
        } catch {
            // error
            print("failed to getCategoryEntity: ", error.localizedDescription)
        }
        
        print("storedCategory: \(storedCategory)")
        print("storedProduct: \(storedProduct)")
    }
    
    private func getAddOnsEntity() {
        print("getAddOnsEntity called")
        
        do {
            addOns.removeAll()
            addOnsEntity.removeAll()
            addOnsEntity = try context.fetch(AddOns_Entity.fetchRequest())
            for item in addOnsEntity {
                addOns.append(AddOnsData(
                    finished_product_ids: item.addOn_finished_product_ids ?? [],
                    product_id: Int(item.addOn_product_id),
                    name: item.addOn_name ?? "",
                    type: item.addOn_type ?? "",
                    guid: item.addOn_guid ?? "",
                    price: item.addOn_price,
                    category: Int(item.addOn_category)))
            }
        } catch {
            print("failed to getAddOnsEntity: ", error.localizedDescription)
        }
    }
    
    private func getCategoryEntity() {
        print("getCategoryEntity called")
        
        do {
            categoryEntity.removeAll()
            let sCategoryEntity = try context.fetch(Categories_Entity.fetchRequest())
            categoryEntity = sCategoryEntity.sorted(by: { $0.category_id < $1.category_id })
        } catch {
            // error
            print("failed to getCategoryEntity: ", error.localizedDescription)
        }
    }
    
    private func getProductEntity() {
        print("getProductEntity called")
        do {
            productEntity.removeAll()
            let sProductEntity = try context.fetch(Products_Entity.fetchRequest())
            productEntity = sProductEntity.sorted(by: { $0.product_id < $1.product_id })
        } catch {
            // error
            print("failed to getProductEntity: ", error.localizedDescription)
        }
    }
    
    private func getProductAttribs() {
        print("getProductAttribs called")
        do {
            productAttributesEntity.removeAll()
            let sProductAttributesEntity = try context.fetch(Product_Attributes_Entity.fetchRequest())
            productAttributesEntity = sProductAttributesEntity.sorted(by: { $0.id < $1.id })
        } catch {
            // error
            print("failed to getProductAttribs: ", error.localizedDescription)
        }
    }
    
    private func getProductVariations() {
        print("getProductVariations called")
        do {
            productVariationsEntity.removeAll()
            let sProductVariationsEntity = try context.fetch(Product_Variations_Entity.fetchRequest())
            productVariationsEntity = sProductVariationsEntity.sorted(by: { $0.id < $1.id })
        } catch {
            // error
            print("failed to getProductVariations: ", error.localizedDescription)
        }
    }
    
    private func getVariationsAttribs() {
        print("getVariationsAttribs called")
        do {
            variationAttributesEntity.removeAll()
            let sVariationAttributesEntity = try context.fetch(Variation_Attributes_Entity.fetchRequest())
            variationAttributesEntity = sVariationAttributesEntity.sorted(by: { $0.id < $1.id })
        } catch {
            // error
            print("failed to getProductAttribs: ", error.localizedDescription)
        }
    }
    
    private func createProductsObjectFromCoreData() {
//        productsObject.append(
//            Products(product_id: T##Int,
//                     name: T##String,
//                     type: T##String,
//                     attributes: T##[ProductAttribute],
//                     guid: T##String,
//                     price: T##Double,
//                     category: T##Int,
//                     variations: T##[Variation]?))
    }
    
    private func passCategoryName(with name: String) {
        MenuViewController.categoryName = name
    }
    
    
    private func addChildControllers() {
        /// adding child controller to MenuVC
        addChild(historyVC)
        addChild(accountVC)
        
        accountVC.accountViewControllerDelegate = self
        addChild(queueVC)
        addChild(notifVC)
        addChild(termsCondition)
        addChild(contactUs)
        addChild(settingsVC)
        
        /// adding each view us a subView
        view.addSubview(historyVC.view)
        view.addSubview(accountVC.view)
        view.addSubview(queueVC.view)
        view.addSubview(notifVC.view)
        view.addSubview(termsCondition.view)
        view.addSubview(contactUs.view)
        view.addSubview(settingsVC.view)
        /// setting frame to be the entirety of the screen
        historyVC.view.frame = view.bounds
        accountVC.view.frame = view.bounds
        queueVC.view.frame = view.bounds
        notifVC.view.frame = view.bounds
        termsCondition.view.frame = view.bounds
        contactUs.view.frame = view.bounds
        settingsVC.view.frame = view.bounds
        /// moved to be a child under the parent itself MenuVC
        historyVC.didMove(toParent: self)
        accountVC.didMove(toParent: self)
        queueVC.didMove(toParent: self)
        notifVC.didMove(toParent: self)
        termsCondition.didMove(toParent: self)
        contactUs.didMove(toParent: self)
        settingsVC.didMove(toParent: self)
        
        // hide
        historyVC.view.isHidden = true
        
        // time in checking
        
        title = isHaveTimeInPinEntered ? "Menu" : "Account"
        accountVC.view.isHidden = isHaveTimeInPinEntered ? true : false // if already have user pin, redirect to menu
        navigationItem.rightBarButtonItems = isHaveTimeInPinEntered ? [cartBarButton] : nil // if already have user pin, redirect to menu, and hide search bar
        
        navigationItem.searchController = nil // isHaveTimeInPinEntered ? menuSearchController : nil
        
        queueVC.view.isHidden = true
        notifVC.view.isHidden = true
        termsCondition.view.isHidden = true
        contactUs.view.isHidden = true
        settingsVC.view.isHidden = true
    }
    
    // MARK: - Configure CollectionView
    private func configureCollectionView() {
        view.addSubview(collectionView)
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        
        collectionView.register(CategoryCollectionViewCell.self, forCellWithReuseIdentifier: CategoryCollectionViewCell.identifier)
        collectionView.register(CategoryItemsCollectionViewCell.self, forCellWithReuseIdentifier: CategoryItemsCollectionViewCell.identifier)
        
        collectionView.register(
            SearchHeaderCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: SearchHeaderCollectionReusableView.identifier)
        
        collectionView.register(
            ProductsCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: ProductsCollectionReusableView.identifier)
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        searchBar.setShowsCancelButton(true, animated: true)
        
        let query = searchText
        
        guard let resultsController = menuSearchController.searchResultsController as? MenuSearchResultsViewController else { return }
        
        resultsController.menuSearchResultsViewControllerDelegate = self
        resultsController.searchQuery = query
        
        let searchResult = filteringProductsArray.filter({ $0.name.lowercased().range(of: query.lowercased()) != nil })
        
        resultsController.update(withResults: searchResult)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        guard let resultsController = menuSearchController.searchResultsController as? MenuSearchResultsViewController,
              let query = searchBar.text, !query.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        
        resultsController.menuSearchResultsViewControllerDelegate = self
        resultsController.searchQuery = query
        
        let searchResult = filteringProductsArray.filter({ $0.name.lowercased().range(of: query.lowercased()) != nil })
        
        resultsController.update(withResults: searchResult)
    }
    
    @objc func didTapSettings() {
        guard let drawer = drawer else {
            return
        }
        present(drawer, animated: true, completion: nil)
    }
    
    @objc func didTapCart() {
        print("Did tap cart")
        let vc = CartViewController()
        vc.cartViewControllerDelegate = self
        vc.cartViewControllerCashierInfoDelegate = self
        
        /// refresh navigation bar to reflect cart badge count update
        _ = navigationController?.view.snapshotView(afterScreenUpdates: true)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func didTapUserImage() {
        print("Did tap User Image")
    }
    
    @objc func didTapDomainCheck() {
        print("didTapDomainCheck")
        
        let alert = UIAlertController(title: "", message: "Enter domain to check.", preferredStyle: .alert)
        
        alert.addTextField { field in
            field.placeholder = "domain"
            field.returnKeyType = .next
            field.keyboardType = .default
        }
        alert.addAction(UIAlertAction(title: "Submit", style: .default, handler: { _ in
            
//            guard let domainField = alert.textFields?.first,
//                  let domain = domainField.text, !domain.isEmpty,
//                  !domain.trimmingCharacters(in: .whitespaces).isEmpty else {
//                print("Invalid entries!")
//                return
//            }
            guard let domainField = alert.textFields?.first,
                  let domain = domainField.text else {
                print("Invalid entries!")
                return
            }
            
            print("domain:",domain)
            
            APICaller.shared.getTokenWithDomain(with: domain) { result in
                switch result {
                case .success: // (let model):
                    break
                case .failure(let error):
                    print("failure getTokenWithDomain: ", error.localizedDescription)
                    break
                }
            }
            
//            self?.settingsVC.createItem(name: name, qty: Int(qty) ?? 0)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    @objc func didTapPlus() {
        print("did Tap Plus")
        let alert = UIAlertController(title: "New item", message: "Enter new item", preferredStyle: .alert)
        
//        alert.addTextField(configurationHandler: nil)
        alert.addTextField { field in
            field.placeholder = "Name"
            field.returnKeyType = .next
            field.keyboardType = .default
        }
        alert.addTextField { field in
            field.placeholder = "Quantity"
            field.returnKeyType = .next
            field.keyboardType = .numberPad
        }
        alert.addAction(UIAlertAction(title: "Submit", style: .default, handler: { [weak self] _ in
            guard let fields = alert.textFields, fields.count == 2  else { return }
            
            let nameField = fields[0]
            let quantityField = fields[1]
            
            guard let name = nameField.text, !name.isEmpty,
                  let qty = quantityField.text, !qty.isEmpty else {
                print("Invalid entries")
                return }
            
            self?.notifVC.createItem(name: name, qty: Int(qty) ?? 0)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
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
            // signout, clear cached credentials
//            UserDefaults.standard.setValue(nil, forKey: Constants.access_token)
            UserDefaults.standard.setValue(nil, forKey: Constants.user_id)
            UserDefaults.standard.setValue(nil, forKey: Constants.user_name)
            UserDefaults.standard.setValue(nil, forKey: Constants.user_email)
            UserDefaults.standard.setValue(nil, forKey: Constants.user_pin)
            UserDefaults.standard.setValue(nil, forKey: Constants.is_user_handle_cash)
            UserDefaults.standard.setValue(nil, forKey: Constants.user_role)
            UserDefaults.standard.setValue(nil, forKey: Constants.user_emp_id)
            
            UserDefaults.standard.setValue(nil, forKey: Constants.pin_code_entered)
            UserDefaults.standard.setValue(nil, forKey: Constants.pin_entered_username)
            
            let navVC = UINavigationController(rootViewController: DomainViewController())
            navVC.navigationBar.prefersLargeTitles = false
            navVC.viewControllers.first?.navigationItem.largeTitleDisplayMode = .never
            navVC.modalPresentationStyle = .fullScreen
            navVC.setNavigationBarHidden(true, animated: true)
            self?.present(navVC, animated: true, completion: {
                self?.navigationController?.popToRootViewController(animated: false)
            })
        }))
        // addActionSheetForiPad(actionSheet: alert)
        present(alert, animated: true, completion: nil)
    }
    
    private func shouldInitializeLastOrderID() {
        CartViewController.shared.initLastOrderID(with: Int64(100000000))
    }
    
    private func fetchUpdatedCategories() {
        
        APICaller.shared.getMenuCategories { result in
            switch result {
            case .success(let model):
                print("CATEGORIES: \(model.data)")
                
                
                var newFetchedCategories = model.data
                let all = Category(
                    id: 0,
                    name: "All",
                    slug: "all",
                    parent_id: 0,
                    guid: "https://jeeves-reboot.codedisruptors.com/wp-content/uploads/2021/12/all_meal-1.png")
                
                newFetchedCategories.insert(all, at: 0)
                print("newFetchedCategories: \(newFetchedCategories.count) ?= \(self.categoryEntity.count)")
                
                if self.categoryEntity.count != newFetchedCategories.count {
                    // clear categories, saved newFetchedCategories
                    self.clearCategories()
                    self.storeCategories(data: newFetchedCategories)
                }
                
                break
            case .failure(let error):
                print("fetchUpdatedCategories error: \(error.localizedDescription)")
                break
            }
        }
    }
    
    /// Fetch Updated products since date
    private func fetchUpdatedProducts() {
//        var updatedProducts: [Product]?
        
        let currentDateString = UserDefaults.standard.string(forKey: Constants.date_since_last_update) ?? Date().sinceDateFormat()
        
        APICaller.shared.getMenuUpdatedProductsSince(with: currentDateString) { [weak self] result in
            switch result {
            case .success(let model):
                print("fetchUpdatedProducts: \(model)")
                
//                updatedProducts = model.data
                self?.deleteProduct(with: model.data)
                self?.updateProduct(with: model.data)
                
                break
            case .failure(let error):
                print("fetchUpdatedProducts: \(error.localizedDescription)")
                
                break
            }
        }
    }
    
    private func filterProductsByCategory(categoryID: Int, categoryName: String, section: Int) {
        
        productsArray = filteringProductsArray.filter({ $0.category == categoryID})
        
        if sections.count == 2 || sections.count > 1  { // only 2 section
            sections.removeLast()
            
            if categoryName.lowercased() == "all" || categoryID == 33 {
                productsArray = filteringProductsArray
                sections.append(.productSection(viewModels: productsArray.compactMap({
                    return CategoryItemsCellViewModel(
                        image: URL(string: $0.guid),
                        name: $0.name,
                        price: $0.price,
                        productID: $0.product_id)
                })))
            } else {
                sections.append(.productSection(viewModels: productsArray.compactMap({
                    return CategoryItemsCellViewModel(
                        image: URL(string: $0.guid),
                        name: $0.name,
                        price: $0.price,
                        productID: $0.product_id)
                })))
            }
        }
        
        collectionView.reloadSections(IndexSet(integer: section))
        print("sections:", sections.count, "filteredProductsArray:", productsArray.count)
    }
    
    // need to change to filter by product id
    private func calculateProductCount(with productID: Int, with cartQty: Int, with productName: String) -> Int {
        var cartQuantity: Int = 0 // refresh to zero
        
        let filteringArray = cart.filter({ $0.cart_product_name == productName })
        
        for item in filteringArray {
            let qty = item.cart_quantity
            
//            print("filteringArray = \(filteringArray.count)")
//            print("qty = \(qty)")
            print("id: \(item.cart_product_id), item: \(item.cart_product_name ?? "-"), orderCount: \(qty)")
            
            cartQuantity += Int(qty)
        }
        
//        print("cartQuantity of: \(productName) = \(cartQuantity)")
        return cartQuantity
    }
    
    public func configCashierBarButton(with name: String?, with image: URL?, with role: String?) {
        
        guard let name = name,
              let image = image,
              let role = role else { return }
        
        print("name: \(name) role: \(role)")
        
        
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
        
        let infoLabel: UILabel = {
            let label = UILabel()
            label.numberOfLines = 0
            label.textColor = Constants.whiteLabelColor
            label.font = .systemFont(ofSize: 10, weight: .regular)
            label.textAlignment = .right
            return label
        }()
        
        let nameLabel: UILabel = {
            let label = UILabel()
            label.numberOfLines = 0
            label.textColor = Constants.whiteLabelColor
            label.font = .systemFont(ofSize: 10, weight: .semibold)
            label.textAlignment = .right
            return label
        }()
        
        let userImage: UIImageView = {
            let imageView = UIImageView(frame: .zero)
            imageView.contentMode = .scaleAspectFill
            imageView.layer.masksToBounds = true
            imageView.clipsToBounds = true
            imageView.tintColor = Constants.whiteLabelColor
            imageView.backgroundColor = Constants.blackBackgroundColor
            return imageView
        }()
        
        infoLabel.frame = CGRect(x: 0, y: 0, width: cashierInfoContainer.width, height: cashierInfoContainer.height/2)
        nameLabel.frame = CGRect(x: 0, y: infoLabel.bottom, width: cashierInfoContainer.width, height: cashierInfoContainer.height/2)
        cashierInfoContainer.addSubview(infoLabel)
        cashierInfoContainer.addSubview(nameLabel)
        
        
        userImage.frame = imageContainer.bounds
        imageContainer.addSubview(userImage)
        
        
        userImage.sd_setImage(with: image, completed: nil)
        nameLabel.text = name
        infoLabel.text = "I'm a \(role)"
        
        imageContainer.isHidden = name == "-"
        cashierInfoContainer.isHidden = name == "-"
        
        cashierNavBarButton = [
            UIBarButtonItem(customView: imageContainer),
            UIBarButtonItem(customView: cashierInfoContainer)
        ]
        
        
    }
    
    public func postCartCountNotification(with count: Int) {
//        let count = cart.count
        NotificationCenter.default.post(name: .cartCount, object: nil, userInfo: ["count" : count])
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
    
    
}

extension MenuViewController: AccountViewControllerDelegate {
    func cashierInfo(data: CashierInfoViewModel) {
        configCashierBarButton(with: data.name ?? nil, with: data.userImageUrl, with: data.userRole ?? nil)
        print("MenuViewController: AccountViewControllerDelegate \(data)")
    }
}

extension MenuViewController: CartViewControllerCashierInfoDelegate {
    func cashierData(data: CashierInfoViewModel) {
        AccountViewController.staffName = data.name ?? ""
        configCashierBarButton(with: data.name, with: data.userImageUrl, with: data.userRole)
        DispatchQueue.main.async {
            self.accountVC.collectionView.reloadData()
        }
        print("MenuViewController: CartViewControllerCashierInfoDelegate; \(data.name)")
    }
}


extension MenuViewController: MenuSearchResultsViewControllerDelegate {
    func didTapResultItem(with result: Product) {
        print("goto-", result.name)
        
        let filteredAddOns = addOns.filter({ $0.finished_product_ids.contains(where: { $0 == result.product_id }) })
        
        let vc = OptionsViewController(product: result, addOns: filteredAddOns)
        vc.navigationItem.largeTitleDisplayMode =  .never
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension MenuViewController: OptionsViewControllerDelegate {
    func shouldReloadDataFromOptionsVC() {
        print("shouldReloadDataFromOptionsVC")
        getCartEntityItems()
    }
}

extension MenuViewController: CartViewControllerDelegate {
    func shouldReloadDataFromCartVC() {
        print("shouldReloadDataFromCartVC")
        getCartEntityItems()
    }
}


// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension MenuViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let type = sections[section]
        switch type {
        case .categorySection(let viewModels):
            return viewModels.count
        case .productSection(let viewModels):
            return viewModels.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let type = sections[indexPath.section]
        
        switch type {
        case .categorySection(let viewModels):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryCollectionViewCell.identifier, for: indexPath) as? CategoryCollectionViewCell else {
                return UICollectionViewCell()
            }
            //for first cell in the collection
//            if allisSelected == true  && didPullToRefreshData == true && indexPath.row == 0 {
//                cell.isSelected = true
//            }
            
            let viewModel = viewModels[indexPath.row]
            cell.configure(withModel: viewModel)
            return cell
            
        case .productSection(let viewModels):
            
            let viewModel = viewModels[indexPath.row]
            
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryItemsCollectionViewCell.identifier, for: indexPath) as? CategoryItemsCollectionViewCell else {
                return UICollectionViewCell()
            }
            
//            let coreDataCount = coreDataArray.count
//            let coreDataModels = coreDataArray[coreDataCount-1]
            
//            let orderCount = cart.filter({ $0.cart_product_id == viewModel.productID }).first?.cart_quantity
            var orderCount: Int? = 0
            let sameOrder = cart.filter({ $0.cart_product_id == viewModel.productID })
            for item in sameOrder {
                orderCount! += Int(item.cart_quantity)
            }
            
            //            if !coreDataArray.isEmpty {
//            if !cart.isEmpty {
//                let coreDataCount = cart.count //coreDataArray.count
//                let coreDataModels = cart[coreDataCount-1] //coreDataArray[coreDataCount-1] /// array starts [0]
//
//                let productId = Int(coreDataModels.cart_product_id) //coreDataModels.value(forKey: "product_id") as? String ?? "NSManagedObject Error"
//                let quantity = Int(coreDataModels.cart_quantity) //coreDataModels.value(forKey: "quantity") as? String ?? "NSManagedObject Error"
////                let intProductID = Int(productId) ?? 0
////                let intQuantity = Int(quantity) ?? 0
//
//                let cartItemCountLabel = calculateProductCount(with: productId, with: quantity, with: viewModel.name)
//
//                if cartItemCountLabel > 0 {
//                    cell.cartItemCountLabel.text = "\(cartItemCountLabel)"
//                } else {
//                    cell.cartItemCountContainerView.isHidden = true
//                }
//            } else {
//                cell.cartItemCountContainerView.isHidden = true
//            }
            
            cell.configure(withModel: viewModel, with: Int(orderCount ?? 0))
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let section = sections[indexPath.section]
        
        switch section {
        case .categorySection:
            
//            if indexPath.row == 0 {
//                allisSelected = true
//            } else {
//                allisSelected = false
//            }
            
            print("allisSelected: ", allisSelected)
            
            let category = categoryArray[indexPath.row]
            
            passCategoryName(with: category.name)
            
//            print("didSelectItemAt sections:", sections.count, "productsArray:", productsArray.count)
            
            // filter and assign to same array
            filterProductsByCategory(categoryID: category.id,categoryName: category.name, section: indexPath.section+1)
            // append to sections
            
            print(category.id)
            print(category.name)
            break
        case .productSection:
            
            let product = productsArray[indexPath.row]
            
            print("Addons: \(addOns.count)")
            
            let filteredAddOns = addOns.filter({ $0.finished_product_ids.contains(where: { $0 == product.product_id }) })
            let sortedAddons = filteredAddOns.sorted(by: { $0.product_id > $1.product_id })
            print("filteredAddOns: \(filteredAddOns.count)")
            
            print("productSection product: \(product)")
            let vc = OptionsViewController(product: product, addOns: filteredAddOns)
            vc.title = "Options"// items.product_name
            vc.navigationItem.largeTitleDisplayMode = .never
            vc.optionsViewControllerDelegate = self
            navigationController?.pushViewController(vc, animated: true)
            break
        }
    }
    
    // MARK: - CollectionView Layout
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let section = sections[indexPath.section]
        
        switch section {
        case .categorySection:
            guard let header = collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: SearchHeaderCollectionReusableView.identifier,
                    for: indexPath) as? SearchHeaderCollectionReusableView, kind == UICollectionView.elementKindSectionHeader else {
                return UICollectionReusableView()
            }
            let section = indexPath.section
            let modelTitle = sections[section].title
            
            header.configure(with: modelTitle)
            return header
            
        case .productSection(let model):
            guard let header = collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: ProductsCollectionReusableView.identifier,
                    for: indexPath) as? ProductsCollectionReusableView, kind == UICollectionView.elementKindSectionHeader else {
                return UICollectionReusableView()
            }
            let section = indexPath.section
            let sectionModel = sections[section]
            
            header.configure(sectionTitle: sectionModel.title, categoryName: MenuViewController.categoryName ?? "All", resultCount: model.count)
            return header
        }
    }
    
    static func createSectionLayout(section: Int) -> NSCollectionLayoutSection {
        let supplementaryViews = [
            
            NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .absolute(50)
                ),
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top
            )
        ]
        
        switch section {
        case 0:
            // item
            let item = NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .fractionalHeight(1.0)))
            
            item.contentInsets = NSDirectionalEdgeInsets(
                top: 0,
                leading: 5,
                bottom: 0,
                trailing: 5)
            
            // horizontal group inside horizontal group
            let verticalGroup = NSCollectionLayoutGroup.vertical(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .absolute(105),
                    heightDimension: .absolute(100)),
                subitem: item,
                count: 1)
            
            // group
            // vertical group inside horizontal group
            let horizontalGroup = NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .absolute(105),
                    heightDimension: .absolute(100)),
                subitem: verticalGroup,
                count: 1)
            
            // section
            let section = NSCollectionLayoutSection(group: horizontalGroup)
            section.orthogonalScrollingBehavior = .continuous
            section.contentInsets = NSDirectionalEdgeInsets(
                top: 10,
                leading: 10,
                bottom: 10,
                trailing: 10)
            // section header
            section.boundarySupplementaryItems = supplementaryViews
            
            return section
            
        case 1:
            // item
            let item = NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .fractionalHeight(1.0)))
            
            item.contentInsets = NSDirectionalEdgeInsets(
                top: 5,
                leading: 5,
                bottom: 5,
                trailing: 5)
            
            // horizontal group inside horizontal group
//            let verticalGroup = NSCollectionLayoutGroup.vertical(
//                layoutSize: NSCollectionLayoutSize(
//                    widthDimension: .fractionalWidth(1.0),
//                    heightDimension: .absolute(500)),
//                subitem: item,
//                count: 3)
            
            // group
            // vertical group inside horizontal group
            let horizontalGroup = NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .absolute(170)),
                subitem: item,
                count: 3)
            
            // section
            let section = NSCollectionLayoutSection(group: horizontalGroup)
            section.contentInsets = NSDirectionalEdgeInsets(
                top: 0,
                leading: 10,
                bottom: 0,
                trailing: 10)
            // section header
            section.boundarySupplementaryItems = supplementaryViews
            return section
            
        default:
            // item
            let item = NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .fractionalHeight(1.0)))
            
            item.contentInsets = NSDirectionalEdgeInsets(
                top: 5,
                leading: 5,
                bottom: 5,
                trailing: 5)
            
            // horizontal group inside horizontal group
//            let verticalGroup = NSCollectionLayoutGroup.vertical(
//                layoutSize: NSCollectionLayoutSize(
//                    widthDimension: .fractionalWidth(1.0),
//                    heightDimension: .absolute(500)),
//                subitem: item,
//                count: 3)
            
            // group
            // vertical group inside horizontal group
            let horizontalGroup = NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .absolute(170)),
                subitem: item,
                count: 3)
            
            // section
            let section = NSCollectionLayoutSection(group: horizontalGroup)
            section.contentInsets = NSDirectionalEdgeInsets(
                top: 0,
                leading: 10,
                bottom: 0,
                trailing: 10)
            // section header
            section.boundarySupplementaryItems = supplementaryViews
            return section
        }
    }
}

extension MenuViewController {
    func didSelectDrawerItem(at index: Int, menuItem: DrawerItems) {
        drawer?.dismiss(animated: true, completion: nil)    // [weak self] in
        // print(menuItem)
        title = menuItem.rawValue
        
        /// switch view controllers
        switch menuItem {
        case .menu:
            navigationItem.searchController = menuSearchController
            navigationItem.rightBarButtonItems = [cartBarButton]
            historyVC.view.isHidden = true
            accountVC.view.isHidden = true
            queueVC.view.isHidden = true
            notifVC.view.isHidden = true
            termsCondition.view.isHidden = true
            contactUs.view.isHidden = true
            settingsVC.view.isHidden = true
            break
        case .history:
            let historySearchCtrl = historyVC.historySearchController
            navigationItem.searchController = historySearchCtrl
            navigationItem.rightBarButtonItems = [cartBarButton]
            historyVC.view.isHidden = false
            accountVC.view.isHidden = true
            queueVC.view.isHidden = true
            notifVC.view.isHidden = true
            termsCondition.view.isHidden = true
            contactUs.view.isHidden = true
            settingsVC.view.isHidden = true
            break
            
        case .account:
            navigationItem.searchController = nil
            navigationItem.rightBarButtonItems = [cartBarButton] // cashierNavBarButton //[cartBarButton] // cashierInfoBarButtonItems
            historyVC.view.isHidden = true
            accountVC.view.isHidden = false
            queueVC.view.isHidden = true
            notifVC.view.isHidden = true
            termsCondition.view.isHidden = true
            contactUs.view.isHidden = true
            settingsVC.view.isHidden = true
            
            /// call to refetchdata
            accountVC.fetchData()
            accountVC.fetchUnclosedAttendance()
            accountVC.bottomContainer.isHidden = true
            
            
            break
        case .queue:
            navigationItem.searchController = nil
            navigationItem.rightBarButtonItems = [cartBarButton]
            historyVC.view.isHidden = true
            accountVC.view.isHidden = true
            queueVC.view.isHidden = false
            notifVC.view.isHidden = true
            termsCondition.view.isHidden = true
            contactUs.view.isHidden = true
            settingsVC.view.isHidden = true
            
            // fetch queue
//            queueVC.fetchQueue()
            
            break
//        case .notification:
//            navigationItem.searchController = nil
//            navigationItem.rightBarButtonItems = nil //[checkDomainBarButton]
//            historyVC.view.isHidden = true
//            accountVC.view.isHidden = true
//            queueVC.view.isHidden = true
//            notifVC.view.isHidden = false
//            termsCondition.view.isHidden = true
//            contactUs.view.isHidden = true
//            settingsVC.view.isHidden = true
//            break
        case .termsCondition:
            navigationItem.searchController = nil
            navigationItem.rightBarButtonItems = nil
            historyVC.view.isHidden = true
            accountVC.view.isHidden = true
            queueVC.view.isHidden = true
            notifVC.view.isHidden = true
            termsCondition.view.isHidden = false
            contactUs.view.isHidden = true
            settingsVC.view.isHidden = true
            break
        case .contactUs:
            navigationItem.searchController = nil
            navigationItem.rightBarButtonItems = [cartBarButton] // userInfoBarButton
            historyVC.view.isHidden = true
            accountVC.view.isHidden = true
            queueVC.view.isHidden = true
            notifVC.view.isHidden = true
            termsCondition.view.isHidden = true
            contactUs.view.isHidden = false
            settingsVC.view.isHidden = true
            break
        case .settings:
            navigationItem.searchController = nil
            navigationItem.rightBarButtonItems = [cartBarButton] // userInfoBarButton
            historyVC.view.isHidden = true
            accountVC.view.isHidden = true
            queueVC.view.isHidden = true
            notifVC.view.isHidden = true
            termsCondition.view.isHidden = true
            contactUs.view.isHidden = true
            settingsVC.view.isHidden = false
            break
//        case .logout:
//            navigationItem.searchController = nil
//            navigationItem.rightBarButtonItem = nil
//            historyVC.view.isHidden = true
//            accountVC.view.isHidden = true
//            queueVC.view.isHidden = true
//            notifVC.view.isHidden = true
//            settingsVC.view.isHidden = true
//            logOutTapped()
        }
    }
}













// MARK:- Working Menu


//enum MenuSectionType {
//    case categorySection(viewModels: [CategoryCellViewModel])        // 0
//    case productSection(viewModels: [CategoryItemsCellViewModel])          // 1
//
//    var title: String {
//        switch self {
//        case .categorySection:
//            return "Choose a Category"
//        case .productSection:
//            if MenuViewController.categoryName == nil {
//                return "All Menu"
//            } else {
//                let name = MenuViewController.categoryName!
//                return "\(name) Menu"
//            }
//        }
//    }
//}
//
