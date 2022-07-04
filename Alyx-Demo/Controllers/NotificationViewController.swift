//
//  NotificationViewController.swift
//  Jeeves-dev
//
//  Created by Jervy Umandap on 2/4/22.
//

import UIKit
import CoreData


class TestAPICaller {
    var isPaginating = false
    func fetchData(pagination: Bool = false, completion: @escaping(Result<[String], Error>) -> Void) {
        
        if pagination {
            isPaginating = true
        }
        DispatchQueue.global().asyncAfter(deadline: .now() + (pagination ? 1.5 : 0)) {
            let originalData = [
                "Apple", "Facebook", "Microsoft", "IBM", "Facebook", "Microsoft","IBM", "Apple", "Facebook", "Microsoft", "IBM", "Facebook", "Microsoft","IBM", "Apple", "Facebook", "Microsoft", "IBM", "Facebook", "Microsoft","IBM"
            ]
            
            let newData = [
                "Banana", "orange", "grapes", "Santol", "Kamatis"
            ]
            
            completion(.success( pagination ? newData : originalData ))
            
            if pagination {
                self.isPaginating = false
            }
        }
    }
}


class NotificationViewController: UIViewController {
    
    static let shared = NotificationViewController()
    
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()
    
    private var cart = [Cart_Entity]()
    
    private let testApiCaller = TestAPICaller()
    private var data = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Notifications"
        view.backgroundColor = .systemBlue
        
        getAllItems()
        
//        self.save(value: "testing 1", createdAt: Date())
//        self.save(value: "testing 2", createdAt: Date())
//        self.save(value: "testing 3", createdAt: Date())
//        self.save(value: "testing 4", createdAt: Date())
//        self.retrieveValues()
        
        view.addSubview(tableView)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(didTapPlus))
        
        fetchData()
    }
    
    @objc func didTapPlus() {
        print("did Tap notifications Plus")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
        
    }
    
    private func fetchData() {
        testApiCaller.fetchData(pagination: false) { [weak self] result in
            switch result {
            case .success(let data):
                self?.data.append(contentsOf: data)
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            case .failure(_):
                print("Error test api caller")
                break
            }
        }
    }
    
    private func createSpinnerFooterView() -> UIView {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: view.width, height: 44))
        let spinner = UIActivityIndicatorView()
        spinner.startAnimating()
        spinner.center = footerView.center
        footerView.addSubview(spinner)
        return footerView
    }
}

