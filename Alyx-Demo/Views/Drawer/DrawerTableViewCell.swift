//
//  DrawerTableViewCell.swift
//  Jeeves-dev
//
//  Created by Jervy Umandap on 2/4/22.
//

import UIKit

class DrawerTableViewCell: UITableViewCell {
    
    static let identifier = "DrawerTableViewCell"
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        label.numberOfLines = 1
        return label
    }()
    
    private let iconImage: UIImageView = {
        let imageView = UIImageView()
        if #available(iOS 13.0, *) {
            imageView.image = UIImage(systemName: "launchLogo")
        } else {
            // Fallback on earlier versions
        }
        imageView.contentMode = .scaleAspectFit
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 10
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(titleLabel)
        contentView.addSubview(iconImage)
        contentView.backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        titleLabel.sizeToFit()
        let iconSize = contentView.height/2
        
        iconImage.frame = CGRect(x: 16,
                                 y: (contentView.height-iconSize)/2,
                                 width: iconSize,
                                 height: iconSize)
        iconImage.tintColor = Constants.iconColor
//        iconImage.backgroundColor = .red
//        contentView.backgroundColor = .gray
        
        titleLabel.frame = CGRect(x: iconImage.right + 10,
                                  y: 0,
                                  width: contentView.width-iconImage.width,
                                  height: contentView.height)
        titleLabel.textColor = Constants.drawerLabelColor
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        iconImage.image = nil
    }
    
    func configure(with model: DrawerData) {
        titleLabel.text = model.title
        iconImage.image = UIImage(systemName: model.imageIcon)
    }
    
}
