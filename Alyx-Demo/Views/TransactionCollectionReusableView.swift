//
//  TransactionCollectionReusableView.swift
//  Jeeves-dev
//
//  Created by Jervy Umandap on 2/4/22.
//

import UIKit
import CoreData

class TransactionCollectionReusableView: UICollectionReusableView {
    static let identifier = "TransactionCollectionReusableView"
    
    private let sectionHeaderlabel: UILabel = {
        let label = UILabel()
        label.textColor = Constants.secondaryDarkLabelColor
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 14, weight: .regular)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        addSubview(sectionHeaderlabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        sectionHeaderlabel.frame = CGRect(
            x: 15,
            y: 0,
            width: width-30,
            height: height)
//        sectionHeaderlabel.backgroundColor = .red
    }
    
    func configure(with sectionTitle: String) {
        sectionHeaderlabel.text = sectionTitle.firstCapitalized
    }
    
}


protocol CartItemsCollectionReusableViewDelegate: class {
    func deleteTapped(with cartItems: [Cart_Entity])
}


class CartItemsCollectionReusableView: UICollectionReusableView {
    static let identifier = "CartItemsCollectionReusableView"
    
    weak var cartItemsCollectionReusableViewDelegate: CartItemsCollectionReusableViewDelegate?
    
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    private let sectionHeaderlabel: UILabel = {
        let label = UILabel()
        label.textColor = Constants.secondaryDarkLabelColor
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 14, weight: .regular)
        return label
    }()
    
//    private let deleteButton: DeleteButton = {
//        let button = DeleteButton(frame: .zero)
//        return button
//    }()
    
    public let deleteButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = Constants.clearColor
        button.setTitle("Delete", for: .normal)
        button.setTitleColor(Constants.systemRedColor, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 16)
        button.layer.cornerRadius = 5.0
        button.layer.masksToBounds = true
        button.isHidden = true
        button.contentHorizontalAlignment = .right
        return button
    }()
    
    private let tagButton: TagButton = {
        let button = TagButton(frame: .zero)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        addSubview(sectionHeaderlabel)
        addSubview(deleteButton)
//        addSubview(tagButton)
        
        let deleteGesture = UITapGestureRecognizer(target: self, action: #selector(didTapDelete))
        deleteButton.addGestureRecognizer(deleteGesture)
        
        let tagGesture = UITapGestureRecognizer(target: self, action: #selector(didTapTag))
        tagButton.addGestureRecognizer(tagGesture)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func didTapDelete() {
        do {
            let cart: [Cart_Entity] = try context.fetch(Cart_Entity.fetchRequest())
            let cartCheckedItems = cart.filter({ $0.cart_isChecked == true && $0.cart_status == "added" })
            cartItemsCollectionReusableViewDelegate?.deleteTapped(with: cartCheckedItems)
        } catch {
            print("error deleting checked cart items: ", error.localizedDescription)
        }
    }
    
    @objc func didTapTag() {
        tagButton.handleTap()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let deleteButtonSize = height*0.75
        let tagButtonSize = height*0.75
        let sectionHeaderlabelWidth = width-100// width-60-10 //width-deleteButtonSize-tagButtonSize-10
        
        sectionHeaderlabel.frame = CGRect(
            x: 15,
            y: 0,
            width: sectionHeaderlabelWidth-30,
            height: height)
//        sectionHeaderlabel.backgroundColor = .red
        
        deleteButton.frame = CGRect(
            x: sectionHeaderlabel.right,
            y: (height-deleteButtonSize)/2,
            width: width-sectionHeaderlabelWidth, //deleteButtonSize
            height: deleteButtonSize)
//        deleteButton.layer.cornerRadius = deleteButtonSize/2
//        deleteButton.backgroundColor = .cyan
        
        tagButton.frame = CGRect(
            x: deleteButton.right+10,
            y: (height-deleteButtonSize)/2,
            width: deleteButtonSize,
            height: deleteButtonSize)
        tagButton.layer.cornerRadius = tagButtonSize/2
//        tagButton.backgroundColor = .systemTeal
    }
    
    func configure(with sectionTitle: String) {
        sectionHeaderlabel.text = sectionTitle.firstCapitalized
    }
}
