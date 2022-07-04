//
//  CashDrawerTableViewCell.swift
//  Jeeves-dev
//
//  Created by Jervy Umandap on 2/4/22.
//

import UIKit

class CashDrawerTableViewCell: UITableViewCell {
    static let idenditifier = "CashDrawerTableViewCell"
    
    public var billAmount: Double = 0
    
    public let billLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = Constants.blackLabelColor
        label.font = .systemFont(ofSize: 20, weight: .medium)
        label.text = "Bill"
        label.textAlignment = .right
        return label
    }()
    
    public let timesLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = Constants.blackLabelColor
        label.font = .systemFont(ofSize: 20, weight: .thin)
        label.text = "x"
        label.textAlignment = .center
        return label
    }()
    
    public let billCountTextField: UITextField = {
        let textField = UITextField(frame: .zero)
        textField.textColor = Constants.blackLabelColor
        textField.backgroundColor = Constants.vcBackgroundColor
        
        textField.textAlignment = .left
        textField.borderStyle = .roundedRect
        textField.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        textField.placeholder = "0"
        textField.autocorrectionType = .no
        textField.returnKeyType = .default
        textField.keyboardType = .numberPad
        
        textField.attributedPlaceholder = NSAttributedString(
            string: "0",
            attributes: [NSAttributedString.Key.foregroundColor : Constants.lightGrayColor])
        
        return textField
    }()
    
    public let equalLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = Constants.blackLabelColor
        label.font = .systemFont(ofSize: 20, weight: .thin)
        label.text = "="
        label.textAlignment = .center
        return label
    }()
     
    public let totalLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = Constants.blackLabelColor
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.text = "Total"
        label.textAlignment = .right
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = Constants.whiteBackgroundColor
        
        contentView.addSubview(billLabel)
        contentView.addSubview(timesLabel)
        contentView.addSubview(billCountTextField)
        contentView.addSubview(equalLabel)
        contentView.addSubview(totalLabel)
        
        billCountTextField.delegate = self
        
        addDoneButtonOnKeyboard()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let labelWidth = contentView.width/4
        
        billCountTextField.frame = CGRect(
            x: 16,
            y: 5,
            width: labelWidth,
            height: contentView.height-10)
        
        timesLabel.frame = CGRect(
            x: billCountTextField.right+10,
            y: 5,
            width: 15,
            height: contentView.height-10)
        
        billLabel.frame = CGRect( //billLabel
            x: timesLabel.right+10,
            y: 5,
            width: labelWidth,
            height: contentView.height-10)
        
        equalLabel.frame = CGRect(
            x: billLabel.right+10,
            y: 5,
            width: 15,
            height: contentView.height-10)
        
        totalLabel.frame = CGRect(
            x: equalLabel.right+10,
            y: 5,
            width: contentView.width-billLabel.width-10-timesLabel.width-10-billCountTextField.width-10-equalLabel.width-10-32,
            height: contentView.height-10)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        billLabel.text = nil
        timesLabel.text = nil
//        billCountTextField.text = "0"
        equalLabel.text = nil
        totalLabel.text = nil
    }
    
    func configure(with viewModel: CashDrawerTableViewCellViewModel) {
        billLabel.text = String(format:"₱%.2f", viewModel.bill)
        timesLabel.text = "x"
//        billCountTextField.text = String(describing: viewModel.count)
        equalLabel.text = "="
        let total = viewModel.bill * Double(viewModel.count ?? 0)
        totalLabel.text = String(format:"₱%.2f", total)
        billAmount = viewModel.bill
    }
    
    public func addDoneButtonOnKeyboard() {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        doneToolbar.isTranslucent = true
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonAction))
        done.tintColor = .label

        let items = NSMutableArray()
        items.add(flexSpace)
        items.add(done)

        doneToolbar.items = items as? [UIBarButtonItem]
        doneToolbar.sizeToFit()

        billCountTextField.inputAccessoryView = doneToolbar
    }
    
    @objc public func doneButtonAction() {
        print("done button tapped")
        switch billCountTextField.tag {
        case 0:
            billCountTextField.resignFirstResponder()
            print("\(billCountTextField.tag) resigned")
            
            if billCountTextField.tag == 1 {
                billCountTextField.becomeFirstResponder()
            }
        case 1:
            billCountTextField.resignFirstResponder()
            print("\(billCountTextField.tag) resigned")
            
            if billCountTextField.tag == 2 {
                billCountTextField.becomeFirstResponder()
            }
        case 2:
            billCountTextField.resignFirstResponder()
            print("\(billCountTextField.tag) resigned")
            
            if billCountTextField.tag == 3 {
                billCountTextField.becomeFirstResponder()
            }
        default:
            billCountTextField.resignFirstResponder()
            print("\(billCountTextField.tag) resigned")
        }
    }

}

extension CashDrawerTableViewCell: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        print("textFieldShouldReturn")
//        let nextTag = textField.tag+1
//
//        if let nextTextField = textField.superview?.viewWithTag(textField.tag+1) as? UITextField {
//            nextTextField.becomeFirstResponder()
//        } else {
//            resignFirstResponder()
//        }
        
//        switch textField.tag {
//        case 0:
//            if textField.tag == 0 {
//                print("textField",textField.tag)
//                textField.t
//            }
//        case 1:
//            if textField.tag == 2 {
//                print("textField",textField.tag)
//                becomeFirstResponder()
//            }
//        case 2:
//            if textField.tag == 3 {
//                print("textField",textField.tag)
//                becomeFirstResponder()
//            }
//        default:
//            resignFirstResponder()
//        }
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
//        print("textFieldShouldEndEditing: \(textField.tag)")
        
        return true
    }
}
