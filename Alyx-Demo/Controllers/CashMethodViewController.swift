//
//  CashMethodViewController.swift
//  Jeeves-dev
//
//  Created by Jervy Umandap on 2/4/22.
//

import UIKit
import CoreData

protocol CashMethodViewControllerDelegate: AnyObject {
    func didPostOrder()
}

class CashMethodViewController: UIViewController, UITextFieldDelegate {
    
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    weak var cashMethodViewControllerDelegate: CashMethodViewControllerDelegate?
    
    enum CoreDataError: Error {
        case noAppDelegate
    }
    
    
    public var remarks: String?
    
    private var timer = Timer()
    private var counter: Double = 0
    
    private var surchargesData: [Surcharges_Entity]?
    private var couponsEntity = [Coupons_Entity]()
    
    private var cart = [Cart_Entity]()
//    private var coreDataArray: [NSManagedObject] = []
    private var cartSubTotal: Double = 0 // price sum of regular in cart
    private var appliedDiscountAmount: Double = 0 // price sum of discounted in cart
    private var grandTotal: Double = 0
    
    private var lineItems: [LineItem] = []
    private var discountedPWD: [ValueElement] = []
    private var discountedSenior: [ValueElement] = []
    private var discountedItemsMetaData: [ValueElement] = []
    
    private var surchargeArray: [SurchargeData] = []
    
    private var fetchedCoupons: [CouponData] = []
    
    private var surchargeData: [SurchargeData]?
    private var orderToPost: PostOrderModel?
    
    private var updateCoupons = [UpdateCouponDataModel]()
    
    private var isUpdateCouponFinished: Bool = false
    
    private let cashTenderedTextField: UITextField = {
        let textField = UITextField(frame: .zero)
        textField.textAlignment = .right
        textField.borderStyle = .roundedRect
        textField.font = UIFont.systemFont(ofSize: 24, weight: .regular)
//        textField.placeholder = "0.00"// "₱ 0.00"
        textField.autocorrectionType = .no
        textField.keyboardType = .decimalPad
        textField.setLeftView(image: UIImage(systemName: "pesosign.square.fill")!)
        
        textField.backgroundColor = Constants.whiteBackgroundColor
        textField.textColor = Constants.blackLabelColor
        
        textField.attributedPlaceholder = NSAttributedString(
            string: "0.00",
            attributes: [NSAttributedString.Key.foregroundColor : Constants.lightGrayColor])
        
        return textField
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        tableView.register(CashPaymentTableViewCell.self, forCellReuseIdentifier: CashPaymentTableViewCell.identifier)
        
        tableView.register(CashPaymentHeaderTableViewCell.self, forCellReuseIdentifier: CashPaymentHeaderTableViewCell.identifier)
        
        tableView.isHidden = false
        tableView.separatorStyle = .none
        tableView.backgroundColor = Constants.whiteBackgroundColor
        return tableView
    }()
    
    // bottom view
    private let bottomContainer: UIView = {
        let container = UIView(frame: .zero)
        container.layer.masksToBounds = true
        container.clipsToBounds = true
        return container
    }()
    
    // MARK: - labels
    private let subTotalLabel: UILabel = {
        let label = UILabel()
        label.textColor = Constants.secondaryDarkLabelColor
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.text = "Subtotal"
        label.textAlignment = .left
        return label
    }()
    
    private let vatableSalesLabel: UILabel = {
        let label = UILabel()
        label.textColor = Constants.secondaryDarkLabelColor
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.text = "Vatable Sales"
        label.textAlignment = .left
        return label
    }()
    
    private let vatExemptLabel: UILabel = {
        let label = UILabel()
        label.textColor = Constants.secondaryDarkLabelColor
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.text = "Vat Exempt Sales"
        label.textAlignment = .left
        return label
    }()
    
    private let surchargeLabel: UILabel = {
        let label = UILabel()
        label.textColor = Constants.secondaryDarkLabelColor
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.text = "Surcharge"
        label.textAlignment = .left
        return label
    }()
    
    private let vatLabel: UILabel = {
        let label = UILabel()
        label.textColor = Constants.secondaryDarkLabelColor
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.text = "Vat (12%)"
        label.textAlignment = .left
        return label
    }()
    
    private let seniorPwdDiscountLabel: UILabel = {
        let label = UILabel()
        label.textColor = Constants.secondaryDarkLabelColor
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.text = "Senior/PWD Discount"
        label.textAlignment = .left
        return label
    }()
    
    private let totalLabel: UILabel = {
        let label = UILabel()
        label.textColor = Constants.blackLabelColor
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.text = "Total"
        label.textAlignment = .left
        return label
    }()
    
    private let cashTenderedLabel: UILabel = {
        let label = UILabel()
        label.textColor = Constants.secondaryDarkLabelColor
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.text = "Cash Tendered"
        label.textAlignment = .left
        return label
    }()

    private let changeLabel: UILabel = {
        let label = UILabel()
        label.textColor = Constants.blackLabelColor
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.text = "Change"
        label.textAlignment = .left
        return label
    }()
    
    
    // MARK: - Value labels
    private let subTotalValueLabel: UILabel = {
        let label = UILabel()
        label.textColor = Constants.secondaryDarkLabelColor
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textAlignment = .right
        return label
    }()
    
    private let vatableSalesValueLabel: UILabel = {
        let label = UILabel()
        label.textColor = Constants.secondaryDarkLabelColor
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textAlignment = .right
        return label
    }()
    
    private let vatExemptValueLabel: UILabel = {
        let label = UILabel()
        label.textColor = Constants.secondaryDarkLabelColor
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textAlignment = .right
        return label
    }()
    
    private let surchargeValueLabel: UILabel = {
        let label = UILabel()
        label.textColor = Constants.secondaryDarkLabelColor
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textAlignment = .right
        return label
    }()
    
