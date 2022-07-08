//
//  ContactUsViewController.swift
//  Alyx-Demo
//
//  Created by CDI on 7/4/22.
//

import UIKit

class ContactUsViewController: UIViewController, UITextFieldDelegate {
    
    private var contactUsField = [String]()
    
    private let container: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.layer.masksToBounds = true
        return view
    }()
    
    private let headerLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = Constants.blackLabelColor
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.font = .italicSystemFont(ofSize: 20)
        label.text = "Let's have a talk!"
        label.textAlignment = .center
        return label
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = Constants.blackLabelColor
        label.font = .systemFont(ofSize: 14, weight: .bold)
        label.text = "Name"
        label.textAlignment = .left
        return label
    }()
    
    private let contactLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = Constants.blackLabelColor
        label.font = .systemFont(ofSize: 14, weight: .bold)
        label.text = "Contact No."
        label.textAlignment = .left
        return label
    }()
    
    private let emailLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = Constants.blackLabelColor
        label.font = .systemFont(ofSize: 14, weight: .bold)
        label.text = "Email"
        label.textAlignment = .left
        return label
    }()
    
    private let companyLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = Constants.blackLabelColor
        label.font = .systemFont(ofSize: 14, weight: .bold)
        label.text = "Business/Company Name (Optional)"
        label.textAlignment = .left
        return label
    }()
    
    private let locationLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = Constants.blackLabelColor
        label.font = .systemFont(ofSize: 14, weight: .bold)
        label.text = "Location/Address (Optional)"
        label.textAlignment = .left
        return label
    }()
    
    private let nameTextField: UITextField = {
        let textField = UITextField(frame: .zero)
        textField.textAlignment = .left
        textField.borderStyle = .roundedRect
        textField.font = UIFont.systemFont(ofSize: 16, weight: .regular)
//        textField.placeholder = "Username"
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.backgroundColor = Constants.whiteBackgroundColor
        textField.textColor = Constants.blackLabelColor
        
        textField.attributedPlaceholder = NSAttributedString(
            string: "Enter name",
            attributes: [NSAttributedString.Key.foregroundColor : Constants.lightGrayColor])
        
        return textField
    }()
    
    private let contactTextField: UITextField = {
        let textField = UITextField(frame: .zero)
        textField.textAlignment = .left
        textField.borderStyle = .roundedRect
        textField.font = UIFont.systemFont(ofSize: 16, weight: .regular)
//        textField.placeholder = "Username"
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.backgroundColor = Constants.whiteBackgroundColor
        textField.textColor = Constants.blackLabelColor
        
        textField.attributedPlaceholder = NSAttributedString(
            string: "Enter contact number",
            attributes: [NSAttributedString.Key.foregroundColor : Constants.lightGrayColor])
        
        return textField
    }()
    
    private let emailTextField: UITextField = {
        let textField = UITextField(frame: .zero)
        textField.textAlignment = .left
        textField.borderStyle = .roundedRect
        textField.font = UIFont.systemFont(ofSize: 16, weight: .regular)
//        textField.placeholder = "Username"
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.backgroundColor = Constants.whiteBackgroundColor
        textField.textColor = Constants.blackLabelColor
        
        textField.attributedPlaceholder = NSAttributedString(
            string: "Enter email",
            attributes: [NSAttributedString.Key.foregroundColor : Constants.lightGrayColor])
        
        return textField
    }()
    
    private let companyTextField: UITextField = {
        let textField = UITextField(frame: .zero)
        textField.textAlignment = .left
        textField.borderStyle = .roundedRect
        textField.font = UIFont.systemFont(ofSize: 16, weight: .regular)
//        textField.placeholder = "Username"
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.backgroundColor = Constants.whiteBackgroundColor
        textField.textColor = Constants.blackLabelColor
        
        textField.attributedPlaceholder = NSAttributedString(
            string: "Enter business/company name",
            attributes: [NSAttributedString.Key.foregroundColor : Constants.lightGrayColor])
        
        return textField
    }()
    
    private let locationTextField: UITextField = {
        let textField = UITextField(frame: .zero)
        textField.textAlignment = .left
        textField.borderStyle = .roundedRect
        textField.font = UIFont.systemFont(ofSize: 16, weight: .regular)
//        textField.placeholder = "Username"
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.backgroundColor = Constants.whiteBackgroundColor
        textField.textColor = Constants.blackLabelColor
        
        textField.attributedPlaceholder = NSAttributedString(
            string: "Enter location/address",
            attributes: [NSAttributedString.Key.foregroundColor : Constants.lightGrayColor])
        
        return textField
    }()
    
    private let submitButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = Constants.blackBackgroundColor
        button.setTitle("Submit Details", for: .normal)
        button.setTitleColor(Constants.whiteLabelColor, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 16)
        button.layer.cornerRadius = 5.0
        button.layer.masksToBounds = true
        return button
    }()
    
    
    private let footerLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = Constants.darkGrayColor
        label.font = .systemFont(ofSize: 12, weight: .light)
        label.font = .italicSystemFont(ofSize: 12)
        label.text = "Upon submitting your details, our sales team\nwill contact you within 1-2 business days."
        label.textAlignment = .center
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Constants.vcBackgroundColor// .red

        // Do any additional setup after loading the view.
        view.addSubview(container)
        container.addSubview(headerLabel)
        
        container.addSubview(nameLabel)
        container.addSubview(nameTextField)
        
        container.addSubview(contactLabel)
        container.addSubview(contactTextField)
        
        container.addSubview(emailLabel)
        container.addSubview(emailTextField)
        
        container.addSubview(companyLabel)
        container.addSubview(companyTextField)
        
        container.addSubview(locationLabel)
        container.addSubview(locationTextField)
        
        view.addSubview(footerLabel)
        view.addSubview(submitButton)
        
        nameTextField.delegate = self
        contactTextField.delegate = self
        emailTextField.delegate = self
        companyTextField.delegate = self
        locationTextField.delegate = self
        
        submitButton.addTarget(self, action: #selector(didTapSubmitForm), for: .touchUpInside)
        
        setupFieldsData()
    }
    
    @objc func didTapSubmitForm() {
        
        guard let demoUserName = nameTextField.text, !demoUserName.isEmpty,
              let demoUserContact = contactTextField.text, !demoUserContact.isEmpty,
              let demoUserEmail = emailTextField.text, !demoUserEmail.isEmpty,
              let demoUserCompany = companyTextField.text,
              let demoUserLocation = locationTextField.text else {
            print("Required inputs!")
            showAlertWith(title: "", message: "Please fill all the required fields", shouldClear: false, style: .alert)
            return
        }
        
        let alert = UIAlertController(title: "Submit Form", message: "You are about to submit your details to Alyx Team", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Proceed", style: .default, handler: { [weak self] action in
            
            APICaller.shared.postForm(with: demoUserName, with: demoUserContact, with: demoUserEmail, with: demoUserCompany, with: demoUserLocation) { result in
                switch result {
                case .success(let model):
                    print("didTapSubmitForm: \(model.data.message)")
                    self?.showAlertWith(title: nil, message: "\(model.message)", shouldClear: true, style: .alert)
                    break
                case .failure(let error):
                    print("didTapSubmitForm: \(error.localizedDescription)")
                    self?.showAlertWith(title: "Error submitting form", message: "Please check internet connection and try again", shouldClear: false, style: .alert)
                    break
                }
            }
        }))
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    private func showAlertWith(title: String?, message: String?, shouldClear: Bool?, style: UIAlertController.Style = .alert) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: style)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: { [weak self] action in
            self?.shouldClearFields(shouldClear: shouldClear ?? false)
        }))
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    private func setupFieldsData() {
        contactUsField.removeAll()
        contactUsField.append("Name")
        contactUsField.append("Contact No.")
        contactUsField.append("Email")
        contactUsField.append("Business/Company (Optional)")
        contactUsField.append("Location/Address (Optional)")
    }
    
    private func shouldClearFields(shouldClear: Bool) {
        
        if shouldClear {
            nameTextField.text = nil
            contactTextField.text = nil
            emailTextField.text = nil
            companyTextField.text = nil
            locationTextField.text = nil
        }
    }
    
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        container.frame = CGRect(
            x: 10 + view.safeAreaInsets.left,
            y: 10,
            width: view.width - 20 - view.safeAreaInsets.left - view.safeAreaInsets.right,
            height: view.height / 1.7)
