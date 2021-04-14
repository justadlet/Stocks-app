//
//  StockTableViewController.swift
//  MDS-Yandex
//
//  Created by Adlet Zeineken on 22.03.2021.
//  Copyright © 2021 justadlet. All rights reserved.
//

import Foundation
import UIKit

class StocksTableViewController: UIViewController {
    enum stocksView {
        case stocks
        case favourite
    }
    var stocks : [Stock] = [Stock]()
    var favouriteStocks : [Stock] = [Stock]()
    var tableViewHeader = UITableViewHeaderFooterView()
    var currentView: stocksView = .stocks
    var stockProfiles : [String : Stock] = [:]
    var stockPrices : [String : StockPrice] = [:]
    var isFavourite : [String : Bool] = [:]
    var tickersQueue = Queue<String>()
    let tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        fetchData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.isHidden = false
        if let savedFavouriteStocks = UserDefaults.standard.dictionary(forKey: Stock.userDefaultsFavouriteKey) as? [String : Bool] {
            self.isFavourite = savedFavouriteStocks
        }
        if let savedStockPrices = UserDefaults.standard.dictionary(forKey: Stock.userDefaultsPricesKey) as? [String : StockPrice] {
            self.stockPrices = savedStockPrices
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UserDefaults.standard.set(isFavourite, forKey: Stock.userDefaultsFavouriteKey)
    }
    
    func configureUI() {
        view.backgroundColor = .white
        setupTableView()
        
        addSubviews()
        addConstraints()
    }
    
    func fetchData() {
        
    }
    
    func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        tableView.separatorStyle = .none
        
        tableView.register(StockCell.self, forCellReuseIdentifier: StockCell.reuseIdentifier)
        tableView.register(TableViewHeader.self, forHeaderFooterViewReuseIdentifier: TableViewHeader.reuseIdentifier)
    }
    
    func addSubviews() {
        view.addSubview(tableView)
    }
    
    func addConstraints() {
        tableView.addConstraint(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor, centerXAnchor: nil, centerYAnchor: nil, paddingLeading: 16, paddingTrailing: -16)
    }
    
    func fetchData() {
        if let url = URL(string: Constants.SP500ProfilesURL) { // fetching S&P 500 profiles
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let data = data {
                    do {
                        self.stocks = try JSONDecoder().decode([Stock].self, from: data)
                        for stock in self.stocks {
                            self.stockProfiles[stock.ticker] = stock
                        }
                        self.getStockPrices()
                    } catch let error {
                        print(error)
                    }
                }
            }.resume()
        }
    }
}