    private let vatValueLabel: UILabel = {
        let label = UILabel()
        label.textColor = Constants.secondaryDarkLabelColor
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textAlignment = .right
        return label
    }()
    
    private let seniorPwdDiscountValueLabel: UILabel = {
        let label = UILabel()
        label.textColor = Constants.secondaryDarkLabelColor
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textAlignment = .right
        return label
    }()
    
    private let totalValueLabel: UILabel = {
        let label = UILabel()
        label.textColor = Constants.blackLabelColor
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textAlignment = .right
        return label
    }()
    
    private let cashTenderedValueLabel: UILabel = {
        let label = UILabel()
        label.textColor = Constants.secondaryDarkLabelColor
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textAlignment = .right
        return label
    }()
    
    private let changeValueLabel: UILabel = {
        let label = UILabel()
        label.textColor = Constants.blackLabelColor
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textAlignment = .right
        return label
    }()
    
    private let submitButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = Constants.blackBackgroundColor
        button.setTitle("Submit", for: .normal)
        button.setTitleColor(Constants.whiteLabelColor, for: .normal)
        button.setTitleColor(Constants.lightGrayColor, for: .disabled)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.layer.cornerRadius = 5.0
        button.layer.masksToBounds = true
        return button
    }()
    
    private let demoLabelContainer: UIView = {
        let view = UIView(frame: .zero)
//        view.layer.masksToBounds = true
//        view.clipsToBounds = true
        view.transform = CGAffineTransform(rotationAngle: -CGFloat.pi / 4)
        return view
    }()
    
    private let demoLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = Constants.whiteLabelColor
        label.font = .systemFont(ofSize: 18, weight: .heavy)
        label.text = "DEMO"
        label.textAlignment = .center
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        title = "Cash Amount"
        view.backgroundColor = Constants.whiteBackgroundColor
        
        getAllItems()
        getCouponsEntity()
        getSurcharges()
        
        tableView.delegate = self
        tableView.dataSource = self
        cashTenderedTextField.delegate = self
        view.addSubview(cashTenderedTextField)
        view.addSubview(tableView)
        
        view.addSubview(bottomContainer)
        
        configureBottomContainer()
        configureBottomContainerData()
        
        let tapAny: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboardByTappingOutside))
        view.addGestureRecognizer(tapAny)
        
