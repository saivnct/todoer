//
//  Category.swift
//  Todoer
//
//  Created by Giang Bb on 1/18/19.
//  Copyright © 2019 giangbb. All rights reserved.
//

import Foundation
import RealmSwift

class Category:  Object{
    @objc dynamic var name: String = ""
    let items = List<Item>()
}
