//
//  ContentView.swift
//  ConcurrencyFun
//
//  Created by Neal Archival on 9/17/24.
//

import SwiftUI

// MARK: ContentView

struct ContentView: View {
    @State private var viewModel = ContentViewModel()
    
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(viewModel.items, id: \.id) { item in
                        Button(action: { viewModel.presentItemSheet(withID: item.id) }) {
                            itemRow(item)
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                viewModel.deleteItem(withID: item.id)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                } header: {
                    sectionHeader()
                }
            }
            .toolbar {
                bottomBarContent()
            }
            .sheet(isPresented: $viewModel.itemSheetPresented) {
                if let presentedItem = viewModel.presentedItem {
                    ItemView(
                        item: presentedItem,
                        onIncrease: viewModel.incrementItemCount,
                        onDecrease: viewModel.decrementItemCount
                    )
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
                    .padding()
                    .padding(.vertical)
                }
            }
            .sheet(isPresented: $viewModel.addItemSheetPresented) {
                AddItemView(onAdd: viewModel.addItem)
                    .presentationDetents(.init([.large]))
                    .interactiveDismissDisabled()
            }
        }
    }
}

// MARK: Sub-views

extension ContentView {
    @ViewBuilder
    private func itemRow(_ item: ItemDisplayable) -> some View {
        let title = "\(item.emoji) \(item.name)"
        let quantity = "\(item.quantity.formatWithCommas())x"
        
        HStack {
            VStack(alignment: .leading, spacing: 0) {
                Text(.init(title))
                    .foregroundStyle(colorScheme == .dark ? .white : .black)
                
                Text(.init(quantity))
                    .foregroundStyle(.gray)
            }
            .multilineTextAlignment(.leading)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundStyle(.gray)
        }
    }
    
    @ToolbarContentBuilder
    private func bottomBarContent() -> some ToolbarContent {
        ToolbarItem(placement: .bottomBar) {
            HStack {
                Button(action: viewModel.fetchItems) {
                    Text("Refresh")
                }
                .fontWeight(.semibold)
                
                Spacer()
                
                Button(action: viewModel.presentAddItemSheet) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Add Item")
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    @ViewBuilder
    private func sectionHeader() -> some View {
        HStack {
            Text("What is in my bag?! 🤨")
            if viewModel.fetchingItems {
                ProgressView()
            }
        }
    }
}

#Preview {
    ContentView()
}