//        cashTenderedTextField.addTarget(self, action: #selector(myTextFieldDidChange), for: .editingChanged)
        
        isDeviceAuthorized()
        let discountCode = couponsEntity.first(where: { $0.coupon_title?.lowercased() == "pwd" })?.coupon_id
        print("getCouponsEntity: \(discountCode)")
        
        createPostOrderObject()
        let isDemo = UserDefaults.standard.bool(forKey: Constants.is_demo_build)
        if isDemo {
            addDemoLabel()
        }
    }
    
    private func addDemoLabel() {
        view.addSubview(demoLabelContainer)
        demoLabelContainer.addSubview(demoLabel)
    }
    
    private func layoutDemoLabel() {
        let demoLabelContainerHeight: CGFloat = 30
        let demoLabelContainerWidth = demoLabelContainerHeight * 2
        demoLabelContainer.frame = CGRect(
            x: view.width-demoLabelContainerWidth,
            y: view.height-demoLabelContainerWidth,
            width: demoLabelContainerWidth,
            height: demoLabelContainerHeight*2)
        demoLabelContainer.backgroundColor = .gray
        
        demoLabel.sizeToFit()
        demoLabel.frame = CGRect(
            x: -(demoLabelContainerWidth*1.5),
            y: demoLabelContainerHeight/1.5,
            width: demoLabelContainerWidth*3,
            height: demoLabelContainerHeight)
        demoLabel.backgroundColor = .systemRed
//        demoLabel.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        demoLabel.backgroundColor = UIColor.red.withAlphaComponent(0.75)
    }
    
    
    
    @objc func hideKeyboardByTappingOutside() {
        print("hideKeyboardByTappingOutside")
        view.endEditing(true)
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(UpdateTimer), userInfo: nil, repeats: true)
    }
    
    @objc func UpdateTimer() {
        counter += 1
    }
    
    private func calculateTotal(with totalSurcharge: Double){
        cartSubTotal = 0 // refresh to zero
        appliedDiscountAmount = 0
        
        var allVatableSales: Double = 0
        var allVatExemptSales: Double = 0
        var allVat12Amount: Double = 0
        var rawGrandTotal: Double = 0
        
        print("cart: ", cart)
        for item in cart {
            
//            let inclusiveVatRate = 1.12
//            let vatRate = item.cart_tax_class == "" ? 0.12 : 0
//            let vatableSales = (item.cart_product_cost / inclusiveVatRate) * Double(item.cart_quantity)
//            let roundedVatableSales = Double(round(100 * vatableSales) / 100)
//
//            let vat12Amount = vatableSales * vatRate
//            let roundedVat12Amount = Double(round(100 * vat12Amount) / 100)
//
//            let discountAmount = vatableSales * item.cart_discount
//            let roundedDiscountAmount = Double(round(100 * discountAmount) / 100)
//
//            let subTotal = (vatableSales + vat12Amount) - discountAmount
//            let roundedSubTotal = Double(round(100 * subTotal) / 100)
            
            let inclusiveVatRate = 1.12
            let vatRate = item.cart_tax_class == "" ? 0.12 : 0
            
            let vatableSales = item.cart_discount == 0 ? (item.cart_product_cost / inclusiveVatRate) * Double(item.cart_quantity) : 0
            let vatExemptSales = item.cart_discount == 0 ? 0 : (item.cart_product_cost / inclusiveVatRate) * Double(item.cart_quantity)
            
            let vatableSalesForGrandtotal = (item.cart_product_cost / inclusiveVatRate) * Double(item.cart_quantity)
            let roundedVatableSalesForGrandtotal = Double(round(100 * vatableSalesForGrandtotal) / 100)
 
            let roundedVatableSales = Double(round(100 * vatableSales) / 100)
            let roundedVatExemptSales = Double(round(100 * vatExemptSales) / 100)
            
            let vat12Amount = vatableSales * vatRate
            let roundedVat12Amount = Double(round(100 * vat12Amount) / 100)
            
            let vat12AmountForGrandTotal = vatableSalesForGrandtotal * vatRate
            let roundedVat12AmountForGrandTotal = Double(round(100 * vat12AmountForGrandTotal) / 100)
            
            let discountAmount = (vatableSales + vatExemptSales) * item.cart_discount
            let roundedDiscountAmount = Double(round(100 * discountAmount) / 100)
            
            let discountAmountForGrandTotal = vatableSalesForGrandtotal * item.cart_discount
            let roundedDiscountAmountForGrandTotal = Double(round(100 * discountAmountForGrandTotal) / 100)
            
            // grandTotal = vatableSalesForGrandtotal + vat12 - discountAmountForGrandTotal
            
            
//            let subTotal = (vatableSales + vatExemptSales + vat12Amount) - discountAmount
            let subTotal = item.cart_product_cost * Double(item.cart_quantity)
            let roundedSubTotal = Double(round(100 * subTotal) / 100)
            
            
            allVatableSales += roundedVatableSales //vatableSales
            allVatExemptSales += roundedVatExemptSales
            allVat12Amount += roundedVat12Amount //vat12Amount
            
            appliedDiscountAmount += roundedDiscountAmount
            cartSubTotal += roundedSubTotal
            
//            rawGrandTotal += (vatableSalesForGrandtotal + vat12AmountForGrandTotal) - discountAmountForGrandTotal
            rawGrandTotal += (roundedVatableSalesForGrandtotal + roundedVat12AmountForGrandTotal) - roundedDiscountAmountForGrandTotal
            
            print("\(item.cart_variation_name ?? "") roundedVatableSales: ", roundedVatableSales)
            print("\(item.cart_variation_name ?? "") roundedVatExemptSales: ", roundedVatExemptSales)
//            print("\(item.cart_variation_name ?? "") roundedVat12Amount: ", roundedVat12Amount)
//            print("\(item.cart_variation_name ?? "") roundedDiscountAmount: ", roundedDiscountAmount)
//            print("subTotal: ", subTotal)
//            print("\(item.cart_variation_name ?? "") roundedSubTotal: ", roundedSubTotal)
//            print("cartSubTotal: \(cartSubTotal)")
        }
          
        print("priceSum: \(cartSubTotal), totalSurcharges: \(totalSurcharge)")
        cartSubTotal = Double(round(100 * cartSubTotal) / 100)
        
        print("cartSubTotal: \(cartSubTotal) + totalSurcharges: \(totalSurcharge) = \(cartSubTotal+totalSurcharge)")
//        let rawGrandTotal = cartSubTotal + totalSurcharge
        rawGrandTotal += totalSurcharge
        
//        grandTotal = cartSubTotal + totalSurcharge
        grandTotal = Double(round(100 * rawGrandTotal) / 100)
        
        print("cartSubTotal: \(cartSubTotal)")
        print("totalSurcharge: \(totalSurcharge)")
        print("grandTotal: \(grandTotal)")
        
        DispatchQueue.main.async {
            self.subTotalValueLabel.text = String(format:"₱%.2f", self.cartSubTotal)
            self.vatableSalesValueLabel.text = String(format:"₱%.2f", allVatableSales)
            self.vatExemptValueLabel.text = String(format:"₱%.2f", allVatExemptSales)
            self.vatValueLabel.text = String(format:"₱%.2f", allVat12Amount )
            self.seniorPwdDiscountValueLabel.text = String(format:"₱%.2f", self.appliedDiscountAmount)
            self.surchargeValueLabel.text = String(format:"₱%.2f", totalSurcharge)
            self.totalValueLabel.text = String(format:"₱%.2f", self.grandTotal)
            self.cashTenderedTextField.placeholder = String(format:"%.2f", self.grandTotal)
        }
        
    }
    
    @objc func myTextFieldDidChange(_ textField: UITextField) {
        if let amountString = textField.text?.currencyInputFormatting() {
            textField.text = amountString
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        guard let cash = cashTenderedTextField.text, !cash.isEmpty,
              let doubledCash = Double(cash)
              else { return }
        
        var totalSurcharges: Double = 0
        
        if let surcharges = surchargeData {
            surcharges.forEach({ item in
                totalSurcharges += Double(item.amount)
            })
        }
        
        if textField == cashTenderedTextField {
            cashTenderedValueLabel.text = String(format:"₱%.2f", doubledCash)  //"₱\(cashTenderedTextField.text ?? "0.00")"
            let change = doubledCash - grandTotal //(priceSum+totalSurcharges)
            changeValueLabel.text = String(format:"₱%.2f", change) //"₱\(doubledCash - priceSum)"
        } else {
            
        }
    }
    
    
    func configureBottomContainer() {
        bottomContainer.addSubview(subTotalLabel)
        bottomContainer.addSubview(        vatableSalesLabel)
        bottomContainer.addSubview(vatExemptLabel)
        bottomContainer.addSubview(surchargeLabel)
        bottomContainer.addSubview(vatLabel)
        bottomContainer.addSubview(seniorPwdDiscountLabel)
        bottomContainer.addSubview(totalLabel)
        bottomContainer.addSubview(cashTenderedLabel)
        bottomContainer.addSubview(changeLabel)
        
        bottomContainer.addSubview(subTotalValueLabel)
        bottomContainer.addSubview(vatableSalesValueLabel)
        bottomContainer.addSubview(vatExemptValueLabel)
        bottomContainer.addSubview(surchargeValueLabel)
        bottomContainer.addSubview(vatValueLabel)
        bottomContainer.addSubview(seniorPwdDiscountValueLabel)
        bottomContainer.addSubview(totalValueLabel)
        bottomContainer.addSubview(cashTenderedValueLabel)
        bottomContainer.addSubview(changeValueLabel)
        
        bottomContainer.addSubview(submitButton)
        submitButton.addTarget(self, action: #selector(didTapSubmitButton), for: .touchUpInside)
    }
    
    @objc private func didTapSubmitButton() {
        
        var totalSurcharges: Double = 0
        
        if let surcharges = surchargeData {
            surcharges.forEach({ item in
                totalSurcharges += Double(item.amount)
            })
        }
        
        guard let cash = cashTenderedTextField.text, !cash.isEmpty,
              let doubledCash = Double(cash) else {
            
            let alert = UIAlertController(title: "Invalid amount", message: "Please check cash entered.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
            
            // iPad specific code
            alert.popoverPresentationController?.sourceView = self.view
            let xOrigin = self.view.bounds.width / 2 // nil // Replace this with one of the lines at the end
            let yOrigin = self.view.height / 2
            let popoverRect = CGRect(x: xOrigin, y: yOrigin, width: 1, height: 1)
            alert.popoverPresentationController?.sourceRect = popoverRect
            alert.popoverPresentationController?.permittedArrowDirections = .up
            
            present(alert, animated: true, completion: nil)
            return
        }
        
        if doubledCash >= grandTotal { //priceSum + totalSurcharges {
            createPostOrderObject()
            createAlert()
        } else {
            let alert = UIAlertController(title: "Invalid amount", message: "Please check cash entered.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
            
            // iPad specific code
            alert.popoverPresentationController?.sourceView = self.view
            let xOrigin = self.view.bounds.width / 2 // nil // Replace this with one of the lines at the end
            let yOrigin = self.view.height / 2
            let popoverRect = CGRect(x: xOrigin, y: yOrigin, width: 1, height: 1)
            alert.popoverPresentationController?.sourceRect = popoverRect
            alert.popoverPresentationController?.permittedArrowDirections = .up
            
            present(alert, animated: true, completion: nil)
        }
    }
    
    func displayToastMessage(_ message : String) {
        
        let toastView = UILabel()
        toastView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        toastView.textColor = UIColor.white
        toastView.textAlignment = .center
        toastView.font = UIFont.preferredFont(forTextStyle: .caption1)
        toastView.layer.cornerRadius = 8.0 // 25
        toastView.layer.masksToBounds = true
        toastView.text = message
        toastView.numberOfLines = 0
        toastView.alpha = 0
        toastView.translatesAutoresizingMaskIntoConstraints = false
        
        guard let window = UIApplication.shared.mainKeyWindow else {
            return
        }
        window.addSubview(toastView)
        
        let horizontalCenterContraint: NSLayoutConstraint = NSLayoutConstraint(item: toastView, attribute: .centerX, relatedBy: .equal, toItem: window, attribute: .centerX, multiplier: 1, constant: 0)
        
        let widthContraint: NSLayoutConstraint = NSLayoutConstraint(item: toastView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 275)
        
        let verticalContraint: [NSLayoutConstraint] = NSLayoutConstraint.constraints(withVisualFormat: "V:|-(>=200)-[loginView(==50)]-68-|", options: [.alignAllCenterX, .alignAllCenterY], metrics: nil, views: ["loginView": toastView])
        
        NSLayoutConstraint.activate([horizontalCenterContraint, widthContraint])
        NSLayoutConstraint.activate(verticalContraint)
        
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn, animations: {
            toastView.alpha = 1
        }, completion: nil)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double((Int64)(2 * NSEC_PER_SEC)) / Double(NSEC_PER_SEC), execute: {
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn, animations: {
                toastView.alpha = 0
            }, completion: { finished in
                toastView.removeFromSuperview()
            })
        })
    }
    
    private func createAlert() {
        
        let alert = UIAlertController(title: "", message: "Would you like to submit this order?", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { [weak self] _ in
            
            guard let strongSelf = self else { return }
            
            strongSelf.submitButton.isEnabled = false
            strongSelf.submitButton.setTitle("Processing...", for: .disabled)
            strongSelf.startTimer()
            
            strongSelf.navigationController?.navigationBar.isUserInteractionEnabled = false
//            self?.navigationController?.navigationBar.tintColor = UIColor.red
            
            guard let order = strongSelf.orderToPost else {
                let dismissAlert = UIAlertController(title: "", message: "Error submitting order. Please check if you already time in.", preferredStyle: .alert)
                dismissAlert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
                self?.present(dismissAlert, animated: true, completion: nil)
                
                strongSelf.submitButton.isEnabled = true
                strongSelf.submitButton.setTitle("Submit", for: .normal)
                
                strongSelf.timer.invalidate()
                return
            }
            
            print("postOrder from createAlert: ", order)
            // 10 secs checking
//            self?.counter = 30
            
            if strongSelf.counter <= 10 {
                
                if !strongSelf.updateCoupons.isEmpty {
                    print("updateCoupons: ", strongSelf.updateCoupons)
                    DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
                        for item in strongSelf.updateCoupons {
                            strongSelf.putUpdateCoupon(with: item.discount_name, with: order)
                        }
                    })
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
                        strongSelf.putUpdateCoupon(with: nil, with: order)
                    })
                }
                
                
            } else {
                strongSelf.timer.invalidate()
                if let cashTenderedDoubled = Double(strongSelf.cashTenderedTextField.text ?? "0") {
                    strongSelf.updateCartStatus(items: strongSelf.cart, status: "queue", cashTendered: cashTenderedDoubled)
                }
                DispatchQueue.main.async {
                    strongSelf.navigationController?.popToRootViewController(animated: true)
                }
            }
            
        }))
        
        // iPad specific code
        alert.popoverPresentationController?.sourceView = self.view
        let xOrigin = self.view.bounds.width / 2 // nil // Replace this with one of the lines at the end
        let yOrigin = self.view.height / 2
        let popoverRect = CGRect(x: xOrigin, y: yOrigin, width: 1, height: 1)
        alert.popoverPresentationController?.sourceRect = popoverRect
        alert.popoverPresentationController?.permittedArrowDirections = .up
        
        present(alert, animated: true, completion: nil)
    }
    
    
    
    public func isDeviceAuthorized() {
        APICaller.shared.getDevices { result in
            switch result {
            case .success(let model):
                if let deviceID = UserDefaults.standard.string(forKey: "generated_device_id") {
                    if !model.data.contains(where: { $0.device_id == deviceID && $0.device_id_status == true }) {
                        // logout
                        self.showAlertForDeviceAuth()
                    }
                }
                break
            case .failure(let error):
                print("isDeviceAuthorized error: \(error.localizedDescription)")
                break
            }
        }
    }
    
    private func showAlertForDeviceAuth() {
        let alert = UIAlertController(title: "Invalid Device ID", message: "You will be logged out because your device id is invalid.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: { action in
            AuthManager.shared.shouldClearSavedUserData()
            let navVC = UINavigationController(rootViewController: DomainViewController())
            navVC.navigationBar.prefersLargeTitles = false
            navVC.viewControllers.first?.navigationItem.largeTitleDisplayMode = .never
            navVC.modalPresentationStyle = .fullScreen
            navVC.setNavigationBarHidden(true, animated: true)
            DispatchQueue.main.async {
                self.present(navVC, animated: true, completion: {
                    self.navigationController?.popToRootViewController(animated: false)
                })
            }
        }))
        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
    }
    
    func configureBottomContainerData() {
        subTotalValueLabel.text = "₱0.00"
        vatableSalesValueLabel.text = "₱0.00"
        vatExemptValueLabel.text = "₱0.00"
        surchargeValueLabel.text = "₱0.00"
        vatValueLabel.text = "₱0.00" // 12%
        seniorPwdDiscountValueLabel.text = "₱0.00"
        totalValueLabel.text = "₱0.00"
        cashTenderedValueLabel.text = "₱0.00"
        changeValueLabel.text = "₱0.00"
    }
    
    private func stringToInt(with data: String) -> Int {
        return Int(data) ?? 0
    }
    
    private func fetchSurcharge() {
        APICaller.shared.getSurcharges { [weak self] result in
            switch result {
            case .success(let model):
                self?.surchargeData = model
                
                var totalSurcharge: Double = 0
                
                model.forEach({ item in
                    totalSurcharge += Double(item.amount)
                })
                
                self?.calculateTotal(with: totalSurcharge)
                break
            case .failure(let error):
                print(error.localizedDescription)
                break
            }
        }
    }
    
    private func fetchCoupons() {
        APICaller.shared.getCoupons { result in
            switch result {
            case .success(let model):
                self.fetchedCoupons = model
                print("getCoupons from cartVC: \(model)")
                break
            case .failure(let error):
                print("getCoupons error from cartVC: \(error.localizedDescription)")
                break
            }
        }
    }
    
    private func putUpdateCoupon(with code: String?, with order: PostOrderModel) {
        
        print("surchargeArray: ", surchargeArray)
        print("updateCoupons: ", updateCoupons)
        if let discountName = code?.lowercased() {
            print("discountName: \(discountName)")
            
            if let updateCouponDataModel = updateCoupons.first(where: { $0.discount_name.lowercased() == discountName }) {
                print("updateCouponDataModel: \(updateCouponDataModel)")
                
                if let discountCode = couponsEntity.first(where: { $0.coupon_title?.lowercased() == discountName })?.coupon_id {
                    print("discountCode: \(discountCode)")
                    
                    APICaller.shared.updateCouponWithCode(with: "order id", with: Int(discountCode), with: updateCouponDataModel) { [weak self] success in
                        switch success {
                        case true:
                            print("success PWD updateCoupon")
                            
                            APICaller.shared.postOrder(with: order, completion: { success in
                                switch success {
                                case true:
                                    
                                    // if success - reloaddata
                                    self?.timer.invalidate()
                                    
                                    self?.cashMethodViewControllerDelegate?.didPostOrder() // clear cart in cart
                                    self?.cart.removeAll()
                                    DispatchQueue.main.async {
                                        self?.displayToastMessage("Order sent successfully!")
                                        self?.tableView.reloadData()
                                        self?.navigationController?.popToRootViewController(animated: true)
                                    }
                                    break
                                case false:
                                    // if not success - reloaddata, send to queue
                                    print("Failed to post order, instead sent to queue. need to pop to root vc")
                                    // print("cart from failed: ", self?.cart)
                                    break
                                }
                            })
                            break
                        case false:
                            print("failed PWD updateCoupon")
                            
                            self?.timer.invalidate()
                            DispatchQueue.main.async {
                                if let cart = self?.cart,
                                   let cashTenderedDoubled = Double(self?.cashTenderedTextField.text ?? "0") {
                                    self?.displayToastMessage("Order has been queued!")
                                    self?.updateCartStatus(items: cart, status: "queue", cashTendered: cashTenderedDoubled)
                                }
                                self?.navigationController?.popToRootViewController(animated: true)
                            }
                            
                            // if not success - reloaddata, send to queue
                            print("Failed to post order, instead sent to queue. need to pop to root vc")
                            // print("cart from failed: ", self?.cart)
                            break
                        }
                    }
                }
            }
        } else {
            
            APICaller.shared.postOrder(with: order, completion: { [weak self] success in
                switch success {
                case true:
                    
                    // if success - reloaddata
                    self?.timer.invalidate()
                    
                    self?.cashMethodViewControllerDelegate?.didPostOrder() // clear cart in cart
                    self?.cart.removeAll()
                    DispatchQueue.main.async {
                        self?.displayToastMessage("Order sent successfully!")
                        self?.tableView.reloadData()
                        self?.navigationController?.popToRootViewController(animated: true)
                    }
                    break
                case false:
                    self?.timer.invalidate()
                    DispatchQueue.main.async {
                        if let cart = self?.cart,
                           let cashTenderedDoubled = Double(self?.cashTenderedTextField.text ?? "0") {
                            self?.displayToastMessage("Order has been queued!")
                            self?.updateCartStatus(items: cart, status: "queue", cashTendered: cashTenderedDoubled)
                        }
                        self?.navigationController?.popToRootViewController(animated: true)
                    }
                    
                    // if not success - reloaddata, send to queue
                    print("Failed to post order, instead sent to queue. need to pop to root vc")
                    // print("cart from failed: ", self?.cart)
                    break
                }
            })
        }
        
    }
    
    
    
    private func createPostOrderObject() {
        lineItems.removeAll()
        updateCoupons.removeAll()
        surchargeArray.removeAll()
        
//        let regulars = cart.filter({ $0.cart_discount_key == "" })
        
        for item in cart {
            lineItems.append(
                LineItem(
                    product_id: Int(item.cart_product_id),
                    variation_id: Int(item.cart_variation_id),
                    quantity: Int(item.cart_quantity),
                    tax_class: item.cart_tax_class ?? ""))
        }
        
        guard let userID = UserDefaults.standard.string(forKey: "pin_entered_user_id"),
              let shift = UserDefaults.standard.string(forKey: "pin_entered_employee_shift"),
              let deviceID = UserDefaults.standard.string(forKey: "generated_device_id") else {
            print("either userID or shift is nil")
            return
        }
        
        // refactor making metadata for coupons
        var metaDataForCouponsUsed = [MetaData]()
        let discountedItems = cart.filter({ $0.cart_discount_key != "" && $0.cart_tagged_product == 0})
        
        for item in couponsEntity {
            metaDataForCouponsUsed.append(MetaData(
                key: item.coupon_code ?? "",
                value: .valueElementArray(
                    discountedItems.compactMap({ cartItem in
                        if cartItem.cart_discount_key == item.coupon_code {
                            return ValueElement(
                                product_id: Int(cartItem.cart_product_id),
                                variation_id: Int(cartItem.cart_variation_id),
                                quantity: Int(cartItem.cart_quantity))
                        } else {
                            return nil
                        }
                    }))))
            
            let couponedCartItem = discountedItems.filter({ $0.cart_discount_key == item.coupon_code })
            if let discountName = couponedCartItem.first?.cart_discount_key?.uppercased() {
                updateCoupons.append(UpdateCouponDataModel(
                    discount_name: discountName,
                    product_ids: couponedCartItem.compactMap({ cartItem in
                        let idForApplyingCoupon = cartItem.cart_variation_id != 0 ? cartItem.cart_variation_id : cartItem.cart_product_id
                        return Int(idForApplyingCoupon)
                    })))
            }
            
        }
        
        
        let pwds = cart.filter({ $0.cart_discount_key == "pwd" })
        let seniors = cart.filter({ $0.cart_discount_key == "senior" })
        
        for pwd in pwds {
            discountedPWD.append(
                ValueElement(
                    product_id: Int(pwd.cart_product_id),
                    variation_id: Int(pwd.cart_variation_id),
                    quantity: Int(pwd.cart_quantity))
            )
        }
        
        for senior in seniors {
            discountedSenior.append(
                ValueElement(
                    product_id: Int(senior.cart_product_id),
                    variation_id: Int(senior.cart_variation_id),
                    quantity: Int(senior.cart_quantity))
            )
        }
        
//        if !seniors.isEmpty {
//            updateCoupons.append(UpdateCouponDataModel(discount_name: "SENIOR", product_ids: seniors.compactMap({
//                let idForApplyingCoupon = $0.cart_variation_id != 0 ? $0.cart_variation_id : $0.cart_product_id
//                return Int(idForApplyingCoupon)
//            })))
//        }
//        if !pwds.isEmpty {
//            updateCoupons.append(UpdateCouponDataModel(discount_name: "PWD", product_ids: pwds.compactMap({
//                let idForApplyingCoupon = $0.cart_variation_id != 0 ? $0.cart_variation_id : $0.cart_product_id
//                return Int(idForApplyingCoupon)
//            })))
//        }
        
        print("updateCoupons createPostOrderObject:", updateCoupons)
        
        if let surcharges = surchargeData { print("fetch surcharges: ", surcharges) }
        
        if let surchargesData = surchargesData {
            for sur in surchargesData {
                surchargeArray.append(
                    SurchargeData(
                        id: Int(sur.surcharge_id),
                        name: sur.surcharge_name ?? "-",
                        type: sur.surcharge_type ?? "-",
                        amount: Int(sur.surcharge_amount),
                        tax_class: sur.surcharge_tax_class ?? "-"))
            }
        }
        
        var couponLines = [CouponLine]()
        for item in updateCoupons {
//            couponLines.append(CouponLine(code: item.code, product_ids: item.product_ids))
            couponLines.append(CouponLine(code: item.discount_name))
        }
        
        orderToPost = PostOrderModel(
            payment_method: "cod",
            status: "completed",
            line_items: lineItems,
            fee_lines: surchargeArray.compactMap({
                return FeeLine(
                    name: $0.name,
                    total: "\($0.amount)",
                    tax_class: "zero-rate")
            }),
            coupon_lines: couponLines,
            meta_data: [
                MetaData(
                    key: "cashier_user_id",
                    value: .string(userID)),
                MetaData(
                    key: "shift",
                    value: .string(shift)),
                MetaData(
                    key: "operating_day",
                    value: .string(Date().operatingDay())),
                MetaData(
                    key: "order_id",
                    value: .string(cart.first?.cart_order_id ?? "-")),
                MetaData(
                    key: "device_id",
                    value: .string(deviceID)),
                MetaData(
                    key: "cash_tendered",
                    value: .string(cashTenderedTextField.text ?? "0.00")),
                MetaData(
                    key: "remarks",
                    value: .string(remarks ?? "")),
                MetaData(
                    key: "date_created_local",
                    value: .string(cart.first?.cart_created_at?.createdAtLocal() ?? "-")),
                MetaData(
                    key: "line_items_count",
                    value: .string("\(lineItems.count)"))
//                MetaData(
//                    key: "pwd",
//                    value: .valueElementArray(discountedPWD)),
//                MetaData(
//                    key: "senior",
//                    value: .valueElementArray(discountedSenior))
            ])
        orderToPost?.meta_data.append(contentsOf: metaDataForCouponsUsed)
        
        print("orderToPost: ", orderToPost ?? "no orderToPost")
        print("metaDataForCouponsUsed: \(metaDataForCouponsUsed)")
        
        do {
            let postOrderJson = try JSONEncoder().encode(orderToPost)
            let postOrderJSONtoString = String(data: postOrderJson, encoding: .utf8)!
            print("postOrderJSONtoString: \(postOrderJSONtoString)")
            
//            let metaData = try JSONEncoder().encode(metaDataForCouponsUsed)
//            let metaDataJSONtoString = String(data: metaData, encoding: .utf8)!
//            print("metaDataJSONtoString: \(metaDataJSONtoString)")
            
            let updateCouponsJson = try JSONEncoder().encode(updateCoupons)
            let updateCouponsJsontoString = String(data: updateCouponsJson, encoding: .utf8)!
            print("updateCouponsJsontoString: \(updateCouponsJsontoString)")
        } catch {
            print("error decoding postOrderJson, metaDataJSONtoString \(error.localizedDescription)")
        }
        
        
    }
}

