//
//  CartItemUpdateOptionViewController.swift
//  Jeeves-dev
//
//  Created by Jervy Umandap on 2/4/22.
//

import UIKit
import GMStepper


enum CartOptionsSectionType {
    case headerSection(viewModels: FakeProductItems)            // 0
    case variationSection(viewModels: [CartProductOptionSection])   // 1
}

class CartItemUpdateOptionViewController: UIViewController {
    private let product: FakeProductItems
    private var productOptionSection = [CartProductOptionSection]()
    private var sections = [CartOptionsSectionType]()
    
    init(product: FakeProductItems) {
        self.product = product
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var collectionView: UICollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewCompositionalLayout { (sectionIndex, _) -> NSCollectionLayoutSection? in
            return CartItemUpdateOptionViewController.createSectionLayout(section: sectionIndex)
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
        stepper.minimumValue = 1
        return stepper
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .medium)
        label.textColor = Constants.blackLabelColor
        label.numberOfLines = 0
        label.textAlignment = .right
        label.text = "₱135.00"
        return label
    }()
    
    private let updateButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = Constants.blackBackgroundColor
        button.setTitle("Update", for: .normal)
        button.setTitleColor(Constants.whiteLabelColor, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 16)
        button.layer.cornerRadius = 5.0
        button.layer.masksToBounds = true
        button.backgroundColor = Constants.drawerTableBackgroundColor
        return button
    }()
    
    private let spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView()
        spinner.tintColor = Constants.drawerLabelColor
        spinner.hidesWhenStopped = true
        return spinner
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
//        title = "Update Options"
        view.backgroundColor = Constants.whiteBackgroundColor
        
        view.addSubview(topContainer)
        view.addSubview(collectionView)
        view.addSubview(bottomContainer)
        
        configureCollectionView()
        configureProductOptionModel()
        
        topContainer.addSubview(productImage)
        topContainer.addSubview(productLabel)
        
        bottomContainer.addSubview(updateButton)
        bottomContainer.addSubview(qtyStepper)
        bottomContainer.addSubview(priceLabel)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        updateButton.addTarget(self, action: #selector(didTapUpdate), for: .touchUpInside)
        
//        print(product)
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
        collectionView.backgroundColor = .clear
        updateUI(with: product)
        
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
        
        updateButton.frame = CGRect(
            x: 20,
            y: qtyStepper.bottom+15,
            width: bottomContainer.width-40,
            height: (bottomContainer.height/2)-20)
        
        configureModels()
    }
    
    private func updateUI(with model: FakeProductItems) {
        qtyStepper.value = Double(product.cart_qty)
        qtyStepper.maximumValue = 12.5 // available stock
        qtyStepper.minimumValue = 1    // zero is for deletion
        productImage.sd_setImage(with: URL(string: model.product_img ?? ""), completed: nil)
        productLabel.text = model.product_name
        priceLabel.text = String(format:"₱%.2f", model.product_price)
        
    }
    
    @objc private func didTapUpdate() {
        print("Did tap Update")
        
        DispatchQueue.main.async { [weak self] in
            self?.createSpinnerView()
            self?.updateButton.setTitle("Updating...", for: .normal)
        }
        
        // wait two seconds to simulate some work happening
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            // go to back to cart
            self?.navigationController?.popViewController(animated: true)
        }
    }
    
    private func configureProductOptionModel() {
        productOptionSection.append(
            CartProductOptionSection(
                title: "Mood",
                options: [
                    CartProductOption(title: "Hot", handler: { [weak self] in
                        self?.didChangeVariation(with: "Hot")
                    }),
                    CartProductOption(title: "Cold", handler: { [weak self] in
                        self?.didChangeVariation(with: "Cold")
                    })
                ])
        )
        productOptionSection.append(
            CartProductOptionSection(
                title: "Size",
                options: [
                    CartProductOption(title: "Extra Small", handler: { [weak self] in
                        self?.didChangeVariation(with: "Extra Small")
                    }),
                    CartProductOption(title: "Small", handler: { [weak self] in
                        self?.didChangeVariation(with: "Small")
                    }),
                    CartProductOption(title: "Medium", handler: { [weak self] in
                        self?.didChangeVariation(with: "Medium")
                    }),
                    CartProductOption(title: "Large", handler: { [weak self] in
                        self?.didChangeVariation(with: "Large")
                    }),
                    CartProductOption(title: "Extra Large", handler: { [weak self] in
                        self?.didChangeVariation(with: "Extra Large")
                    })
                ])
        )
        productOptionSection.append(
            CartProductOptionSection(
                title: "Sugar",
                options: [
                    CartProductOption(title: "0%", handler: { [weak self] in
                        self?.didChangeVariation(with: "0%")
                    }),
                    CartProductOption(title: "20%", handler: { [weak self] in
                        self?.didChangeVariation(with: "20%")
                    }),
                    CartProductOption(title: "30%", handler: { [weak self] in
                        self?.didChangeVariation(with: "30%")
                    })
                ])
        )
    }
    
    private func configureModels() {
        sections.append(.headerSection(
                            viewModels: FakeProductItems(
                                id: product.id,
                                product_name: product.product_name,
                                product_img: product.product_img,
                                order_qty: product.order_qty,
                                cart_qty: product.cart_qty,
                                product_price: product.product_price)))
        
        sections.append(.variationSection(viewModels: productOptionSection.compactMap({
            return CartProductOptionSection(title: $0.title, options: productOptionSection.compactMap({
                return CartProductOption(title: $0.title) {
                    print("Did tap cell")
                }
            }))
        })))
    }
    
    private func didChangeVariation(with name: String) {
        print("Did change variation to: ", name)
    }
    
    private func configureCollectionView() {
        view.addSubview(collectionView)
        
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        
        collectionView.register(OptionsCollectionViewCell.self, forCellWithReuseIdentifier: OptionsCollectionViewCell.identifier)
        
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            // then remove the spinner view controller
            child.willMove(toParent: nil)
            child.view.removeFromSuperview()
            child.removeFromParent()
        }
    }
}

// MARK:- CollectionView UICollectionViewDelegate, UICollectionViewDataSource
extension CartItemUpdateOptionViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return productOptionSection.count
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return productOptionSection[section].options.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
//        cell.backgroundColor = .green
//        return cell
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OptionsCollectionViewCell.identifier, for: indexPath) as? OptionsCollectionViewCell else {
            return UICollectionViewCell()
        }
        let model = productOptionSection[indexPath.section].options[indexPath.row]
        cell.configure(withModel: OptionsCollectionViewCellViewModel(
            id: 1,
            data: model.title,
            image: nil,
            addOnPrice: nil))
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        collectionView.indexPathsForSelectedItems?.filter({ $0.section == indexPath.section }).forEach({ collectionView.deselectItem(at: $0, animated: false) })
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let model = productOptionSection[indexPath.section].options[indexPath.row]
        print(model.title)
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



// MARK:- CollectionView Sections Layout
extension CartItemUpdateOptionViewController {
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
    }
}
