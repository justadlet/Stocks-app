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
    weak var delegate: StockCellDelegate?
    var cellIndexPath: IndexPath?
    var parentViewWidth: CGFloat = 0.0
    var stock: Stock? {
        didSet {
            if let name = stock?.name {
                stockNameLabel.text = name
            }
            if let logoURL = URL(string: stock?.logo ?? "") {
                logoImageView.setImage(from: logoURL)
            } else {
                if let ticker = stock?.ticker,
                    let firstLetter = ticker.first?.lowercased() {
                    logoImageView.image = UIImage(systemName: "\(firstLetter).square")
                    logoImageView.tintColor = Color.gray
                }
            }
            if let ticker = stock?.ticker {
                stockTickerLabel.text = ticker
                if (delegate?.isFavourite(ticker: ticker) == true) {
                    starButton.imageView?.tintColor = Color.yellow
                } else {
                    starButton.imageView?.tintColor = Color.gray
                }
                if let stockPrice = delegate?.getStockPrice(for: ticker) {
                    let price: Double = stockPrice.price 
                    let priceUpdate: Double = stockPrice.priceUpdate
                    let percentUpdate: Double = stockPrice.percentUpdate
                    let percent = String(format: "%.2f", percentUpdate)
                    priceLabel.text = "$\(String(format: "%.2f", price))"
                    priceUpdateLabel.text = "+$\(String(format: "%.2f", priceUpdate)) (\(percent)%)"
                    priceUpdateLabel.textColor = Color.green
                    if (priceUpdate < 0) {
                        let positivePrice = -1.0 * priceUpdate
                        priceUpdateLabel.text = "-$\(String(format: "%.2f", positivePrice)) (\(percent)%)"
                        priceUpdateLabel.textColor = Color.red
                    }
                } else {
                    priceLabel.text = "$0.00"
                    priceUpdateLabel.text = "+$0.00 (0.0%)"
                    priceUpdateLabel.textColor = Color.green
                }
            }
        }
    }
    
    private let stockTickerLabel : UILabel = {
        let label = UILabel()
        label.textColor = Color.black
        label.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        label.textAlignment = .left
        return label
    }()
    
    private let stockNameLabel : UILabel = {
        let label = UILabel()
        label.textColor = Color.black
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }()
    
    private let logoImageView : UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 12
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let nameAndTickerView : UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.isUserInteractionEnabled = true
        
        let subview = UIView(frame: view.bounds)
//        subview.backgroundColor = .red
        subview.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.insertSubview(subview, at: 0)
        
        view.isUserInteractionEnabled = true
        return view
    }()
    
    private let tickerStackView : UIStackView = {
        let stackView = UIStackView()
        stackView.clipsToBounds = true
        stackView.isUserInteractionEnabled = true
        return stackView
    }()
    
    private let starButton : UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "star.fill"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFill
        button.imageView?.tintColor = Color.gray
        button.isUserInteractionEnabled = true
        return button
    }()
    
    private let pricesView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.isUserInteractionEnabled = true
//        view.backgroundColor = .blue
        
        let subview = UIView(frame: view.bounds)