extension CashMethodViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cart.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let item = cart[indexPath.row]
        
        if !cart.isEmpty {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CashPaymentTableViewCell.identifier, for: indexPath) as? CashPaymentTableViewCell else {
                return UITableViewCell()
            }
            
            cell.isAddon = item.cart_tagged_product != 0
            cell.configure(with:
                            OrderCellViewModel(
                                id: Int(item.cart_product_id),
                                name: item.cart_variation_name ?? item.cart_product_name ?? "-",
                                quantity: Int(item.cart_quantity),
                                subTotal: item.cart_discounted_product_cost, //item.cart_product_cost
                                originalPrice: item.cart_original_cost,
                                image: item.cart_product_image ?? "-",
                                isChecked: false,
                                discountKey: item.cart_discount_key ?? "-"))
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            cell.textLabel?.text = "Cart is empty"
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableCell(withIdentifier: CashPaymentHeaderTableViewCell.identifier) as! CashPaymentHeaderTableViewCell
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20.0
    }
}

extension CashMethodViewController {
    
    public func getAllItems() {
        cart.removeAll()
        do {
            let cartEntity: [Cart_Entity] = try context.fetch(Cart_Entity.fetchRequest())
//            cart = cartEntity.filter({ $0.cart_status == "added" && $0.cart_isChecked == true })
            cart = cartEntity.filter({ $0.cart_status == "added" })
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        } catch {
            // error
        }
    }
    
