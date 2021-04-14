//
//  StockInfoViewController.swift
//  MDS-Yandex
//
//  Created by Adlet Zeineken on 25.03.2021.
//  Copyright © 2021 justadlet. All rights reserved.
//

import Foundation
import UIKit

class StockInfoViewController: UIViewController {
    static let reuseIdentifier = "\(StockInfoViewController.self)"
    
    weak var delegate: StockCellDelegate?
    let buttonDates = ["D", "W", "M", "6M", "1Y", "All"]
    var dateButtons: [UIButton] = []
    
    enum starState {
        case pressed
        case notPressed
    }
    
    var currentStarState: starState = .notPressed
    
    private let tickerLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.textColor = Color.black
        return label
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        label.textColor = Color.black
        return label
    }()
    
    private let customTitleView: UIView = {
        let titleView = UIView()
        return titleView
    }()
    
    private var starButton = UIBarButtonItem()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        label.textColor = Color.black
        return label
    }()
    
    private let priceUpdateLabel: UILabel = {
        let label = UILabel()
        label.addSpacing(value: -0.2)
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.textColor = Color.green
        
        return label
    }()
    
    private let lineChart: LineChart = {
        let chart = LineChart()
        chart.isCurved = true
        chart.showDots = true
        chart.animateDots = true
        return chart
    }()
    
    private let noDataImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "empty")
        
        return imageView
    }()
    
    private let noDataLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        label.text = "Error: Could not find such data."
        
        return label
    }()
    
    var stock: Stock? {
        didSet {
            nameLabel.text = stock?.name
            if let ticker = stock?.ticker {
                tickerLabel.text = ticker
                if let stockGraphURL = StockGraph.shared.fetchGraph(ofType: "All", for: ticker) {
                    var result: [PointEntry] = []
                    URLSession.shared.dataTask(with: stockGraphURL) { (data, response, error) in
                        if let data = data {
                            do {
                                let stockGraph = try JSONDecoder().decode(StockGraph.self, from: data)
                                if (stockGraph.status == "no data") {
                                    self.hideLineChart()
                                } else {
                                    self.showLineChart()
                                    var prices: [Double] = []
                                    var dates: [TimeInterval] = []
                                    for price in stockGraph.prices {
                                        prices.append(price)
                                    }
                                    for date in stockGraph.dates {
                                        dates.append(date)
                                    }
                                    for i in 0..<prices.count {
                                        result.append(PointEntry(value: prices[i], label: "did not found yet"))
                                    }
                                    DispatchQueue.main.async {
                                        self.lineChart.dataEntries = result
                                    }
                                }
                            } catch let error {
                                print("Could not get graph from \(stockGraphURL) with error: \(error)")
                                self.hideLineChart()
                            }
                        }
                    }.resume()
                }
                if (delegate?.isFavourite(ticker: ticker) == true) {
                    navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "star.fill"), style: .plain, target: self, action: #selector(starButtonPressed))
                    currentStarState = .pressed
                } else {
                    navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "star"), style: .plain, target: self, action: #selector(starButtonPressed))
                    currentStarState = .notPressed
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
    
    func hideLineChart() {
        DispatchQueue.main.async {
            self.noDataImageView.isHidden = false
            self.noDataLabel.isHidden = false
            self.lineChart.isHidden = true
        }
    }
    
    func showLineChart() {
        DispatchQueue.main.async {
            self.noDataImageView.isHidden = true
            self.noDataLabel.isHidden = true
            self.lineChart.isHidden = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.hidesBarsOnSwipe = false
        navigationController?.isNavigationBarHidden = true
        navigationController?.isNavigationBarHidden = false
        
        navigationController?.navigationBar.layer.shadowOpacity = 0.1
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.hidesBarsOnSwipe = true
        
        navigationController?.navigationBar.layer.shadowOpacity = 0.0
        
        delegate?.saveFavouriteStocksLocally()
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        navigationController?.viewControllers.removeAll()
    }
    
    func configureUI() {
        createButtons(with: buttonDates)
        addSubviews()
        addConstraints()
        dateButtons[5].backgroundColor = Color.black
        dateButtons[5].setTitleColor(.white, for: .normal)
    }
    
    func addSubviews() {
        view.backgroundColor = .white
        
        customTitleView.addSubview(tickerLabel)
        customTitleView.addSubview(nameLabel)
        view.addSubview(priceLabel)
        view.addSubview(priceUpdateLabel)
        view.addSubview(lineChart)
        view.addSubview(noDataImageView)
        view.addSubview(noDataLabel)
        dateButtons.forEach { view.addSubview($0) }
    }
    
    func addConstraints() {
        let safeArea = view.layoutMarginsGuide
        navigationItem.titleView = customTitleView
        tickerLabel.addConstraint(top: customTitleView.topAnchor, leading: nil, bottom: nil, trailing: nil, centerXAnchor: customTitleView.centerXAnchor, centerYAnchor: nil)
        nameLabel.addConstraint(top: tickerLabel.bottomAnchor, leading: nil, bottom: nil, trailing: nil, centerXAnchor: customTitleView.centerXAnchor, centerYAnchor: nil, paddingTop: 0)
        
        priceLabel.addConstraint(top: safeArea.topAnchor, leading: nil, bottom: nil, trailing: nil, centerXAnchor: view.centerXAnchor, centerYAnchor: nil, paddingTop: 50)
        priceUpdateLabel.addConstraint(top: priceLabel.bottomAnchor, leading: nil, bottom: nil, trailing: nil, centerXAnchor: view.centerXAnchor, centerYAnchor: nil, paddingTop: 4)
        
        lineChart.addConstraint(top: priceUpdateLabel.bottomAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, centerXAnchor: nil, centerYAnchor: nil, paddingTop: 30, height: 330)
        
        let buttonHeight = ((view.frame.width - 32) - (10 * 5)) / 6
        for i in 0..<dateButtons.count {
            if (i == 0) {
                dateButtons[i].addConstraint(top: nil, leading: view.leadingAnchor, bottom: safeArea.bottomAnchor, trailing: nil, centerXAnchor: nil, centerYAnchor: nil, paddingLeading: 16, paddingBottom: -20, width: buttonHeight, height: buttonHeight)
            } else {
                dateButtons[i].addConstraint(top: nil, leading: dateButtons[i - 1].trailingAnchor, bottom: nil, trailing: nil, centerXAnchor: nil, centerYAnchor: dateButtons[0].centerYAnchor, paddingLeading: 10, width: buttonHeight, height: buttonHeight)
            }
            dateButtons[i].tag = i
            dateButtons[i].addTarget(self, action: #selector(highlightButton), for: .touchDown)
            dateButtons[i].addTarget(self, action: #selector(unhighlightButton), for: .touchDragOutside)
            dateButtons[i].addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
        }
        
        noDataImageView.addConstraint(top: nil, leading: nil, bottom: nil, trailing: nil, centerXAnchor: lineChart.centerXAnchor, centerYAnchor: lineChart.centerYAnchor, width: 150, height: 150)
        noDataLabel.addConstraint(top: noDataImageView.bottomAnchor, leading: nil, bottom: nil, trailing: nil, centerXAnchor: noDataImageView.centerXAnchor, centerYAnchor: nil)
    }
    
    @objc
    func unhighlightButton(sender: UIButton) {
        dateButtons[sender.tag].backgroundColor = Color.cellBackground
    }
    
    @objc
    func highlightButton(sender: UIButton) {
        dateButtons[sender.tag].backgroundColor = Color.black.withAlphaComponent(0.2)
    }
    
    @objc
    func buttonPressed(sender: UIButton) {
        if let ticker = stock?.ticker,
            let type = sender.titleLabel?.text {
            if let stockGraphURL = StockGraph.shared.fetchGraph(ofType: type, for: ticker) {
                var result: [PointEntry] = []
                URLSession.shared.dataTask(with: stockGraphURL) { (data, response, error) in
                    if let data = data {
                        do {
                            let stockGraph = try JSONDecoder().decode(StockGraph.self, from: data)
                            if (stockGraph.status == "no data") {
                                self.hideLineChart()
                            } else {
                                self.showLineChart()
                                var prices: [Double] = []
                                var dates: [TimeInterval] = []
                                for price in stockGraph.prices {
                                    prices.append(price)
                                }
                                for date in stockGraph.dates {
                                    dates.append(date)
                                }
                                for i in 0..<prices.count {
                                    result.append(PointEntry(value: prices[i], label: "did not found yet"))
                                }
                                DispatchQueue.main.async {
                                    self.lineChart.dataEntries = result
                                }
                                print("count after fetching: \(result.count)")
                            }
                        } catch let error {
                            print("Could not get graph from \(stockGraphURL) with error: \(error)")
                            self.hideLineChart()
                        }
                    }
                }.resume()
            }

        }
        
        
        resetButtons()
        dateButtons[sender.tag].backgroundColor = Color.black
        dateButtons[sender.tag].setTitleColor(.white, for: .normal)
    }
    
    func resetButtons() {
        for i in 0..<6 {
            dateButtons[i].backgroundColor = Color.cellBackground
            dateButtons[i].setTitleColor(Color.black, for: .normal)
        }
    }
    
    func createButtons(with content: [String]) {
        content.forEach { dateButtons.append(createButton(with: $0)) }
    }
    
    func createButton(with text: String) -> UIButton {
        let button = UIButton()
        button.setTitle(text, for: .normal)
        let buttonHeight = ((view.frame.width - 32) - 50) / 6
        button.layer.cornerRadius = buttonHeight / 4
        button.backgroundColor = Color.cellBackground
        button.setTitleColor(Color.black, for: .normal)
        button.setTitleColor(.white, for: .selected)
        
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        return button
    }
    
    @objc
    func starButtonPressed() {
        if (currentStarState == .notPressed) {
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "star.fill"), style: .plain, target: self, action: #selector(starButtonPressed))
            if let stockTicker = stock?.ticker {
                delegate?.addStockToFavourite(ticker: stockTicker)
            }
            currentStarState = .pressed
        } else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "star"), style: .plain, target: self, action: #selector(starButtonPressed))
            if let stockTicker = stock?.ticker {
                delegate?.deleteStockFromFavourite(ticker: stockTicker)
            }
            currentStarState = .notPressed
        }
    }
}
