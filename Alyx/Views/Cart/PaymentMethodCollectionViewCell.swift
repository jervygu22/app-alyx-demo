//
//  PaymentMethodCollectionViewCell.swift
//  Jeeves-dev
//
//  Created by Jervy Umandap on 2/4/22.
//

import UIKit

protocol PaymentMethodCollectionViewCellDelegate: AnyObject {
    func didTapPaymentMethod(data: String)
}

class PaymentMethodCollectionViewCell: UICollectionViewCell {
    
    weak var paymentMethodCollectionViewCellDelegate: PaymentMethodCollectionViewCellDelegate?
    
    static let identifier = "PaymentMethodCollectionViewCell"
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: Constants.app_logo)
        imageView.contentMode = .scaleAspectFit
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 0
        imageView.tintColor = [#colorLiteral(red: 0.1411764771, green: 0.3960784376, blue: 0.5647059083, alpha: 1),#colorLiteral(red: 0.1215686277, green: 0.01176470611, blue: 0.4235294163, alpha: 1),#colorLiteral(red: 0.4392156899, green: 0.01176470611, blue: 0.1921568662, alpha: 1),#colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1),#colorLiteral(red: 0.7254902124, green: 0.4784313738, blue: 0.09803921729, alpha: 1),#colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1)].randomElement()
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 10, weight: .regular)
        label.textColor = Constants.blackLabelColor
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = Constants.vcBackgroundColor
        contentView.clipsToBounds = true
        contentView.layer.cornerRadius = 5.0
        contentView.layer.masksToBounds = true
        
        contentView.addSubview(imageView)
        contentView.addSubview(nameLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var isSelected: Bool {
        willSet{
            super.isSelected = newValue
            if newValue
            {
                self.contentView.layer.borderWidth = 1.0
                self.contentView.layer.cornerRadius = 5.0
                self.contentView.layer.borderColor = UIColor.black.cgColor
                self.contentView.backgroundColor = Constants.darkGrayColor
                self.nameLabel.textColor = UIColor.white
                self.imageView.tintColor = UIColor.white
            }
            else
            {
                self.contentView.layer.borderWidth = 0.0
                self.contentView.layer.cornerRadius = 5.0
                self.contentView.backgroundColor = Constants.vcBackgroundColor
                self.nameLabel.textColor = UIColor.black
                self.imageView.tintColor = [#colorLiteral(red: 0.1411764771, green: 0.3960784376, blue: 0.5647059083, alpha: 1),#colorLiteral(red: 0.1215686277, green: 0.01176470611, blue: 0.4235294163, alpha: 1),#colorLiteral(red: 0.4392156899, green: 0.01176470611, blue: 0.1921568662, alpha: 1),#colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1),#colorLiteral(red: 0.7254902124, green: 0.4784313738, blue: 0.09803921729, alpha: 1),#colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1)].randomElement()
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let imageSize = contentView.height/1.75
        nameLabel.sizeToFit()
        
        imageView.frame = CGRect(
            x: (contentView.width-imageSize)/2,
            y: 5,
            width: imageSize,
            height: imageSize)
//        imageView.backgroundColor = .systemPink
        
        nameLabel.frame = CGRect(
            x: 0,
            y: imageView.bottom,
            width: contentView.width,
            height: contentView.height-imageView.height-5)
//        nameLabel.backgroundColor = .systemGreen
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        nameLabel.text = nil
    }
    
    func configure(with viewModel: PaymentMethodCollectionViewCellViewModel) {
        imageView.image = viewModel.image
        nameLabel.text = viewModel.name
    }
}

struct PaymentMethodCollectionViewCellViewModel {
    let name: String
    let image: UIImage?
}
