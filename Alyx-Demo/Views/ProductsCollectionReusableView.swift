//
//  ProductsCollectionReusableView.swift
//  Jeeves-dev
//
//  Created by Jervy Umandap on 2/4/22.
//


import UIKit

class ProductsCollectionReusableView: UICollectionReusableView {
    static let identifier = "ProductsCollectionReusableView"
    
    private let sectionHeaderlabel: UILabel = {
        let label = UILabel()
        label.textColor = Constants.blackLabelColor
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        return label
    }()
    
    private let resultLabel: UILabel = {
        let label = UILabel()
        label.textColor = Constants.secondaryLabelColor
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textAlignment = .right
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        addSubview(sectionHeaderlabel)
        addSubview(resultLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        sectionHeaderlabel.frame = CGRect(
            x: 4,
            y: 0,
            width: (width/2)-4,
            height: height)
//        sectionHeaderlabel.backgroundColor = .red
        
        resultLabel.frame = CGRect(
            x: sectionHeaderlabel.right,
            y: 0,
            width: (width/2)-4,
            height: height)
//        resultLabel.backgroundColor = .green
    }
    
    func configure(sectionTitle: String, categoryName: String, resultCount: Int) {
        sectionHeaderlabel.text = sectionTitle
        resultLabel.text = resultCount > 1 ? "\(resultCount) Results" : "\(resultCount) Result"
    }
    
}