    private func getCouponsEntity() {
        do {
            couponsEntity.removeAll()
            couponsEntity = try context.fetch(Coupons_Entity.fetchRequest())
        } catch {
            // error
            print("failed to getCouponsEntity: ", error.localizedDescription)
        }
    }
    
    public func getSurcharges() {
        surchargesData?.removeAll()
        do {
            let surchargeEntity: [Surcharges_Entity] = try context.fetch(Surcharges_Entity.fetchRequest())
            surchargesData = surchargeEntity
            
            var surArray = [SurchargeData]()
            
            if let surs = surchargesData {
                for sur in surs {
                    surArray.append(
                        SurchargeData(
                            id: Int(sur.surcharge_id),
                            name: sur.surcharge_name ?? "-",
                            type: sur.surcharge_type ?? "-",
                            amount: Int(sur.surcharge_amount),
                            tax_class: sur.surcharge_tax_class ?? "-"))
                }
            }
            
            var totalSurcharge: Double = 0
            surArray.forEach({ item in
                totalSurcharge += Double(item.amount) 
            })
            
            print("totalSurcharge from sad: ", totalSurcharge)

            self.calculateTotal(with: totalSurcharge)
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        } catch {
            // error
        }
    }
    
    public func updateCartStatus(items: [Cart_Entity], status: String, cashTendered: Double) {
        var totalSurcharges: Double = 0
        
        for item in surchargeArray {
            totalSurcharges += Double(item.amount)
        }
        
        let fetchedcart_discount_key = items.first(where: { $0.cart_discount_key != "" })?.cart_discount_key ?? ""
        print("fetchedcart_discount_key: \(fetchedcart_discount_key)")
        
        do {
            let queue = Queue_Entity(context: context)
            for item in items {
                item.cart_status = status
                item.queue = queue
                queue.addToCart(item)
                queue.queue_order_id = item.cart_order_id
                queue.queue_cash_tendered = cashTendered
                queue.queue_surcharges = totalSurcharges
                queue.queue_remarks = remarks
                
                
                let discountCode = fetchedCoupons.first(where: { $0.code.lowercased() == fetchedcart_discount_key.lowercased() })?.id ?? 0
                
                queue.queue_coupon_code = discountCode
                
                if item.cart_discount_key == "pwd" {
                    queue.queue_coupon_title = "pwd"
//                    queue.queue_product_ids.append(Int(item.cart_product_id))
                    let idForApplyingCoupon = item.cart_variation_id != 0 ? item.cart_variation_id : item.cart_product_id
                    queue.queue_product_ids.append(Int(idForApplyingCoupon))
                }
                if item.cart_discount_key == "senior" {
                    queue.queue_coupon_title = "senior"
                    let idForApplyingCoupon = item.cart_variation_id != 0 ? item.cart_variation_id : item.cart_product_id
                    queue.queue_product_ids.append(Int(idForApplyingCoupon))
                }
                
            }
            queue.queue_created_at = Date()
            
            try context.save()
            getAllItems()
        } catch {
            // error
        }
    }
}

