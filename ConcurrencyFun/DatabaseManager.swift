//
//  DatabaseManager.swift
//  ConcurrencyFun
//
//  Created by Neal Archival on 9/17/24.
//

import Foundation

// MARK: DatabaseActor

/// A global actor responsible for managing database operations.
///
/// The `DatabaseActor` ensures that all database-related operations are executed in a serialized and
/// thread-safe manner. It is a singleton, and its shared instance can be accessed through the `shared` property.
///
/// - Note: This actor is used to isolate database operations from other asynchronous contexts and ensure that
///         all interactions with the database are properly synchronized.
///
/// Example usage:
/// ```swift
/// @DatabaseActor
/// private func fetchItemsFromDatabse() {
///     Task {
///         await MainActor.run {
///             isLoading = true
///         }
///         let result = await DatabaseManager.shared.fetch()
///         await MainActor.run {
///             self.data = result
///             fetchingItems = false
///         }
///     }
/// }
///
/// ```
///
/// This ensures that the `someDatabaseOperation` method is executed within the context of the `DatabaseActor`.
@globalActor actor DatabaseActor: GlobalActor {
    static let shared = DatabaseActor()
}

// MARK: DatabaseManager

/// Manager responsible for creating, reading, updating, and deleting persistent data.
///
/// - Note: This app does not actually persist any data in a data store.
/// The data stored in this app are in the `items` array and are in memory.
@DatabaseActor
class DatabaseManager {
    /// Globally accessible and long-lived instance of `DatabaseManager`.
    ///
    /// - Note: If this function is called from the main actor or any asynchronous context that is **not** isolated to the database actor,
    /// you must use `await`.
    ///
    /// However, if the caller is within an asynchronous context **isolated to the database actor**,
    /// `await` is not required since the function is already running within the actor's context.
    ///
    /// To achieve isolation to database actor then annotate your object/protocol/method/property with `@DatabaseActor`.
    ///
    static let shared = DatabaseManager()
    
    /// Specify private access  to ensure only a instantiation is controlled in-class.
    private init() {}
    
    /// The simulated database.
    private var items: [ItemRecord] = [
        ItemRecord(emoji: "💻", name: "Laptop", quantity: 1),
        ItemRecord(emoji: "🕶️", name: "Sunglasses", quantity: 1),
        ItemRecord(emoji: "📓", name: "Notebook", quantity: 3),
        ItemRecord(emoji: "🥑", name: "Avocado", quantity: 1200)
    ]
}

// MARK: Public Interface

extension DatabaseManager {
    
    /// Simulates a fetch request to the database, querying and returning all items mapped as a value-type.
    ///
    /// - Parameter time: The number of seconds this method will sleep.
    /// - Returns: A collection of `ItemDisplayable` value-type objects.
    func fetchItems(sleepFor time: UInt64 = .zero) async -> [ItemDisplayable] {
        if time != .zero {
            let sleepTime = time * NSEC_PER_SEC
            try? await Task.sleep(nanoseconds: sleepTime)
        }
        return items.map { $0.toDisplayable }
    }
    
    /// Adds an `ItemRecord` with the given `item`.
    ///
    /// - Parameter item: Value-type created from a View/ViewModel context.
    /// - Returns: The item displayable that was passed as a parameter.
    @discardableResult
    func addItem(_ item: ItemDisplayable) async -> ItemDisplayable {
        let itemRecord = ItemRecord(
            id: item.id,
            emoji: item.emoji,
            name: item.name,
            quantity: item.quantity
        )
        items.append(itemRecord)
        return item
    }
    
    /// Deletes an item with the specified unique identifier.
    ///
    /// - Parameter id: The unique identifier of the item to be deleted.
    /// - Returns: The `UUID` of the deleted item.
    @discardableResult
    func deleteItem(withID id: UUID) async -> UUID {
        if let index = items.firstIndex(where: { $0.id == id }) {
            items.remove(at: index)
        }
        return id
    }
    
    /// Edits the properties of an item with the specified unique identifier.
    ///
    /// - Parameters:
    ///   - id: The unique identifier of the item to be edited.
    ///   - emoji: An optional `String` representing the new emoji for the item. Pass `nil` to leave unchanged.
    ///   - name: An optional `String` representing the new name for the item. Pass `nil` to leave unchanged.
    ///   - quantity: An optional `Int` representing the new quantity for the item. Pass `nil` to leave unchanged.
    /// - Returns: An optional `ItemDisplayable` containing the updated item if successful, or `nil` if the item was not found.
    @discardableResult
    func editItem(withID id: UUID, emoji: String? = nil, name: String? = nil, quantity: Int? = nil) async -> ItemDisplayable? {
        let itemRecord: ItemRecord? = {
            if let index = items.firstIndex(where: { $0.id == id }) {
                return items[index]
            }
            return nil
        }()
        
        guard let itemRecord else { return nil }
        
        if let emoji {
            itemRecord.emoji = emoji
        }
        
        if let name {
            itemRecord.name = name
        }
        
        if let quantity {
            itemRecord.quantity = quantity
        }
        
        return itemRecord.toDisplayable
    }
    
    /// Increments the quantity of an item by a specified amount.
    ///
    /// - Parameters:
    ///   - id: The unique identifier of the item whose quantity is to be incremented.
    ///   - step: The value by which the item's quantity should be incremented. This can be a positive or negative integer.
    /// - Returns: An optional `ItemDisplayable` containing the updated item if successful, or `nil` if the item was not found.
    /// - Throws: This function doesn't throw an error but returns `nil` if the item cannot be found.
    /// - Note: This function is marked `async` and should be awaited due to the asynchronous nature of locating and updating the item.
    @discardableResult
    func incrementItemQuantity(withID id: UUID, by step: Int) async -> ItemDisplayable? {
        let itemRecord: ItemRecord? = {
            if let index = items.firstIndex(where: { $0.id == id }) {
                return items[index]
            }
            return nil
        }()
        
        guard let itemRecord else { return nil }
        
        let newQuantity = itemRecord.quantity + step
        
        if newQuantity < 0 {
            return itemRecord.toDisplayable
        }
        
        itemRecord.quantity = newQuantity
        
        return itemRecord.toDisplayable
    }
}
