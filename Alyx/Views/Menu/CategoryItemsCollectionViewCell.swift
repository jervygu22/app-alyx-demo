//
//  CategoryItemsCollectionViewCell.swift
//  Jeeves-dev
//
//  Created by Jervy Umandap on 2/4/22.
//

import UIKit

class CategoryItemsCollectionViewCell: UICollectionViewCell {
    static let identifier = "CategoryItemsCollectionViewCell"
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: Constants.app_logo)
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 5
        return imageView
    }()
    
    public let cartItemCountContainerView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.layer.masksToBounds = true
        view.backgroundColor = Constants.darkGrayColor
        
        
        view.roundCorners(radius: 5.0, corners: [.topRight, .bottomLeft])
        view.layer.borderWidth = 1.0
        view.layer.borderColor = UIColor.black.cgColor
        
        view.isHidden = false
        
        return view
    }()
    
    public var cartItemCountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = Constants.whiteLabelColor
        label.numberOfLines = 0
        label.textAlignment = .center
        label.text = "0"
        return label
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .black
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    private let subLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .black
        label.numberOfLines = 0
        label.textAlignment = .right
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        contentView.addSubview(label)
        contentView.addSubview(subLabel)
        contentView.addSubview(cartItemCountContainerView)
        cartItemCountContainerView.addSubview(cartItemCountLabel)
        contentView.clipsToBounds = true
        contentView.layer.cornerRadius = 5.0
        contentView.layer.masksToBounds = true
        contentView.backgroundColor = Constants.collectionViewCellColor
        
        cartItemCountLabel.text = "99"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let imageSize = contentView.height/1.75
        label.sizeToFit()
        subLabel.sizeToFit()
        cartItemCountLabel.sizeToFit()
        
        imageView.frame = CGRect(
            x: 20,
            y: 10,
            width: contentView.width-40,
            height: imageSize)
//        imageView.backgroundColor = .systemPink
        
        label.frame = CGRect(
            x: 10,
            y: imageView.bottom,
            width: contentView.width-20,
            height: ((contentView.height-imageView.height)-10)*0.5)
//        label.backgroundColor = .red
        
//        let countContainerSize = contentView.height-imageSize-label.height
        
        cartItemCountContainerView.frame = CGRect(
            x: 0,
            y: label.bottom,
            width: label.height,
            height: label.height)
//        cartItemCountContainerView.backgroundColor = .red
        
        cartItemCountLabel.frame = cartItemCountContainerView.bounds
//        cartItemCountLabel.backgroundColor = .red
        
        subLabel.frame = CGRect(
            x: cartItemCountContainerView.right,
            y: label.bottom,
            width: contentView.width-cartItemCountContainerView.width-10,
            height: ((contentView.height-imageView.height)-10)*0.5)
//        subLabel.backgroundColor = .systemGreen
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        label.text = nil
        subLabel.text = nil
        cartItemCountLabel.text = nil
        
    }
    
    func configure(withModel model: CategoryItemsCellViewModel, with orderCount: Int?) {
        imageView.sd_setImage(with: model.image, completed: nil)
        label.text = model.name
        subLabel.text = String(format:"₱%.2f", Double(model.price))
        if let orderCount = orderCount {
            cartItemCountContainerView.isHidden = orderCount > 0 ? false : true
        }
        cartItemCountLabel.text = "\(orderCount ?? 0)"
    }
}