// MARK: - viewDidLayoutSubviews
extension CashMethodViewController {
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        cashTenderedTextField.sizeToFit()
        
        let bottomContainerHeight: CGFloat = 220.0+44.0+10
        
        cashTenderedTextField.frame = CGRect(
            x: 16,
            y: 10,
            width: view.width-32,
            height: 44.0)
        
        tableView.frame = CGRect(
            x: 0,
            y: cashTenderedTextField.bottom+10,
            width: view.width,
            height: view.height-cashTenderedTextField.height-bottomContainerHeight)
        
        bottomContainer.frame = CGRect(
            x: 14+view.safeAreaInsets.left,
            y: tableView.bottom,
            width: view.width-28-view.safeAreaInsets.left-view.safeAreaInsets.right,
            height: bottomContainerHeight-view.safeAreaInsets.bottom)
        
        bottomContainer.addTopBorder(with: Constants.lightGrayBorderColor, andWidth: 0.5)
        //        bottomContainer.backgroundColor = .systemGreen
        
        let buttonHeight: CGFloat = 44.0
        let labelHeight: CGFloat = (bottomContainer.height-10-buttonHeight-10-10)/9
        let labelWidth: CGFloat = bottomContainer.width/2
        
        //
        subTotalLabel.frame = CGRect(x: 0, y: 10, width: labelWidth, height: labelHeight)
        vatableSalesLabel.frame = CGRect(x: 0, y: subTotalLabel.bottom, width: labelWidth, height: labelHeight)
        vatExemptLabel.frame = CGRect(x: 0, y: vatableSalesLabel.bottom, width: labelWidth, height: labelHeight)
        vatLabel.frame = CGRect(x: 0, y: vatExemptLabel.bottom, width: labelWidth, height: labelHeight)
        seniorPwdDiscountLabel.frame = CGRect(x: 0, y: vatLabel.bottom, width: labelWidth, height: labelHeight)
        surchargeLabel.frame = CGRect(x: 0, y: seniorPwdDiscountLabel.bottom, width: labelWidth, height: labelHeight)
        totalLabel.frame = CGRect(x: 0, y: surchargeLabel.bottom, width: labelWidth, height: labelHeight)
        cashTenderedLabel.frame = CGRect(x: 0, y: totalLabel.bottom, width: labelWidth, height: labelHeight)
        changeLabel.frame = CGRect(x: 0, y: cashTenderedLabel.bottom, width: labelWidth, height: labelHeight)
        
