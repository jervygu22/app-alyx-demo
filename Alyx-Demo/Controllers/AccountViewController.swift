//
//  AccountViewController.swift
//  Jeeves-dev
//
//  Created by Jervy Umandap on 2/4/22.
//

import UIKit

struct ShiftSection {
    let id: Int
    let title: String
    let options: [ShiftOption]
}

struct ShiftOption {
    let id: Int
    let title: String
//    let handler: () -> Void
}

enum AccountSectionType {
    case inOutSection(viewModels: [ShiftOption])
    case shiftSetion(viewModels: [ShiftOption])
    
    var title: String {
        switch self {
        case .inOutSection:
            return String().todayToString(with: AccountViewController.staffName)
        case .shiftSetion:
            return "Select your Shift"
        }
    }
}

protocol AccountViewControllerDelegate: AnyObject {
    func cashierInfo(data: CashierInfoViewModel)
}


class AccountViewController: UIViewController, EnterPasscodeViewControllerDelegate {
    
    weak var accountViewControllerDelegate: AccountViewControllerDelegate?
    
    private var users: [Users] = []
    
    public var selected_InOut: String?
    public var selected_shift: String?
    public var selected_timeSched: String?
    
    private var type: ShiftOption?
    private var shift: ShiftOption?
    private var sched: ShiftOption?
    
//    private var shiftSection = [ShiftSection]()
    private var accountSection = [AccountSectionType]()
    
    private var employeeShifts = [EmployeeShiftTypeData]()
    
    private var newEmployeeShifts = [NewShift]()
    
    private var unlosedAttendance = [GetAttendanceData]()
    
    var selectedIndexPath: IndexPath?
    
