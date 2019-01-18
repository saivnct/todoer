//
//  Item.swift
//  Todoer
//
//  Created by Giang Bb on 1/18/19.
//  Copyright © 2019 giangbb. All rights reserved.
//

import Foundation
import RealmSwift

class Item: Object {    
    @objc dynamic var title: String = ""
    @objc dynamic var done: Bool = false
    @objc dynamic var dateCreated: Date?
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
}
