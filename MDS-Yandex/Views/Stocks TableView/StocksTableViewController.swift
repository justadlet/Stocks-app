//
//  StockTableViewController.swift
//  MDS-Yandex
//
//  Created by Adlet Zeineken on 22.03.2021.
//  Copyright © 2021 justadlet. All rights reserved.
//

import UIKit
import RealmSwift

class StocksTableViewController: UIViewController {
    enum stocksView {
        case stocks
        case favourite
        case search
    }
    var stocks : [Stock] = Stock.stocks()
    var favouriteStocks : [Stock] = [Stock]()
    var filteredStocks: [Stock] = []
    
    var tableViewHeader = UITableViewHeaderFooterView()
    var currentView: stocksView = .stocks
    var stockProfiles : [String : Stock] = [:]
    var stockPrices : [String : StockPrice] = [:]
    var isFavourite : [String : Bool] = [:]
    var tickersQueue = Queue<String>()
    let tableView = UITableView()
    
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchFavouriteStocksWithRealm()
        fetchStockPricesWithRealm()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        saveFavouriteStocksWithRealm()
        saveStockPricesWithRealm()
    }
    
    func fetchFavouriteStocksWithRealm() {
        if let savedFavouriteStocks = realm.objects(FavouriteStocksString.self).last?.string.dictionaryValue() as? [String : Bool] {
            self.isFavourite = savedFavouriteStocks
        }
    }
    
    func fetchStockPricesWithRealm() {
        if let savedStockPrices = realm.objects(StockPricesString.self).last?.string {
            let data = Data(savedStockPrices.utf8)
            do {
                let decoder = JSONDecoder()
                decoder.userInfo[CodingUserInfoKey(rawValue: "site")!] = StockPrice.Site.local
                
                let decodedStockPrices: [String : StockPrice] = try decoder.decode([String : StockPrice].self, from: data)
                self.stockPrices = decodedStockPrices
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            } catch {
                print("Error converting stockPricesString to Dictionary: \(error)")
            }
        }
    }
    
    func saveFavouriteStocksWithRealm() {
        try! realm.write {
            let favouriteStocksString = FavouriteStocksString(newString: isFavourite.jsonString())
            realm.delete(realm.objects(FavouriteStocksString.self))
            realm.add(favouriteStocksString)
        }
    }
    
    func saveStockPricesWithRealm() {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let encodedDictionary = try encoder.encode(stockPrices)
            
            try! realm.write {
                let stockPricesString = StockPricesString(newString: String.init(data: encodedDictionary, encoding: .utf8)!)
                realm.delete(realm.objects(StockPricesString.self))
                realm.add(stockPricesString)
            }
        } catch {
            print("Error converting stockPrices: \(error)")
        }
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let parentVC = parent as! ViewController?,
            let isNavBarHidden = parentVC.navigationController?.isNavigationBarHidden {
            let statusBarBackground = parentVC.statusBarBackground
            if (isNavBarHidden == statusBarBackground.isHidden) {
                statusBarBackground.isHidden = !isNavBarHidden
            }
        }
    }
    
    func configureUI() {
        view.backgroundColor = .white
        setupTableView()
        
        addSubviews()
        addConstraints()
        
        getStockPrices()
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
        tableView.addConstraint(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor, centerXAnchor: nil, centerYAnchor: nil)
    }
    
    func getStockPrices() {
        for stock in self.stocks {
            self.stockProfiles[stock.ticker] = stock
        }
        fetchFavouriteStocks()
        for favouriteStock in favouriteStocks {
            tickersQueue.enqueue(favouriteStock.ticker)
        }
        for stock in stocks {
            if (isFavourite[stock.ticker] != true) {
                tickersQueue.enqueue(stock.ticker)
            }
        }
        var currentCall = 0
        DispatchQueue.main.async {
            Timer.scheduledTimer(withTimeInterval: 0.6, repeats: true) { timer in
                if (currentCall == 0 || currentCall == 33 || currentCall == 66) {
                    self.updatePrices(for: &self.tickersQueue, numberOfStocks: 15, from: StockPrice.Site.finnhub, reloadTableView: true)
                    /*
                     Updating (15 * 3) = 45 stock prices in minute,
                     
                     Finnhub Limit: 60 calls/minute
                     Left 15 are for stock graph
                     */
                }
                self.updatePrices(for: &self.tickersQueue, numberOfStocks: 1, from: StockPrice.Site.IEX, reloadTableView: false)
                currentCall += 1
                if (currentCall % 10 == 0) {
                    self.tableView.reloadData()
                }
                if (currentCall == 100) {
                    currentCall = 0
                }
            }
        }
    }
    
    func fetchFavouriteStocks() {
        self.favouriteStocks = []
        for (ticker, value) in isFavourite {
            if (value == true) {
                if let stock = stockProfiles[ticker] {
                    favouriteStocks.append(stock)
                }
            }
        }
    }
    
    func updatePrices(for queue: inout Queue<String>, numberOfStocks: Int, from website: StockPrice.Site, reloadTableView: Bool) {
        var stocksLeft = numberOfStocks
        let group = DispatchGroup()
        while (stocksLeft != 0) {
            group.enter()
            if let currentTicker = queue.dequeue(),
                let stockQuoteURL = Constants().getStockQuote(from: website, for: currentTicker) {
                queue.enqueue(currentTicker)
                URLSession.shared.dataTask(with: stockQuoteURL) { (data, response, error) in
                    group.leave()
                    if let data = data {
                        do {
                            let decoder = JSONDecoder()
                            decoder.userInfo[CodingUserInfoKey(rawValue: "site")!] = website
                            let decodedStockPrice = try decoder.decode(StockPrice.self, from: data)
                            self.stockPrices[currentTicker] = decodedStockPrice
                        } catch let error {
                            print("Could not decode StockPrice from \(website) for: \(currentTicker) with error: \(error)")
                        }
                    }
                }.resume()
            }
            stocksLeft -= 1
        }
        group.notify(queue: .main) {
            if (reloadTableView == true) {
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    func filterContentForSearchText(_ searchText: String) {
        filteredStocks = stocks.filter({ (stock: Stock) -> Bool in
            let willInclude: Bool = stock.name.lowercased().contains(searchText.lowercased()) || stock.ticker.lowercased().contains(searchText.lowercased())
            return willInclude
        })
        currentView = .search
        
        tableView.reloadData()
    }
}
