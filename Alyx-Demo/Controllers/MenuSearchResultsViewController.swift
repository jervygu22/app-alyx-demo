//
//  MenuSearchResultsViewController.swift
//  Jeeves-dev
//
//  Created by Jervy Umandap on 2/4/22.
//

import UIKit
import CoreData

protocol MenuSearchResultsViewControllerDelegate: AnyObject {
    func didTapResultItem(with item: Product)
}

class MenuSearchResultsViewController: UIViewController {
    
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    private var cartEntityModels = [Cart_Entity]()
    
    private var coreDataArray: [NSManagedObject] = []
    public var searchQuery: String?
    
    weak var menuSearchResultsViewControllerDelegate: MenuSearchResultsViewControllerDelegate?
    
    private var productsArray: [Product] = []
    private var addOns: [AddOnsData] = []
    private var cart: [Cart_Entity] = []
    
    private var collectionView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewCompositionalLayout { (sectionIndex, _) -> NSCollectionLayoutSection? in
        return MenuSearchResultsViewController.createSectionLayout(section: sectionIndex)
    })
    
    private let noResultsLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = Constants.lightGrayColor
        label.font = .systemFont(ofSize: 16, weight: .light)
        label.text = "No matches found."
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isHidden = false
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getCartEntityItems()
        print("viewWillAppear getCartEntityItems called")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Constants.vcBackgroundColor
        // Do any additional setup after loading the view.
        
        fetchData()
//        fetchAddons()
        getCartEntityItems()
        
        view.addSubview(collectionView)
        configureCollectionView()
        collectionView.delegate = self
        collectionView.dataSource = self
        
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
        collectionView.backgroundColor = Constants.vcBackgroundColor
        layoutDemoLabel()
    }
    
    public func defaultEmptyView(with message: String) {
        noResultsLabel.sizeToFit()
        noResultsLabel.text = message
        noResultsLabel.isHidden = false
        noResultsLabel.center = view.center
        view.addSubview(noResultsLabel)
    }
    
    private func configureCollectionView() {
        view.addSubview(collectionView)
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        
        collectionView.register(CategoryItemsCollectionViewCell.self, forCellWithReuseIdentifier: CategoryItemsCollectionViewCell.identifier)
        
        collectionView.register(
            ProductsCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: ProductsCollectionReusableView.identifier)
        
        collectionView.isHidden = true
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
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
    
    private func fetchData() {
        APICaller.shared.getMenuProducts(completion: { [weak self] result in
            switch result{
            case .success(let model):
                self?.productsArray = model.data
                DispatchQueue.main.async {
                    self?.collectionView.reloadData()
                }
            case .failure(let error):
                print("getJeevesProducts: ", error.localizedDescription)
            }
        })
    }
    
    private func fetchAddons() {
        APICaller.shared.getAddOns { [weak self] (result) in
            switch result {
            case .success(let model):
                self?.addOns = model
            case .failure(let error):
                print("fetchAddons error: \(error.localizedDescription)")
            }
        }
    }
    
    func update(withResults results: [Product]) {
        productsArray.removeAll()
//        productsArray.append(contentsOf: results)
        productsArray = results
        
        if !results.isEmpty {
            noResultsLabel.isHidden = true
            collectionView.isHidden = false
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        } else {
            collectionView.isHidden = true
            defaultEmptyView(with: "No matches found.")
        }
    }
    
    // need to change to filter by product id
    private func calculateProductCount(with productID: Int, with cartQty: Int, with productName: String) -> Int {
        var cartQuantity: Int = 0 // refresh to zero
        
        let filteringArray = coreDataArray.filter({ $0.value(forKey: "product_name") as! String == productName })
        
        for res in filteringArray {
            let qty = res.value(forKey: "quantity") as? String ?? "NSObject Error"
            guard let intQty = Int(qty) else { return 0 }
            cartQuantity += intQty
            
            let name = res.value(forKey: "product_name") as? String ?? "NSObject Error"
            print("name: ", name)
        }
        print("cartQuantity: ", cartQuantity)
        return cartQuantity
    }
    
    
    private func getCartEntityItems() {
        do {
            cartEntityModels = try context.fetch(Cart_Entity.fetchRequest())
            cart = cartEntityModels.filter({ $0.cart_status == "added"})
            coreDataArray = cartEntityModels
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        } catch {
            // error
            print("failed to get CartEntities: ", error.localizedDescription)
        }
    }

}

extension MenuSearchResultsViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return productsArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let viewModel = productsArray[indexPath.row]
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryItemsCollectionViewCell.identifier, for: indexPath) as? CategoryItemsCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        var orderCount: Int? = 0
        let sameOrder = cart.filter({ $0.cart_product_id == viewModel.product_id })
        for item in sameOrder {
            orderCount! += Int(item.cart_quantity)
        }
        
        cell.cartItemCountContainerView.isHidden = true
        cell.configure(withModel: CategoryItemsCellViewModel(
                        image: URL(string: viewModel.guid),
                        name: viewModel.name,
                        price: viewModel.price,
                        productID: viewModel.product_id), with: orderCount ?? 0)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let product = productsArray[indexPath.row]
        
        let productEncoded = try! JSONEncoder().encode(product)
        let jsonData = try! JSONSerialization.jsonObject(with: productEncoded, options: .allowFragments)
        
        print("didSelectItemAt JSONproduct: \(jsonData)")
        
        
        
        print(productsArray.count)
        
        print("searchQuery:", searchQuery ?? "no passed data")
        print("coreDataArray count ",coreDataArray.count)
        
        menuSearchResultsViewControllerDelegate?.didTapResultItem(with: product)
        
        
        print("addOns: \(addOns.count)")
        let filteredAddOns = addOns.filter({ $0.finished_product_ids.contains(where: { $0 == product.product_id }) })
        print("filteredAddOns: \(filteredAddOns.count)")
        
        let vc = OptionsViewController(product: product, addOns: filteredAddOns)
        vc.title = "Options"// items.product_name
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
    // MARK: - CollectionView Layout
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
//        let product = productsArray[indexPath.row]
        
        guard let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: ProductsCollectionReusableView.identifier,
            for: indexPath) as? ProductsCollectionReusableView, kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }
        
        header.configure(sectionTitle: "Matches found", categoryName: "Search Results", resultCount: productsArray.count)
        return header
    }
}

extension MenuSearchResultsViewController {
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
        
        // group
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