        //
        subTotalValueLabel.frame = CGRect(x: subTotalLabel.right, y: 10, width: labelWidth, height: labelHeight)
        vatableSalesValueLabel.frame = CGRect(x: vatableSalesLabel.right, y: subTotalValueLabel.bottom, width: labelWidth, height: labelHeight)
        vatExemptValueLabel.frame = CGRect(x: vatExemptLabel.right, y: vatableSalesValueLabel.bottom, width: labelWidth, height: labelHeight)
        vatValueLabel.frame = CGRect(x: vatLabel.right, y: vatExemptValueLabel.bottom, width: labelWidth, height: labelHeight)
        seniorPwdDiscountValueLabel.frame = CGRect(x: seniorPwdDiscountLabel.right, y: vatValueLabel.bottom, width: labelWidth, height: labelHeight)
        surchargeValueLabel.frame = CGRect(x: surchargeLabel.right, y: seniorPwdDiscountValueLabel.bottom, width: labelWidth, height: labelHeight)
        totalValueLabel.frame = CGRect(x: totalLabel.right, y: surchargeValueLabel.bottom, width: labelWidth, height: labelHeight)
        cashTenderedValueLabel.frame = CGRect(x: cashTenderedLabel.right, y: totalValueLabel.bottom, width: labelWidth, height: labelHeight)
        changeValueLabel.frame = CGRect(x: changeLabel.right, y: cashTenderedValueLabel.bottom, width: labelWidth, height: labelHeight)
        
