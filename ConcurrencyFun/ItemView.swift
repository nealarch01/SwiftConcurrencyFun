//
//  ItemView.swift
//  ConcurrencyFun
//
//  Created by Neal Archival on 9/17/24.
//

import SwiftUI

struct ItemView: View {
    let item: ItemDisplayable
    let onIncrease: () -> Void
    let onDecrease: () -> Void

    @State private var isRotating = false
    
    @State private var increaseClicked = false
    @State private var decreaseClicked = false

    var body: some View {
        VStack(alignment: .center) {
            Text(.init("\(item.emoji)"))
                .font(.system(size: 72))
                .rotationEffect(Angle.degrees(isRotating ? 360 : 0))
                .animation(
                    .linear(duration: 1.75).repeatForever(autoreverses: false),
                    value: isRotating
                )
            
            Text(.init("\(item.name)"))
                .font(.system(size: 32))
                .bold()
            
            Divider()
                .padding(.horizontal)
            
            VStack {
                HStack(spacing: 16) {
                    Button(action: {
                        decreaseClicked.toggle()
                        decreaseClicked.toggle()
                        onDecrease()
                    }) {
                        Image(systemName: "minus")
                            .font(.system(size: 32))
                            .fontWeight(.medium)
                    }
                    .sensoryFeedback(.decrease, trigger: decreaseClicked)
                    
                    Spacer()
                    
                    Text("\(item.quantity)")
                        .font(.system(size: 42))
                        .contentTransition(.numericText())

                    Spacer()
                    
                    Button(action: {
                        increaseClicked.toggle()
                        increaseClicked.toggle()
                        onIncrease()
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 32))
                            .fontWeight(.medium)
                    }
                    .sensoryFeedback(.decrease, trigger: increaseClicked)
                }
                .padding(.top, 12)
            }
            .padding(.vertical, 16)
            
            Spacer()
        }
        .multilineTextAlignment(.center)
        .onAppear {
            isRotating = true
        }
    }
}

#Preview {
    @Previewable @State var presented = false
    @Previewable @State var item = ItemDisplayable(emoji: "🍕", name: "Pizza Slice", quantity: 1)
    
    VStack {
        Button(action: { presented = true }) {
            Text("Open sheet")
        }
    }
    .sheet(isPresented: $presented) {
        ItemView(item: item, onIncrease: { item.quantity += 1 }, onDecrease: { item.quantity -= 1 })
            .padding()
            .presentationDetents([.height(350)])
    }
}
