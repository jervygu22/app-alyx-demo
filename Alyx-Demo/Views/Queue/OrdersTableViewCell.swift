//
//  OrdersTableViewCell.swift
//  Jeeves-dev
//
//  Created by Jervy Umandap on 2/4/22.
//

import UIKit

class OrdersTableViewCell: UITableViewCell {
    static let identifier = "OrdersTableViewCell"
    
    public var isAddon: Bool = false
    
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
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.numberOfLines = 0
        label.textColor = Constants.blackLabelColor
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private let qtyLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.numberOfLines = 0
        label.textColor = Constants.secondaryDarkLabelColor
        return label
    }()
    
    private let finalItemPriceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.numberOfLines = 0
        label.textColor = Constants.blackLabelColor
        label.textAlignment = .right
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private let originalPriceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.numberOfLines = 0
        label.textColor = Constants.secondaryDarkLabelColor
        label.textAlignment = .right
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = Constants.whiteBackgroundColor
        
        contentView.addSubview(productImage)
        contentView.addSubview(midContainer)
        contentView.addSubview(rightContainer)
        
        midContainer.addSubview(nameLabel)
        midContainer.addSubview(qtyLabel)
        
        rightContainer.addSubview(finalItemPriceLabel)
        rightContainer.addSubview(originalPriceLabel)
        
        contentView.clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let imageSize: CGFloat = contentView.height-20
        let midContainerWidth: CGFloat = (contentView.width/2)
        let rightContainerWidth: CGFloat = (contentView.width/2)-imageSize-30-15
        
        productImage.frame = CGRect(
            x: !isAddon ? 15 : 15 + (imageSize/2),// 15,
            y: 10,
            width: imageSize,
            height: imageSize)
        
        midContainer.frame = CGRect(
            x: productImage.right+15,
            y: 10,
            width: !isAddon ? midContainerWidth : midContainerWidth - (imageSize/2), //midContainerWidth,
            height: contentView.height-20)
//        midContainer.backgroundColor = .systemPink
        
        nameLabel.frame = CGRect(
            x: 0,
            y: 0,
            width: midContainer.width,
            height: midContainer.height*0.60) //midContainer.height/2
//        nameLabel.backgroundColor = .systemRed
        
        qtyLabel.frame = CGRect(
            x: 0,
            y: nameLabel.bottom,
            width: midContainer.width,
            height: midContainer.height*0.40)
//        qtyLabel.backgroundColor = .systemBlue
        
        rightContainer.frame = CGRect(
            x: midContainer.right,
            y: 10,
            width: rightContainerWidth,
            height: contentView.height-20)
//        rightContainer.backgroundColor = .systemTeal
        
        finalItemPriceLabel.frame = CGRect(
            x: 0,
            y: 0,
            width: rightContainer.width,
            height: rightContainer.height*0.60)
//        finalItemPriceLabel.backgroundColor = .systemTeal
        
        originalPriceLabel.frame = CGRect(
            x: 0,
            y: finalItemPriceLabel.bottom,
            width: rightContainer.width,
            height: rightContainer.height*0.40)
        originalPriceLabel.strikeThrough(true)
//        originalPriceLabel.backgroundColor = .systemPink
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        productImage.image = nil
        nameLabel.text = nil
        qtyLabel.text = nil
        finalItemPriceLabel.text = nil
        originalPriceLabel.text = nil
    }
    
    func configure(with viewModel: OrdersTableViewCellViewModel) {
        productImage.sd_setImage(with: URL(string: viewModel.image), completed: nil)
        nameLabel.text = "\(viewModel.name)"
        qtyLabel.text = "x\(viewModel.quantity)"
//        finalItemPriceLabel.text = viewModel.originalPrice
        let thisFinalPrice = viewModel.discount == 0 ? viewModel.originalPrice : viewModel.finalPrice
        finalItemPriceLabel.text = String(format:"₱%.2f", thisFinalPrice)
        originalPriceLabel.text = String(format:"₱%.2f", Double(viewModel.originalPrice))
        
        
        originalPriceLabel.isHidden = viewModel.originalPrice != viewModel.finalPrice ? false : true
        
    }
}



