//
//  ProductOptionsHeaderCollectionReusableView.swift
//  Jeeves-dev
//
//  Created by Jervy Umandap on 2/4/22.
//

import UIKit

class ProductOptionsHeaderCollectionReusableView: UICollectionReusableView {
    static let identifier = "ProductOptionsHeaderCollectionReusableView"
    
    private let productImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: Constants.app_logo)
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 0
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .semibold)
        label.numberOfLines = 0
        return label
    }()
    
    // MARK:- Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
//        backgroundColor = .systemBackground
        
        addSubview(productImage)
        addSubview(nameLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let imageSize: CGFloat = (height/1.5)
        
        
        productImage.frame = CGRect(
            x: (width-imageSize)/2,
            y: safeAreaInsets.top+20,
            width: imageSize,
            height: imageSize)
        
        nameLabel.frame = CGRect(
            x: 15,
            y: productImage.bottom,
            width: width-30,
            height: height-productImage.height-20)
        
        
    }
    
    func configure(withModel model: ProductOptionsHeaderCollectionReusableViewViewModel){
        nameLabel.text = model.name
        productImage.sd_setImage(
            with: model.imageURL,
            placeholderImage: UIImage(named: Constants.app_logo),
            completed: nil)
    }
    
}
