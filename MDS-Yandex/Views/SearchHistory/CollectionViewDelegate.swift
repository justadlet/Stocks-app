//
//  PopularRequestsCollectionViewDelegate.swift
//  MDS-Yandex
//
//  Created by Adlet Zeineken on 16.03.2021.
//  Copyright © 2021 justadlet. All rights reserved.
//

import UIKit

class PopularRequestsCollectionViewDelegate: NSObject, UICollectionViewDelegateFlowLayout {
    let numberOfItemsPerRow: CGFloat
    let interItemSpacing: CGFloat
    
    init(numberOfItemsPerRow: CGFloat, interItemSpacing: CGFloat) {
        self.numberOfItemsPerRow = numberOfItemsPerRow
        self.interItemSpacing = interItemSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let maxWidth = UIScreen.main.bounds.width
        let totalSpacing = interItemSpacing * numberOfItemsPerRow
        
        let itemWidth = (maxWidth - totalSpacing) / numberOfItemsPerRow
        return CGSize(width: itemWidth, height: itemWidth)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return interItemSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if section == 0 {
            return UIEdgeInsets(top: 0, left: 0, bottom: interItemSpacing / 2, right: 0)
        } else {
            return UIEdgeInsets(top: interItemSpacing / 2, left: 0, bottom: interItemSpacing / 2, right: 0)
        }
    }
}
