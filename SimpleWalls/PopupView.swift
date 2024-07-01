//
//  PopupView.swift
//  SimpleWalls
//
//  Created by Reksi Gustio on 22/06/24.
//

import SwiftUI

struct PopupView: View {
    @State private var offset = CGSize.zero
    var removal: () -> Void
    let message: String
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(uiColor: .tertiarySystemBackground))
                .shadow(radius: 5)
            
            Text(message)
                .lineLimit(2)
                .padding(.horizontal)
        }
        .frame(maxHeight: 60)
        .padding()
        .offset(x: 0, y: offset.height)
        .opacity(2 - Double(abs(offset.height / 20)))
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    offset = gesture.translation
                }
                .onEnded { _ in
                    if abs(offset.height) > 50 {
                        removal()
                    } else {
                        withAnimation { offset = .zero }
                    }
                }
        )
        .transition(.move(edge: .bottom))
    } // end of body
    
    init(message: String, removal: @escaping () -> Void) {
        self.message = message
        self.removal = removal
    }
}

#Preview {
    PopupView(message: "Error: unknown error") { }
}
