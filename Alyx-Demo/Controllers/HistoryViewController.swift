//
//  HistoryViewController.swift
//  Jeeves-dev
//
//  Created by Jervy Umandap on 2/4/22.
//

import UIKit

class HistoryViewController: UIViewController, UISearchResultsUpdating, HistoryItemViewControllerDelegate {
    
    static let shared = HistoryViewController()
    
    var searchBar: UISearchBar?
    
//    var history = [FakeQueueListItems]()
    
    lazy var historyLatest = [HistoryData]()
//    private var historyNewPages = [HistoryData]()
    
//    private var history: [HistoryAllResponseData] = []
    lazy var filteringHistory = [HistoryData]()
    
    private var page = 1
    
    public let historySearchController: UISearchController = {
        let vc = HistorySearchResultsViewController()
        let searchController = UISearchController(searchResultsController: vc)
        searchController.searchBar.placeholder = "Search history"
        searchController.searchBar.searchBarStyle = .default
        searchController.definesPresentationContext = true
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.keyboardAppearance = .default
        return searchController
    }()
    
    private let filterContainer: UIView = {
        let container = UIView()
        container.layer.masksToBounds = true
        container.clipsToBounds = true
        return container
    }()
    
    private let startLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = Constants.secondaryDarkLabelColor
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.text = "From:"
        label.textAlignment = .center
        return label
    }()
    
    
    private let endLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = Constants.secondaryDarkLabelColor
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.text = "To:"
        label.textAlignment = .center
        return label
    }()
    
    private let startContainer: UIView = {
        let container = UIView()
        container.layer.masksToBounds = true
        container.clipsToBounds = true
        return container
    }()
    
    private let startDatePicker: UIDatePicker = {
        let picker = UIDatePicker(frame: .zero)
        picker.datePickerMode = .date
        picker.tintColor = .black
        picker.backgroundColor = .clear
        
        if #available(iOS 13.4, *) {
            picker.preferredDatePickerStyle = .compact
        } else {
            // Fallback on earlier versions
        }
        return picker
    }()
    
    private let endContainer: UIView = {
        let container = UIView()
        container.layer.masksToBounds = true
        container.clipsToBounds = true
        return container
    }()
    
    private let endDatePicker: UIDatePicker = {
        let picker = UIDatePicker(frame: .zero)
        picker.datePickerMode = .date
        picker.tintColor = .black
        picker.backgroundColor = .clear
        
        if #available(iOS 13.4, *) {
            picker.preferredDatePickerStyle = .compact
        } else {
            // Fallback on earlier versions
        }
        return picker
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        // to replace
        
        tableView.register(
            NoResultTableViewCell.self,
            forCellReuseIdentifier: NoResultTableViewCell.identifier)
        
        tableView.register(
            QueueTableViewCell.self,
            forCellReuseIdentifier: QueueTableViewCell.identifier)
        
        
        tableView.isHidden = false
        tableView.separatorStyle = .singleLine
        tableView.backgroundColor = Constants.whiteBackgroundColor
        return tableView
    }()
    
    
    private let noResultsLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = Constants.lightGrayColor
        label.font = .systemFont(ofSize: 16, weight: .light)
        label.text = "Empty History\nTransactions that has been submitted will appear here."
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isHidden = false
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private let reloadHistoryButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 8.0
        button.layer.masksToBounds = true
        button.setImage(UIImage(systemName: "arrow.triangle.2.circlepath"), for: .normal)
        button.tintColor = Constants.lightGrayColor
        button.isHidden = true
        
        return button
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchData()
//        fetchHistoryFull()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // title = "History"
        
        fetchData()
//        fetchHistoryFull()
        
        view.backgroundColor = Constants.whiteBackgroundColor
//        configureSearchBar()
        configureSubviews()
        
        historySearchController.searchResultsUpdater = self
        historySearchController.searchBar.delegate = self
        historySearchController.hidesNavigationBarDuringPresentation = false
        
        navigationItem.searchController = historySearchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .lightGray
