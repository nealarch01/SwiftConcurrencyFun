//
//  Item.swift
//  ConcurrencyFun
//
//  Created by Neal Archival on 9/17/24.
//

import Foundation

// MARK: Item

protocol Item {
    var id: UUID { get }
    var emoji: String { get set }
    var name: String { get set }
    var quantity: Int { get set }
}

// MARK: ItemRecord

/// Persistent `Item` that is stored into a database.
class ItemRecord: Item {
    var id: UUID
    var emoji: String
    var name: String
    var quantity: Int
    
    init(id: UUID = UUID(), emoji: String, name: String, quantity: Int = 0) {
        self.id = id
        self.emoji = emoji
        self.name = name
        self.quantity = quantity
    }
    
    var toDisplayable: ItemDisplayable {
        ItemDisplayable(
            id: id,
            emoji: emoji,
            name: name,
            quantity: quantity
        )
    }
}

// MARK: ItemDisplayable

/// Transient `Item` that is used exclusively for presentations to a View.
struct ItemDisplayable: Item {
    var id: UUID = UUID()
    var emoji: String
    var name: String
    var quantity: Int = 0
}

extension ItemDisplayable: Hashable {}
