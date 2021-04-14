//
//  PopularRequestsCollectionViewCell.swift
//  MDS-Yandex
//
//  Created by Adlet Zeineken on 14.03.2021.
//  Copyright © 2021 justadlet. All rights reserved.
//

import UIKit

class PopularRequestsCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = String("\(PopularRequestsCollectionViewCell.self)")
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
