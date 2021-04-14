//
//  SearchHistoryViewController.swift
//  MDS-Yandex
//
//  Created by Adlet Zeineken on 23.03.2021.
//  Copyright © 2021 justadlet. All rights reserved.
//

import Foundation
import UIKit

class SearchHistoryViewController: UIViewController {
    let titles = ["Popular requests", "You’ve searched for this"]
    let content = [["Apple", "Amazon", "Googl", "Tesla", "Microsoft", "Facebook", "Mastercard"],
                   ["Nvidia", "GM", "Microsoft", "Intel", "AMD", "Visa", "Bank of America"]]
    var delegate1 = SearchHistoryCollectionViewDelegate1([], searchBarDelegate: nil)
    var delegate2 = SearchHistoryCollectionViewDelegate2([], searchBarDelegate: nil)
    var popularRequests: [String] = []
    var searchedForThis: [String] = []
    var dataSource1 = SearchHistoryCollectionViewDataSource1([])
    var dataSource2 = SearchHistoryCollectionViewDataSource2([])
    var firstCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
    var secondCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
    var buttons: [UIButton] = []
    var searchBarDelegate: CustomSearchBarDelegate? {
        didSet {
            delegate1 = SearchHistoryCollectionViewDelegate1(content[0], searchBarDelegate: searchBarDelegate)
            delegate2 = SearchHistoryCollectionViewDelegate2(content[1], searchBarDelegate: searchBarDelegate)
            firstCollectionView.delegate = delegate1
            secondCollectionView.delegate = delegate2
            firstCollectionView.reloadData()
            secondCollectionView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
    }
    
    func configureUI() {
        setupCollectionViews(
            withTitles: titles,
            withContent: content
        )
//        setupScrollViews(withTitles: titles, withContent: content)
    }
    
    func setupScrollViews(withTitles titles: [String], withContent content: [[String]]) {
        let firstTitleLabel = createTitleLabel(with: titles[0])
        let secondTitleLabel = createTitleLabel(with: titles[1])
        
        let firstScrollView = createScrollView(with: content[0])
        let secondScrollView = createScrollView(with: content[1])
        
        view.addSubview(firstTitleLabel)
        view.addSubview(secondTitleLabel)
        view.addSubview(firstScrollView)
        view.addSubview(secondScrollView)
        
        firstTitleLabel.addConstraint(top: view.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: nil, centerXAnchor: nil, centerYAnchor: nil, paddingTop: 16, paddingLeading: 4)
        firstScrollView.addConstraint(top: firstTitleLabel.bottomAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, centerXAnchor: nil, centerYAnchor: nil, paddingTop: 16, height: 110)
    }
    
    func setupCollectionViews(withTitles titles: [String], withContent content: [[String]]) {
        let firstTitleLabel = createTitleLabel(with: titles[0])
        let secondTitleLabel = createTitleLabel(with: titles[1])
        
        dataSource1 = SearchHistoryCollectionViewDataSource1(content[0])
        dataSource2 = SearchHistoryCollectionViewDataSource2(content[1])
        delegate1 = SearchHistoryCollectionViewDelegate1(content[0], searchBarDelegate: searchBarDelegate)
        delegate2 = SearchHistoryCollectionViewDelegate2(content[1], searchBarDelegate: searchBarDelegate)
        firstCollectionView = createCollectionView(with: content[0], dataSource: dataSource1, delegate: delegate1)
        secondCollectionView = createCollectionView(with: content[1], dataSource: dataSource2, delegate: delegate2)
        
        view.addSubview(firstTitleLabel)
        view.addSubview(secondTitleLabel)
        view.addSubview(firstCollectionView)
        view.addSubview(secondCollectionView)
        
        firstTitleLabel.addConstraint(top: view.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: nil, centerXAnchor: nil, centerYAnchor: nil, paddingTop: 16, paddingLeading: 4)
        firstCollectionView.addConstraint(top: firstTitleLabel.bottomAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, centerXAnchor: nil, centerYAnchor: nil, paddingTop: 16, height: 110)
        secondTitleLabel.addConstraint(top: firstCollectionView.bottomAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, centerXAnchor: nil, centerYAnchor: nil, paddingTop: 40, paddingLeading: 4)
        secondCollectionView.addConstraint(top: secondTitleLabel.bottomAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, centerXAnchor: nil, centerYAnchor: nil, paddingTop: 16, height: 110)
    }
    
    func createTitleLabel(with title: String) -> UILabel {
        let titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        titleLabel.textAlignment = .left
        titleLabel.textColor = Color.black
        titleLabel.text = title
        return titleLabel
    }
    
    func createScrollView(with content: [String]) -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.backgroundColor = .red
        
        for i in 0..<content.count {
            let buttonTitle = content[i]
            let button = createButton(with: buttonTitle)
            button.tag = buttons.count
            buttons.append(button)
            scrollView.addSubview(button)
        }
        
        return scrollView
    }
    
    private func createButton(with title: String) -> UIButton {
        let button = UIButton()
        button.setTitle(title, for: .normal)
        button.backgroundColor = Color.cellBackground
        button.setTitleColor(Color.black, for: .normal)

        button.addTarget(self, action: #selector(highlightButton), for: .touchDown)
        button.addTarget(self, action: #selector(unhighlightButton), for: .touchUpInside)
        return button
    }
    
    @objc
    func unhighlightButton(sender: UIButton) {
        buttons[sender.tag].backgroundColor = Color.cellBackground
    }
    
    @objc
    func highlightButton(sender: UIButton) {
        buttons[sender.tag].backgroundColor = Color.black.withAlphaComponent(0.2)
    }
    
    func createCollectionView(with content: [String], dataSource: UICollectionViewDataSource, delegate: UICollectionViewDelegate) -> UICollectionView {
        let flowLayout = UICollectionViewLeftAlignedLayout()
        flowLayout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        
        collectionView.dataSource = dataSource
        collectionView.delegate = delegate
        collectionView.backgroundColor = .clear
        
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        
        collectionView.register(SearchHistoryCollectionViewCell.self, forCellWithReuseIdentifier: SearchHistoryCollectionViewCell.reuseIdentifier)
        return collectionView
    }
    

}
