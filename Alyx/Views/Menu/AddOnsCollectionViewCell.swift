//
//  AddOnsCollectionViewCell.swift
//  Alyx
//
//  Created by CDI on 6/1/22.
//

import UIKit

class AddOnsCollectionViewCell: UICollectionViewCell {
    static let identifier = "AddOnsCollectionViewCell"
    
    private let addOnsNameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = Constants.blackLabelColor
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .left
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private let addOnsPriceLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = Constants.blackLabelColor
        label.font = .systemFont(ofSize: 14, weight: .light)
        label.textAlignment = .left
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
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
        
        imageView.layer.borderWidth = 1.0
        imageView.layer.borderColor = Constants.darkGrayCGColor
        
        return imageView
    }()
    
    override var isSelected: Bool {
        willSet{
            super.isSelected = newValue
            if newValue
            {
//                self.contentView.layer.borderWidth = 1.0
//                self.contentView.layer.cornerRadius = 5.0
//                self.contentView.layer.borderColor = UIColor.black.cgColor
//                self.contentView.backgroundColor = Constants.darkGrayColor
//                self.addOnsNameLabel.textColor = UIColor.white
                
                
                self.checkBoxButton.setBackgroundImage(UIImage(systemName: "checkmark.circle.fill"), for: .selected)
                self.checkBoxButton.isSelected = newValue
                
            }
            else
            {
//                self.contentView.layer.borderWidth = 0.0
//                self.contentView.layer.cornerRadius = 5.0
//                self.contentView.backgroundColor = Constants.vcBackgroundColor
//                self.addOnsNameLabel.textColor = UIColor.black
                
                
                
                self.checkBoxButton.setBackgroundImage(UIImage(systemName: "circle"), for: .normal)
                self.checkBoxButton.isSelected = newValue
                
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = Constants.vcBackgroundColor
        contentView.clipsToBounds = true
        contentView.layer.cornerRadius = 5.0
        contentView.layer.masksToBounds = true
        
        
        contentView.addSubview(checkBoxButton)
        contentView.addSubview(addOnsPriceLabel)
        contentView.addSubview(addOnsNameLabel)
        contentView.addSubview(productImage)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
//        addOnsNameLabel.frame = contentView.bounds
        
        let productImageSize = contentView.height-10
        
        let checkBoxButtonSize: CGFloat = 40/2 // contentView.height/2
        
        let labelWidth = contentView.width - checkBoxButtonSize - 20 - productImageSize - 20
        let labelHeight = (contentView.height/2) - 5
        
        checkBoxButton.sizeToFit()
        checkBoxButton.frame = CGRect(
            x: 10,
            y: (contentView.height-checkBoxButtonSize)/2,
            width: checkBoxButtonSize,
            height: checkBoxButtonSize)
//        checkBoxButton.backgroundColor = .green
        
        addOnsNameLabel.frame = CGRect(
            x: checkBoxButton.right + 10,
            y: 5,
            width: labelWidth,
            height: labelHeight)
//        addOnsNameLabel.backgroundColor = .red
        
        addOnsPriceLabel.frame = CGRect(
            x: checkBoxButton.right + 10,
            y: addOnsNameLabel.bottom,
            width: labelWidth,
            height: labelHeight)
//        addOnsPriceLabel.backgroundColor = .blue
        
        productImage.layer.cornerRadius = productImageSize/2
        productImage.frame = CGRect(
            x: addOnsNameLabel.right + 10,
            y: 5,
            width: productImageSize,
            height: productImageSize)
//        productImage.backgroundColor = .yellow
        
        
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        addOnsNameLabel.text = nil
        productImage.image = nil
        addOnsPriceLabel.text = nil
    }
    
    func configure(withModel model: OptionsCollectionViewCellViewModel) {
        addOnsNameLabel.text = model.data
        productImage.sd_setImage(with: model.image)
        addOnsPriceLabel.text = String(format:"₱%.2f", model.addOnPrice ?? 0)
    }
    
}
