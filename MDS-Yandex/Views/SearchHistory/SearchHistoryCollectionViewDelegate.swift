//
//  SearchHistoryCollectionViewDelegate.swift
//  MDS-Yandex
//
//  Created by Adlet Zeineken on 16.03.2021.
//  Copyright © 2021 justadlet. All rights reserved.
//

import UIKit

final class UICollectionViewLeftAlignedLayout: UICollectionViewFlowLayout {
}


class SearchHistoryCollectionViewDelegate1: NSObject, UICollectionViewDelegateFlowLayout {
    let content: [String]
    var searchBarDelegate: CustomSearchBarDelegate?
    
    init(_ content: [String], searchBarDelegate: CustomSearchBarDelegate?) {
        self.content = content
        self.searchBarDelegate = searchBarDelegate
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let font = UIFont.systemFont(ofSize: 18, weight: .medium)
        let attributes = [NSAttributedString.Key.font: font]
        let attributedString = NSAttributedString(string: content[indexPath.item], attributes: attributes)
        let itemSize = CGSize(width: attributedString.size().width + 32, height: 50)
        return itemSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        searchBarDelegate?.changeText(to: content[indexPath.item])
    }
}

class SearchHistoryCollectionViewDelegate2: NSObject, UICollectionViewDelegateFlowLayout {
    let content: [String]
    var searchBarDelegate: CustomSearchBarDelegate?
    
    init(_ content: [String], searchBarDelegate: CustomSearchBarDelegate?) {
        self.content = content
        self.searchBarDelegate = searchBarDelegate
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let font = UIFont.systemFont(ofSize: 16, weight: .medium)
        let attributes = [NSAttributedString.Key.font: font]
        let attributedString = NSAttributedString(string: content[indexPath.item], attributes: attributes)
        let itemSize = CGSize(width: attributedString.size().width + 32, height: 50)
        return itemSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if section == 0 {
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 4)
        } else {
            return UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .bottom)
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        searchBarDelegate?.changeText(to: content[indexPath.item])
    }
}
