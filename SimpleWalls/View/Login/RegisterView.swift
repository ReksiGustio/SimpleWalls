//
//  RegisterView.swift
//  SimpleWalls
//
//  Created by Reksi Gustio on 23/06/24.
//

import SwiftUI

struct RegisterView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var global: Global
    @FocusState private var isFocused
    @State private var username = ""
    @State private var password = ""
    @State private var retypePassword = ""
    @State private var displayName = ""
    @State private var validationMessage = ""
    @State private var showPassword = false
    @State private var showRetypePassword = false
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Please fill in these forms")
                .font(.headline)
                .padding([.leading, .bottom])
            
            Text("Username:").padding(.leading)
            TextField("Username", text: $username)
                .modifier(CustomTextField())
                .focused($isFocused)
            
            Text("Display Name (Optional):").padding(.leading)
            TextField("Display Name", text: $displayName)
                .modifier(CustomTextField())
                .focused($isFocused)
            
            Text("Password:").padding(.leading)
            Group {
                PasswordView("Password", text: $password, showText: $showPassword)
                PasswordView("Retype Password", text: $retypePassword, showText: $showRetypePassword)
            } // end of group
            .modifier(CustomTextField())
            .focused($isFocused)
            
        } // end of Vstack
        
        Text(validationMessage).foregroundStyle(.red)
        
        Button("Submit", action: validate)
            .buttonStyle(BorderedProminentButtonStyle())
            .disabled(global.loadingState == .loading)
        
        Spacer()
            .navigationTitle("Register to SimpleWalls")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .keyboard) {
                    HStack {
                        Spacer()
                        Button("Done") { isFocused = false }
                    }
                }
            }
    } // end of body
    
    init(_ global: Global) {
        self.global = global
    }
}

#Preview {
    RegisterView(Global())
}

//function and computed properties here
extension RegisterView {
    
    func validate() {
        let username = username.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = password.trimmingCharacters(in: .whitespacesAndNewlines)
        let retypePassword = retypePassword.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let validation = (username.isEmpty, username.count < 3, username.contains(" "), password.isEmpty, password.count < 6, password != retypePassword)
        
        switch validation {
        case (true, _, _, _, _, _) : 
            validationMessage = "Username is required"
        case (_, true, _, _, _, _) : 
            validationMessage = "Username must be at least 3 characters long"
        case (_, _, true, _, _, _) : 
            validationMessage = "Username cannot contains whitespaces"
        case (_, _, _, true, _, _) : 
            validationMessage = "Password is required"
        case (_, _, _, _, true, _) : 
            validationMessage = "Password must be at least 6 characters long"
        case (_, _, _, _, _, true) :
            validationMessage = "Password doesn't match"
        default: 
            registerUser()
        }
    }// end of validation
    
    func registerUser() {
        validationMessage = ""
        isFocused = false
        global.loadingState = .loading
        global.timer.upstream.connect().cancel()
        Task {
            let response = await register(username: username, password: password, name: displayName)
            global.errorHandling(response: response)
            global.loadingState = .loaded
            global.loginState = .logout
            if global.message.hasPrefix("User ") { dismiss() }
        }
    } // end of loginUser
}
