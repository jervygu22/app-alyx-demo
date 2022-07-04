//
//  ShiftOptionsTableViewCell.swift
//  Jeeves-dev
//
//  Created by Jervy Umandap on 2/4/22.
//

import UIKit

class ShiftOptionsTableViewCell: UITableViewCell {
    static let identifier = "ShiftOptionsTableViewCell"
    
//    public let optionButton: UIButton = {
//        let button = UIButton(frame: .zero)
//        button.backgroundColor = Constants.lightGrayBorderColor
//        button.setTitle("Option", for: .normal)
//        button.setTitleColor(.label, for: .normal)
//        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
//        button.layer.cornerRadius = 5.0
//        button.layer.masksToBounds = true
//        return button
//    }()
    
    private let collectionView: UICollectionView = {
        let collection = UICollectionView(
            frame: .zero,
            collectionViewLayout: UICollectionViewCompositionalLayout { (sectionIndex, _) -> NSCollectionLayoutSection? in
                return CartViewController.createBottomContainerCollectionLayout(section: sectionIndex)
            })
        collection.bounces = false
        collection.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collection.backgroundColor = Constants.whiteBackgroundColor
        return collection
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = Constants.whiteBackgroundColor
//        contentView.addSubview(optionButton)
        contentView.addSubview(collectionView)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
//        let optionButtonWidth = contentView.width/3
//        optionButton.frame = CGRect(
//            x: 20,
//            y: 10,
//            width: optionButtonWidth,
//            height: contentView.height-20)
        collectionView.frame = contentView.bounds
        
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
//        optionButton.titleLabel?.text = nil
        
    }
    
    func configure(with viewModel: ShiftOptionsTableViewCellViewModel) {
//        optionButton.setTitle(viewModel.name, for: .normal)
    }
}

extension ShiftOptionsTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        cell.backgroundColor = .red
        return cell
    }
    
    
}

struct ShiftOptionsTableViewCellViewModel {
    let id: Int
    let name: String
}
