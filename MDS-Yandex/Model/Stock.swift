//
//  Stock.swift
//  MDS-Yandex
//
//  Created by Adlet Zeineken on 18.02.2021.
//  Copyright © 2021 justadlet. All rights reserved.
//

import Foundation

struct Stock: Decodable {
    var name: String = ""
    var logo: String = ""
    var ticker: String = ""
    
    static func stocks() -> [Stock] {
        do {
            if let path = Bundle.main.path(forResource: "stockProfiles", ofType: "json"),
                let jsonData = try String(contentsOfFile: path).data(using: .utf8) {
                do {
                    let stocks: [Stock] = try JSONDecoder().decode([Stock].self, from: jsonData)
                    return stocks
                }
            }
        } catch {
            print(error)
        }
        return []
    }
}
