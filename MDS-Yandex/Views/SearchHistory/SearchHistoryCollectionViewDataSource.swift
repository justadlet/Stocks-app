//
//  PopularRequestsCollectionViewDataSource.swift
//  MDS-Yandex
//
//  Created by Adlet Zeineken on 16.03.2021.
//  Copyright © 2021 justadlet. All rights reserved.
//

import UIKit

class SearchHistoryCollectionViewDataSource1: NSObject, UICollectionViewDataSource {
    let content: [String]
    
    init(_ content: [String]) {
        self.content = content
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return content.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchHistoryCollectionViewCell.reuseIdentifier, for: indexPath) as? SearchHistoryCollectionViewCell else {
            fatalError("Could not create CollectionViewCell")
        }
        cell.backgroundColor = Color.cellBackground
        cell.layer.cornerRadius = 25
        cell.stockLabel.text = content[indexPath.item]
        return cell
    }
}


class SearchHistoryCollectionViewDataSource2: NSObject, UICollectionViewDataSource {
    let content: [String]
    
    init(_ content: [String]) {
        self.content = content
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return content.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchHistoryCollectionViewCell.reuseIdentifier, for: indexPath) as? SearchHistoryCollectionViewCell else {
            fatalError("Could not create CollectionViewCell")
        }
        cell.backgroundColor = Color.cellBackground
        cell.layer.cornerRadius = 25
        cell.stockLabel.text = content[indexPath.item]
        return cell
    }
}
