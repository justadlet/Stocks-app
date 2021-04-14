//
//  SearchHistoryCollectionViewCell.swift
//  MDS-Yandex
//
//  Created by Adlet Zeineken on 14.03.2021.
//  Copyright © 2021 justadlet. All rights reserved.
//

import UIKit

class SearchHistoryCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = String("\(SearchHistoryCollectionViewCell.self)")
    var searchBarDelegate: CustomSearchBarDelegate?
    let stockLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.textColor = Color.black
        return label
    }()
    
    override var isHighlighted: Bool {
        didSet {
            if(isHighlighted == true){
                self.backgroundColor = Color.black.withAlphaComponent(0.1)
            }else{
                self.backgroundColor = Color.cellBackground
            }
        }
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.sizeToFit()
        addSubviews()
        addConstraints()
    }
    
    func addSubviews() {
        self.addSubview(stockLabel)
    }
    
    func addConstraints() {
        stockLabel.addConstraint(top: contentView.topAnchor, leading: contentView.leadingAnchor, bottom: contentView.bottomAnchor, trailing: contentView.trailingAnchor, centerXAnchor: nil, centerYAnchor: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
