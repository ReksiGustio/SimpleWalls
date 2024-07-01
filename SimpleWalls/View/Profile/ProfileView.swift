//
//  ProfileView.swift
//  SimpleWalls
//
//  Created by Reksi Gustio on 24/06/24.
//

import SwiftUI

struct ProfileView: View {
    @ObservedObject var global: Global
    @Binding var path: NavigationPath
    let userId: Int
    
    @State private var viewState = ViewState.downloading
    @State private var user = User.example
    @State private var selectedPost = -1
    @State private var deleteAlert = false
    
    var body: some View {
        switch viewState {
        case .downloading:
            ProgressView()
                .tint(.primary)
                .onAppear { downloadUser(userId) }
        case .downloaded:
            ScrollView {
                LazyVStack {
                    //image placeholder
                    VStack(alignment: .center) {
                        Circle()
                            .fill(.gray)
                            .frame(width: 128, height: 128)
                            .padding()
                        
                        Text(name)
                            .font(.title3.bold())
                        
                        Text(bio)
                            .lineLimit(4)
                    } // end of vstack
                    
                    Divider()
                    
                    if userId == global.userData.id {
                        NavigationLink {
                            EditProfileView(global, profile: profile)
                        } label: {
                            Label("Edit profile", systemImage: "pencil.circle.fill")
                                .foregroundStyle(.white)
                                .padding(10)
                                .background(.blue)
                                .clipShape(.rect(cornerRadius: 10))
                        }
                    }
                    
                    Text("\(name)'s Posts")
                        .font(.title3.bold())
                        .padding()
                    
                    Group {
                        if userId == global.userData.id {
                            NavigationLink { 
                                NewPostView(global) { post in
                                    user.posts?.insert(post, at: 0)
                                }
                            } label: {
                                Text("Write new post")
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .overlay (
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(lineWidth: 1)
                                    )
                                    .tint(.primary)
                            } // end of navlink
                        } // end if
                        
                        ForEach(posts) { post in
                            PostView(global, post: post, author: partialUser, path: $path)
                                .contextMenu {
                                    if userId == global.userData.id {
                                        Button(role: .destructive) {
                                            selectedPost = post.id
                                            deleteAlert = true
                                        } label: {
                                            Label("Delete post", systemImage: "trash")
                                        }
                                        
                                    } // end if
                                    
                                    Button {
                                        UIPasteboard.general.string = post.title
                                    } label: {
                                        Label("Copy text to clipboard", systemImage: "doc.on.doc")
                                    }
                                    
                                }
                        } // end of foreach
                    
                        
                    } // end of group
                    .padding(.horizontal, 20)
                    .padding(.bottom, 10)
                    
                    //end post marker
                    Color.primary
                        .frame(height: 1)
                    
                } // end of vstack
            } // end of Scrollview
            .navigationTitle(name)
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: Int.self) { authorId in
                ProfileView(global, userId: authorId, path: $path)
            }
            .onDisappear { viewState = .downloading }
            .alert("Delete your post?", isPresented: $deleteAlert) {
                Button("Delete", role: .destructive) { removePost(postId: selectedPost) }
                Button("Cancel", role: .cancel) { selectedPost = -1 }
            } message: {
                Text("Deleted post can't be recovered")
            }
            .toolbar {
                if !path.isEmpty {
                    Button("Home") { path = NavigationPath() }
                }
            }
        case .failed:
            Button { downloadUser(userId) } label: {
                Label("Try again", systemImage: "arrow.circlepath")
            }
        }
        
    } // end of body
    
    init(_ global: Global, userId: Int, path: Binding<NavigationPath>) {
        self.global = global
        self.userId = userId
        _path = path
    }
    
}

#Preview {
    ProfileView(Global(), userId: 3, path: .constant(NavigationPath()))
}

//function and computed properties here
extension ProfileView {
    
    var profile: Profile {
        return user.profile
    } // end of profile property
    
    var posts: [Post] {
        return user.posts?.sorted { $0.createdAt > $1.createdAt } ?? [.example]
    }
    
    var name: String {
        return profile.name == "" ? "" : profile.name ?? ""
    } // end of name property
    
    var bio: String {
        return profile.bio ?? ""
    } // end of bio property
    
    var partialUser: PartialUser {
        return PartialUser(id: user.id, userName: user.userName, profile: user.profile)
    }
    
    func downloadUser(_ id: Int) {
        viewState = .downloading
        global.timer.upstream.connect().cancel()
        
        Task {
            let response = await statusById(id)
            
            //get data success
            if let data = try? JSONDecoder().decode(ResponseData<User>.self, from: response) {
                user = data.data
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    viewState = .downloaded
                }
            } else {
                print("error handling")
                global.errorHandling(response: response)
                viewState = .failed
            }
        }
    } // end of downloaduser
    
    func removePost(postId: Int) {
        global.message = ""
        global.timer.upstream.connect().cancel()
        
        Task {
            let response = await deletePost(postId: postId)
            
            //get data success
            global.errorHandling(response: response)
            if global.message.hasPrefix("Deleted") {
                selectedPost = -1
                viewState = .downloading
                downloadUser(userId)
            }
        }
    } // end of removepost
    
}
