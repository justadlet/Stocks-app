//
//  ViewController.swift
//  MDS-Yandex
//
//  Created by Adlet Zeineken on 16.02.2021.
//  Copyright © 2021 justadlet. All rights reserved.
//

import UIKit

protocol CustomSearchBarDelegate: AnyObject {
    func changeText(to: String)
}

class ViewController: UIViewController{
    let searchBar = UISearchBar()
    let stocksTableViewController = StocksTableViewController()
    let searchHistoryViewController = SearchHistoryViewController()
    let statusBarBackground = UIView()
    var filteredStocks: [Stock] = []
    var isSearchBarEmpty: Bool {
        return searchBar.text?.isEmpty ?? true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        searchHistoryViewController.view.isHidden = true
        stocksTableViewController.view.isHidden = false
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let statusBarHeight = view.window?.windowScene?.statusBarManager?.statusBarFrame.size.height ?? 0
        statusBarBackground.backgroundColor = .white
        statusBarBackground.isHidden = true
        
        view.addSubview(statusBarBackground)
        statusBarBackground.addConstraint(top: view.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, centerXAnchor: nil, centerYAnchor: nil, height: statusBarHeight)
    }
    
    func configureUI() {
        view.backgroundColor = .white
        configureNavigationController()
        addSubviews()
        addConstraints()
        
        searchHistoryViewController.searchBarDelegate = self 
    }
    
    func configureNavigationController() {
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.tintColor = Color.black
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.hidesBarsOnSwipe = true
        
        navigationController?.navigationBar.layer.masksToBounds = false
        navigationController?.navigationBar.layer.shadowColor = UIColor.black.cgColor
        navigationController?.navigationBar.layer.shadowOpacity = 0.0
        navigationController?.navigationBar.layer.shadowOffset = CGSize(width: 0, height: 1.0)
        navigationController?.navigationBar.layer.shadowRadius = 0
        searchBar.delegate = self
        
        
        searchBar.placeholder = "Find company or ticker"
        navigationItem.titleView = searchBar
    }
    
    func addSubviews() {
        self.addChild(stocksTableViewController)
        view.addSubview(stocksTableViewController.view)
        
        self.addChild(searchHistoryViewController)
        view.addSubview(searchHistoryViewController.view)
    }
    
    func addConstraints() {
        stocksTableViewController.didMove(toParent: self)
        stocksTableViewController.view.addConstraint(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor, centerXAnchor: nil, centerYAnchor: nil, paddingLeading: 16, paddingTrailing: -16)
        
        searchHistoryViewController.didMove(toParent: self)
        searchHistoryViewController.view.addConstraint(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor, centerXAnchor: nil, centerYAnchor: nil, paddingLeading: 16, paddingTrailing: -16)
    }
}
// MARK: - SearchBar delegate

extension ViewController: UISearchBarDelegate {
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        stocksTableViewController.view.isHidden = true
        searchHistoryViewController.view.isHidden = false
        navigationController?.hidesBarsOnSwipe = false
        searchBar.setShowsCancelButton(true, animated: true)
        return true
    }
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        return true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        stocksTableViewController.stocksButtonPressed()
        stocksTableViewController.tableView.reloadData()
        stocksTableViewController.view.isHidden = false
        searchHistoryViewController.view.isHidden = true
        navigationController?.hidesBarsOnSwipe = true
        searchBar.resignFirstResponder()
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        stocksTableViewController.view.isHidden = false
        searchHistoryViewController.view.isHidden = true
        navigationController?.hidesBarsOnSwipe = true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty == false {
            stocksTableViewController.view.isHidden = false
            searchHistoryViewController.view.isHidden = true
            stocksTableViewController.filterContentForSearchText(searchText)
            navigationController?.hidesBarsOnSwipe = true
        } else {
            stocksTableViewController.view.isHidden = true
            searchHistoryViewController.view.isHidden = false
            navigationController?.hidesBarsOnSwipe = false
        }
    }
}

extension ViewController: CustomSearchBarDelegate {
    func changeText(to newText: String) {
        searchBar.text = newText
        searchBar.delegate?.searchBar?(searchBar, textDidChange: newText)
    }
}
