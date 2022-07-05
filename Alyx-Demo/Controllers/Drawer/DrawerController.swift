//
//  DrawerController.swift
//  Jeeves-dev
//
//  Created by Jervy Umandap on 2/4/22.
//

import UIKit

struct DrawerData {
    let imageIcon: String
    let title: String
}

protocol DrawerControllerDelegate: AnyObject {
    func didSelectDrawerItem(at index: Int, menuItem: DrawerItems)
}

enum DrawerItems: String, CaseIterable {
    case menu = "Menu"
    case history = "History"
    case account = "Account"
    case queue = "Queue"
//    case notification = "Notification"
    case termsCondition = "Terms & Condition"
    case contactUs = "Contact Us"
    case settings = "Settings"
//    case logout = "Logout"
    
    var vc: UIViewController {
        switch self {
        case .menu:
            return MenuViewController()
        case .history:
            return HistoryViewController()
        case .account:
            return AccountViewController()
        case .queue:
            return QueueViewController()
//        case .notification:
//            return NotificationViewController()
        case .termsCondition:
            return WebViewController()
        case .contactUs:
            return ContactUsViewController()
        case .settings:
            return SettingsViewController()
//        case .logout:
//            return MenuViewController()
        }
    }
    
    var imageName: String {
        switch self {
        case .menu:
            return "house.fill" // "fork.knife"
        case .history:
            return "clock.arrow.circlepath"
        case .account:
            return "person.fill"
        case .queue:
            return "arrow.clockwise.icloud.fill"
//        case .notification:
//            return "bell.fill"
        case .termsCondition:
            return "checkmark.shield.fill"
        case .contactUs:
            return "ic_contact_us" // "questionmark.circle.fill"
        case .settings:
            return "gearshape.fill"
//        case .logout:
//            return "power"
        }
    }
}
 
class DrawerController: UIViewController {
    
    weak var drawerControllerDelegate: DrawerControllerDelegate?
    
    private var models = [DrawerData]()
    
    init(with drawerItems: [DrawerItems]) {
        self.drawerItems = drawerItems
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let drawerItems: [DrawerItems]
    
    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        table.isHidden = true
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        table.register(DrawerTableViewCell.self, forCellReuseIdentifier: DrawerTableViewCell.identifier)
        return table
    }()
    
    private let tableHeaderView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.layer.masksToBounds = true
        return view
    }()
    
    private let logoImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "alyx_logo_white")
        imageView.contentMode = .scaleAspectFit
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 0
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let versionLabelContainer: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.layer.masksToBounds = true
        return view
    }()
    
    private let versionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = Constants.whiteLabelColor
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        label.text = Constants.version
        label.textAlignment = .left
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Constants.drawerBackgroundColor
        
        view.addSubview(tableHeaderView)
        tableHeaderView.addSubview(logoImage)
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = Constants.drawerTableBackgroundColor
        view.addSubview(versionLabelContainer)
        versionLabelContainer.addSubview(versionLabel)
        
        
        
        updateUI()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let headerViewSize = view.width
        let versionLabelContainerHeight: CGFloat = 44.0
        
//        tableView.frame = view.bounds
        tableView.frame = CGRect(x: 0, y: 0, width: view.width, height: view.height-versionLabelContainerHeight-view.safeAreaInsets.bottom)
        
        
        tableHeaderView.frame = CGRect(x: 0, y: 0, width: headerViewSize, height: headerViewSize*0.5)
        //        tableHeaderView.backgroundColor = .purple
        
        
        let imageSize: CGFloat = tableHeaderView.width/3
        logoImage.frame = CGRect(x: (tableHeaderView.width-imageSize)/2,
                                 y: (tableHeaderView.height-imageSize)/2,
                                 width: imageSize,
                                 height: imageSize)
        //        logoImage.backgroundColor = .red
        
        tableView.tableHeaderView = tableHeaderView
        tableView.separatorStyle = .none
        
        versionLabelContainer.frame = CGRect(
            x: 16,
            y: tableView.bottom,
            width: view.width-32,
            height: versionLabelContainerHeight)
//        versionLabelContainer.backgroundColor = .green
        versionLabel.frame = versionLabelContainer.bounds
    }
    
    private func updateUI() {
        tableView.isHidden = false
    }
    
    private func failedToGetProfile() {
        let label = UILabel(frame: .zero)
        label.text = "Failed to load profile."
        label.sizeToFit()
        label.textColor = .white
        view.addSubview(label)
        label.center = view.center
    }
    
}

extension DrawerController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DrawerItems.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: DrawerTableViewCell.identifier, for: indexPath) as? DrawerTableViewCell else {
            return UITableViewCell()
        }
        cell.backgroundColor = Constants.drawerTableViewCellBackgroundColor
        cell.selectionStyle = .default
        
        cell.configure(with: DrawerData(
                        imageIcon: DrawerItems.allCases[indexPath.row].imageName,
                        title: DrawerItems.allCases[indexPath.row].rawValue))
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
//        print(indexPath.row)
        
        let selectedItem = DrawerItems.allCases[indexPath.row] // drawerItems[indexPath.row]
        
        if indexPath != tableView.lastIndexpath() {
            print(selectedItem)
        } else {
            print("Logging OUT!")
        }
        
        drawerControllerDelegate?.didSelectDrawerItem(at: indexPath.row, menuItem: selectedItem)
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
}

