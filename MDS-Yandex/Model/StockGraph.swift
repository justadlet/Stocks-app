//
//  StockGraph.swift
//  MDS-Yandex
//
//  Created by Adlet Zeineken on 26.03.2021.
//  Copyright © 2021 justadlet. All rights reserved.
//

import Foundation

struct StockGraph: Decodable, Hashable {
    static let shared = StockGraph(prices: [], dates: [], status: "")
    
    var prices: [Double]
    var dates: [TimeInterval]
    var status: String
    
    enum CodingKeys: String, CodingKey {
        case prices = "c"
        case dates = "t"
        case status = "s"
    }
    
    func fetchGraph(ofType type: String, for symbol: String) -> URL? {
        var from: TimeInterval = 0
        var resolution = "M"
        let to = Date().timeIntervalSince1970
        switch type {
        case "1Y":
            from = to - (60 * 60 * 24 * 365)
            resolution = "D"
        case "6M":
            from = to - (60 * 60 * 24 * 183)
            resolution = "D"
        case "M":
            from = to - (60 * 60 * 24 * 30)
            resolution = "D"
        case "W":
            from = to - (60 * 60 * 24 * 30)
            resolution = "30"
        case "D":
            from = to - (60 * 60 * 24)
            resolution = "5"
        default:
            from = 0
            resolution = "M"
        }
        
        return Constants().getGraphURL(from: Int(from), to: Int(to), resolution: resolution, for: symbol)
        
    }
}
