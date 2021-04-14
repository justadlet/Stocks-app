//
//  TableViewHeader.swift
//  MDS-Yandex
//
//  Created by Adlet Zeineken on 26.02.2021.
//  Copyright © 2021 justadlet. All rights reserved.
//

import UIKit

protocol TableViewHeaderDelegate: AnyObject {
    func stocksButtonPressed()
    func favouriteStocksButtonPressed()
}

class TableViewHeader: UITableViewHeaderFooterView {
    static let reuseIdentifier = "\(TableViewHeader.self)"
    
    var stocksButtonHeightConstraint = NSLayoutConstraint()
    var favouriteStocksButtonHeightConstraint = NSLayoutConstraint()
    weak var delegate: TableViewHeaderDelegate?
    
    private let stocksButton: UIButton = {
        let button = UIButton()
        button.setTitle("Stocks", for: .normal)
        button.contentVerticalAlignment = .top
        button.setTitleColor(Color.black.withAlphaComponent(0.5), for: .normal)
        button.setTitleColor(Color.black, for: .selected)
        button.setTitleColor(Color.black.withAlphaComponent(0.5), for: .highlighted)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 36, weight: .bold)
        return button
    }()
    
    private let favouriteStocksButton: UIButton = {
       let button = UIButton()
        button.setTitle("Favourite", for: .normal)
        button.contentVerticalAlignment = .top
        button.setTitleColor(Color.gray, for: .normal)
        button.setTitleColor(Color.black.withAlphaComponent(0.5), for: .highlighted)
        button.setTitleColor(Color.black, for: .selected)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 26, weight: .bold)
        return button
    }()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        addSubviews()
        addConstraints()
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addSubviews() {
        contentView.addSubview(stocksButton)
        contentView.addSubview(favouriteStocksButton)
    }
    
    func addConstraints() {
        stocksButton.addConstraint(top: nil, leading: contentView.leadingAnchor, bottom: contentView.bottomAnchor, trailing: nil, centerXAnchor: nil, centerYAnchor: nil, paddingLeading: 4, paddingBottom: -15, height: 41)
        favouriteStocksButton.addConstraint(top: nil, leading: stocksButton.trailingAnchor, bottom: contentView.bottomAnchor, trailing: nil, centerXAnchor: nil, centerYAnchor: nil, paddingLeading: 20, paddingBottom: -15, height: 32)
        
        if let constraint = stocksButton.constraints.last {
            stocksButtonHeightConstraint = constraint
        }
        if let constraint = favouriteStocksButton.constraints.last {
            favouriteStocksButtonHeightConstraint = constraint
        }
        
    }
    
    func configureUI() {
        contentView.backgroundColor = .white
        stocksButton.isSelected = true
        favouriteStocksButton.isSelected = false
        stocksButton.addTarget(self, action: #selector(stocksButtonPressed), for: .touchUpInside)
        favouriteStocksButton.addTarget(self, action: #selector(favouriteStocksButtonPressed), for: .touchUpInside)
    }
    
    
    @objc
    func stocksButtonPressed() {
        delegate?.stocksButtonPressed()
        favouriteStocksButton.isSelected = false
        stocksButton.isSelected = true
        stocksButton.titleLabel?.font = UIFont.systemFont(ofSize: 36, weight: .bold)
        favouriteStocksButton.titleLabel?.font = UIFont.systemFont(ofSize: 26, weight: .bold)
        favouriteStocksButtonHeightConstraint.constant = 32
        stocksButtonHeightConstraint.constant = 41
        
        favouriteStocksButton.setTitleColor(Color.gray, for: .normal)
        favouriteStocksButton.setTitleColor(Color.black.withAlphaComponent(0.5), for: .highlighted)
        favouriteStocksButton.setTitleColor(Color.black, for: .selected)
        stocksButton.setTitleColor(Color.black.withAlphaComponent(0.5), for: .normal)
        stocksButton.setTitleColor(Color.black, for: .selected)
        stocksButton.setTitleColor(Color.black.withAlphaComponent(0.5), for: .highlighted)
    
    }
    
    @objc
    func favouriteStocksButtonPressed() {
        delegate?.favouriteStocksButtonPressed()
        favouriteStocksButton.isSelected = true
        stocksButton.isSelected = false
        stocksButton.titleLabel?.font = UIFont.systemFont(ofSize: 26, weight: .bold)
        favouriteStocksButton.titleLabel?.font = UIFont.systemFont(ofSize: 36, weight: .bold)
        
        stocksButtonHeightConstraint.constant = 32
        favouriteStocksButtonHeightConstraint.constant = 41
        
        favouriteStocksButton.setTitleColor(Color.black.withAlphaComponent(0.5), for: .normal)
        favouriteStocksButton.setTitleColor(Color.black, for: .selected)
        favouriteStocksButton.setTitleColor(Color.black.withAlphaComponent(0.5), for: .highlighted)
        stocksButton.setTitleColor(Color.gray, for: .normal)
        stocksButton.setTitleColor(Color.black.withAlphaComponent(0.5), for: .highlighted)
        stocksButton.setTitleColor(Color.black, for: .selected)
    }
    
}
