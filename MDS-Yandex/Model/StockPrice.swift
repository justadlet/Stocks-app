//
//  StockPrice.swift
//  
//
//  Created by Adlet Zeineken on 05.03.2021.
//

import RealmSwift
import Foundation

class StockPrice: Object, Codable {
    @objc dynamic var price: Double = 0.0
    @objc dynamic var previousPrice: Double = 0.0
    @objc dynamic var priceUpdate: Double {
        get {
            return price - previousPrice
        }
    }
    @objc dynamic var percentUpdate: Double {
        get {
            var diff = price - previousPrice
            if (diff < 0) {
                diff = diff * -1.0
            }
            if (price == 0) {
                return 0.0
            }
            return (diff / price) * 100
        }
    }
    
    enum Site {
        case finnhub
        case IEX
        case local
    }
    enum SiteError: Error {
        case unknownSite
    }
    enum FinnhubCodingKeys: String, CodingKey {
        case price = "c"
        case previousPrice = "pc"
    }
    enum IEXCodingKeys: String, CodingKey {
        case price = "latestPrice"
        case previousPrice = "previousClose"
    }
    enum localCodingKeys: String, CodingKey {
        case price
        case previousPrice
    }
    
    required init(from decoder: Decoder) throws {
        guard let key = CodingUserInfoKey(rawValue: "site"),
            let value = decoder.userInfo[key],
            let site = value as? Site else {
                throw SiteError.unknownSite
        }
        
        switch site {
        case .finnhub:
            let container = try decoder.container(keyedBy: FinnhubCodingKeys.self)
            
            price = try container.decode(Double.self, forKey: .price)
            previousPrice = try container.decode(Double.self, forKey: .previousPrice)
        case .IEX:
            let container = try decoder.container(keyedBy: IEXCodingKeys.self)
            
            price = try container.decode(Double.self, forKey: .price)
            previousPrice = try container.decode(Double.self, forKey: .previousPrice)
        case .local:
            let container = try decoder.container(keyedBy: localCodingKeys.self)
            
            price = try container.decode(Double.self, forKey: .price)
            previousPrice = try container.decode(Double.self, forKey: .previousPrice)
        }
        
    }
    
    required init() {
        
    }
}

