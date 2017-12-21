//
//  Item.swift
//  Todoey
//
//  Created by Polina Fiksson on 21/12/2017.
//  Copyright © 2017 PolinaFiksson. All rights reserved.
//

import Foundation
import RealmSwift

class Item: Object {
    @objc dynamic var title:String = ""
    @objc dynamic var done: Bool = false
    @objc dynamic var dateCreated:Date?    //inverse relationship: each item has an inverse rel to category called "parentCategory"
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
    //Category.self = type
    //property: "items" points to the name of the forward relationship
}
