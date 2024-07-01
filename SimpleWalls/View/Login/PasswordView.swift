//
//  PasswordView.swift
//  SimpleWalls
//
//  Created by Reksi Gustio on 23/06/24.
//

import SwiftUI

//view for password
struct PasswordView: View {
    var field: String
    @Binding var text: String
    @Binding var showText: Bool
    var body: some View {
        HStack {
            if showText {
                TextField(field, text: $text)
            } else {
                SecureField(field, text: $text)
            }
            
            Spacer()
            Button { showText.toggle() } label: {
                Image(systemName: showText ? "eye.fill" : "eye.slash.fill")
                    .foregroundStyle(showText ? .primary : .secondary)
            }
            .buttonStyle(PlainButtonStyle())
        } // end of hstack
    }
    
    init(_ field: String, text: Binding<String>, showText: Binding<Bool>) {
        self.field = field
        _text = text
        _showText = showText
    }
}