//        refreshControl.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        tableView.refreshControl = refreshControl
        
        tableView.refreshControl?.addTarget(self, action: #selector(didPullDownToRefresh), for: .valueChanged)
        reloadHistoryButton.addTarget(self, action: #selector(didPullDownToRefresh), for: .touchUpInside)
    }
    
    
    public func defaultEmptyView(with message: String) {
        noResultsLabel.sizeToFit()
        noResultsLabel.text = message
        noResultsLabel.isHidden = false
        noResultsLabel.center = view.center
        let reloadHistoryButtonSize: CGFloat = 50
        reloadHistoryButton.isHidden = false
        reloadHistoryButton.frame = CGRect(
            x: (view.width-reloadHistoryButtonSize)/2,
            y: noResultsLabel.bottom+5,
            width: reloadHistoryButtonSize,
            height: reloadHistoryButtonSize)
        view.addSubview(noResultsLabel)
        view.addSubview(reloadHistoryButton)
        
//        reloadHistoryButton.backgroundColor = .red
    }
    
    @objc private func didPullDownToRefresh() {
        // refetch data
        page = 1
        fetchData()
//        fetchHistoryFull()
        isDeviceAuthorized()
        APICaller.shared.historyIsPaginating = false
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
//        history.removeAll()
//        historyData.removeAll()
//        filteringHistoryData.removeAll()
//        filteringHistory.removeAll()
        
        DispatchQueue.main.async {
            if self.tableView.refreshControl?.isRefreshing == true {
                print("refreshing history...page: ", self.page)
            } else {
                print("fetching history..page: ", self.page)
            }
        }
        
        APICaller.shared.getHistory(pagination: false , page: page) { [weak self] result in
            guard let strongSelf = self else {
                return
            }
            switch result {
            case .success(let model):
                strongSelf.historyLatest = model
                
                if !strongSelf.historyLatest.isEmpty {
                    DispatchQueue.main.async {
                        strongSelf.noResultsLabel.isHidden = true
                        strongSelf.tableView.isHidden = false
                        strongSelf.tableView.refreshControl?.endRefreshing()
                        strongSelf.tableView.reloadData()
                        strongSelf.reloadHistoryButton.isHidden = true
                    }
                } else {
                    DispatchQueue.main.async {
                        strongSelf.tableView.isHidden = true
                        strongSelf.defaultEmptyView(with: "No orders found\nTransactions that has been submitted will appear here.")
                    }
                }
            case .failure(let error):
                print("getHistory error from History VC", error.localizedDescription)
                DispatchQueue.main.async {
                    strongSelf.tableView.isHidden = true
                    strongSelf.defaultEmptyView(with: "No orders found\nPlease check internet connection.")
                }
            }
        }
        
    }
    
    private func fetchHistoryFull() {
        APICaller.shared.getAllHistory(completion: { [weak self] result in
            switch result {
            case .success(let model):
                self?.filteringHistory = model
                print("filteringHistory: ", self?.filteringHistory.count ?? 0)
            case .failure(let error):
                print("getAllHistory error from History VC", error.localizedDescription)
            }
        })
    }
    
    private func configureSubviews() {
//        view.addSubview(filterContainer)
        view.addSubview(tableView)
        
        filterContainer.addSubview(startContainer)
        filterContainer.addSubview(endContainer)
        
        filterContainer.addSubview(startLabel)
        filterContainer.addSubview(endLabel)
        
        startContainer.addSubview(startDatePicker)
        endContainer.addSubview(endDatePicker)
        
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        // perform search
    }
    
    func shouldReloadData() {
        print("reloading tableView")
        fetchData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
//        guard let safeSearchBar = searchBar else { return }
//        safeSearchBar.sizeToFit()
        
//        let filterContainerHeight: CGFloat = 70.0
            
//        filterContainer.frame = CGRect(
//            x: 20,
//            y: safeSearchBar.bottom,
//            width: view.width-40,
//            height: filterContainerHeight+20)
//        filterContainer.addBottomBorder(with: Constants.lightGrayBorderColor, andWidth: 0.5)
////        filterContainer.backgroundColor = .lightGray
        
//        startLabel.sizeToFit()
//        endLabel.sizeToFit()
//        startDatePicker.sizeToFit()
//        startDatePicker.semanticContentAttribute = .forceRightToLeft
//        startDatePicker.subviews.first?.semanticContentAttribute = .forceRightToLeft
//        endDatePicker.sizeToFit()
//
//        let dateContainerWidth: CGFloat = filterContainer.width*0.40
//        let dateContainerheight: CGFloat = filterContainer.height*0.7
//
//        startLabel.frame = CGRect(
//            x: 0,
//            y: 0,
//            width: filterContainer.width/2,
//            height: filterContainer.height-dateContainerheight)
//
//        endLabel.frame = CGRect(
//            x: startLabel.right,
//            y: 0,
//            width: filterContainer.width/2,
//            height: filterContainer.height-dateContainerheight)
//
//        startContainer.frame = CGRect(
//            x: 0,
//            y: startLabel.bottom,
//            width: dateContainerWidth,
//            height: dateContainerheight-10)
//        startDatePicker.frame = startContainer.bounds
////        startDatePicker.backgroundColor = .red
//
//
//        endContainer.frame = CGRect(
//            x: startContainer.right+(filterContainer.width*0.20),
//            y: endLabel.bottom,
//            width: dateContainerWidth,
//            height: dateContainerheight-10)
//        endDatePicker.frame = startContainer.bounds
////        endDatePicker.backgroundColor = .systemTeal
        
//        tableView.frame = CGRect(
//            x: 0,
//            y: filterContainer.bottom,
//            width: view.width,
//            height: view.height-safeSearchBar.height-filterContainer.height)
////        tableView.backgroundColor = .systemGray
        
        tableView.frame = view.bounds
    }
    
    private func createSpinnerFooterView() -> UIView {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: view.width, height: 80))
        let spinner = UIActivityIndicatorView()
        spinner.style = .medium
        spinner.color = .lightGray
        spinner.startAnimating()
        spinner.center = footerView.center
        footerView.addSubview(spinner)
        return footerView
    }
}

