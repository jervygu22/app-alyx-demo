//
//  CashPaymentHeaderTableViewCell.swift
//  Jeeves-dev
//
//  Created by Jervy Umandap on 2/4/22.
//

import UIKit

class CashPaymentHeaderTableViewCell: UITableViewCell {
    static let identifier = "CashPaymentHeaderTableViewCell"
    
    private let descHeaderLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.numberOfLines = 0
        label.textColor = Constants.darkGrayColor
        label.text = "DESCRIPTION"
        return label
    }()
    
    private let qtyHeaderLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.numberOfLines = 0
        label.textColor = Constants.darkGrayColor
        label.textAlignment = .right
        label.text = "QTY"
        return label
    }()
    
    private let priceHeaderLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.numberOfLines = 0
        label.textColor = Constants.darkGrayColor
        label.textAlignment = .right
        label.text = "PRICE"
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = Constants.whiteBackgroundColor
        contentView.clipsToBounds = true
        contentView.layer.masksToBounds = true
        
        contentView.addSubview(descHeaderLabel)
        contentView.addSubview(qtyHeaderLabel)
        contentView.addSubview(priceHeaderLabel)
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let nameLabelWidth: CGFloat = (contentView.width/2)-50
        let qtyPriceWidth: CGFloat = ((contentView.width/2)-50)/2
        
        descHeaderLabel.frame = CGRect(
            x: 50+15+10,
            y: 0,
            width: nameLabelWidth,
            height: contentView.height)
//        descHeaderLabel.backgroundColor = .lightGray
        
        qtyHeaderLabel.frame = CGRect(
            x: descHeaderLabel.right+10,
            y: 0,
            width: qtyPriceWidth-10-25,
            height: contentView.height)
//        qtyHeaderLabel.backgroundColor = .yellow
        
        priceHeaderLabel.frame = CGRect(
            x: qtyHeaderLabel.right+10,
            y: 0,
            width: qtyPriceWidth-10+25+10,
            height: contentView.height)
//        priceHeaderLabel.backgroundColor = .green
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        descHeaderLabel.text = nil
        qtyHeaderLabel.text = nil
        priceHeaderLabel.text = nil
    }
    
    func configure(with viewModel: OrderCellViewModel) {
        descHeaderLabel.text = viewModel.name
        qtyHeaderLabel.text = "\(viewModel.quantity)"
        priceHeaderLabel.text = String(format:"₱%.2f", viewModel.subTotal)
    }
    
}
