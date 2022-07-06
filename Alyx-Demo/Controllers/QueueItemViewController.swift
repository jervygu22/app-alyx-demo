//
//  QueueItemViewController.swift
//  Jeeves-dev
//
//  Created by Jervy Umandap on 2/4/22.
//

import UIKit


class QueueItemViewController: UIViewController {
    
//    private let orders: [FakeOrders]
    private let orders: [Cart_Entity]
    private let cashTendered: Double
    private let totalSurcharge: Double
    
    init(queueItem: Queue_Entity, orders: [Cart_Entity]) {
        self.orders = orders.sorted(by: { $0.cart_created_at ?? Date() < $1.cart_created_at ?? Date() })
        self.cashTendered = queueItem.queue_cash_tendered
        self.totalSurcharge = queueItem.queue_surcharges
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var homeButton = UIBarButtonItem()
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.register(OrdersTableViewCell.self, forCellReuseIdentifier: OrdersTableViewCell.identifier)
        
        tableView.backgroundColor = Constants.whiteBackgroundColor
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        return tableView
    }()
    
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
    
    private let vatExemptSalesLabel: UILabel = {
        let label = UILabel()
        label.textColor = Constants.secondaryDarkLabelColor
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.text = "Vat Exempt Sales"
        label.textAlignment = .left
        return label
    }()
    
