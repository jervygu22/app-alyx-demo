//
//  TransactionTypeCollectionViewCell.swift
//  Jeeves-dev
//
//  Created by Jervy Umandap on 2/4/22.
//

import UIKit

class TransactionTypeCollectionViewCell: UICollectionViewCell {
    static let identifier = "TransactionTypeCollectionViewCell"
    
    private let transactionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.numberOfLines = 0
        label.textColor = Constants.blackLabelColor
        label.textAlignment = .center
        return label
    }()
    
    override var isSelected: Bool {
        willSet{
            super.isSelected = newValue
            if newValue
            {
                self.contentView.layer.borderWidth = 1.0
                self.contentView.layer.cornerRadius = 5.0
                self.contentView.layer.borderColor = UIColor.black.cgColor
                self.contentView.backgroundColor = Constants.darkGrayColor
                self.transactionLabel.textColor = UIColor.white
            }
            else
            {
                self.contentView.layer.borderWidth = 0.0
                self.contentView.layer.cornerRadius = 5.0
                self.contentView.backgroundColor = Constants.vcBackgroundColor
                self.transactionLabel.textColor = UIColor.black
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = Constants.vcBackgroundColor
        contentView.clipsToBounds = true
        contentView.layer.cornerRadius = 5.0
        contentView.layer.masksToBounds = true
        
        contentView.addSubview(transactionLabel)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        transactionLabel.frame = contentView.bounds
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        transactionLabel.text = nil
    }
    
    func configure(with viewModel: TransactionTypeCollectionViewCellViewModel) {
        transactionLabel.text = viewModel.name.firstCapitalized
    }
}