//        subview.backgroundColor = .blue
        subview.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.insertSubview(subview, at: 0)
        return view
    }()
    
    private let priceLabel : UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        label.textColor = Color.black
        label.textAlignment = .right
        return label
    }()
    
    private let priceUpdateLabel : UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        label.textAlignment = .right
        label.textColor = Color.black
        label.addSpacing(value: -0.2)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubviews()
        addConstraints()
    }
    
    func addSubviews() {
        self.contentView.addSubview(logoImageView)
        self.contentView.addSubview(pricesView)
        self.contentView.addSubview(nameAndTickerView)
        pricesView.addSubview(priceLabel)
        pricesView.addSubview(priceUpdateLabel)
        nameAndTickerView.addSubview(stockNameLabel)
        nameAndTickerView.addSubview(stockTickerLabel)
        nameAndTickerView.addSubview(tickerStackView)
        tickerStackView.addSubview(stockTickerLabel)
        tickerStackView.addSubview(starButton)
        starButton.addTarget(self, action: #selector(starButtonPressed), for: .touchUpInside)
    }
    
    func addConstraints() {
        
        logoImageView.addConstraint(top: nil, leading: contentView.leadingAnchor, bottom: nil, trailing: nil, centerXAnchor: nil, centerYAnchor: self.contentView.centerYAnchor, paddingLeading: 10, width: 64, height: 64)
        
        
        var pricesWidth: CGFloat = contentView.frame.width * 0.46875
        if let priceLabelWidth = priceLabel.text?.width(withConstrainedHeight: 24, font: UIFont.systemFont(ofSize: 22, weight: .bold)),
            let priceUpdateLabelWidth = priceUpdateLabel.text?.width(withConstrainedHeight: 16, font: UIFont.systemFont(ofSize: 14, weight: .semibold)) {
            pricesWidth = max(priceUpdateLabelWidth, priceLabelWidth)
        }
        
        
        pricesView.addConstraint(top: nil, leading: nil, bottom: nil, trailing: contentView.trailingAnchor, centerXAnchor: nil, centerYAnchor: contentView.centerYAnchor, width: pricesWidth, height: 40)
        priceLabel.addConstraint(top: pricesView.topAnchor, leading: nil, bottom: nil, trailing: pricesView.trailingAnchor, centerXAnchor: nil, centerYAnchor: nil, paddingTrailing: -16, height: 24)
        priceUpdateLabel.addConstraint(top: priceLabel.bottomAnchor, leading: nil, bottom: nil, trailing: pricesView.trailingAnchor, centerXAnchor: nil, centerYAnchor: nil, paddingTrailing: -16, height: 16)
        
        nameAndTickerView.addConstraint(top: nil, leading: logoImageView.trailingAnchor, bottom: nil, trailing: pricesView.leadingAnchor, centerXAnchor: nil, centerYAnchor: contentView.centerYAnchor, paddingLeading: 16, paddingTrailing: -12, height: 40)
        tickerStackView.addConstraint(top: nameAndTickerView.topAnchor, leading: nameAndTickerView.leadingAnchor, bottom: nil, trailing: nameAndTickerView.trailingAnchor, centerXAnchor: nil, centerYAnchor: nil, height: 24)
        stockTickerLabel.addConstraint(top: tickerStackView.topAnchor, leading: tickerStackView.leadingAnchor, bottom: nil, trailing: nil, centerXAnchor: nil, centerYAnchor: nil, height: 24)
        starButton.addConstraint(top: nil, leading: stockTickerLabel.trailingAnchor, bottom: nil, trailing: nil, centerXAnchor: nil, centerYAnchor: tickerStackView.centerYAnchor, paddingLeading: 4, width: 18, height: 18)
        
        stockNameLabel.addConstraint(top: tickerStackView.bottomAnchor, leading: nameAndTickerView.leadingAnchor, bottom: nil, trailing: nameAndTickerView.trailingAnchor, centerXAnchor: nil, centerYAnchor: nil, height: 16)
    }
    
    func getContentWidth(for text: String, with font: UIFont) -> CGFloat {
        let attributes = [NSAttributedString.Key.font: font]
        let attributedString = NSAttributedString(string: text, attributes: attributes)
        return attributedString.size().width + 32.0
    }
    
    @objc
    func starButtonPressed() {
        guard var currentStarColor = starButton.imageView?.tintColor else { return }
        if (currentStarColor == Color.yellow) {
            currentStarColor = Color.gray
            if let ticker = stock?.ticker {
                delegate?.deleteStockFromFavourite(ticker: ticker)
            }
        } else {
            currentStarColor = Color.yellow
            if let ticker = stock?.ticker {
                delegate?.addStockToFavourite(ticker: ticker)
            }
        }
        UIView.animate(withDuration: 0.3) {
            self.starButton.imageView?.tintColor = currentStarColor
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