    public var collectionView: UICollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewCompositionalLayout { (sectionIndex, _) -> NSCollectionLayoutSection? in
            return AccountViewController.createSectionLayout(section: sectionIndex)
        }
    )
    
    private let passCodeField: UITextField = {
        let textField = UITextField()
        textField.textColor = Constants.blackLabelColor
        textField.textAlignment = .center
        textField.borderStyle = .roundedRect
        textField.font = UIFont.systemFont(ofSize: 30, weight: .heavy)
        textField.keyboardType = .numberPad
//        textField.placeholder = "Passcode"
        
        textField.attributedPlaceholder = NSAttributedString(
            string: "Passcode",
            attributes: [NSAttributedString.Key.foregroundColor : Constants.lightGrayColor])
        
        
        return textField
    }()
    
    public let bottomContainer: UIView = {
        let container = UIView(frame: .zero)
        container.layer.masksToBounds = true
        container.clipsToBounds = true
        container.isHidden = true
        return container
    }()
    
    private let actualTimeLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = Constants.secondaryLabelColor
        label.font = .systemFont(ofSize: 20, weight: .medium)
        label.text = "Actual Time: "
        label.textAlignment = .right
        return label
    }()
    
    private let actualTimeValueLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = Constants.blackLabelColor
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.text = "3:00 pm"
        label.textAlignment = .left
        return label
    }()
    
    private let workTimeLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = Constants.secondaryLabelColor
        label.font = .systemFont(ofSize: 20, weight: .medium)
        label.text = "Work Time: "
        label.textAlignment = .right
        return label
    }()
    
    private let workTimeValueLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = Constants.blackLabelColor
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.text = "7 hours"
        label.textAlignment = .left
        return label
    }()
    
    static var staffName = UserDefaults.standard.string(forKey: "pin_entered_username") ?? "Staff" //"Staff"
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isDeviceAuthorized()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Account"
        view.backgroundColor = Constants.whiteBackgroundColor
        
        fetchData()
        fetchUnclosedAttendance()
        
        configureCollectionView()
        configureBottomContainer()
        
        
        selected_timeSched = "9am"
    }
    
    func dataReceived(data: UserPassingData) {
        print("UserPassingData:  \(data.userLogin), \(data.userName), \(data.currentTime), \(data.workingTime)")
        DispatchQueue.main.async {
            AccountViewController.staffName = data.userName.capitalized //data.userLogin
            
            self.accountViewControllerDelegate?.cashierInfo(data: CashierInfoViewModel(
                name: data.userName,
                userRole: data.userRole,
                userImageUrl: data.userImage))
            
            self.actualTimeValueLabel.text = data.currentTime
            self.workTimeValueLabel.text = data.workingTime
            self.collectionView.reloadData()
            self.bottomContainer.isHidden = false
        }
    }
    
    public func fetchUnclosedAttendance() {
        unlosedAttendance.removeAll()
        APICaller.shared.getUnclosedAttendance { [weak self] result in
            switch result {
            case .success(let model):
                print("fetchUnclosedAttendance: \(model.data)")
                self?.unlosedAttendance = model.data
            case .failure(let error):
                print("fetchUnclosedAttendance error: \(error.localizedDescription)")
            }
        }
    }
    
    private func configureBottomContainer() {
        view.addSubview(bottomContainer)
        bottomContainer.addTopBorder(with: Constants.lightGrayBorderColor, andWidth: 0.5)
        bottomContainer.addSubview(actualTimeLabel)
        bottomContainer.addSubview(actualTimeValueLabel)
        bottomContainer.addSubview(workTimeLabel)
        bottomContainer.addSubview(workTimeValueLabel)
    }
    
    private func didTapOption(with name: String) {
        print("Did tap ", name)
    }
    
    public func fetchData() {
        
        users.removeAll()
        employeeShifts.removeAll()
        newEmployeeShifts.removeAll()
        
        
        let dispatchGroup = DispatchGroup()
        var users: [Users]?
        var employeeShifts: [EmployeeShiftTypeData]?
        var newEmployeeShifts: [NewShift]?
        
        dispatchGroup.enter()
        APICaller.shared.getAllUsers { result in
            defer {
                dispatchGroup.leave()
            }
            switch result {
            case .success(let model):
                users = model.data
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        
        dispatchGroup.enter()
        APICaller.shared.getJeevesEmployeeShifts { result in
            defer {
                dispatchGroup.leave()
            }
            switch result {
            case .success(let model):
                employeeShifts = model.data
            break
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        
        dispatchGroup.enter()
        APICaller.shared.getNewShifts { result in
            defer {
                dispatchGroup.leave()
            }
            switch result {
            case .success(let model):
                newEmployeeShifts = model.shifts
            break
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        
        
        dispatchGroup.notify(queue: .main) {
            guard let users = users,
                  let employeeShifts = employeeShifts,
                  let newEmployeeShifts = newEmployeeShifts else {
                return
            }
            
            DispatchQueue.main.async { [weak self] in
                self?.configureModels(users: users, shifts: employeeShifts, newShifts: newEmployeeShifts)
            }
        }
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
    
    private func configureModels(users: [Users], shifts: [EmployeeShiftTypeData], newShifts: [NewShift]) {
        
        accountSection.removeAll()
        
        self.users = users
        self.employeeShifts = shifts
        self.newEmployeeShifts = newShifts
        
        var type: ShiftSection?
        var shift: ShiftSection?
        
        print("newEmployeeShifts: \(newEmployeeShifts)")
        
        type = ShiftSection(id: 1, title: "", options: [
            ShiftOption(id: 1, title: "In"),
            ShiftOption(id: 2, title: "Out")
        ])
        
//        shift = ShiftSection(id: 2, title: "Select your Shift", options: [
//            ShiftOption(id: 1, title: "Opening"),
//            ShiftOption(id: 2, title: "Middle"),
//            ShiftOption(id: 3, title: "Closing"),
//            ShiftOption(id: 4, title: "Graveyard")
//        ])
        
        shift = ShiftSection(id: 2, title: "Select your Shift", options: employeeShifts.compactMap({ shft in
            return ShiftOption(id: 0, title: shft.shift_code.capitalized)
        }))
        
        
        guard let safetype = type,
              let safeShift = shift else {
            return
        }
        
        accountSection.append(.inOutSection(viewModels: safetype.options))
        accountSection.append(.shiftSetion(viewModels: safeShift.options))
        
        collectionView.reloadData()
    }
    
    private func configureCollectionView() {
        view.addSubview(collectionView)
        collectionView.backgroundColor = Constants.whiteBackgroundColor
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.register(ShiftCollectionViewCell.self, forCellWithReuseIdentifier: ShiftCollectionViewCell.identifier)
        
        collectionView.register(
            TitleHeaderCollectionReusableView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: TitleHeaderCollectionReusableView.identifier)
        
        collectionView.allowsMultipleSelection = true
        collectionView.bounces = false
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let bottomContainerHeight: CGFloat = 40.0 // 60
        let bottomContainerWidth: CGFloat = view.width-20
        let labelWidth: CGFloat = (bottomContainer.width-10)/2
        
        collectionView.frame = CGRect(
            x: 0,
            y: 0,
            width: view.width,
            height: view.height-bottomContainerHeight-view.safeAreaInsets.bottom)
        
        bottomContainer.frame = CGRect(
            x: 10,
            y: collectionView.bottom,
            width: bottomContainerWidth,
            height: bottomContainerHeight)
        
        actualTimeLabel.frame = CGRect(
            x: 0,
            y: 10, // 0,
            width: labelWidth,
            height: bottomContainer.height/2)
        actualTimeValueLabel.frame = CGRect(
            x: actualTimeLabel.right+10,
            y: 10, // 0
            width: labelWidth,
            height: bottomContainer.height/2)
        
        
//        workTimeLabel.frame = CGRect(
//            x: 0,
//            y: currentTimeLabel.bottom,
//            width: labelWidth,
//            height: bottomContainer.height/2)
//        workTimeValueLabel.frame = CGRect(
//            x: workTimeLabel.right+10,
//            y: currentTimeValueLabel.bottom,
//            width: labelWidth,
//            height: bottomContainer.height/2)
        
    }
}

extension AccountViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return accountSection.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let type = accountSection[section]
        switch type {
        case .inOutSection(let viewModels):
            return viewModels.count
        case .shiftSetion(let viewModels):
            return viewModels.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let type = accountSection[indexPath.section]
        switch type {
        case .inOutSection(let viewModels):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ShiftCollectionViewCell.identifier, for: indexPath) as? ShiftCollectionViewCell else {
                return UICollectionViewCell()
            }
            let model = viewModels[indexPath.row]
            cell.configure(withModel: OptionsCollectionViewCellViewModel(id: model.id, data: model.title, image: nil, addOnPrice: nil))
            return cell
        case .shiftSetion(let viewModels):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ShiftCollectionViewCell.identifier, for: indexPath) as? ShiftCollectionViewCell else {
                return UICollectionViewCell()
            }
            let model = viewModels[indexPath.row]
            cell.configure(withModel: OptionsCollectionViewCellViewModel(id: model.id, data: model.title, image: nil, addOnPrice: nil))
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        collectionView.indexPathsForSelectedItems?.filter({ $0.section == indexPath.section }).forEach({ collectionView.deselectItem(at: $0, animated: false) })
        return true
    }
    
    func getAllIndexPathsInSection(section : Int) -> [IndexPath] {
        let count = collectionView.numberOfItems(inSection: section)
        return (0..<count).map { IndexPath(row: $0, section: section) }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let type = accountSection[indexPath.section]
//        print(shifts)
        
        switch type {
        case .inOutSection(let viewModels):
            print("didTap: ", viewModels[indexPath.row].title)
            selected_InOut = viewModels[indexPath.row].title
            
            return
        case .shiftSetion(let viewModels):
            print("didTap: ", viewModels[indexPath.row].title)
            
            selected_shift = viewModels[indexPath.row].title
            
            
            guard let selected_InOut = selected_InOut,
                  let selected_shift = selected_shift else {
                return
            }

            print("showing alert")

            let alert = UIAlertController(
                title: "Confirm attendance",
                message: "You are about to send the following attendance details: \n\nTime \(selected_InOut): \(Date().attendanceDate())\nShift: \(selected_shift)\n\nIs this correct?",
                preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
                self.showAlert()
            }))


            DispatchQueue.main.async {
                self.present(alert, animated: true, completion: nil)
            }
            
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: TitleHeaderCollectionReusableView.identifier,
                for: indexPath) as? TitleHeaderCollectionReusableView, kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }
        
        let section = indexPath.section
        let title = accountSection[section].title
        
        header.configure(withTitle: title)
        return header
    }
    
    private func showAlert() {
        
        print("users: \(users)")
        
        print("Alert showed!")
        guard let selected_InOut = selected_InOut?.lowercased(),
              let selected_shift = selected_shift?.lowercased(),
              let selected_timeSched = selected_timeSched else {
//            let userID = AuthManager.shared.userID
            return
        }
        let currentMonth = Date().currentMonth()
        let currentDate = Date().currentDate()
        let currentYear = Date().currentYear()
        let currentHour = Date().currentHour()
        let currentMinute = Date().currentMinute()
        
        let workingDate = UserDefaults.standard.string(forKey: Constants.pin_entered_work_date)
        
        print("Selected Time In/ Out: ", selected_InOut)
        print("Selected Shift: ", selected_shift)
        print("Selected start time: ", selected_timeSched) // add to api
//        print("UserID: ", userID)
        print("month: ", currentMonth)
        print("date: ", currentDate)
        print("year: ", currentYear)
        print("hour: ", currentHour)
        print("minute: ", currentMinute)
        
        createEnterPasscodeView(
            users: users,
            selected_InOut: selected_InOut,
            selected_shift: selected_shift,
            workDate: workingDate ?? Date().workDate())
        
//        createEnterPasscodeView(
//            users: users,
//            selected_InOut: selected_InOut,
//            selected_shift: selected_shift,
//            selected_timeSched: selected_timeSched,
//            currentMonth: currentMonth,
//            currentDate: currentDate,
//            currentYear: currentYear,
//            currentHour: currentHour,
//            currentMinute: currentMinute)
        
//        let alert = UIAlertController(
//            title: "Enter your passcode",
//            message: "",
//            preferredStyle: .alert)
//
//        alert.addTextField { (textField) in
//            textField.placeholder = "Passcode"
//            textField.keyboardType = .numberPad
//            textField.isSecureTextEntry = true
//        }
//
//        alert.addAction(
//            UIAlertAction(
//                title: "Cancel",
//                style: .cancel,
//                handler: nil))
//
//        alert.addAction(
//            UIAlertAction(
//                title: "Continue",
//                style: .default,
//                handler: { [weak self] _ in
//                    // Read text values
//                    guard let fields = alert.textFields?.first,
//                          let passcode = fields.text,
//                          !passcode.trimmingCharacters(in: .whitespaces).isEmpty else {
//                        print("Enter your code!")
//                        return
//                    }
//
//                    guard let strongSelf = self else {
//                        return
//                    }
//
//                    // verify user
//                    if strongSelf.users.contains(where: { $0.user_pin == passcode }) {
//                        print("Passcode verified: ", passcode)
//
//                        // get user data
//                        guard let userPassingCode = strongSelf.users.filter( { $0.user_pin == passcode }).first else {
//                            return
//                        }
//
//                        APICaller.shared.postAttendance(
//                            userId: userPassingCode.user_id,
//                            type: selected_InOut,
//                            shift: selected_shift,
//                            currentMonth: currentMonth,
//                            currentDate: currentDate,
//                            currentYear: currentYear,
//                            currentHour: currentHour,
//                            currentMinute: currentMinute) { (success) in
//                            if success {
//                                // go back
//                                DispatchQueue.main.async {
//                                    AccountViewController.staffName = userPassingCode.user_login
//                                    print("Hi! ", AccountViewController.staffName)
//
//                                    strongSelf.bottomContainer.isHidden = false
//
//
//                                    // display current time
//                                    strongSelf.currentTimeValueLabel.text = Date().current12FHour()
//                                    // display remaining hrs of duty
//                                    strongSelf.workTimeValueLabel.text = "7 hours"
//
//                                    strongSelf.collectionView.reloadData()
//                                }
//                            } else {
//                                print("Failed to post attendance")
//                            }
//                        }
//
//                    } else {
//                        print("Invalid passcode!- ", passcode)
//                    }
//
//                    // save time-in info
//
//                    // post attendance
//
//
//                }
//            )
//        )
//        present(alert, animated: true, completion: nil)
        
    }
    
    
//    func createEnterPasscodeView(users: [Users], selected_InOut: String, selected_shift: String, selected_timeSched: String, currentMonth: Int, currentDate: Int, currentYear: Int, currentHour: Int, currentMinute: Int) {
//        let vc = EnterPasscodeViewController(users: users, selected_InOut: selected_InOut, selected_shift: selected_shift, selected_timeSched: selected_timeSched, currentMonth: currentMonth, currentDate: currentDate, currentYear: currentYear, currentHour: currentHour, currentMinute: currentMinute)
//        vc.enterPasscodeViewControllerDelegate = self
//        vc.modalPresentationStyle = .overFullScreen
//        vc.modalTransitionStyle = .crossDissolve
//        present(vc, animated: true, completion: nil)
//    }
    
    
    func createEnterPasscodeView(users: [Users], selected_InOut: String, selected_shift: String, workDate: String) {
        
        let vc = EnterPasscodeViewController(users: users, selected_InOut: selected_InOut, selected_shift: selected_shift, workDate: workDate, unclosedAttandance: self.unlosedAttendance)
        
        vc.enterPasscodeViewControllerDelegate = self
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        present(vc, animated: true, completion: nil)
    }
}


// MARK:- CollectionView Sections Layout
extension AccountViewController {
    static func createSectionLayout(section: Int) -> NSCollectionLayoutSection? {
        
        let supplementaryViews = [
            NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .absolute(50)
                ),
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top
            )
        ]
        
        // Item
        let item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(1.0)
            )
        )
        item.contentInsets = NSDirectionalEdgeInsets(
            top: 0,
            leading: 10,
            bottom: 20,
            trailing: 10)
        
        // Group
        // vertical group inside horizontal group
        let hGroup = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(60.0)
            ),
            subitem: item,
            count: 3)
        
        let vGroup = NSCollectionLayoutGroup.vertical(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(60.0)
            ),
            subitem: hGroup,
            count: 1)
        
        // Section
        let section = NSCollectionLayoutSection(group: vGroup)
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 0,
            leading: 20,
            bottom: 0,
            trailing: 20)
        
        section.boundarySupplementaryItems = supplementaryViews
