//
//  AddItemView.swift
//  ConcurrencyFun
//
//  Created by Neal Archival on 9/17/24.
//

import SwiftUI

struct AddItemView: View {
    private enum Field: Equatable {
        case emoji
        case name
    }
    
    @FocusState private var focusedTextField: Field?
    
    let onAdd: (ItemDisplayable) -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var emoji: String = ""
    @State private var name: String = ""
    
    @State private var showAlert: Bool = false
    
    var body: some View {
        List {
            Section {
                TextField("Emoji", text: $emoji)
                    .focused($focusedTextField, equals: .emoji)
                TextField("Name", text: $name)
                    .focused($focusedTextField, equals: .name)
            } header: {
                Text("New Item")
            }
            
            Section {
                Button(action: addItem) {
                    Text("Add")
                }
                
                Button(action: cancel) {
                    Text("Cancel")
                        .foregroundStyle(.red)
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .keyboard) {
                HStack {
                    Spacer()
                    Button(action: { focusedTextField = nil }) {
                        Text("Close")
                    }
                }
            }
        }
        .onChange(of: emoji) { _, updated in
            if updated.count > 1 {
                emoji.removeLast()
            }
        }
        .onAppear {
            focusedTextField = .emoji
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Invalid Input"),
                message: Text("Emoji and Name must be at least 1 character long.")
            )
        }
    }
    
    private func addItem() {
        if emoji.isEmpty || name.isEmpty {
            showAlert = true
            return
        }
        
        dismiss()

        let item = ItemDisplayable(
            emoji: emoji,
            name: name,
            quantity: 1
        )
        onAdd(item)
    }
    
    private func cancel() {
        dismiss()
    }
}

#Preview {
    @Previewable @State var showSheet = false
    
    VStack {
        Button(action: { showSheet = true }) {
            Text("Open Sheet")
        }
    }
    .sheet(isPresented: $showSheet) {
        AddItemView(onAdd: { _ in })
    }
}