//        container.backgroundColor = .red
        
        let headerHeight: CGFloat = 50
        let labelHeight: CGFloat = 30
        let fieldHeight = (container.height - headerHeight - (labelHeight*5)) / 5
        let submitButtonHeight: CGFloat = 44.0
//        let fieldHeight: CGFloat = 44
        
        headerLabel.frame = CGRect(
            x: 0,
            y: 0,
            width: container.width,
            height: headerHeight)
        
        nameLabel.frame = CGRect(
            x: 0,
            y: headerLabel.bottom,
            width: container.width,
            height: labelHeight)
        
        nameTextField.frame = CGRect(
            x: 0,
            y: nameLabel.bottom,
            width: container.width,
            height: fieldHeight)
        
        contactLabel.frame = CGRect(
            x: 0,
            y: nameTextField.bottom,
            width: container.width,
            height: labelHeight)
        
        contactTextField.frame = CGRect(
            x: 0,
            y: contactLabel.bottom,
            width: container.width,
            height: fieldHeight)
        
        emailLabel.frame = CGRect(
            x: 0,
            y: contactTextField.bottom,
            width: container.width,
            height: labelHeight)
        
        emailTextField.frame = CGRect(
            x: 0,
            y: emailLabel.bottom,
            width: container.width,
            height: fieldHeight)
        
        companyLabel.frame = CGRect(
            x: 0,
            y: emailTextField.bottom,
            width: container.width,
            height: labelHeight)
        
        companyTextField.frame = CGRect(
            x: 0,
            y: companyLabel.bottom,
            width: container.width,
            height: fieldHeight)
        
        locationLabel.frame = CGRect(
            x: 0,
            y: companyTextField.bottom,
            width: container.width,
            height: labelHeight)
        
        locationTextField.frame = CGRect(
            x: 0,
            y: locationLabel.bottom,
            width: container.width,
            height: fieldHeight)
        
        
        submitButton.frame = CGRect(
            x: 10 + view.safeAreaInsets.left,
            y: view.height - submitButtonHeight - view.safeAreaInsets.bottom - 10,
            width: view.width - 20 - view.safeAreaInsets.left - view.safeAreaInsets.right,
            height: submitButtonHeight)
        
        footerLabel.frame = CGRect(
            x: 10,
            y: submitButton.top - submitButtonHeight - 10,
            width: view.width - 20,
            height: submitButtonHeight)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }

}
