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
    @Published var showImage = false
    @Published var imageData = Data()
    
    //used for custombackground
    @Published var customBackground = 
    ["light": CustomBackground(r: 0.9, g: 0.9, b: 0.9),
     "dark": CustomBackground(r: 0.1, g: 0.1, b: 0.1)] {
        didSet {
            if let encoded = try? JSONEncoder().encode(customBackground) {
                UserDefaults.standard.setValue(encoded, forKey: "customBackground")
            }
        }
    }
    
    //used for store current user data
    @Published var userData: User = .example {
        didSet {
            if let encoded = try? JSONEncoder().encode(userData) {
                UserDefaults.standard.setValue(encoded, forKey: "userData")
            }
        }
    }
    
    //used for popup message
    @Published var message = ""
    @Published var showMessage = false
    @Published var timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()
    
    init() {
        if let data = UserDefaults.standard.data(forKey: "userData") {
            if let decoded = try? JSONDecoder().decode(User.self, from: data) {
                userData = decoded
            } else {
                userData = .example
            }
        }
        
        if let data = UserDefaults.standard.data(forKey: "customBackground") {
            if let decoded = try? JSONDecoder().decode([String: CustomBackground].self, from: data) {
                customBackground = decoded
            } else {
                customBackground = ["light": CustomBackground(r: 0.9, g: 0.9, b: 0.9),
                                    "dark": CustomBackground(r: 0.1, g: 0.1, b: 0.1)]
            }
        }
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
    
    func loadImage(data: Data) -> Image? {
        if let UIPicture = UIImage(data: data) {
            return Image(uiImage: UIPicture)
        }
        
        return nil
    } // end of load user image
    
    func logout() {
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
    } // end of clearData
}

//class for custom background color
struct CustomBackground: Codable {
    var red: Double
    var green: Double
    var blue: Double
    
    init(r: Double, g: Double, b: Double) {
        red = r
        green = g
        blue = b
    }
}

//class to save image to gallery
class ImageSaver: NSObject {
    var successHandler: (() -> Void)?
    var errorHandler: ((Error) -> Void)?
    
    func writeToPhotoAlbum(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveCompleted), nil)
    }
    
    @objc func saveCompleted(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            errorHandler?(error)
        } else {
            successHandler?()
        }
    }
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
