//
//  CategoryCollectionViewCell.swift
//  Jeeves-dev
//
//  Created by Jervy Umandap on 2/4/22.
//

import UIKit

class CategoryCollectionViewCell: UICollectionViewCell {
    static let identifier = "CategoryCollectionViewCell"
    
    private let artWorkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: Constants.app_logo)
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 2.5
        return imageView
    }()
    
    public let categoryLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.textColor = .black
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    override var isSelected: Bool {
        didSet {
            self.contentView.layer.borderWidth = isSelected ? 1.0 : 0
            self.contentView.layer.cornerRadius = isSelected ? 5.0 : 5.0
            self.contentView.layer.borderColor = isSelected ? UIColor.black.cgColor : nil
            self.contentView.backgroundColor = isSelected ? Constants.darkGrayColor : Constants.collectionViewCellColor
            self.categoryLabel.textColor = isSelected ? UIColor.white : UIColor.black
        }
        
//        willSet{
//            super.isSelected = newValue
//            if newValue
//            {
//                self.contentView.layer.borderWidth = 1.0
//                self.contentView.layer.cornerRadius = 5.0
//                self.contentView.layer.borderColor = UIColor.black.cgColor
//                self.contentView.backgroundColor = Constants.darkGrayColor
//                self.categoryLabel.textColor = UIColor.white
//            }
//            else
//            {
//                self.contentView.layer.borderWidth = 0.0
//                self.contentView.layer.cornerRadius = 5.0
//                self.contentView.backgroundColor = Constants.collectionViewCellColor
//                self.categoryLabel.textColor = UIColor.black
//            }
//        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = Constants.collectionViewCellColor
        contentView.clipsToBounds = true
        contentView.layer.cornerRadius = 5.0
        contentView.layer.masksToBounds = true
        
        contentView.addSubview(artWorkImageView)
        contentView.addSubview(categoryLabel)
        artWorkImageView.backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let imageSize = contentView.width/2
        categoryLabel.sizeToFit()
        
        artWorkImageView.frame = CGRect(
            x: (contentView.width-imageSize)/2,
            y: 10,
            width: imageSize,
            height: imageSize)
//        imageView.backgroundColor = .systemPink
        
        categoryLabel.frame = CGRect(
            x: 0,
            y: artWorkImageView.bottom+10,
            width: contentView.width,
            height: min(80, contentView.height-artWorkImageView.height-10-10))
//        label.backgroundColor = .systemGreen
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        artWorkImageView.image = nil
        categoryLabel.text = nil
        if self.isSelected {
            self.contentView.layer.borderWidth = 1.0
            self.contentView.layer.cornerRadius = 5.0
            self.contentView.layer.borderColor = UIColor.black.cgColor
            self.contentView.backgroundColor = Constants.darkGrayColor
            self.categoryLabel.textColor = UIColor.white
        } else {
            self.contentView.layer.borderWidth = 0.0
            self.contentView.layer.cornerRadius = 5.0
            self.contentView.backgroundColor = Constants.collectionViewCellColor
            self.categoryLabel.textColor = UIColor.black
        }
    }
    
    func configure(withModel model: CategoryCellViewModel) {
        //        imageView.image = UIImage(systemName: "photo")
        let guid = model.artworkUrl ?? URL(string: "https://alyx-staging.codedisruptors.com/new-franchisee/wp-content/uploads/sites/111/2022/03/cropped-logo.png")
        artWorkImageView.sd_setImage(with: guid, completed: nil)
        categoryLabel.text = model.name
    }
    
    
}
