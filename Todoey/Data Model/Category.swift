//
//  Category.swift
//  Todoey
//
//  Created by Polina Fiksson on 21/12/2017.
//  Copyright © 2017 PolinaFiksson. All rights reserved.
//

import Foundation
import RealmSwift


class Category:Object {
    @objc dynamic var name = ""
    //forward relationship
    let items = List<Item>()
}
