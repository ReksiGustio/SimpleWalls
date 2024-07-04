//
//  FollowView.swift
//  SimpleWalls
//
//  Created by Reksi Gustio on 04/07/24.
//

import SwiftUI

struct FollowView: View {
    @ObservedObject var global: Global
    @Binding var path: NavigationPath
    @State private var displayPicture: Image?
    @State private var picture: Data?
    let follows: [Follow]
    
    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(users, id: \.id) { user in
                    Button { path.append(user.userId) } label: {
                        HStack {
                            ProfilePictureView(global: global, data: picture, imageURL: user.profilePicture, frameSize: 44)
                            
                            Text(user.name ?? "")
                                .font(.title3.weight(.semibold))
                            
                            Spacer()
                        }
                        .padding()
                        .background(Color(uiColor: .systemBackground))
                        .clipShape(.rect(cornerRadius: 10))
                        .overlay (
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(.primary)
                        )
                    }
                    .contentShape(Rectangle())
                    .buttonStyle(PlainButtonStyle())
                    .padding()
                } // end of foreach
            } // end of lazyvstack
        } // end of scrollview
        .navigationTitle("Follow list")
        .toolbar {
            if !path.isEmpty {
                Button("Home") { path = NavigationPath() }
            }
        }
    } // end of body
    
}

#Preview {
    FollowView(global: Global(), path: .constant(NavigationPath()), follows: [Follow(id: 1, displayName: "Gustio", imageURL: nil, userId: 2)])
}

extension FollowView {
    var users: [Profile] {
        var users = [Profile]()
        
        var id = 0
        for follow in follows {
            let user = Profile(id: id, name: follow.displayName, bio: nil, profilePicture: follow.imageURL, userId: follow.userId)
            id += 1
            
            users.append(user)
        }
        
        return users
    }
}
