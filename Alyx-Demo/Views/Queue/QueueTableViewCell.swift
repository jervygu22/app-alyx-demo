//
//  QueueTableViewCell.swift
//  Jeeves-dev
//
//  Created by Jervy Umandap on 2/4/22.
//

import UIKit

class QueueTableViewCell: UITableViewCell {
    static let identifier = "QueueTableViewCell"
    
    private let leftContainer: UIView = {
        let container = UIView(frame: .zero)
        return container
    }()
    
    private let transactionIdLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.numberOfLines = 0
        label.textColor = Constants.blackLabelColor
        return label
    }()
    
    private let dateTimeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.numberOfLines = 0
        label.textColor = Constants.blackLabelColor
        return label
    }()
    
    private let cashierInfoLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.numberOfLines = 0
        label.textColor = Constants.blackLabelColor
        return label
    }()
    
    private let rightContainer: UIView = {
        let container = UIView(frame: .zero)
        return container
    }()
    
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.numberOfLines = 0
        label.textColor = Constants.blackLabelColor
        label.textAlignment = .center
        return label
    }()
    
    private let numberOfItemsLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.numberOfLines = 0
        label.textColor = Constants.blackLabelColor
        label.textAlignment = .center
        return label
    }()
    
    
    public let printImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(systemName: "printer.fill")
        imageView.tintColor = Constants.blackBackgroundColor
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(leftContainer)
        contentView.addSubview(rightContainer)
        contentView.addSubview(printImageView)
        
        leftContainer.addSubview(transactionIdLabel)
        leftContainer.addSubview(dateTimeLabel)
        leftContainer.addSubview(cashierInfoLabel)
        rightContainer.addSubview(statusLabel)
        rightContainer.addSubview(numberOfItemsLabel)
        
        contentView.clipsToBounds = true
        backgroundColor = Constants.whiteBackgroundColor
        
//        accessoryType = .disclosureIndicator
        let chevronImageView = UIImageView(image: UIImage(systemName: "chevron.right"))
        chevronImageView.tintColor = Constants.darkGrayColor
        accessoryView = chevronImageView
        
        printImageView.isHidden = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let printImageViewSize: CGFloat = 18.0
        
        let leftContainerWidth: CGFloat = (contentView.width*0.75)-printImageViewSize
        leftContainer.frame = CGRect(
            x: 16,
            y: 10,
            width: leftContainerWidth,
            height: contentView.height-20)
//        leftContainer.backgroundColor = .systemPink
        
        transactionIdLabel.frame = CGRect(
            x: 0,
            y: 0,
            width: leftContainer.width,
            height: leftContainer.height/2)
//        transactionIdLabel.backgroundColor = .systemYellow
        
        dateTimeLabel.frame = CGRect(
            x: 0,
            y: transactionIdLabel.bottom,
            width: leftContainer.width,
            height: leftContainer.height/4)
//        dateTimeLabel.backgroundColor = .systemGreen
        
        cashierInfoLabel.frame = CGRect(
            x: 0,
            y: dateTimeLabel.bottom,
            width: leftContainer.width,
            height: leftContainer.height/4)
//        cashierInfoLabel.backgroundColor = .systemTeal
        
        let rightContainerSize: CGFloat = contentView.width-leftContainer.width-30-printImageViewSize
        rightContainer.frame = CGRect(
            x: leftContainer.right,
            y: 10,
            width: rightContainerSize,
            height: contentView.height-20)
//        rightContainer.backgroundColor = .systemBlue
        
        statusLabel.frame = CGRect(
            x: 0,
            y: rightContainer.height*0.25,
            width: rightContainer.width,
            height: rightContainer.height/4)
//        statusLabel.backgroundColor = .red
        
        numberOfItemsLabel.frame = CGRect(
            x: 0,
            y: statusLabel.bottom,
            width: rightContainer.width,
            height: rightContainer.height/4)
//        numberOfItemsLabel.backgroundColor = .systemPink
        
        printImageView.frame = CGRect(
            x: rightContainer.right,
            y: (contentView.height-printImageViewSize)/2,
            width: printImageViewSize,
            height: printImageViewSize)
//        printImageView.backgroundColor = .green
        
        
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        transactionIdLabel.text = nil
        dateTimeLabel.text = nil
        cashierInfoLabel.text = nil
        statusLabel.text = nil
        numberOfItemsLabel.text = nil
    }
    
    func configure(withViewModel viewModel: QueueTableViewCellViewModel) {
        transactionIdLabel.text = viewModel.name
        dateTimeLabel.text = viewModel.date
        cashierInfoLabel.text = viewModel.info.capitalized
        statusLabel.text = viewModel.status
        numberOfItemsLabel.text = "\(viewModel.items) \(viewModel.items > 1 ? "items" : "item")"
    }
    
}
