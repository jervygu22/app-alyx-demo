//
//  CartItemsCollectionViewCell.swift
//  Jeeves-dev
//
//  Created by Jervy Umandap on 2/4/22.
//

import UIKit
import GMStepper
import SwipeCellKit
import CoreData

//protocol CartItemsCollectionViewCellDelegate: class {
//    func stepper(_ stepper: GMStepper, at index: Int, didChangeValueTo newValue: Double)
//    func didCheckButton(_ button: UIButton, at index: Int, didChangeValueTo newValue: Bool)
//}

protocol CartItemsCollectionViewCellDelegate: AnyObject {
    func shouldReloadCollectionView()
    func shouldReloadBottomView()
}

class CartItemsCollectionViewCell: SwipeCollectionViewCell {
    
    static let identifier = "CartItemsCollectionViewCell"
    
    weak var cartItemsCollectionViewCellDelegate: CartItemsCollectionViewCellDelegate?
    
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    private var cart = [Cart_Entity]()
    
    public var checkBoxButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.tintColor = Constants.secondaryDarkLabelColor
        button.setImage(UIImage(systemName: "circle"), for: .normal)
        button.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .selected)
        button.layer.masksToBounds = true
        button.clipsToBounds = true
        button.isSelected = false
        button.contentMode = .scaleAspectFit
        return button
    }()
    
    private let productImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: Constants.app_logo)
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 5.0
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let midContainer: UIView = {
        let container = UIView(frame: .zero)
        return container
    }()
    
    private let rightContainer: UIView = {
        let container = UIView(frame: .zero)
        return container
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.numberOfLines = 0
        label.textColor = Constants.blackLabelColor
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private let addOnsLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .light)
        label.numberOfLines = 0
        label.textColor = Constants.blackLabelColor
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private let qtyLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.numberOfLines = 0
        label.textColor = Constants.secondaryDarkLabelColor
        return label
    }()
    
    public let qtyStepper: GMStepper = {
        let stepper = GMStepper(frame: .zero)
        stepper.borderColor = .black
        stepper.buttonsBackgroundColor = Constants.darkGrayColor
        stepper.buttonsFont = .systemFont(ofSize: 14, weight: .semibold)
        stepper.labelFont = .systemFont(ofSize: 14, weight: .medium)
        stepper.labelTextColor = Constants.blackLabelColor
        stepper.labelBackgroundColor = Constants.whiteBackgroundColor
        stepper.limitHitAnimationColor = Constants.secondaryLabelColor
        stepper.minimumValue = 1

        return stepper
    }()
    
    public let finalItemPriceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.numberOfLines = 0
        label.textColor = Constants.blackLabelColor
        label.textAlignment = .right
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    public let originalPriceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.numberOfLines = 0
        label.textColor = Constants.secondaryDarkLabelColor
        label.textAlignment = .right
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        getAllItems()
        
        backgroundColor = Constants.whiteBackgroundColor
        
        contentView.addSubview(checkBoxButton)
        contentView.addSubview(productImage)
        contentView.addSubview(midContainer)
        contentView.addSubview(rightContainer)
        
        midContainer.addSubview(nameLabel)
        midContainer.addSubview(addOnsLabel)
//        midContainer.addSubview(qtyLabel)
        midContainer.addSubview(qtyStepper)
        
        
        rightContainer.addSubview(finalItemPriceLabel)
        rightContainer.addSubview(originalPriceLabel)
        
