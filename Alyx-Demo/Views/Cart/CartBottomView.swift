//
//  CartBottomView.swift
//  Jeeves-dev
//
//  Created by Jervy Umandap on 2/4/22.
//

import UIKit
import CoreData

struct PaymentMethods {
    let name: String
    let id: Int
    let image: UIImage?
    let url: URL?
}

protocol CartBottomViewDelegate: AnyObject {
    func navigatePushViewController(data: String, remarks: String?)
    func showAlertFromCartBottomView()
    func didTapCheckAll(isChecked: Bool)
}

class CartBottomView: UIView {
    
    weak var cartBottomViewDelegate: CartBottomViewDelegate?
    
    private var paymentMenthods = [PaymentMethods]()
    
    
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
    
    private let totalLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = Constants.blackLabelColor
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.text = "Total"
        label.textAlignment = .left
        return label
    }()
    
    public let totalValueLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = Constants.blackLabelColor
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .right
        return label
    }()
    
    public let remarksField: UITextField = {
        let textField = UITextField(frame: .zero)
        textField.textAlignment = .left
        textField.borderStyle = .roundedRect
        textField.font = UIFont.systemFont(ofSize: 16, weight: .regular)
//        textField.placeholder = "Remarks"
        textField.backgroundColor = Constants.whiteBackgroundColor
        textField.textColor = Constants.blackLabelColor
        
        textField.attributedPlaceholder = NSAttributedString(
            string: "Remarks",
            attributes: [NSAttributedString.Key.foregroundColor : Constants.lightGrayColor])
        
        return textField
    }()
    
    private let paymentMethodLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = Constants.blackLabelColor
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.text = "Payment Methods"
        label.textAlignment = .left
        return label
    }()
    
    public let collectionView: UICollectionView = {
        
        let collection = UICollectionView(
            frame: .zero,
            collectionViewLayout: UICollectionViewCompositionalLayout { (sectionIndex, _) -> NSCollectionLayoutSection? in
                return CartViewController.createBottomContainerCollectionLayout(section: sectionIndex)
            })
        collection.bounces = false
        collection.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collection.register(PaymentMethodCollectionViewCell.self,
                            forCellWithReuseIdentifier: PaymentMethodCollectionViewCell.identifier)
        
        return collection
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(checkBoxButton)
        
        addSubview(totalLabel)
        addSubview(totalValueLabel)
//        totalValueLabel.text = "₱ 385.00"
        addSubview(remarksField)
        addSubview(paymentMethodLabel)
        addSubview(collectionView)
        
        remarksField.delegate = self
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
//        layer.cornerRadius = 5.0
        layer.masksToBounds = true
        clipsToBounds = true
        configurePaymentMethod()
        
        collectionView.allowsMultipleSelection = true
        
        
        checkBoxButton.addTarget(self, action: #selector(didTapCheckButton(_:)), for: .touchUpInside)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    @objc func didTapCheckButton(_ sender: UIButton) {
        if !sender.isSelected {
            checkBoxButton.setBackgroundImage(UIImage(systemName: "checkmark.circle.fill"), for: .selected)
            checkBoxButton.isSelected = true
            cartBottomViewDelegate?.didTapCheckAll(isChecked: true)
        } else {
            checkBoxButton.setBackgroundImage(UIImage(systemName: "circle"), for: .normal)
            checkBoxButton.isSelected = false
            cartBottomViewDelegate?.didTapCheckAll(isChecked: false)
        }
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let collectionViewHeight = height/2
//        let labelHeight = ((height-collectionView.height)/2)/1.8
//        let remarksHeight = height-collectionView.height-(labelHeight*2)-10
        
        let checkBoxButtonSize: CGFloat = 40 / 2
        let labelHeight = ((height-collectionView.height)/3)//1.8
        let remarksHeight = ((height-collectionView.height)/3)
        
        checkBoxButton.frame = CGRect(
            x: 0,
            y: (((10+labelHeight)-checkBoxButtonSize)/2),
            width: checkBoxButtonSize,
            height: checkBoxButtonSize)
//        checkBoxButton.backgroundColor = .orange
        
        totalLabel.frame = CGRect(
            x: checkBoxButton.right + 10,
            y: 5,
            width: (width/2) - checkBoxButtonSize - 10,
            height: labelHeight)
//        totalLabel.backgroundColor = .magenta
        
        totalValueLabel.frame = CGRect(
            x: totalLabel.right,
            y: 5,
            width: (width/2)-safeAreaInsets.right,
            height: labelHeight)
//        totalValueLabel.backgroundColor = .cyan
        
        remarksField.frame = CGRect(
            x: 0,
            y: totalValueLabel.bottom+5,
            width: width-safeAreaInsets.right,
            height: remarksHeight)
        
        paymentMethodLabel.frame = CGRect(
            x: 0,
            y: remarksField.bottom,
            width: width-safeAreaInsets.right,
            height: labelHeight)
//        paymentMethodLabel.backgroundColor = .systemTeal
        
        collectionView.frame = CGRect(
            x: 0,
            y: paymentMethodLabel.bottom,
            width: width,
            height: collectionViewHeight)
        collectionView.backgroundColor = .clear
    }
    
    private func configurePaymentMethod() {
//        paymentMenthods.append(
//            PaymentMethods(
//                name: "Queue",
//                id: 0,
//                image: UIImage(systemName: "clock.fill"),
//                url: URL(string: "www.example.com")))
        
        paymentMenthods.append(
            PaymentMethods(
                name: "Cash",
                id: 1,
                image: UIImage(named: "cash"), // UIImage(systemName: "dollarsign.circle.fill"),
                url: URL(string: "www.example.com")))
        
//        paymentMenthods.append(
//            PaymentMethods(
//                name: "Debit/Credit",
//                id: 2,
//                image: UIImage(named: "card"), // UIImage(systemName: "creditcard.fill"),
//                url: URL(string: "www.example.com")))
//        paymentMenthods.append(
//            PaymentMethods(
//                name: "E-Wallet",
//                id: 3,
//                image: UIImage(named: "e_wallet"), // UIImage(systemName: "folder.fill"),
//                url: URL(string: "www.example.com")))
//        paymentMenthods.append(
//            PaymentMethods(
//                name: "Loyalty Points",
//                id: 4,
//                image: UIImage(systemName: "star.leadinghalf.fill"),
//                url: URL(string: "www.example.com")))
//        paymentMenthods.append(
//            PaymentMethods(
//                name: "Voucher",
//                id: 5,
//                image: UIImage(systemName: "giftcard.fill"),
//                url: URL(string: "www.example.com")))
    }
}

