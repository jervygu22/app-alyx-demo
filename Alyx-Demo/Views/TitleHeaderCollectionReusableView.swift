//
//  TitleHeaderCollectionReusableView.swift
//  Jeeves-dev
//
//  Created by Jervy Umandap on 2/4/22.
//


import UIKit

class TitleHeaderCollectionReusableView: UICollectionReusableView {
    static let identifier = "TitleHeaderCollectionReusableView"
    
    private let label: UILabel = {
        let label = UILabel()
        label.textColor = Constants.secondaryDarkLabelColor
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 14, weight: .regular)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        addSubview(label)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        label.frame = CGRect(
            x: 0,
            y: 0,
            width: width,
            height: height)
//        label.backgroundColor = .red
    }
    
    func configure(withTitle title: String) {
        label.text = title
    }
    
}
