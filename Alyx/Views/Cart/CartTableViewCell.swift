//
//  CartTableViewCell.swift
//  Jeeves-dev
//
//  Created by Jervy Umandap on 2/4/22.
//

import UIKit
import GMStepper
import CoreData
//import SwipeCellKit

class CartTableViewCell: UITableViewCell {
    static let identifier = "CartTableViewCell"
    
    let checkBox: CircularCheckBox = {
        let checkBox = CircularCheckBox(frame: .zero)
        return checkBox
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
        return label
    }()
    
    private let qtyLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.numberOfLines = 0
        label.textColor = Constants.secondaryDarkLabelColor
        return label
    }()
    
    private let qtyStepper: GMStepper = {
        let stepper = GMStepper(frame: .zero)
        stepper.borderColor = .black
        stepper.buttonsBackgroundColor = Constants.blackLabelColor
        stepper.buttonsFont = .systemFont(ofSize: 14, weight: .semibold)
        stepper.labelFont = .systemFont(ofSize: 14, weight: .medium)
        stepper.labelTextColor = Constants.blackLabelColor
        stepper.labelBackgroundColor = Constants.whiteBackgroundColor
        stepper.limitHitAnimationColor = Constants.secondaryLabelColor

        return stepper
    }()
    
    
    private let finalItemPriceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.numberOfLines = 0
        label.textColor = Constants.blackLabelColor
        label.textAlignment = .right
        return label
    }()
    
    private let originalPriceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.numberOfLines = 0
        label.textColor = Constants.secondaryDarkLabelColor
        label.textAlignment = .right
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = Constants.whiteBackgroundColor
        
        contentView.addSubview(checkBox)
        contentView.addSubview(productImage)
        contentView.addSubview(midContainer)
        contentView.addSubview(rightContainer)
        
        midContainer.addSubview(nameLabel)
//        midContainer.addSubview(qtyLabel)
        midContainer.addSubview(qtyStepper)
        
        qtyStepper.addTarget(self, action: #selector(didTapStepper), for: .allEvents)
        
        rightContainer.addSubview(finalItemPriceLabel)
        rightContainer.addSubview(originalPriceLabel)
        
        let checkGesture = UITapGestureRecognizer(target: self, action: #selector(didTapCheckBox))
        checkBox.addGestureRecognizer(checkGesture)
        
        contentView.clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func didTapCheckBox(check: Bool, item: Cart_Entity) {
        print("FROM cartcell isCheck: \(check), item: \(item.objectID)")
//        checkBox.toggleCheck(check: check, item: item)
    }
    
    @objc func didTapStepper() {
        print(qtyStepper.value)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let checkBoxSize = contentView.height/3
        let imageSize: CGFloat = contentView.height-20
        let midContainerWidth: CGFloat = (contentView.width/2)-checkBoxSize-10
        let rightContainerWidth: CGFloat = (contentView.width/2)-imageSize-30-10
        
        checkBox.frame = CGRect(
            x: 15,
            y: (contentView.height-checkBoxSize)/2,
            width: checkBoxSize,
            height: checkBoxSize)
        checkBox.layer.cornerRadius = checkBoxSize/2
        
        productImage.frame = CGRect(
            x: checkBox.right+15,
            y: 10,
            width: imageSize,
            height: imageSize)
        
        midContainer.frame = CGRect(
            x: productImage.right+10,
            y: 10,
            width: midContainerWidth,
            height: contentView.height-20)
//        midContainer.backgroundColor = .systemPink
        
        nameLabel.frame = CGRect(
            x: 0,
            y: 0,
            width: midContainer.width,
            height: midContainer.height*0.40)
//        nameLabel.backgroundColor = .gray
        
        qtyStepper.frame = CGRect(
            x: 0,
            y: nameLabel.bottom+(midContainer.height*0.20),
            width: 100,
            height: midContainer.height*0.40)
        
        rightContainer.frame = CGRect(
            x: midContainer.right,
            y: 10,
            width: rightContainerWidth,
            height: contentView.height-20)
//        rightContainer.backgroundColor = .systemTeal
        
        finalItemPriceLabel.frame = CGRect(
            x: 0,
            y: rightContainer.height*0.10,
            width: rightContainer.width,
            height: rightContainer.height*0.40)
        
        originalPriceLabel.frame = CGRect(
            x: 0,
            y: finalItemPriceLabel.bottom,
            width: rightContainer.width,
            height: rightContainer.height*0.40)
        originalPriceLabel.strikeThrough(true)
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        productImage.image = nil
        nameLabel.text = nil
//        qtyLabel.text = nil
        qtyStepper.value = 0
        finalItemPriceLabel.text = nil
        originalPriceLabel.text = nil
        
    }
    
    func configure(with viewModel: OrderCellViewModel) {
        productImage.sd_setImage(with: URL(string: viewModel.image), completed: nil)
        nameLabel.text = viewModel.name
//        qtyLabel.text = "\(viewModel.quantity)"
        qtyStepper.value = Double(viewModel.quantity)
        qtyStepper.minimumValue = 1  // zero - delete
        qtyStepper.maximumValue = 12 // available stock
        finalItemPriceLabel.text = "₱ \(viewModel.subTotal)"
        originalPriceLabel.text = "₱ \(viewModel.originalPrice)"
    }
}