    private let surchargesLabel: UILabel = {
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
    
    private let vatExemptSalesValueLabel: UILabel = {
        let label = UILabel()
        label.textColor = Constants.secondaryDarkLabelColor
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textAlignment = .right
        return label
    }()
    
    private let surchargesValueLabel: UILabel = {
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
        view.backgroundColor = Constants.whiteBackgroundColor
        
        homeButton = UIBarButtonItem(
            image: UIImage(systemName: "house.fill"),
            style: .done,
            target: self,
            action: #selector(didTapHome))
        
//        navigationItem.rightBarButtonItem = homeButton
        
        tableView.delegate = self
        tableView.dataSource = self
        
        view.addSubview(tableView)
        view.addSubview(bottomContainer)
        configureBottomContainer()
        configureBottomContainerData()
        
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
    
    @objc func didTapHome() {
        print("didTapHome")
//        let vc = MenuViewController()
//        vc.historyVC.view.isHidden = true
//        vc.accountVC.view.isHidden = true
//        vc.queueVC.view.isHidden = true
//        vc.notifVC.view.isHidden = true
//        vc.termsCondition.view.isHidden = true
//        vc.settingsVC.view.isHidden = true
//
//        navigationController?.popToViewController(vc, animated: true)
        
        navigationController?.popToRootViewController(animated: true)
//        MenuViewController().view.removeFromSuperview()
        
        
//        for controller in self.navigationController!.viewControllers as Array {
//            if controller.isKind(of: MenuViewController.self) {
//                self.navigationController!.popToViewController(controller, animated: true)
//                break
//            }
//        }
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let bottomContainerHeight: CGFloat = 220.0
        
        tableView.frame = CGRect(
            x: 0,
            y: 0,
            width: view.width,
            height: view.height-bottomContainerHeight)
        
        bottomContainer.frame = CGRect(
            x: 14,
            y: tableView.bottom,
            width: view.width-28-view.safeAreaInsets.right,
            height: bottomContainerHeight-view.safeAreaInsets.bottom)
        bottomContainer.addTopBorder(with: Constants.lightGrayBorderColor, andWidth: 0.5)
//        bottomContainer.backgroundColor = .systemGreen
        
        let labelHeight: CGFloat = (bottomContainer.height-10-10)/9
        let labelWidth: CGFloat = bottomContainer.width/2
            
        subTotalLabel.frame = CGRect(x: 0, y: 10, width: labelWidth, height: labelHeight)
        vatableSalesLabel.frame = CGRect(x: 0, y: subTotalLabel.bottom, width: labelWidth, height: labelHeight)
        vatExemptSalesLabel.frame = CGRect(x: 0, y: vatableSalesLabel.bottom, width: labelWidth, height: labelHeight)
        vatLabel.frame = CGRect(x: 0, y: vatExemptSalesLabel.bottom, width: labelWidth, height: labelHeight)
        seniorPwdDiscountLabel.frame = CGRect(x: 0, y: vatLabel.bottom, width: labelWidth, height: labelHeight)
        surchargesLabel.frame = CGRect(x: 0, y: seniorPwdDiscountLabel.bottom, width: labelWidth, height: labelHeight)
        totalLabel.frame = CGRect(x: 0, y: surchargesLabel.bottom, width: labelWidth, height: labelHeight)
        cashTenderedLabel.frame = CGRect(x: 0, y: totalLabel.bottom, width: labelWidth, height: labelHeight)
        changeLabel.frame = CGRect(x: 0, y: cashTenderedLabel.bottom, width: labelWidth, height: labelHeight)
        
        subTotalValueLabel.frame = CGRect(x: subTotalLabel.right, y: 10, width: labelWidth, height: labelHeight)
        vatableSalesValueLabel.frame = CGRect(x: vatableSalesLabel.right, y: subTotalValueLabel.bottom, width: labelWidth, height: labelHeight)
        vatExemptSalesValueLabel.frame = CGRect(x: vatExemptSalesLabel.right, y: vatableSalesValueLabel.bottom, width: labelWidth, height: labelHeight)
        vatValueLabel.frame = CGRect(x: vatLabel.right, y: vatExemptSalesValueLabel.bottom, width: labelWidth, height: labelHeight)
        seniorPwdDiscountValueLabel.frame = CGRect(x: seniorPwdDiscountLabel.right, y: vatValueLabel.bottom, width: labelWidth, height: labelHeight)
        surchargesValueLabel.frame = CGRect(x: surchargesLabel.right, y: seniorPwdDiscountValueLabel.bottom, width: labelWidth, height: labelHeight)
        totalValueLabel.frame = CGRect(x: totalLabel.right, y: surchargesValueLabel.bottom, width: labelWidth, height: labelHeight)
        cashTenderedValueLabel.frame = CGRect(x: cashTenderedLabel.right, y: totalValueLabel.bottom, width: labelWidth, height: labelHeight)
        changeValueLabel.frame = CGRect(x: changeLabel.right, y: cashTenderedValueLabel.bottom, width: labelWidth, height: labelHeight)
        
        layoutDemoLabel()
    }
    
    func configureBottomContainer() {
        bottomContainer.addSubview(subTotalLabel)
        bottomContainer.addSubview(vatableSalesLabel)
        bottomContainer.addSubview(vatExemptSalesLabel)
        bottomContainer.addSubview(surchargesLabel)
        bottomContainer.addSubview(vatLabel)
        bottomContainer.addSubview(seniorPwdDiscountLabel)
        bottomContainer.addSubview(totalLabel)
        bottomContainer.addSubview(cashTenderedLabel)
        bottomContainer.addSubview(changeLabel)
        
        bottomContainer.addSubview(subTotalValueLabel)
        bottomContainer.addSubview(vatableSalesValueLabel)
        bottomContainer.addSubview(vatExemptSalesValueLabel)
        bottomContainer.addSubview(surchargesValueLabel)
        bottomContainer.addSubview(vatValueLabel)
        bottomContainer.addSubview(seniorPwdDiscountValueLabel)
        bottomContainer.addSubview(totalValueLabel)
        bottomContainer.addSubview(cashTenderedValueLabel)
        bottomContainer.addSubview(changeValueLabel)
    }
    
    
    func configureBottomContainerData() {
        var cartSubTotal: Double = 0
        var appliedDiscountAmount: Double = 0
        var allVatableSales: Double = 0
        var allVatExemptSales: Double = 0
        var allVat12Amount: Double = 0
        var rawGrandTotal: Double = 0
        
        for item in orders {
            
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
//            let subTotal = (roundedVatableSales + roundedVat12Amount) - roundedDiscountAmount
            
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
        
        cartSubTotal = Double(round(100 * cartSubTotal) / 100)
        var grandTotal = cartSubTotal + totalSurcharge
        rawGrandTotal += totalSurcharge
        grandTotal = Double(round(100 * rawGrandTotal) / 100)
        let change = cashTendered - grandTotal
        
        print("cartSubTotal: \(cartSubTotal)")
        print("totalSurcharge: \(totalSurcharge)")
        print("grandTotal: \(grandTotal)")
        print("cashTendered: \(cashTendered)")
        print("change: \(change)")
        
        subTotalValueLabel.text = String(format:"₱%.2f", Double(cartSubTotal))
        vatableSalesValueLabel.text = String(format:"₱%.2f", Double(allVatableSales))
        vatExemptSalesValueLabel.text = String(format:"₱%.2f", Double(allVatExemptSales))
        vatValueLabel.text = String(format:"₱%.2f", Double(allVat12Amount))
        seniorPwdDiscountValueLabel.text = String(format:"₱%.2f", Double(appliedDiscountAmount))
        surchargesValueLabel.text = String(format:"₱%.2f", Double(totalSurcharge))
        totalValueLabel.text = String(format:"₱%.2f", Double(grandTotal))
        cashTenderedValueLabel.text = String(format:"₱%.2f", Double(cashTendered))
        changeValueLabel.text = String(format:"₱%.2f", Double(change))
    }
}

extension QueueItemViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = orders[indexPath.row]
        
        guard let cell = tableView.dequeueReusableCell(
                withIdentifier: OrdersTableViewCell.identifier,
                for: indexPath) as? OrdersTableViewCell else {
            return UITableViewCell()
        }
        cell.isAddon = model.cart_tagged_product != 0
        cell.configure(with: OrdersTableViewCellViewModel(
            image: model.cart_product_image ?? "-",
            name: model.cart_variation_name ?? "-",
            quantity: Int(model.cart_quantity),
            finalPrice: model.cart_discounted_product_cost,
            originalPrice: model.cart_product_cost,
            discount: nil,
            itemPrice: model.cart_product_cost))
        
        return cell
    }
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
//        print(orders[indexPath.row].product_name)
//    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let headerString = "Items"
        return headerString
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = UIColor.red
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = Constants.darkGrayColor
    }
    
}
