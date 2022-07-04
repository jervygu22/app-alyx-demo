//
//  CartWorkingViewController.swift
//  Jeeves-dev
//
//  Created by Jervy Umandap on 2/4/22.
//

import UIKit
import SwipeCellKit
import SDWebImage


class CartWorkingViewController: UIViewController {
    private var orders: [Order] = []
    private var transactionTypes: [TransactionType] = []

    private var sections = [CartSection]()

    private var collectionView: UICollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewCompositionalLayout { (sectionIndex, _) -> NSCollectionLayoutSection? in
            return CartWorkingViewController.createSectionLayout(section: sectionIndex)
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

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Cart"
        view.backgroundColor = Constants.whiteBackgroundColor
        configureNavItem()

        configureCollectionView()

        view.addSubview(spinner)
        view.addSubview(bottomContainer)
        fetchData()
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
    }

    private func configureModels(transactionTypes: [TransactionType], orders: [Order]) {
        self.transactionTypes = transactionTypes
        self.orders = orders

        sections.append(.transactionType(viewModels: transactionTypes.compactMap({
            return TransactionTypeCellViewModel(
                id: $0.id,
                name: $0.transaction_name,
                percent: $0.percent,
                key: $0.key,
                tax_class: $0.tax_class)
        })))

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

    private func fetchData() {
        let dispatchGroup = DispatchGroup()

        dispatchGroup.enter()

        //        var orders: Order?
        //        var transactionTypes: TransactionType?
        var cartData: CartData?

        APICaller.shared.getCartData { result in
            // defer, whenever this ApiCall is completed, decrement the number of dispatchGroup entries
            defer {
                dispatchGroup.leave()
            }
            switch result {
            case .success(let model):
                //                orders = model.cart.orders
                //                transactionTypes = model.transaction_type
                cartData = model
            case .failure(let error):
                print(error.localizedDescription)
            }
        }

        dispatchGroup.notify(queue: .main) {
            guard let orders = cartData?.cart.orders,
                  let transactionTypes = cartData?.transaction_type
            else {
                return
            }

            self.configureModels(transactionTypes: transactionTypes, orders: orders)
        }
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

    private func configureNavItem() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "person.fill"),
            style: .done,
            target: self,
            action: #selector(didTapImage))
    }


    @objc func didTapImage() {
        print("Did tap image")
    }

}


extension CartWorkingViewController: UICollectionViewDelegate, UICollectionViewDataSource, SwipeCollectionViewCellDelegate {
    func deleteData(at indexPath: IndexPath) {
        print("deleting... ", orders[indexPath.row].product_name)
    }
    
    func collectionView(_ collectionView: UICollectionView, editActionsForItemAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        
        guard orientation == .right else { return nil }

        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            // handle action by updating model with deletion
        }

        // customize the action appearance
        deleteAction.image = UIImage(systemName: "trash")

        return [deleteAction]
    }
    
    func collectionView(_ collectionView: UICollectionView, editActionsOptionsForItemAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .destructive
//        options.transitionStyle = .border
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
        case .orders(let viewModels):
            return viewModels.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let type = sections[indexPath.section]
        
        switch type {
        case .transactionType(viewModels: let viewModels):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TransactionTypeCollectionViewCell.identifier, for: indexPath) as? TransactionTypeCollectionViewCell else {
                return UICollectionViewCell()
            }
            
            let models = viewModels[indexPath.row]
            cell.configure(with: TransactionTypeCollectionViewCellViewModel(
                            id: models.id,
                            name: models.name,
                            percent: models.percent))
            return cell
            
        case .orders(viewModels: let viewModels):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CartItemsCollectionViewCell.identifier, for: indexPath) as? CartItemsCollectionViewCell else {
                return UICollectionViewCell()
            }
            
            
            let models = viewModels[indexPath.row]
            cell.configure(with: CartItemsCollectionViewCellViewModel(
                            id: models.id,
                            name: models.name,
                            quantity: models.quantity,
                            subTotal: models.subTotal,
                            originalPrice: models.originalPrice,
                            image: models.image,
                            isChecked: models.isChecked,
                            discountKey: "",
                            index: indexPath.row,
                            addOns: nil, isCheckBoxHidden: false))
            
            cell.delegate = self
            return cell
        }
    }
    
    

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let section = sections[indexPath.section]
        switch section {
        case .transactionType(let viewModels):
            print(viewModels[indexPath.row].name)
        case .orders(let viewModels):
            let model = viewModels[indexPath.row]
            
            let vc = CartItemUpdateOptionViewController(
                product: FakeProductItems(
                    id: model.id,
                    product_name: model.name,
                    product_img: model.image,
                    order_qty: model.quantity,
                    cart_qty: model.quantity,
                    product_price: model.subTotal))
            
            vc.title = "Update - \(model.name)"
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
//    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
//        let cell = collectionView.cellForItem(at: indexPath) as! TransactionTypeCollectionViewCell
//
//        cell.contentView.backgroundColor = Constants.darkGrayColor
//        cell.transactionLabel.textColor = .white
//
//    }

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
            let section = indexPath.section
            let modelTitle = sections[section].title
            
            header.configure(with: modelTitle)
            return header
        }

    }


}