        submitButton.frame = CGRect(x: 0, y: changeLabel.bottom+10, width: bottomContainer.width, height: buttonHeight)
        
        layoutDemoLabel()
    }
}

//{
//    "code": "PWD",
//    "product_ids": [40]
//}


//{
//    "payment_method": "cod",
//    "status": "completed",
//    "line_items": [
//        {
//            "product_id": 38,
//            "variation_id": 0,
//            "quantity": 1
//        }
//    ],
//    "fee_lines": [
//        {
//            "name": "Service Charge",
//            "total": "50.0"
//        }
//    ],
//    "coupon_lines": [
//        {
//            "code": "PWD"
//        }
//    ],
//    "meta_data": [
//        {
//            "key": "cashier_user_id",
//            "value": "43"
//        }, {
//            "key": "shift",
//            "value": "opening"
//        }, {
//            "key": "operating_day",
//            "value": "03/02/2022"
//        }, {
//            "key": "order_id",
//            "value": "ETGY-100000062"
//        }, {
//            "key": "device_id",
//            "value": "FGESOK4ZETGY"
//        }, {
//            "key": "cash_tendered",
//            "value": "140"
//        }, {
//            "key": "pwd",
//            "value": [
//                {
//                    "product_id": 38,
//                    "variation_id": 0,
//                    "quantity": 1
//                }
//            ]
//        }, {
//            "key": "senior",
//            "value": []
//        }
//    ]
//}
