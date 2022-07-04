//
//  CircularCheckBox.swift
//  Jeeves-dev
//
//  Created by Jervy Umandap on 2/4/22.
//

import UIKit

class CircularCheckBox: UIView {
    
    public var isChecked = false
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.tintColor = Constants.secondaryDarkLabelColor
        
        imageView.isHidden = true
        if #available(iOS 13.0, *) {
            imageView.image = UIImage(systemName: "checkmark.circle.fill")
        } else {
            // Fallback on earlier versions
        }
        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = Constants.whiteBackgroundColor
        
        addSubview(imageView)
        
        layer.borderWidth = 1.0
        layer.borderColor = Constants.lightGrayBorderColor.cgColor
        layer.cornerRadius = frame.width/2
        
        clipsToBounds = true
        layer.masksToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = bounds
    }
    
    func toggleCheck() {
        self.isChecked = !isChecked
        imageView.isHidden = !isChecked
        print(isChecked)
//        circularCheckBoxDelegate?.didChangeCheckBox(isChecked: isChecked)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
    }
    
}



class DeleteButton: UIView {
//    public var handler: () -> Void?
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = Constants.systemRedColor
    
        if #available(iOS 13.0, *) {
            imageView.image = UIImage(systemName: "trash")
        } else {
            // Fallback on earlier versions
        }
        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = Constants.whiteBackgroundColor
        
        addSubview(imageView)
        
        layer.borderWidth = 0.5
        layer.borderColor = Constants.lightGrayBorderColor.cgColor
        layer.cornerRadius = frame.width/2
        
        clipsToBounds = true
        layer.masksToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = CGRect(
            x: 5,
            y: 5,
            width: width-10,
            height: height-10)
    }
    
    func handleDelete() {
        print("Deleting...")
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
    }
    
}



class TagButton: UIView {
//    public var handler: () -> Void?
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = Constants.blackLabelColor
    
        if #available(iOS 13.0, *) {
            imageView.image = UIImage(systemName: "tag.fill")
        } else {
            // Fallback on earlier versions
        }
        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = Constants.whiteBackgroundColor
        
        addSubview(imageView)
        
        layer.borderWidth = 0.5
        layer.borderColor = Constants.lightGrayBorderColor.cgColor
        layer.cornerRadius = frame.width/2
        
        clipsToBounds = true
        layer.masksToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = CGRect(
            x: 5,
            y: 5,
            width: width-10,
            height: height-10)
    }
    
    func handleTap() {
        print("DidTap tag...")
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
    }
    
}
