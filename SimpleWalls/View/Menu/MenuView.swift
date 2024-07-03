//
//  MenuView.swift
//  SimpleWalls
//
//  Created by Reksi Gustio on 24/06/24.
//

import SwiftUI

struct MenuView: View {
    @ObservedObject var global: Global
    @State private var path = NavigationPath()
    @State private var showLogoutPrompt = false
    @State private var picture: Data?
    
    var body: some View {
        NavigationStack(path: $path) {
            Form {
                Section {
                    HStack {
                        ProfilePictureView(global: global, data: picture, imageURL: global.userData.profile.profilePicture, frameSize: 64)
                        
                        VStack(alignment: .leading) {
                            Text(name)
                                .font(.title3.bold())
                                .padding(.leading, 10)
                        } // end of vstack
                        
                    } // end of hstack
                    Button("View profile") { path.append(global.userData.id) }
                } // end of section
                
                Section("Settings") {
                    NavigationLink("Customize theme") { CustomThemeView(global) }
                    Button("Log out") { showLogoutPrompt = true }
                        .foregroundStyle(.red)
                }
            } // end of form
            .navigationTitle("Menu")
            .navigationDestination(for: Int.self) { userId in
                ProfileView(global, userId: userId, path: $path)
            }
            .navigationDestination(for: Post.self) { post in
                DetailPostView(global, postId: post.id, authorId: post.authorId, commentTapped: tapped, path: $path)
            }
            .alert("Log out your account?", isPresented: $showLogoutPrompt) {
                Button("Confirm") { global.logout() }
                Button("Cancel", role: .cancel) { }
            }
        } // end of navstack
    } // end of body
    
    init(_ global: Global) {
        self.global = global
    }
    
}

#Preview {
    MenuView(Global())
}

//function and computed properties here
extension MenuView {
    var profile: Profile { global.userData.profile }
    
    var tapped: Bool { global.commentTapped }
    
    var name: String {
        if let name = global.userData.profile.name {
            if name == "" { return "New User" } else {
                return name
            }
        }
        
        return "New User"
    } // end of name property
    
    
}
