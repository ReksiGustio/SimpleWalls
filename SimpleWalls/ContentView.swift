//
//  ContentView.swift
//  SimpleWalls
//
//  Created by Reksi Gustio on 22/06/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var global = Global()
    @State private var showLastMessage = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            
            ZStack {
                Color.clear
                
                if global.loginState == .opening {
                    Text("Simple\nWalls")
                        .multilineTextAlignment(.center)
                        .font(.largeTitle.bold())
                        .onAppear { loadData() }
                } else if global.loginState == .login {
                    DashboardView(global)
                } else {
                    LoginView(global)
                }
                
                if global.loadingState == .loading {
                    LoadingView()
                } 
                
            } // end of zstack
            
            if global.showMessage {
                PopupView(message: global.message) { global.showMessage = false }
                    .onReceive(global.timer) { _ in withAnimation { global.showMessage = false } }
                    .onDisappear { 
                        global.timer.upstream.connect().cancel()
                        global.message = ""
                    }
            }
            
        } // end of zstack
    } // end of body
    
}

#Preview {
    ContentView()
}

//function and computed properties here
extension ContentView {
    func loadData() {
        if global.userData.userName == "" {
            global.loginState = .logout
        } else {
            global.loginState = .login
        }
    }
}

struct LoadingView: View {
    
    var body: some View {
        Color.primary
            .opacity(0.4)
            .ignoresSafeArea()
        
        ProgressView()
            .controlSize(.large)
            .tint(.white)
    }
    
}