//        section.orthogonalScrollingBehavior = .continuous
        return section
    }
}
 





//
//  AccountViewController.swift
//  app-jeeves-reboot
//
//  Created by Jervy Umandap on 11/15/21.
//

//import UIKit
//
//struct ShiftSection {
//    let id: Int
//    let title: String
//    let options: [ShiftOption]
//}
//
//struct ShiftOption {
//    let id: Int
//    let title: String
////    let handler: () -> Void
//}
//
//enum AccountSectionType {
//    case inOutSection(viewModels: [ShiftOption])
//    case shiftSetion(viewModels: [ShiftOption])
//    case timeSchedSection(viewModels: [ShiftOption])
//
//    var title: String {
//        switch self {
//        case .inOutSection:
//            return String().todayToString(with: AccountViewController.staffName)
//        case .shiftSetion:
//            return "Select your Shift"
//        case .timeSchedSection:
//            return "Select your Sched"
//        }
//    }
//}
//
//
//class AccountViewController: UIViewController, EnterPasscodeViewControllerDelegate {
//
//    private var users: [Users] = []
//
//    private var selected_InOut: String?
//    private var selected_shift: String?
//    private var selected_timeSched: String?
//
//    private var type: ShiftOption?
//    private var shift: ShiftOption?
//    private var sched: ShiftOption?
//
////    private var shiftSection = [ShiftSection]()
//    private var accountSection = [AccountSectionType]()
//
//    private var shifts: EmployeeShiftType?
//    //
//    var selectedIndexPath: IndexPath?
//
//    private var collectionView: UICollectionView = UICollectionView(
//        frame: .zero,
//        collectionViewLayout: UICollectionViewCompositionalLayout { (sectionIndex, _) -> NSCollectionLayoutSection? in
//            return AccountViewController.createSectionLayout(section: sectionIndex)
//        }
//    )
//
//    private let passCodeField: UITextField = {
//        let textField = UITextField()
//        textField.textColor = Constants.blackLabelColor
//        textField.textAlignment = .center
//        textField.borderStyle = .roundedRect
//        textField.font = UIFont.systemFont(ofSize: 30, weight: .heavy)
//        textField.keyboardType = .numberPad
//        textField.placeholder = "Passcode"
//        return textField
//    }()
//
//    private let bottomContainer: UIView = {
//        let container = UIView(frame: .zero)
//        container.layer.masksToBounds = true
//        container.clipsToBounds = true
//        container.isHidden = true
//        return container
//    }()
//
//    private let currentTimeLabel: UILabel = {
//        let label = UILabel()
//        label.numberOfLines = 0
//        label.textColor = Constants.secondaryLabelColor
//        label.font = .systemFont(ofSize: 20, weight: .medium)
//        label.text = "Current Time: "
//        label.textAlignment = .right
//        return label
//    }()
//
//    private let currentTimeValueLabel: UILabel = {
//        let label = UILabel()
//        label.numberOfLines = 0
//        label.textColor = Constants.blackLabelColor
//        label.font = .systemFont(ofSize: 20, weight: .bold)
//        label.text = "3:00 pm"
//        label.textAlignment = .left
//        return label
//    }()
//
//    private let workTimeLabel: UILabel = {
//        let label = UILabel()
//        label.numberOfLines = 0
//        label.textColor = Constants.secondaryLabelColor
//        label.font = .systemFont(ofSize: 20, weight: .medium)
//        label.text = "Work Time: "
//        label.textAlignment = .right
//        return label
//    }()
//
//    private let workTimeValueLabel: UILabel = {
//        let label = UILabel()
//        label.numberOfLines = 0
//        label.textColor = Constants.blackLabelColor
//        label.font = .systemFont(ofSize: 20, weight: .bold)
//        label.text = "7 hours"
//        label.textAlignment = .left
//        return label
//    }()
//
//    static var staffName = "Staff"
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        title = "Account"
//        view.backgroundColor = Constants.whiteBackgroundColor
//
//        fetchUsers()
//        fetchShifts()
//
//        configureCollectionView()
//        configureSections()
//        configureBottomContainer()
//
//
//
//        APICaller.shared.getSchedules { result in
//            switch result {
//            case .success:
//                break
//            case .failure(let error):
//                print(error.localizedDescription)
//            }
//        }
//    }
//
//    func dataReceived(data: UserPassingData) {
//        print("UserPassingData:  \(data.name), \(data.currentTime), \(data.workingTime)")
//        DispatchQueue.main.async {
//            AccountViewController.staffName = data.name
//            self.currentTimeValueLabel.text = data.currentTime
//            self.workTimeValueLabel.text = data.workingTime
//            self.collectionView.reloadData()
//            self.bottomContainer.isHidden = false
//        }
//    }
//
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        let bottomContainerHeight: CGFloat = 60.0
//        let bottomContainerWidth: CGFloat = view.width-20
//        let labelWidth: CGFloat = (bottomContainer.width-10)/2
//
//        collectionView.frame = CGRect(
//            x: 0,
//            y: 0,
//            width: view.width,
//            height: view.height-bottomContainerHeight-view.safeAreaInsets.bottom)
//
//        bottomContainer.frame = CGRect(
//            x: 10,
//            y: collectionView.bottom,
//            width: bottomContainerWidth,
//            height: bottomContainerHeight)
//
//        currentTimeLabel.frame = CGRect(
//            x: 0,
//            y: 0,
//            width: labelWidth,
//            height: bottomContainer.height/2)
//        currentTimeValueLabel.frame = CGRect(
//            x: currentTimeLabel.right+10,
//            y: 0,
//            width: labelWidth,
//            height: bottomContainer.height/2)
//
//        workTimeLabel.frame = CGRect(
//            x: 0,
//            y: currentTimeLabel.bottom,
//            width: labelWidth,
//            height: bottomContainer.height/2)
//        workTimeValueLabel.frame = CGRect(
//            x: workTimeLabel.right+10,
//            y: currentTimeValueLabel.bottom,
//            width: labelWidth,
//            height: bottomContainer.height/2)
//
//    }
//
//    private func configureSections() {
//        var type: ShiftSection?
//        var shift: ShiftSection?
//        var sched: ShiftSection?
//
//        type = ShiftSection(id: 1, title: "", options: [
//            ShiftOption(id: 1, title: "In"),
//            ShiftOption(id: 2, title: "Out")
//        ])
//
//        shift = ShiftSection(id: 2, title: "Select your Shift", options: [
//            ShiftOption(id: 1, title: "Opening"),
//            ShiftOption(id: 2, title: "Middle"),
//            ShiftOption(id: 3, title: "Closing"),
//            ShiftOption(id: 4, title: "Graveyard")
//        ])
//
//        sched = ShiftSection(id: 3, title: "Select your Sched", options: [
//            ShiftOption(id: 3, title: "8am"),
//            ShiftOption(id: 4, title: "9am"),
//            ShiftOption(id: 5, title: "10am")
//        ])
//
//        guard let safetype = type,
//              let safeShift = shift,
//              let safeSched = sched else {
//            return
//        }
//
//        accountSection.append(.inOutSection(viewModels: safetype.options))
//        accountSection.append(.shiftSetion(viewModels: safeShift.options))
//        accountSection.append(.timeSchedSection(viewModels: safeSched.options))
//    }
//
//    private func configureBottomContainer() {
//        view.addSubview(bottomContainer)
//        bottomContainer.addTopBorder(with: Constants.lightGrayBorderColor, andWidth: 0.5)
//        bottomContainer.addSubview(currentTimeLabel)
//        bottomContainer.addSubview(currentTimeValueLabel)
//        bottomContainer.addSubview(workTimeLabel)
//        bottomContainer.addSubview(workTimeValueLabel)
////        bottomContainer.backgroundColor = .green
//
////        currentTimeLabel.backgroundColor = .green
////        workTimeLabel.backgroundColor = .blue
////        currentTimeValueLabel.backgroundColor = .blue
////        workTimeValueLabel.backgroundColor = .green
//    }
//
//    private func didTapOption(with name: String) {
//        print("Did tap ", name)
//    }
//
//    private func fetchUsers() {
//        APICaller.shared.getUsersRoles { [weak self] result in
//            switch result {
//            case .success(let model):
//                self?.users = model.data
//            case .failure(let error):
//                print(error.localizedDescription)
//            }
//        }
//    }
//
//    private func fetchShifts() {
//        APICaller.shared.getJeevesEmployeeShifts { [weak self] result in
//            switch result {
//            case .success(let model):
//                self?.shifts = model
//            break
//            case .failure(let error):
//                print(error.localizedDescription)
//            }
//        }
//    }
//
//    private func configureCollectionView() {
//        view.addSubview(collectionView)
//        collectionView.backgroundColor = Constants.whiteBackgroundColor
//        collectionView.delegate = self
//        collectionView.dataSource = self
//
//        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
//        collectionView.register(ShiftCollectionViewCell.self, forCellWithReuseIdentifier: ShiftCollectionViewCell.identifier)
//
//        collectionView.register(
//            TitleHeaderCollectionReusableView.self,
//            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
//            withReuseIdentifier: TitleHeaderCollectionReusableView.identifier)
//
//        collectionView.allowsMultipleSelection = true
//        collectionView.bounces = false
//    }
//}
//
//extension AccountViewController: UICollectionViewDelegate, UICollectionViewDataSource {
//
//    func numberOfSections(in collectionView: UICollectionView) -> Int {
//        return accountSection.count
//    }
//
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        let type = accountSection[section]
//        switch type {
//        case .inOutSection(let viewModels):
//            return viewModels.count
//        case .shiftSetion(let viewModels):
//            return viewModels.count
//        case .timeSchedSection(let viewModels):
//            return viewModels.count
//        }
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let type = accountSection[indexPath.section]
//        switch type {
//        case .inOutSection(let viewModels):
//            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ShiftCollectionViewCell.identifier, for: indexPath) as? ShiftCollectionViewCell else {
//                return UICollectionViewCell()
//            }
//            let model = viewModels[indexPath.row]
//            cell.configure(withModel: OptionsCollectionViewCellViewModel(id: model.id, data: model.title))
//            return cell
//        case .shiftSetion(let viewModels):
//            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ShiftCollectionViewCell.identifier, for: indexPath) as? ShiftCollectionViewCell else {
//                return UICollectionViewCell()
//            }
//            let model = viewModels[indexPath.row]
//            cell.configure(withModel: OptionsCollectionViewCellViewModel(id: model.id, data: model.title))
//            return cell
//        case .timeSchedSection(let viewModels):
//            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ShiftCollectionViewCell.identifier, for: indexPath) as? ShiftCollectionViewCell else {
//                return UICollectionViewCell()
//            }
////            let model1 = viewModels.sort{ $0.id < $0.id })
//            let model = viewModels[indexPath.row]
//
//            cell.configure(withModel: OptionsCollectionViewCellViewModel(id: model.id, data: model.title))
//            return cell
//        }
//    }
//
//    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
//        collectionView.indexPathsForSelectedItems?.filter({ $0.section == indexPath.section }).forEach({ collectionView.deselectItem(at: $0, animated: false) })
//        return true
//    }
//
//    func getAllIndexPathsInSection(section : Int) -> [IndexPath] {
//        let count = collectionView.numberOfItems(inSection: section)
//        return (0..<count).map { IndexPath(row: $0, section: section) }
//    }
//
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let type = accountSection[indexPath.section]
////        print(shifts)
//
//        switch type {
//        case .inOutSection(let viewModels):
//            print("didTap: ", viewModels[indexPath.row].title)
//            selected_InOut = viewModels[indexPath.row].title
//
//            return
//        case .shiftSetion(let viewModels):
//            print("didTap: ", viewModels[indexPath.row].title)
//
//            configureSched(index: indexPath.row, section: indexPath.section+1) // plus 1 to reflect in the next section
//
//            selected_shift = viewModels[indexPath.row].title
//            return
//        case .timeSchedSection(let viewModels):
//            print("didTap: ", viewModels[indexPath.row].title)
//            selected_timeSched = viewModels[indexPath.row].title
//
//            print("Sched count", viewModels.count)
//
//            DispatchQueue.main.async {
//                self.showAlert()
//            }
//        }
//
//    }
//
//    private func configureSched(index: Int, section: Int) {
//        var open: ShiftSection?
//        var mid: ShiftSection?
//        var close: ShiftSection?
//        var grave: ShiftSection?
//
//        guard let openingShift = shifts?.opening,
//              let midShift = shifts?.mid,
//              let closeShift = shifts?.closing,
//              let graveShift = shifts?.graveyard else {
//            return
//        }
//
//        open = ShiftSection(id: 3, title: "Select your Sched", options: openingShift.compactMap({
//            ShiftOption(
//                id: $0.id,
//                title: $0.time_in) // Date().intToTwelve(with: $0.time_in)
//        }))
//        mid = ShiftSection(id: 3, title: "Select your Sched", options: midShift.compactMap({
//            ShiftOption(
//                id: $0.id,
//                title: $0.time_in)
//        }))
//        close = ShiftSection(id: 3, title: "Select your Sched", options: closeShift.compactMap({
//            ShiftOption(
//                id: $0.id,
//                title: $0.time_in)
//        }))
//        grave = ShiftSection(id: 3, title: "Select your Sched", options: graveShift.compactMap({
//            ShiftOption(
//                id: $0.id,
//                title: $0.time_in)
//        }))
//
//        switch index {
//        case 0:
//            if accountSection.count == 3 {
//                accountSection.removeLast()
//            }
//
//            guard let open = open else { return }
//            accountSection.append(.timeSchedSection(viewModels: open.options))
//
//            DispatchQueue.main.async {
////                self.collectionView.reloadItems(at: self.getAllIndexPathsInSection(section: section))
//                self.collectionView.reloadSections(IndexSet(integer: section))
//            }
//
//        case 1:
//            if accountSection.count == 3 {
//                accountSection.removeLast()
//            }
//
//            guard let mid = mid else { return }
//            accountSection.append(.timeSchedSection(viewModels: mid.options))
//            DispatchQueue.main.async {
////                self.collectionView.reloadItems(at: self.getAllIndexPathsInSection(section: section))
//                self.collectionView.reloadSections(IndexSet(integer: section))
//            }
//        case 2:
//            if accountSection.count == 3 {
//                accountSection.removeLast()
//            }
//
//            guard let close = close else { return }
//            accountSection.append(.timeSchedSection(viewModels: close.options))
//            DispatchQueue.main.async {
////                self.collectionView.reloadItems(at: self.getAllIndexPathsInSection(section: section))
//                self.collectionView.reloadSections(IndexSet(integer: section))
//            }
//        case 3:
//            if accountSection.count == 3 {
//                accountSection.removeLast()
//            }
//
//            guard let grave = grave else { return }
//            accountSection.append(.timeSchedSection(viewModels: grave.options))
//            DispatchQueue.main.async {
////                self.collectionView.reloadItems(at: self.getAllIndexPathsInSection(section: section))
//                self.collectionView.reloadSections(IndexSet(integer: section))
//            }
//        default:
//            break
//        }
//    }
//
//    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
//        guard let header = collectionView.dequeueReusableSupplementaryView(
//                ofKind: kind,
//                withReuseIdentifier: TitleHeaderCollectionReusableView.identifier,
//                for: indexPath) as? TitleHeaderCollectionReusableView, kind == UICollectionView.elementKindSectionHeader else {
//            return UICollectionReusableView()
//        }
//
//        let section = indexPath.section
//        let title = accountSection[section].title
//
//        header.configure(withTitle: title)
//        return header
//    }
//
//    private func showAlert() {
//        guard let selected_InOut = selected_InOut?.lowercased(),
//              let selected_shift = selected_shift?.lowercased(),
//              let selected_timeSched = selected_timeSched,
//              let userID = AuthManager.shared.userID else {
//            return
//        }
//        let currentMonth = Date().currentMonth()
//        let currentDate = Date().currentDate()
//        let currentYear = Date().currentYear()
//        let currentHour = Date().currentHour()
//        let currentMinute = Date().currentMinute()
//
//        print("Selected Time In/ Out: ", selected_InOut)
//        print("Selected Shift: ", selected_shift)
//        print("Selected start time: ", selected_timeSched) // add to api
//        print("UserID: ", userID)
//        print("month: ", currentMonth)
//        print("date: ", currentDate)
//        print("year: ", currentYear)
//        print("hour: ", currentHour)
//        print("minute: ", currentMinute)
//
//        createEnterPasscodeView(
//            users: users,
//            selected_InOut: selected_InOut,
//            selected_shift: selected_shift,
//            selected_timeSched: selected_timeSched,
//            currentMonth: currentMonth,
//            currentDate: currentDate,
//            currentYear: currentYear,
//            currentHour: currentHour,
//            currentMinute: currentMinute)
//
////        let alert = UIAlertController(
////            title: "Enter your passcode",
////            message: "",
////            preferredStyle: .alert)
////
////        alert.addTextField { (textField) in
////            textField.placeholder = "Passcode"
////            textField.keyboardType = .numberPad
////            textField.isSecureTextEntry = true
////        }
////
////        alert.addAction(
////            UIAlertAction(
////                title: "Cancel",
////                style: .cancel,
////                handler: nil))
////
////        alert.addAction(
////            UIAlertAction(
////                title: "Continue",
////                style: .default,
////                handler: { [weak self] _ in
////                    // Read text values
////                    guard let fields = alert.textFields?.first,
////                          let passcode = fields.text,
////                          !passcode.trimmingCharacters(in: .whitespaces).isEmpty else {
////                        print("Enter your code!")
////                        return
////                    }
////
////                    guard let strongSelf = self else {
////                        return
////                    }
////
////                    // verify user
////                    if strongSelf.users.contains(where: { $0.user_pin == passcode }) {
////                        print("Passcode verified: ", passcode)
////
////                        // get user data
////                        guard let userPassingCode = strongSelf.users.filter( { $0.user_pin == passcode }).first else {
////                            return
////                        }
////
////                        APICaller.shared.postAttendance(
////                            userId: userPassingCode.user_id,
////                            type: selected_InOut,
////                            shift: selected_shift,
////                            currentMonth: currentMonth,
////                            currentDate: currentDate,
////                            currentYear: currentYear,
////                            currentHour: currentHour,
////                            currentMinute: currentMinute) { (success) in
////                            if success {
////                                // go back
////                                DispatchQueue.main.async {
////                                    AccountViewController.staffName = userPassingCode.user_login
////                                    print("Hi! ", AccountViewController.staffName)
////
////                                    strongSelf.bottomContainer.isHidden = false
////
////
////                                    // display current time
////                                    strongSelf.currentTimeValueLabel.text = Date().current12FHour()
////                                    // display remaining hrs of duty
////                                    strongSelf.workTimeValueLabel.text = "7 hours"
////
////                                    strongSelf.collectionView.reloadData()
////                                }
////                            } else {
////                                print("Failed to post attendance")
////                            }
////                        }
////
////                    } else {
////                        print("Invalid passcode!- ", passcode)
////                    }
////
////                    // save time-in info
////
////                    // post attendance
////
////
////                }
////            )
////        )
////        present(alert, animated: true, completion: nil)
//
//    }
//
//
//    func createEnterPasscodeView(users: [Users], selected_InOut: String, selected_shift: String, selected_timeSched: String, currentMonth: Int, currentDate: Int, currentYear: Int, currentHour: Int, currentMinute: Int) {
//        let vc = EnterPasscodeViewController(users: users, selected_InOut: selected_InOut, selected_shift: selected_shift, selected_timeSched: selected_timeSched, currentMonth: currentMonth, currentDate: currentDate, currentYear: currentYear, currentHour: currentHour, currentMinute: currentMinute)
//        vc.enterPasscodeViewControllerDelegate = self
//        vc.modalPresentationStyle = .overFullScreen
//        vc.modalTransitionStyle = .crossDissolve
//        present(vc, animated: true, completion: nil)
//
//
//    }
//}
//
//
//// MARK:- CollectionView Sections Layout
//extension AccountViewController {
//    static func createSectionLayout(section: Int) -> NSCollectionLayoutSection? {
//
//        let supplementaryViews = [
//            NSCollectionLayoutBoundarySupplementaryItem(
//                layoutSize: NSCollectionLayoutSize(
//                    widthDimension: .fractionalWidth(1.0),
//                    heightDimension: .absolute(50)
//                ),
//                elementKind: UICollectionView.elementKindSectionHeader,
//                alignment: .top
//            )
//        ]
//
//        // Item
//        let item = NSCollectionLayoutItem(
//            layoutSize: NSCollectionLayoutSize(
//                widthDimension: .fractionalWidth(1.0),
//                heightDimension: .fractionalHeight(1.0)
//            )
//        )
//        item.contentInsets = NSDirectionalEdgeInsets(
//            top: 0,
//            leading: 10,
//            bottom: 20,
//            trailing: 10)
//
//        // Group
//        // vertical group inside horizontal group
//        let hGroup = NSCollectionLayoutGroup.horizontal(
//            layoutSize: NSCollectionLayoutSize(
//                widthDimension: .fractionalWidth(1.0),
//                heightDimension: .absolute(60.0)
//            ),
//            subitem: item,
//            count: 3)
//
//        let vGroup = NSCollectionLayoutGroup.vertical(
//            layoutSize: NSCollectionLayoutSize(
//                widthDimension: .fractionalWidth(1.0),
//                heightDimension: .absolute(60.0)
//            ),
//            subitem: hGroup,
//            count: 1)
//
//        // Section
//        let section = NSCollectionLayoutSection(group: vGroup)
//        section.contentInsets = NSDirectionalEdgeInsets(
//            top: 0,
//            leading: 20,
//            bottom: 0,
//            trailing: 20)
//
//        section.boundarySupplementaryItems = supplementaryViews
////        section.orthogonalScrollingBehavior = .continuous
//        return section
//    }
//}
//
