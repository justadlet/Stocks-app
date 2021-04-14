//
//  ObjectFavouriteString.swift
//  MDS-Yandex
//
//  Created by Adlet Zeineken on 29.03.2021.
//  Copyright © 2021 justadlet. All rights reserved.
//

import RealmSwift

class FavouriteStocksString: Object {
    @objc dynamic var string: String = ""
    
    init(newString: String) {
        self.string = newString
    }
    
    required init() {
        self.string = ""
    }
}
