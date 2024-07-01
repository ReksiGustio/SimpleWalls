//
//  LoginView.swift
//  SimpleWalls
//
//  Created by Reksi Gustio on 22/06/24.
//

import SwiftUI

struct LoginView: View {
    @ObservedObject var global: Global
    @FocusState private var isFocused
    @State private var username = ""
    @State private var password = ""
    @State private var validationMessage = ""
    @State private var showPassword = false
    
    var body: some View {
        NavigationStack {
            Text("Login to SimpleWalls")
                .font(.largeTitle.bold())
            
            Group {
                TextField("Username", text: $username)
                PasswordView("Password", text: $password, showText: $showPassword)
            } // end of group
            .modifier(CustomTextField(frame: 300, radius: 30))
            .focused($isFocused)
            
            Text(validationMessage).foregroundStyle(.red)
            
            HStack {
                Button("Login", action: validate)
                NavigationLink("Register") {
                    RegisterView(global)
                        .onAppear { validationMessage = "" }
                }
            } // end of hstack
            .buttonStyle(BorderedProminentButtonStyle())
            .toolbar {
                ToolbarItem(placement: .keyboard) {
                    HStack {
                        Spacer()
                        Button("Done") { isFocused = false }
                    }
                }
            }
        } // end of navstack
        .disabled(global.loadingState == .loading)
    } // end of body
    
    init(_ global: Global) {
        self.global = global
    }
}

#Preview {
    LoginView(Global())
}

//function and computed properties here
extension LoginView {
    var getState: LoginState {
        if global.message.hasPrefix("Logged in") {
            return .login
        } else {
            return .logout
        }
    }
    
    func validate() {
        let username = username.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = password.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let validation = (username.isEmpty, password.isEmpty)
        
        switch validation {
        case (true, _) : validationMessage = "Username is required"
        case (_, true) : validationMessage = "Password is required"
        default: loginUser()
        }
    }
    
    func loginUser() {
        validationMessage = ""
        isFocused = false
        global.loadingState = .loading
        global.timer.upstream.connect().cancel()
        Task {
            let response = await login(username: username, password: password)
            global.errorHandling(response: response)
            global.loadingState = .loaded
            global.loginState = getState
        }
    } // end of loginUser

}