//        let checkGesture = UITapGestureRecognizer(target: self, action: #selector(didTapCheckBox))
//        checkBox.addGestureRecognizer(checkGesture)
        
        qtyStepper.addTarget(self, action: #selector(myStepperValueChanged), for: .valueChanged)
        
        checkBoxButton.addTarget(self, action: #selector(didTapCheckButton(_:)), for: .touchUpInside)
        
        print("cart:", cart.count)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func didTapCheckButton(_ sender: UIButton) {
        print("check button toggled!")
        if !sender.isSelected {
            checkBoxButton.setBackgroundImage(UIImage(systemName: "checkmark.circle.fill"), for: .selected)
            checkBoxButton.isSelected = true
        } else {
            checkBoxButton.setBackgroundImage(UIImage(systemName: "circle"), for: .normal)
            checkBoxButton.isSelected = false
        }
        
        let cartItem = cart[sender.tag]
        let newValue = checkBoxButton.isSelected
        CartViewController.shared.checkItem(item: cartItem, isChecked: newValue)
        cartItemsCollectionViewCellDelegate?.shouldReloadCollectionView()
        cartItemsCollectionViewCellDelegate?.shouldReloadBottomView()
        
    }
    
    @objc func myStepperValueChanged(_ sender: GMStepper) {
        
       // if cart[sender.tag].cart_quantity
        print("stepper tapped: \(sender.tag) - \(sender.value)")
        let cartItem = cart[sender.tag]
        let newValue = Int(sender.value)
        updateQty(item: cartItem, qty: newValue)
        getAllItems()
        cartItemsCollectionViewCellDelegate?.shouldReloadBottomView()
        
//        contentView.reloadInputViews()
    }
    
    public func getAllItems() {
        do {
            // let items = try context.fetch(ToDoListItem.fetchRequest())
            let cartEntity: [Cart_Entity] = try context.fetch(Cart_Entity.fetchRequest())
            cart = cartEntity.filter({ $0.cart_status == "added"})
            
        } catch {
            // error
        }
    }
    
    public func updateQty(item: Cart_Entity, qty: Int) {
        
        item.cart_quantity = Int64(qty)
        item.cart_original_cost = item.cart_product_cost * Double(qty)
//        item.cart_final_cost = (item.cart_product_cost * item.cart_discount) * Double(qty)
        item.cart_final_cost = item.cart_discounted_product_cost * Double(qty)
        
        do {
            try context.save()
            getAllItems()
        } catch {
            // error
        }
    }
    
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let checkBoxSize = contentView.height/4
        let imageSize: CGFloat = contentView.height-20
        let midContainerWidth: CGFloat = (contentView.width/2)-checkBoxSize-10
        let rightContainerWidth: CGFloat = (contentView.width/2)-imageSize-35-20
        
        checkBoxButton.frame = CGRect(
            x: 20,
            y: (contentView.height-checkBoxSize)/2,
            width: checkBoxSize,
            height: checkBoxSize)
        checkBoxButton.layer.cornerRadius = checkBoxSize/2
//        checkBoxButton.backgroundColor = .red
        
        productImage.frame = CGRect(
            x: !checkBoxButton.isHidden ? checkBoxButton.right+15 : checkBoxButton.right+15+(imageSize/2),
            y: 10,
            width: imageSize,
            height: imageSize)
        
        midContainer.frame = CGRect(
            x: !checkBoxButton.isHidden ? productImage.right+10 : productImage.right+10,
            y: 10,
            width: !checkBoxButton.isHidden ? midContainerWidth : midContainerWidth-(imageSize/2),
            height: contentView.height-20)
//        midContainer.backgroundColor = .systemPink
        
        nameLabel.frame = CGRect(
            x: 0,
            y: 0,
            width: midContainer.width,
            height: midContainer.height*0.55)
//        nameLabel.backgroundColor = .systemBlue
        
        qtyStepper.frame = CGRect(
            x: 0,
            y: nameLabel.bottom+(midContainer.height*0.05), // addOnsLabel.bottom, //
            width: 100,
            height: midContainer.height*0.40)
//        qtyStepper.backgroundColor = .systemRed
        
        rightContainer.frame = CGRect(
            x: midContainer.right,
            y: 10,
            width: rightContainerWidth,
            height: contentView.height-20)
//        rightContainer.backgroundColor = .systemGreen
        
        finalItemPriceLabel.frame = CGRect(
            x: 0,
            y: rightContainer.height*0.10,
            width: rightContainer.width,
            height: rightContainer.height*0.50)
//        finalItemPriceLabel.backgroundColor = .systemTeal
        
        originalPriceLabel.frame = CGRect(
            x: 0,
            y: finalItemPriceLabel.bottom,
            width: rightContainer.width,
            height: rightContainer.height*0.30)
        originalPriceLabel.strikeThrough(true)
//        originalPriceLabel.backgroundColor = .systemPink
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        productImage.image = nil
        nameLabel.text = nil
//        qtyLabel.text = nil
//        qtyStepper.value = 0
        finalItemPriceLabel.text = nil
        originalPriceLabel.text = nil
        checkBoxButton.setBackgroundImage(nil, for: .normal)
        checkBoxButton.setBackgroundImage(nil, for: .selected)
        
    }
    
    func configure(with viewModel: CartItemsCollectionViewCellViewModel) {
        
        productImage.sd_setImage(with: URL(string: viewModel.image), completed: nil)
//        productImage.image = UIImage(systemName: "person")
        nameLabel.text = viewModel.name
        
        var shortDiscountKey = ""
        if viewModel.discountKey == "senior" {
            shortDiscountKey = "SR・" //•
//            originalPriceLabel.textColor = Constants.seniorLabelColor
            contentView.addRightBorder(with: .brown, andWidth: 3.0)
        } else if viewModel.discountKey == "pwd" {
            shortDiscountKey = "PWD・"
//            originalPriceLabel.textColor = Constants.pwdLabelColor
            contentView.addRightBorder(with: .orange, andWidth: 3.0)
        } else if viewModel.discountKey == "" {
//            shortDiscountKey = "PWD・"
//            originalPriceLabel.textColor = Constants.pwdLabelColor
//            contentView.addRightBorder(with: Constants.lightGrayColor, andWidth: 4.0)
            contentView.addRightBorder(with: Constants.whiteBackgroundColor, andWidth: 3.0)
        } else {
            shortDiscountKey = ""
//            originalPriceLabel.textColor = Constants.secondaryDarkLabelColor
//            contentView.addRightBorder(with: Constants.darkGrayColor, andWidth: 4.0)
            contentView.addRightBorder(with: Constants.darkGrayColor, andWidth: 3.0)
        }
        
        print(shortDiscountKey)
//        checkBox.isChecked = viewModel.isChecked
        
        checkBoxButton.isHidden = viewModel.isCheckBoxHidden
        checkBoxButton.isSelected = viewModel.isChecked
        checkBoxButton.tag = viewModel.index
        qtyStepper.value = Double(viewModel.quantity)
//        qtyStepper.tag = viewModel.index
        finalItemPriceLabel.text = "\(String(format:"₱%.2f", viewModel.subTotal))"
        originalPriceLabel.text = String(format:"₱%.2f", viewModel.originalPrice)
        addOnsLabel.text = viewModel.addOns
    }
}
