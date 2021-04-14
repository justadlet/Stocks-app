//
//  StockCellDelegate.swift
//  MDS-Yandex
//
//  Created by Adlet Zeineken on 30.03.2021.
//  Copyright © 2021 justadlet. All rights reserved.
//

import Foundation

protocol StockCellDelegate: AnyObject {
    func addStockToFavourite(ticker: String)
    func deleteStockFromFavourite(ticker: String)
    func isFavourite(ticker: String) -> Bool
    func getStockPrice(for ticker: String) -> StockPrice
    func saveFavouriteStocksLocally()
}
