//
//  GlobalData.swift
//  SimpleWalls
//
//  Created by Reksi Gustio on 22/06/24.
//

import SwiftUI

//login state
enum LoginState {
    case logout, login, opening
}

enum LoadingState {
    case loading, loaded
}

enum ViewState {
    case downloading, downloaded, failed
}

//global data
class Global: ObservableObject {
    @Published var loginState = LoginState.opening
    @Published var loadingState = LoadingState.loaded
    @Published var commentTapped = false
    
    //used for store current user data
    @Published var userData: User = .example {
        didSet {
            if let encoded = try? JSONEncoder().encode(userData) {
                UserDefaults.standard.setValue(encoded, forKey: "userData")
            }
        }
    }
    
    //used for store someone user image
    @Published var userImage = Data()
    @Published var wallsUserImage = Data()
    @Published var notificationUserImage = Data()
    @Published var menuUserImage = Data()
    
    //used for store someone user per tab menu
    @Published var wallsUserData = User.example
    @Published var notificationUserData = User.example
    @Published var menuUserData = User.example
    
    //used for popup message
    @Published var message = ""
    @Published var showMessage = false
    @Published var timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()
    
    init() {
        if let data = UserDefaults.standard.data(forKey: "userData") {
            if let decoded = try? JSONDecoder().decode(User.self, from: data) {
                userData = decoded
                return
            }
        }
        
        userData = .example
    }
    
    func getStatus() {
        loadingState = .loading
        timer.upstream.connect().cancel()
        Task {
            let response = await userStatus()
            
            //get data success
            if let data = try? JSONDecoder().decode(ResponseData<User>.self, from: response) {
                userData = data.data
                print("get status successfully")
                loadingState = .loaded
                loginState = .login
                timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()
            } else {
                print("error handling")
                errorHandling(response: response)
            }
        }
    } // end of checkStatus
    
    func logout() {
        removeCookie()
        clearData()
        
        message = "Logout successfully"
        showMessage = true
        timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()
    }
    
    func errorHandling(response: Data) {
        if response.isEmpty {
            print("Failed to get message from server")
            message = "Unable to connect to the server"
            showMessage = true
            loadingState = .loaded
            timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()
            return
        }
        
        if let data = try? JSONDecoder().decode(ResMessage.self, from: response) {
            print("get message from server")
            message = data.message
            if message.hasPrefix("Unauthorized") {
                message = "Session expired, please log in again"
                loginState = .logout
                loadingState = .loaded
            }
            showMessage = true
            loadingState = .loaded
            timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()
        }
    } // end of errorHandling
    
    func clearData() {
        loginState = .logout
        userData = .example
        
        userImage = Data()
        wallsUserImage = Data()
        notificationUserImage = Data()
        menuUserImage = Data()
        
        wallsUserData = User.example
        notificationUserData = User.example
        menuUserData = User.example
    } // end of clearData
}

//view modifier
struct CustomTextField: ViewModifier {
    var frame: CGFloat
    var radius: CGFloat
    
    func body(content: Content) -> some View {
        content
            .autocorrectionDisabled()
            .autocapitalization(.none)
            .padding(.leading, 10)
            .padding(10)
            .overlay(
                RoundedRectangle(cornerRadius: radius)
                    .stroke(.primary, lineWidth: 1)
            )
            .frame(maxWidth: frame)
            .padding(.bottom, 8)
            .padding(.horizontal, 20)
    }
    
    init(frame: CGFloat = .infinity, radius: CGFloat = 10) {
        self.frame = frame
        self.radius = radius
    }
}

struct CustomButton: ViewModifier {
    var paddingSize: CGFloat
    
    func body(content: Content) -> some View {
        content
            .dynamicTypeSize(.medium)
            .padding(paddingSize)
            .overlay (
                RoundedRectangle(cornerRadius: 10)
                    .stroke(lineWidth: 1)
            )
            .tint(.primary)
    }
    
    init(paddingSize: CGFloat = 20) {
        self.paddingSize = paddingSize
    }
}