// MARK:- CreateSectionLayout Cart and Payment methods
extension CartWorkingViewController {
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
















//class CartViewController: UIViewController {
//
//    private var orders: [Order] = []
//    private var transactionTypes: [TransactionType] = []
//
//    private var sections = [CartSection]()
//
//    private let userImageView: UIImageView = {
//        let imageView = UIImageView()
//        imageView.image = UIImage(named: "jeeves_logo")
//        imageView.contentMode = .scaleAspectFit
//        imageView.layer.masksToBounds = true
//        imageView.layer.cornerRadius = 5
//        return imageView
//    }()
//
//    private let tableView: UITableView = {
//        let tableView = UITableView(frame: .zero, style: .grouped)
//
//        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
//        tableView.register(CartTableViewCell.self, forCellReuseIdentifier: CartTableViewCell.identifier)
//
//        tableView.isHidden = false
//        tableView.separatorStyle = .none
//        tableView.backgroundColor = Constants.whiteBackgroundColor
////        tableView.allowsMultipleSelection = true
//        return tableView
//    }()
//
//    private let bottomContainer: CartBottomView = {
//        let container = CartBottomView()
//        container.layer.masksToBounds = true
//        container.clipsToBounds = true
//        return container
//    }()
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        title = "Cart"
//        view.backgroundColor = Constants.whiteBackgroundColor
//        configureNavItem()
//
//        tableView.delegate = self
//        tableView.dataSource = self
//
//        view.addSubview(tableView)
//        view.addSubview(bottomContainer)
//        fetchData()
//
//    }
//
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//
//        let bottomContainerHeight: CGFloat = 280.0
////        let labelWidth: CGFloat = (bottomContainer.width-30)/2
////        let labelHeight: CGFloat = (bottomContainer.height-20)/8
//
//        tableView.frame = CGRect(
//            x: 0,
//            y: 0,
//            width: view.width,
//            height: view.height-bottomContainerHeight)
//
//        bottomContainer.frame = CGRect(
//            x: 10,
//            y: tableView.bottom,
//            width: view.width-20,
//            height: bottomContainerHeight-view.safeAreaInsets.bottom)
//        bottomContainer.addTopBorder(with: Constants.lightGrayBorderColor, andWidth: 0.5)
////        bottomContainer.backgroundColor = .systemGreen
//
//    }
//
//    private func configureModels(transactionTypes: [TransactionType], orders: [Order]) {
//        self.transactionTypes = transactionTypes
//        self.orders = orders
//
//        sections.append(.transactionType(viewModels: transactionTypes.compactMap({
//            return TransactionTypeCellViewModel(
//                id: $0.id,
//                name: $0.transaction_name,
//                percent: $0.percent)
//        })))
//
//        sections.append(.orders(viewModels: orders.compactMap({
//            return OrderCellViewModel(
//                id: $0.order_id,
//                name: $0.product_name,
//                quantity: $0.qty,
//                subTotal: $0.sub_total,
//                originalPrice: 270.75,
//                image: $0.image)
//        })))
//
//        tableView.reloadData()
//
//    }
//
//    private func fetchData() {
//        let dispatchGroup = DispatchGroup()
//
//        dispatchGroup.enter()
//
////        var orders: Order?
////        var transactionTypes: TransactionType?
//        var cartData: CartData?
//
//        APICaller.shared.getCartData { result in
//            // defer, whenever this ApiCall is completed, decrement the number of dispatchGroup entries
//            defer {
//                dispatchGroup.leave()
//            }
//            switch result {
//            case .success(let model):
////                orders = model.cart.orders
////                transactionTypes = model.transaction_type
//                cartData = model
//            case .failure(let error):
//                print(error.localizedDescription)
//            }
//        }
//
//        dispatchGroup.notify(queue: .main) {
//            guard let orders = cartData?.cart.orders,
//                  let transactionTypes = cartData?.transaction_type
//            else {
//                return
//            }
//
//            self.configureModels(transactionTypes: transactionTypes, orders: orders)
//        }
//    }
//
//    private func configureNavItem() {
//        navigationItem.rightBarButtonItem = UIBarButtonItem(
//            image: UIImage(systemName: "person.fill"),
//            style: .done,
//            target: self,
//            action: #selector(didTapImage))
//
////        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "I'm a Cashier", style: .done, target: self, action: #selector(didTapUser))
//
//    }
//
//    @objc func didTapImage() {
//        print("Did tap image")
//    }
//
//}
//
//extension CartViewController: UITableViewDelegate, UITableViewDataSource {
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return sections.count
//    }
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        let type = sections[section]
//        switch type {
//        case .transactionType(let viewModels):
//            return viewModels.count
//        case .orders(let viewModels):
//            return viewModels.count
//        }
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let type = sections[indexPath.section]
//
//        switch type {
//        case .transactionType(viewModels: let viewModels):
//            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
//
//            let viewModel = viewModels[indexPath.row]
//            cell.textLabel?.text = viewModel.name
//            cell.textLabel?.textColor = .black
//            return cell
//        case .orders(viewModels: let viewModels):
//            guard let cell = tableView.dequeueReusableCell(withIdentifier: CartTableViewCell.identifier, for: indexPath) as? CartTableViewCell else {
//                return UITableViewCell()
//            }
//
//            let viewModel = viewModels[indexPath.row]
//
//            cell.configure(with: OrderCellViewModel(
//                            id: viewModel.id,
//                            name: viewModel.name,
//                            quantity: viewModel.quantity,
//                            subTotal: viewModel.subTotal,
//                            originalPrice: 270.75,
//                            image: viewModel.image))
//
//            return cell
//        }
//    }
//
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
////        tableView.deselectRow(at: indexPath, animated: true)
//
//        let section = sections[indexPath.section]
//
//        switch section {
//        case .transactionType(let viewModels):
//            print(viewModels[indexPath.row].name)
//        case .orders(let viewModels):
//            print(viewModels[indexPath.row].name)
//        }
//    }
//
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 80.0
//    }
//
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        let models = sections[section]
//        return models.title
//    }
//
//    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
//        let type = sections[indexPath.section]
//
//        switch type {
//        case .transactionType:
//
//            if let selectedIndexPaths = tableView.indexPathsForSelectedRows {
//                for selectedIndexPath in selectedIndexPaths {
//                    if selectedIndexPath.section == indexPath.section {
//                        tableView.deselectRow(at: selectedIndexPath, animated: true)
//                    }
//                }
//            }
//            return indexPath
//        case .orders:
//            return nil
//        }
//    }
//
//    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
//
//        let type = sections[indexPath.section]
//        var swipeActions = UISwipeActionsConfiguration()
//
//        switch type {
//        case .transactionType:
//            break
//        case .orders:
//            let deleteAction = UIContextualAction(style: .destructive, title: "Delete") {  (contextualAction, view, boolValue) in
//                self.deleteData(at: indexPath)
//            }
//            deleteAction.image = UIImage(systemName: "trash.fill")
//
//            swipeActions = UISwipeActionsConfiguration(actions: [deleteAction])
//        }
//
//        return swipeActions
//    }
//
//    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
//        return true
//    }
//
//    func deleteData(at indexPath: IndexPath) {
//        print("deleting... ", orders[indexPath.row].product_name)
//    }
//
//
//
//    static func createBottomContainerCollectionLayout(section: Int) -> NSCollectionLayoutSection {
//
//        // item
//        let item = NSCollectionLayoutItem(
//            layoutSize: NSCollectionLayoutSize(
//                widthDimension: .fractionalWidth(1.0),
//                heightDimension: .fractionalHeight(1.0)))
//
//        item.contentInsets = NSDirectionalEdgeInsets(
//            top: 10,
//            leading: 10,
//            bottom: 10,
//            trailing: 10)
//
//        // horizontal group inside horizontal group
//        let group = NSCollectionLayoutGroup.horizontal(
//            layoutSize: NSCollectionLayoutSize(
//                widthDimension: .absolute(130.0),
//                heightDimension: .fractionalHeight(1.0)),
//            subitem: item,
//            count: 1)
//
//        // section
//        let section = NSCollectionLayoutSection(group: group)
//        section.orthogonalScrollingBehavior = .paging
//
//        return section
//
//    }
//
//}
//
//
//
//// MARK:- SwipeTableViewCellDelegate
//extension CartViewController: SwipeTableViewCellDelegate {
//
//    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
//        guard orientation == .right else { return nil }
//
//        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
//            // handle action by updating model with deletion
//            tableView.reloadData()
//        }
//
//        // customize the action appearance
//        deleteAction.image = UIImage(named: "trash.fill")
//
//        return [deleteAction]
//    }
//
//    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
//        var options = SwipeOptions()
//        options.expansionStyle = .destructive
////        options.transitionStyle = .border
//        return options
//    }
//
//}
//
//enum CartSection {
//    case transactionType(viewModels: [TransactionTypeCellViewModel])
//    case orders(viewModels: [OrderCellViewModel])
//
//    var title: String {
//        switch self {
//        case .transactionType:
//            return "Transcation Type"
//        case .orders:
//            return "Bills"
//        }
//    }
//}
