//
//  DashboardView.swift
//  SimpleWalls
//
//  Created by Reksi Gustio on 24/06/24.
//

import SwiftUI

struct DashboardView: View {
    @ObservedObject var global: Global
    
    var body: some View {
        TabView {
            
            WallsView(global)
                .tabItem {
                    Label("Walls", systemImage: "mail.stack.fill")
                }
            
            NotificationView(global)
                .tabItem {
                    Label("Notifications", systemImage: "bell.fill")
                }
            
            MenuView(global)
                .tabItem {
                    Label("Menu", systemImage: "line.3.horizontal")
                }
            
        } // end of tabview
        .sheet(isPresented: $global.showImage) {
            if !global.imageData.isEmpty {
                PictureView(global: global, data: global.imageData)
                    .onDisappear { global.imageData = Data() }
            }
        }
        .onAppear { DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                global.getStatus()
            }
        }
        
    } // end of body
    
    init(_ global: Global) {
        self.global = global
    }
    
}

#Preview {
    DashboardView(Global())
}
