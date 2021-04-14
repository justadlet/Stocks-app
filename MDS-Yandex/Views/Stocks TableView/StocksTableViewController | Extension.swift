//
//  StocksTableViewController | Extension.swift
//  MDS-Yandex
//
//  Created by Adlet Zeineken on 23.03.2021.
//  Copyright © 2021 justadlet. All rights reserved.
//

import Foundation
import UIKit

extension StocksTableViewController: TableViewHeaderDelegate {
    func stocksButtonPressed() {
        if (currentView != .stocks) {
            currentView = .stocks
            
            tableView.reloadData()
        }
        if let parentVC = parent as? ViewController {
            parentVC.searchBar.resignFirstResponder()
        }
    }
    
    func favouriteStocksButtonPressed() {
        if (currentView != .favourite) {
            currentView = .favourite
            saveFavouriteStocksWithRealm()
            fetchFavouriteStocks()
            tableView.reloadData()
        }
        if let parentVC = parent as? ViewController {
            parentVC.searchBar.resignFirstResponder()
        }
    }
}

extension StocksTableViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (currentView == .stocks) {
            return stocks.count
        } else if (currentView == .favourite) {
            return favouriteStocks.count
        } else {
            return filteredStocks.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: StockCell.reuseIdentifier, for: indexPath) as? StockCell else {
            return UITableViewCell()
        }
        var currentStock: Stock = Stock()
        if (currentView == .stocks) {
            currentStock = stocks[indexPath.item]
        } else if (currentView == .favourite) {
            currentStock = favouriteStocks[indexPath.item]
        } else {
            currentStock = filteredStocks[indexPath.item]
        }
        cell.delegate = self
        
        cell.stock = currentStock
        cell.cellIndexPath = indexPath
        cell.parentViewWidth = view.frame.size.width
        
        if (indexPath.row % 2 == 0) {
            cell.backgroundColor = Color.cellBackground
        } else {
            cell.backgroundColor = .white
        }
        cell.selectedBackgroundView = {
            let backgroundView = UIView(frame: CGRect(x: 0, y: 0, width: cell.frame.size.width, height: cell.frame.size.height))
            backgroundView.backgroundColor = Color.black.withAlphaComponent(0.1)
            backgroundView.layer.cornerRadius = 16
            return backgroundView
        }()
        let maskLayer = CALayer()
        maskLayer.cornerRadius = 16
        maskLayer.backgroundColor = cell.backgroundColor?.cgColor
        maskLayer.frame = CGRect(x: cell.bounds.origin.x, y: cell.bounds.origin.y, width:
            cell.bounds.width, height: cell.bounds.height).insetBy(dx: 0, dy: 5)
        cell.layer.mask = maskLayer
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if (section == 0) {
            guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: TableViewHeader.reuseIdentifier) as? TableViewHeader else { return UIView() }
            headerView.delegate = self
            return headerView
        }
        let headerView = UIView()
        headerView.backgroundColor = view.backgroundColor
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let nextViewController = StockInfoViewController()
        nextViewController.delegate = self
        if (currentView == .stocks) {
            nextViewController.stock = stocks[indexPath.item]
        } else if (currentView == .favourite) {
            nextViewController.stock = favouriteStocks[indexPath.item]
        } else if (currentView == .search) {
            nextViewController.stock = filteredStocks[indexPath.item]
        }
        self.navigationController?.pushViewController(nextViewController, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension StocksTableViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 94
    }
}


extension StocksTableViewController: StockCellDelegate {
    func addStockToFavourite(ticker: String) {
        isFavourite[ticker] = true
    }
    
    func deleteStockFromFavourite(ticker: String) {
        isFavourite[ticker] = false
    }
    
    func isFavourite(ticker: String) -> Bool {
        if (isFavourite[ticker] == true) {
            return true
        }
        return false
    }
    
    func getStockPrice(for ticker: String) -> StockPrice {
        guard let stockPrice = stockPrices[ticker] else { return StockPrice() }
        return stockPrice
    }
    
    func saveFavouriteStocksLocally() {
        self.saveFavouriteStocksWithRealm()
    }
}
