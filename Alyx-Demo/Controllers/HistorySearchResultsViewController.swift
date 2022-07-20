//
//  HistorySearchResultsViewController.swift
//  Jeeves-dev
//
//  Created by Jervy Umandap on 2/4/22.
//

import UIKit

protocol HistorySearchResultsViewControllerDelegate: AnyObject {
    func didTapResultItem(with item: HistoryData)
}

class HistorySearchResultsViewController: UIViewController {
    weak var historySearchResultsViewControllerDelegate: HistorySearchResultsViewControllerDelegate?
    
//    var history = [FakeQueueListItems]()
//    private var history = [HistoryAllResponseData]()
    public var filteringHistory: [HistoryData]?
    
    public var searchQuery: String?
    
    public let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        // to replace
        tableView.register(
            QueueTableViewCell.self,
            forCellReuseIdentifier: QueueTableViewCell.identifier)
        
        tableView.isHidden = false
        tableView.separatorStyle = .singleLine
        tableView.backgroundColor = .white
        return tableView
    }()
    
    private let noResultsLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = Constants.lightGrayColor
        label.font = .systemFont(ofSize: 16, weight: .light)
        label.text = "No matching transactions found."
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isHidden = false
        label.adjustsFontSizeToFitWidth = true
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
        
        view.backgroundColor = Constants.vcBackgroundColor
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        
        fetchData()
        print("filteringHistory Count: ", filteringHistory?.count ?? 0)
        
        isDeviceAuthorized()
        
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
        //        demoLabel.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        //        demoLabel.backgroundColor = UIColor.red.withAlphaComponent(0.75)
        demoLabel.backgroundColor = Constants.demoLabelAlphaBackgroundColor
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
        layoutDemoLabel()
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
    
    private func fetchData() {
//        APICaller.shared.getAllHistory { [weak self] result in
//            switch result {
//            case .success(let model):
//                self?.history = model
////                self?.filteringHistory = model
//                DispatchQueue.main.async {
//                    self?.tableView.reloadData()
//                }
//            case .failure(let error):
//                print(error.localizedDescription)
//            }
//        }
//        APICaller.shared.getHistory(page: 1) { [weak self] result in
//            switch result {
//            case .success(let model):
//                self?.history = model
//                DispatchQueue.main.async {
//                    self?.tableView.reloadData()
//                }
//            case .failure(let error):
//                print("From History search VC", error.localizedDescription)
//            }
//        }
    }
    
    public func update(withResults results: [HistoryData]) {
        filteringHistory = results.sorted(by: { $0.orderID > $1.orderID })
        
        tableView.isHidden = results.isEmpty
        noResultsLabel.isHidden = true
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    public func defaultEmptyView(with message: String) {
        noResultsLabel.sizeToFit()
        noResultsLabel.text = message
        noResultsLabel.isHidden = false
        noResultsLabel.center = view.center
        view.addSubview(noResultsLabel)
    }
    
    
}

extension HistorySearchResultsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteringHistory?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let filteringHistory = filteringHistory {
            if !filteringHistory.isEmpty {
                guard let cell = tableView.dequeueReusableCell(
                        withIdentifier: QueueTableViewCell.identifier,
                        for: indexPath) as? QueueTableViewCell else {
                    return UITableViewCell()
                }
                
                let model = filteringHistory[indexPath.row]
                cell.configure(
                    withViewModel: QueueTableViewCellViewModel(
                        name: "\(model.orderID)",
                        date: model.timestamp,
                        info: model.cashierName,
                        items: model.cartCount,
                        status: model.orderStatus))
                return cell
                
            }
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = "No matches were found for '\(searchQuery ?? "-")'"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let model = filteringHistory?[indexPath.row] else { return }
        print("Did tap", model.orderID)
        historySearchResultsViewControllerDelegate?.didTapResultItem(with: model)
//        let vc = HistoryItemViewController(queueItem: model)
        let vc = HistoryItemViewController(orderID: model.orderID, isCancelled: model.orderStatus.lowercased() == "cancelled")
        vc.title = "\(model.orderID)"
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }
    
    
}