extension CartBottomView: UICollectionViewDelegate, UICollectionViewDataSource, PaymentMethodCollectionViewCellDelegate {
    
    func didTapPaymentMethod(data: String) {
        cartBottomViewDelegate?.navigatePushViewController(data: data, remarks: remarksField.text)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return paymentMenthods.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let model = paymentMenthods[indexPath.row]
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PaymentMethodCollectionViewCell.identifier, for: indexPath) as? PaymentMethodCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        cell.paymentMethodCollectionViewCellDelegate = self
        
        cell.configure(with: PaymentMethodCollectionViewCellViewModel(
                        name: model.name,
                        image: model.image))
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        collectionView.indexPathsForSelectedItems?.filter({ $0.section == indexPath.section }).forEach({ collectionView.deselectItem(at: $0, animated: false) })
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let method = paymentMenthods[indexPath.row]
        print("did tap", method.name)
        
        switch method.id {
        case 1:
//            CartViewController.shared.fetchCart()
//            if !CartViewController.shared.cartSelectedItems.isEmpty {
//                didTapPaymentMethod(data: method.name)
//            } else {
//                cartBottomViewDelegate?.showAlertFromCartBottomView()
//            }
            
            didTapPaymentMethod(data: method.name)
        default:
            break
        }
    }
}

extension CartBottomView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == remarksField {
            textField.resignFirstResponder()
            return true
        } else {
            return false
        }
    }
}
