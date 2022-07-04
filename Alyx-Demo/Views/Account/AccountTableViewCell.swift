//
//  AccountTableViewCell.swift
//  Jeeves-dev
//
//  Created by Jervy Umandap on 2/4/22.
//

import UIKit

class AccountTableViewCell: UITableViewCell {
    static let identifier = "AccountTableViewCell"
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: Constants.app_logo)
        imageView.contentMode = .scaleAspectFit
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 5.0
        imageView.clipsToBounds = true
        imageView.tintColor = Constants.secondaryDarkLabelColor
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.numberOfLines = 0
        label.textColor = Constants.blackLabelColor
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = Constants.whiteBackgroundColor
        
        contentView.addSubview(iconImageView)
        contentView.addSubview(nameLabel)
        
        contentView.clipsToBounds = true
        contentView.layer.masksToBounds = true
        accessoryType = .disclosureIndicator
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let iconImageViewSize = contentView.height-20
        let nameLabelWidth = contentView.width-iconImageViewSize-safeAreaInsets.right
        
        iconImageView.frame = CGRect(
            x: 20,
            y: 10,
            width: iconImageViewSize,
            height: iconImageViewSize)
//        iconImageView.backgroundColor = .red
        
        nameLabel.frame = CGRect (
            x: iconImageView.right+10,
            y: 20,
            width: nameLabelWidth,
            height: contentView.height-40)
//        nameLabel.backgroundColor = .blue
        
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        iconImageView.image = nil
        nameLabel.text = nil
        
    }
    
    func configure(with viewModel: ShiftType) {
        iconImageView.image = viewModel.image
        nameLabel.text = viewModel.name
        
    }
}



