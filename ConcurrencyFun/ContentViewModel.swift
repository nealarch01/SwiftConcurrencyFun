//
//  ContentViewModel.swift
//  ConcurrencyFun
//
//  Created by Neal Archival on 9/17/24.
//

import SwiftUI
import Observation

@MainActor @Observable
class ContentViewModel {
    /// Observed property that stores a collection of value-type objects that conform to `Item`.
    private(set) var items: [ItemDisplayable] = []
    
    /// Observed property that determines whether a fetch request is actively running.
    private(set) var fetchingItems: Bool = false
    
    /// Observed property that contains the ID of the `ItemDisplayable` that will be presented in the `Item`sheet (if one exists).
    var presentedItemID: UUID?
    
    /// Observed property that determines whether an item sheet is presented.
    var itemSheetPresented: Bool = false
    
    /// Computed property that returns a copy of the `ItemDisplayable` whose id matches `presentedItemID` at a given point of the program.
    var presentedItem: ItemDisplayable? {
        guard let presentedItemID else { return nil }
        if let item = items.first(where: { $0.id == presentedItemID }) {
            return item
        }
        return nil
    }
    
    /// Observed property that determines whether an add item sheet is presented.
    var addItemSheetPresented: Bool = false
    
    init() {
        fetchItems()
    }
    
    /// Method for main actor contexes that increments fetches all persisted `Item` objects.
    func fetchItems() {
        if fetchingItems { return }
        Task {
            await fetchItemsFromDatabse()
        }
    }
    
    /// Method for main actor contexes that increments a persisted `Item`'s quantity.
    func incrementItemCount() {
        guard let presentedItemID else { return }
        Task {
            await editItemInDatabase(withID: presentedItemID, incrementBy: 1)
        }
    }
    
    /// Method for main actor contexes that decrements a persisted `Item`'s quantity.
    func decrementItemCount() {
        guard let presentedItemID else { return }
        Task {
            await editItemInDatabase(withID: presentedItemID, incrementBy: -1)
        }
    }

    /// Method for main actor contexes that adds an `Item` to the database.
    func addItem(_ item: ItemDisplayable) {
        Task {
            await addItemToDatabase(item)
        }
    }
    
    /// Method for main actor contexes that deletes an `Item` from the database.
    func deleteItem(withID id: UUID) {
        Task {
            await deleteItemInDatabase(withID: id)
        }
    }
    
    /// Presents the sheet to increment/decrement an item.
    ///
    /// - Parameter id: The unique identifier of the item whose quantity will be edited.
    func presentItemSheet(withID id: UUID) {
        presentedItemID = id
        itemSheetPresented = true
    }
    
    /// Presents the sheet with an input form to add a new item.
    func presentAddItemSheet() {
        addItemSheetPresented = true
    }
}

// MARK: Database Interactors

private extension ContentViewModel {
    
    /// Database actor isolated internal method that fetches all items and assigns the ViewModel's properties after completion.
    @DatabaseActor
    private func fetchItemsFromDatabse() {
        Task {
            await MainActor.run {
                fetchingItems = true
            }
            let fetchedItems = await DatabaseManager.shared.fetchItems(sleepFor: .random(in: 1...2))
            await MainActor.run {
                self.items = fetchedItems
                fetchingItems = false
            }
        }
    }
    
    /// Database actor isolated internal method that adds an `Item` to the database and assigns the ViewModel's properties after completion.
    @DatabaseActor
    private func addItemToDatabase(_ item: ItemDisplayable) async {
        Task {
            let newItem = await DatabaseManager.shared.addItem(item)
            await MainActor.run {
                self.items.append(newItem)
            }
        }
    }
    
    /// Database actor isolated internal method that deletes an `Item` from the database and assigns the ViewModel's properties after completion.
    @DatabaseActor
    private func deleteItemInDatabase(withID id: UUID) {
        Task {
            await DatabaseManager.shared.deleteItem(withID: id)
            await MainActor.run {
                // Synchronize with the database.
                if let index = items.firstIndex(where: { $0.id == id }) {
                    items.remove(at: index)
                }
            }
        }
    }
    
    /// Database actor isolated internal method that edits an `Item` from the database and assigns the ViewModel's properties after completion.
    ///
    /// - Parameters:
    ///   - id: The unique identifier of the item whose quantity will be edited.
    ///   - step: The amount to increase/decrease the quantity by. If a negative number is given, then the quantity will decrease.
    @DatabaseActor
    private func editItemInDatabase(withID id: UUID, incrementBy step: Int) {
        Task {
            let updatedItem = await DatabaseManager.shared.incrementItemQuantity(withID: id, by: step)
            await MainActor.run {
                if let index = items.firstIndex(where: { $0.id == id }), let updatedItem {
                    self.items[index] = updatedItem
                }
            }
        }
    }
}
