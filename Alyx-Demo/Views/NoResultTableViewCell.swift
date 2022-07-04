//
//  NoResultTableViewCell.swift
//  Alyx-dev
//
//  Created by CDI on 3/30/22.
//

import UIKit

class NoResultTableViewCell: UITableViewCell {
    static let identifier = "QueueTableViewCell"
    
    private let label: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.numberOfLines = 0
        label.textColor = Constants.blackLabelColor
        label.textAlignment = .left
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(label)
        
        contentView.clipsToBounds = true
        backgroundColor = Constants.whiteBackgroundColor
        
        accessoryType = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        label.frame = CGRect(
            x: 15,
            y: 0,
            width: contentView.width - 30,
            height: contentView.height)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        label.text = nil
    }
    
    func configure(with message: String) {
        label.text = message
    }
    
}
