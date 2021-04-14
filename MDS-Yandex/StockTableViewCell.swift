//
//  StockTableViewCell.swift
//  MDS-Yandex
//
//  Created by Adlet Zeineken on 18.02.2021.
//  Copyright © 2021 justadlet. All rights reserved.
//

import UIKit

class StockCell: UITableViewCell {
    static let reuseIdentifier = String("\(StockCell.self)")
    var stock: Stock?    {
        didSet {
            
        }
    }
//    cell.layer.cornerRadius = 16
//    if (indexPath.row % 2 == 0) {
//        cell.backgroundColor = Color.cellBackground
//    } else {
//        cell.backgroundColor = .white
//    }
    
}
