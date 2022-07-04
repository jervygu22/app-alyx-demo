//
//  AccountShiftViewController.swift
//  Jeeves-dev
//
//  Created by Jervy Umandap on 2/4/22.
//

import UIKit

class AccountShiftViewController: UIViewController {
    
    private let shiftType: ShiftType
    
    private var shiftSection = [ShiftSection]()
    
    init(shiftType: ShiftType) {
        self.shiftType = shiftType
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.register(ShiftOptionsTableViewCell.self,
                           forCellReuseIdentifier: ShiftOptionsTableViewCell.identifier)
        
        tableView.allowsMultipleSelection = true
        
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = shiftType.name
        view.backgroundColor = Constants.whiteBackgroundColor
        
        tableView.delegate = self
        tableView.dataSource = self
        
        view.addSubview(tableView)
        configureSections()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    private func configureSections() {
//        shiftSection.append(ShiftSection(
//                                id: 1,
//                                title: "",
//                                options: [
//                                    ShiftOption(
//                                        id: 1,
//                                        title: "Time In",
//                                        handler: { [weak self] in
//                                            self?.didTapOption(with: "Time In")
//                                        }),
//                                    ShiftOption(
//                                        id: 2,
//                                        title: "Time Out",
//                                        handler: { [weak self] in
//                                            self?.didTapOption(with: "Time Out")
//                                        })
//                                ]))
    }
    
    
    private func didTapOption(with name: String) {
        print("Did tap ", name)
    }
        

}

extension AccountShiftViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return shiftSection.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shiftSection[section].options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ShiftOptionsTableViewCell.identifier, for: indexPath) as? ShiftOptionsTableViewCell else {
            return UITableViewCell()
        }
        
        let model = shiftSection[indexPath.section].options[indexPath.row]
//        cell.textLabel?.text = model.title
        cell.configure(with: ShiftOptionsTableViewCellViewModel(
                        id: model.id,
                        name: model.title))
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = shiftSection[indexPath.section].options[indexPath.row]
        print(model.title)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let title = shiftSection[section].title
        return title
    }
    
    
    
}



struct ShiftType {
    let id: Int
    let name: String
    let image: UIImage?
    
    init(id: Int, name: String, image: UIImage) {
        self.id = id
        self.name = name
        self.image = image
    }
}
