//
//  Constants.swift
//  MDS-Yandex
//
//  Created by Adlet Zeineken on 02.03.2021.
//  Copyright © 2021 justadlet. All rights reserved.
//

import UIKit

struct Constants {
    static let SP500StocksURL = ""
    
    static let SP500ProfilesURL = "https://raw.githubusercontent.com/justadlet/testing-API/master/api/stockProfiles.json"
    
    let finnhubToken = "YOUR TOKEN"
    let IEXToken = "IEX"
    
    func getStockQuote(from website: StockPrice.Site, for symbol: String) -> URL? {
        switch website {
        case .IEX:
            return URL(string: "https://cloud.iexapis.com/stable/stock/\(symbol)/quote?token=\(IEXToken)")
        case .finnhub:
            return URL(string: "https://finnhub.io/api/v1/quote?symbol=\(symbol)&token=\(finnhubToken)")
        case .local:
            return URL(string: "")
        }
    }
    
    func getGraphURL(from: Int, to: Int, resolution: String, for symbol: String) -> URL? {
        return URL(string: "https://finnhub.io/api/v1/stock/candle?symbol=\(symbol)&resolution=\(resolution)&from=\(from)&to=\(to)&token=\(finnhubToken)")
    }
    
}