extension NotificationViewController: UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let position = scrollView.contentOffset.y
        if position > (tableView.contentSize.height - 100 - scrollView.height) {
            
            // fetch more data
            guard !testApiCaller.isPaginating else {
                // we are already fethcing more data
                return
            }
            
            print("loading more: ", position)
            
            // if start paginating
            self.tableView.tableFooterView = createSpinnerFooterView()
            
            testApiCaller.fetchData(pagination: true) { [weak self] result in
                // pagination finished
                DispatchQueue.main.async {
                    self?.tableView.tableFooterView = nil
                }
                
                switch result {
                case .success(let data):
                    self?.data.append(contentsOf: data)
                    DispatchQueue.main.async {
                        self?.tableView.reloadData()
                    }
                case .failure(_):
                    print("Error test api caller")
                    break
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0//cart.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = cart[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
//        let items = "\(model.name ?? "") - \(String(describing: model.createdAt))"
        
        cell.textLabel?.text = model.cart_product_name
        return cell
    }
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
//
//        let item = models[indexPath.row]
//
//        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet )
//        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
//        sheet.addAction(UIAlertAction(title: "Edit", style: .default, handler: { _ in
//
//            let alert = UIAlertController(title: "Edit item", message: "Edit your item", preferredStyle: .alert)
//
//            alert.addTextField { field in
//                field.placeholder = "\(String(describing: item.quantity))"
//                field.returnKeyType = .continue
//                field.keyboardType = .default
//            }
//
//            alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { [weak self] _ in
//                guard let textField = alert.textFields?.first,
//                      let newQty = textField.text, !newQty.isEmpty else { return }
//
//                self?.updateQty(item: item, qty: Int(newQty) ?? 0)
//
//            }))
//            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
//
//            self.present(alert, animated: true, completion: nil)
//        }))
//        sheet.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] _ in
//            self?.deleteItem(item: item)
//        }))
//
//
//
//        present(sheet, animated: true, completion: nil)
//    }
    
    
}


extension NotificationViewController {
    public func getAllItems() {
        do {
            // let items = try context.fetch(ToDoListItem.fetchRequest())
            cart = try context.fetch(Cart_Entity.fetchRequest())
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        } catch {
            // error
        }
    }
    
    public func createItem(name: String, qty: Int) {
        let newItem = Cart_Entity(context: context)
//        newItem.name = name
        newItem.cart_product_id = 1
        newItem.cart_quantity = 1
        newItem.cart_created_at = Date()
        
        do {
            try context.save()
            getAllItems()
        } catch {
            // error
        }
    }
    
    public func deleteItem(item: Cart_Entity) {
        context.delete(item)
        
        do {
            try context.save()
            getAllItems()
        } catch {
            // error
        }
    }
    
    public func updateQty(item: Cart_Entity, qty: Int) {
        item.cart_quantity = Int64(qty)
        
        do {
            try context.save()
            getAllItems()
        } catch {
            // error
        }
    }
    
}












// MARK:-



//struct TestAPIResponse: Codable {
//    let results: TestAPIResponseResults
//    let status: String
//}
//
//struct TestAPIResponseResults: Codable {
//    let day_length: Int
//    let sunrise, sunset, solar_noon, civil_twilight_begin, civil_twilight_end, nautical_twilight_begin, nautical_twilight_end, astronomical_twilight_begin, astronomical_twilight_end: String
//}
//
//class NotificationViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
//    private var tableData = [String]()
//
//    private let urlString = "https://api.sunrise-sunset.org/json?date=2021-12-17&lng=37.323&lat=-122.0322&formatted=0"
//
//    private let tableView: UITableView = {
//        let tableView = UITableView()
//        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
//        tableView.backgroundColor = .systemBackground
//        return tableView
//    }()
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        title = "Notifications"
//        view.backgroundColor = .systemTeal
//
//        tableView.delegate = self
//        tableView.dataSource = self
//        view.addSubview(tableView)
//
//        fetchData()
//
//        tableView.refreshControl = UIRefreshControl()
//        tableView.refreshControl?.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
//
//        // test cachetoken by domain
//    }
//
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        tableView.frame = view.bounds
//    }
//
//    @objc private func didPullToRefresh() {
//        // refetch data
//        fetchData()
//    }
//
//    private func fetchData() {
//        tableData.removeAll()
//
//        if tableView.refreshControl?.isRefreshing == true {
//            print("refreshing data...")
//        } else {
//            print("fetching data..")
//        }
//
//        guard let url = URL(string: urlString) else { return }
//        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
//            guard let strongSelf = self,
//                let data = data, error == nil else {
//                return
//            }
//
//            var result:  TestAPIResponse?
//
//            do {
//                result = try JSONDecoder().decode(TestAPIResponse.self, from: data)
//            } catch {
//                print("TEST error: ", error.localizedDescription)
//            }
//
//            guard let final = result else {
//                return
//            }
//
//            strongSelf.tableData.append("Sunrise: \(final.results.sunrise)")
//            strongSelf.tableData.append("Sunset: \(final.results.sunset)")
//            strongSelf.tableData.append("DayLength: \(final.results.day_length)")
//
//            DispatchQueue.main.asyncAfter(deadline: .now()+1) {
//                strongSelf.tableView.refreshControl?.endRefreshing()
//                strongSelf.tableView.reloadData()
//            }
//
//        }
//        task.resume()
//    }
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return tableData.count
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
//        cell.textLabel?.text = tableData[indexPath.row]
//        return cell
//    }
//
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
//        print(indexPath.row)
//    }
//
//
//}
//
//
