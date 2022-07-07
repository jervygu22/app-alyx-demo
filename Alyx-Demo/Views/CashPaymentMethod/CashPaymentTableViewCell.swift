//
//  CashPaymentTableViewCell.swift
//  Jeeves-dev
//
//  Created by Jervy Umandap on 2/4/22.
//

import UIKit
import SDWebImage

class CashPaymentTableViewCell: UITableViewCell {
    static let identifier = "CashPaymentTableViewCell"
    
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
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.numberOfLines = 0
        label.textColor = Constants.blackLabelColor
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private let qtyLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .regular)
        label.numberOfLines = 0
        label.textColor = Constants.blackLabelColor
        label.textAlignment = .right
        return label
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.numberOfLines = 0
        label.textColor = Constants.blackLabelColor
        label.textAlignment = .right
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = Constants.vcBackgroundColor
        contentView.clipsToBounds = true
        contentView.layer.masksToBounds = true
        
        
        contentView.addSubview(productImage)
        contentView.addSubview(nameLabel)
        contentView.addSubview(qtyLabel)
        contentView.addSubview(priceLabel)
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let imageSize: CGFloat = contentView.height-20
        let nameLabelWidth: CGFloat = (contentView.width/2)-imageSize
        let qtyPriceWidth: CGFloat = ((contentView.width/2)-imageSize)/2
        
        productImage.frame = CGRect(
            x: !isAddon ? 15 : 15 + imageSize + 10, // 15  //!isAddon ? 15 : 15 + (imageSize/2)
            y: 10,
            width: imageSize,
            height: imageSize)
//        productImage.backgroundColor = .green
        
        nameLabel.frame = CGRect(
            x: productImage.right+10,
            y: 10,
            width: !isAddon ? nameLabelWidth : nameLabelWidth - imageSize - 10, //nameLabelWidth, //!isAddon ? nameLabelWidth : nameLabelWidth - (imageSize/2),
            height: contentView.height-20)
//        nameLabel.backgroundColor = .blue
        
        qtyLabel.frame = CGRect(
            x: nameLabel.right+10,
            y: 10,
            width: qtyPriceWidth-10-25,
            height: contentView.height-20)
//        qtyLabel.backgroundColor = .red
        
        priceLabel.frame = CGRect(
            x: qtyLabel.right+10,
            y: 10,
            width: qtyPriceWidth-10+25+10,
            height: contentView.height-20)
//        priceLabel.backgroundColor = .green
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        productImage.image = nil
        nameLabel.text = nil
        qtyLabel.text = nil
        priceLabel.text = nil
    }
    
    func configure(with viewModel: OrderCellViewModel) {
        productImage.sd_setImage(with: URL(string: viewModel.image), completed: nil)
        nameLabel.text = viewModel.name
        qtyLabel.text = "\(viewModel.quantity)"
        priceLabel.text = String(format:"₱%.2f", viewModel.subTotal)
    }
    
}
