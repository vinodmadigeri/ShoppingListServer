//
//  ShoppingList.swift
//  ShoppingListServerPackageDescription
//
//  Created by Vinod Madigeri on 2/25/18.
//

import Foundation
import Vapor
import FluentProvider
import HTTP

final class ShoppingList : Model {
    
    let storage: Storage = Storage()
    var name: String
    var items: Children <ShoppingList, Item> {
        return children()
    }
    
    
    struct Keys {
        static let id = "id"
        static let name = "name"
    }
    
    init(name: String) {
        self.name = name
    }
    
    init(row: Row) throws {
        name = try row.get(ShoppingList.Keys.name)
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(ShoppingList.Keys.name, self.name)
        return row
    }
}

extension ShoppingList: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self, closure: { (creater) in
            creater.id()
            creater.string(ShoppingList.Keys.name)
        })
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

extension ShoppingList: JSONConvertible {
    convenience init(json: JSON) throws {
        self.init(name: try json.get(ShoppingList.Keys.name))
    }

    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set(ShoppingList.Keys.id, id)
        try json.set(ShoppingList.Keys.name, name)
        try json.set("items", items.all())
    }
}

extension ShoppingList: ResponseRepresentable { }

extension ShoppingList: Updateable {
    public static var updateableKeys: [UpdateableKey<ShoppingList>] {
        return [
            UpdateableKey(ShoppingList.Keys.name, String.self) { shoppingList,
                name in
                shoppingList.name = name
            }
        ]
    }
}

