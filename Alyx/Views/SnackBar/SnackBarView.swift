//
//  SnackBarView.swift
//  Jeeves-dev
//
//  Created by CDI on 3/28/22.
//

import UIKit

class SnackBarView: UIView {
    
    let viewModel: SnackBarViewModel
    
    private var handler: SnackBarHandler?
    
    private let label: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .label
        
        return imageView
    }()
    
    init(viewModel: SnackBarViewModel, frame: CGRect) {
        self.viewModel = viewModel
        super.init(frame: frame)
        
        addSubview(label)
        if viewModel.image != nil {
            addSubview(imageView)
        }
        
        backgroundColor = .systemGreen
        
        clipsToBounds = true
        layer.cornerRadius = 20
        layer.masksToBounds = true
        
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        label.text = viewModel.text
        imageView.image = viewModel.image
        
        switch viewModel.type {
        case .action(let handler):
            self.handler = handler
            
            isUserInteractionEnabled = true
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapSnackBar))
            tapGesture.numberOfTapsRequired = 1
            tapGesture.numberOfTouchesRequired = 1
        case .info:
            break
        }
    }
    
    @objc private func didTapSnackBar() {
        print("didTapSnackBar")
        handler?()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if viewModel.image != nil {
            // label, image
            imageView.frame = CGRect(
                x: 0,
                y: 0,
                width: frame.height,
                height: frame.height)
            label.frame = CGRect(
                x: imageView.right,
                y: 0,
                width: frame.width-imageView.width,
                height: frame.height)
            
        } else {
            label.frame = bounds
        }
    }
}