extension HistoryViewController: UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        print("scrolling")
        let position = scrollView.contentOffset.y
        if position > (tableView.contentSize.height - scrollView.height + 80) {
            // fetch more data
            
            guard !APICaller.shared.historyIsPaginating else {
                // we are already fethcing more data
                return
            }
            page += 1
            print("loading more page: ", page)
            
            self.tableView.tableFooterView = createSpinnerFooterView()
            
            APICaller.shared.getHistory(pagination: true, page: page) { [weak self] result in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0) {
                    self?.tableView.tableFooterView = nil
                }
                
                switch result {
                case .success(let moreData):
                    self?.historyLatest.append(contentsOf: moreData)
//                    self?.historyNewPages.append(contentsOf: moreData)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0) {
                        self?.tableView.reloadData()
                    }
                case .failure(let error):
                    print("getHistory error from VC: ", error)
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return historyLatest.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
//        cell.textLabel?.text = "foo"
//        return cell
        if !historyLatest.isEmpty {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: QueueTableViewCell.identifier,
                for: indexPath) as? QueueTableViewCell else {
                return UITableViewCell()
            }
            
            let sortedHistory = historyLatest.sorted(by: { $0.orderID > $1.orderID })
            
            let model = sortedHistory[indexPath.row]
            cell.configure(
                withViewModel: QueueTableViewCellViewModel(
                    name: "\(model.orderID)",
                    date: model.timestamp,
                    info: model.cashierName,
                    items: model.cartCount,
                    status: model.orderStatus))
            
            return cell
            
        } else {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: NoResultTableViewCell.identifier,
                for: indexPath) as? NoResultTableViewCell else {
                return UITableViewCell()
            }
            cell.configure(with: "No transaction has been made yet.")
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let sortedHistory = historyLatest.sorted(by: { $0.orderID > $1.orderID })
        let model = sortedHistory[indexPath.row]
//        print("Did tap", model.transaction_id)
//        let vc = HistoryItemViewController(queueItem: model)
        let vc = HistoryItemViewController(orderID: model.orderID, isCancelled: model.orderStatus.lowercased() == "cancelled")
        vc.title = "\(model.orderID)"
        vc.historyItemViewControllerDelegate = self
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }
    
}


extension HistoryViewController: HistorySearchResultsViewControllerDelegate {
    func didTapResultItem(with item: HistoryData) {
        print("goto-", item.orderID)
//        let vc = HistoryItemViewController(queueItem: item)
        let vc = HistoryItemViewController(orderID: item.orderID, isCancelled: item.orderStatus.lowercased() == "cancelled")
        vc.title = "\(item.orderID)"
        vc.navigationItem.largeTitleDisplayMode =  .never
        navigationController?.pushViewController(vc, animated: true)
    }
}
//100000208
extension HistoryViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let resultsController = historySearchController.searchResultsController as? HistorySearchResultsViewController,
              let query = searchBar.text, !query.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        
        resultsController.searchQuery = query
        resultsController.historySearchResultsViewControllerDelegate = self
        
        APICaller.shared.searchHistory(with: query) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let model):
                    resultsController.tableView.isHidden = false
                    resultsController.update(withResults: model)
                case .failure(let error):
                    print("searchHistory error searchBarSearchButtonClicked: \(error.localizedDescription)")
                    resultsController.tableView.isHidden = true
                    resultsController.defaultEmptyView(with: "No matching transactions found.")
                }
            }
        }
    }
    
//    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        guard let resultsController = historySearchController.searchResultsController as? HistorySearchResultsViewController else { return }
//        let query = searchText
//
//        resultsController.searchQuery = query
//        resultsController.historySearchResultsViewControllerDelegate = self
//
//        APICaller.shared.searchHistory(with: query) { result in
//            DispatchQueue.main.async {
//                switch result {
//                case .success(let model):
//                    resultsController.update(withResults: model)
//                case .failure(let error):
//                    print("searchHistory error searchBar: \(error.localizedDescription)")
//                }
//            }
//        }
    
    //        if filteringHistory.contains(
    //            where: {
    //                $0.cashierName.lowercased().range(of: query.lowercased()) != nil ||
    //                    $0.timestamp.lowercased().range(of: query.lowercased()) != nil || $0.orderStatus.lowercased().range(of: query.lowercased()) != nil || String($0.orderID).lowercased().range(of: query.lowercased()) != nil
    //            }) {
    //            let searchResult = filteringHistory.filter({
    //                $0.cashierName.lowercased().range(of: query.lowercased()) != nil ||
    //                    $0.timestamp.lowercased().range(of: query.lowercased()) != nil || $0.orderStatus.lowercased().range(of: query.lowercased()) != nil || String($0.orderID).lowercased().range(of: query.lowercased()) != nil
    //            })
    //
    //            print("searchResult: ", searchResult.count)
    //            resultsController.filteringHistory = searchResult
    //            resultsController.update(withResults: searchResult)
    //        }
//    }
}
