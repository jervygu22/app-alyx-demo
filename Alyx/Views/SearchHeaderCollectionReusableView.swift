//
//  SearchHeaderCollectionReusableView.swift
//  Jeeves-dev
//
//  Created by Jervy Umandap on 2/4/22.
//

import UIKit

class SearchHeaderCollectionReusableView: UICollectionReusableView {
    static let identifier = "SearchHeaderCollectionReusableView"
    
    let searchResult: [Product] = []
    
    private let sectionHeaderlabel: UILabel = {
        let label = UILabel()
        label.textColor = Constants.blackLabelColor
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.isHidden = false
        return label
    }()
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar(frame: .zero)
        searchBar.placeholder = "Search item"
        searchBar.layer.masksToBounds = true
        searchBar.clipsToBounds = true
        searchBar.barTintColor = Constants.vcBackgroundColor
        if #available(iOS 13.0, *) {
            searchBar.searchTextField.backgroundColor = .white
        } else {
            // Fallback on earlier versions
        }
        if #available(iOS 13.0, *) {
            searchBar.searchTextField.textColor = .black
        } else {
            // Fallback on earlier versions
        }
        searchBar.backgroundColor = .clear
        searchBar.searchBarStyle = .default
        searchBar.layer.borderWidth = 0.5
        searchBar.layer.cornerRadius = 5.0
        if #available(iOS 13.0, *) {
            searchBar.layer.borderColor = Constants.vcBackgroundCGColor
        } else {
            // Fallback on earlier versions
        }
        searchBar.barStyle = .default
        
        return searchBar
    }()
    
    let searchController: UISearchController = {
        let vc = UISearchController(searchResultsController: MenuSearchResultsViewController())
        vc.searchBar.searchBarStyle = .minimal
        vc.searchBar.placeholder = "Search item"
        vc.searchBar.layer.masksToBounds = true
        vc.searchBar.clipsToBounds = true
        vc.searchBar.barTintColor = Constants.whiteBackgroundColor
        vc.searchBar.searchTextField.backgroundColor = .white
        vc.searchBar.searchTextField.textColor = .black
        vc.searchBar.backgroundColor = .clear
        vc.searchBar.searchBarStyle = .default
        vc.searchBar.layer.borderWidth = 0.5
        vc.searchBar.layer.cornerRadius = 5.0
        vc.searchBar.layer.borderColor = Constants.vcBackgroundCGColor
        vc.searchBar.showsCancelButton = true
        vc.searchBar.setShowsCancelButton(true, animated: true)
        
        vc.automaticallyShowsCancelButton = true
        
        vc.definesPresentationContext = true
        vc.hidesNavigationBarDuringPresentation = true
        return vc
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        addSubview(sectionHeaderlabel)
        
        
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        
        searchBar.delegate = self
        
        
//        addSubview(self.searchBar)
        
        let tapAny = UITapGestureRecognizer(target: self, action: #selector(didTapAny))
        self.addGestureRecognizer(tapAny)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchBar.setShowsCancelButton(true, animated: true)
        print(searchText)
        
    }
    
    @objc func didTapAny() {
        searchController.searchBar.resignFirstResponder()
        self.searchBar.resignFirstResponder()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let searchBar = self.searchBar
        searchBar.sizeToFit()
        
        sectionHeaderlabel.frame = CGRect(
            x: 4,
            y: 0,
            width: (width*0.40)-4,
            height: height)
//        sectionHeaderlabel.backgroundColor = .red
        
        searchBar.frame = CGRect(
            x: sectionHeaderlabel.right,
            y: 5,
            width: (width*0.60)-4,
            height: height-10)
        searchBar.backgroundColor = .systemPink
        
//        searchBar.frame = bounds
    }
    
    func configure(with sectionTitle: String) {
        sectionHeaderlabel.text = sectionTitle
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let resultsController = searchController.searchResultsController as? MenuSearchResultsViewController,
              let query = searchBar.text,
              !query.trimmingCharacters(in: .whitespaces).isEmpty else  {
            return
        }
        
        print("searching..")
        resultsController.menuSearchResultsViewControllerDelegate = self
        
        resultsController.searchQuery = query
        
//        if filteringProductsArray.contains(where: { $0.name.lowercased().range(of: query.lowercased()) != nil }) {
//            let searchResult = filteringProductsArray.filter({ $0.name.lowercased().range(of: query.lowercased()) != nil })
//
//            resultsController.update(withResults: searchResult)
//        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.resignFirstResponder()
    }
    
}

extension SearchHeaderCollectionReusableView: UISearchResultsUpdating, UISearchBarDelegate, MenuSearchResultsViewControllerDelegate {
    
    func didTapResultItem(with result: Product) {
        
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
    }
    
    
}
