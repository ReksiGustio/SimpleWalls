//
//  ProfileView.swift
//  SimpleWalls
//
//  Created by Reksi Gustio on 24/06/24.
//

import SwiftUI

struct ProfileView: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var global: Global
    @Binding var path: NavigationPath
    let userId: Int
    
    @State private var viewState = ViewState.downloading
    @State private var user = User.example
    @State private var selectedPost = -1
    @State private var deleteAlert = false
    @State private var picture: Data?
    
    var body: some View {
        switch viewState {
        case .downloading:
            ProgressView()
                .tint(.primary)
                .onAppear {
                    downloadUser(userId)
                    //download image
                }
        case .downloaded:
            ScrollView {
                VStack {
                    VStack(alignment: .center) {
                        Button {
                            global.imageData = picture ?? Data()
                            global.showImage = true
                        } label: {
                            ProfilePictureView(global: global, data: picture, imageURL: user.profile.profilePicture, frameSize: 128)
                        }
                        
                        if userId != global.userData.id {
                            Button(isFollowed ? "Unfollow" : "Follow") {
                                isFollowed ? unfollow() : follow()
                            }
                            .buttonStyle(BorderedProminentButtonStyle())
                        } // end if
                        
                        Text(name)
                            .font(.title3.bold())
                        
                        Text(bio)
                            .lineLimit(4)
                        
                        HStack {
                            Button { 
                                if user.following.count > 0 {
                                    path.append(user.following)
                                }
                            } label: {
                                VStack {
                                    Text("Following").font(.headline)
                                    Text("\(user.following.count)").font(.title3.bold())
                                }
                            }
                            .padding(.horizontal)
                            
                            Button { 
                                if user.follower.count > 0 {
                                    path.append(user.follower)
                                }
                            } label: {
                                VStack {
                                    Text("Follower").font(.headline)
                                    Text("\(user.follower.count)").font(.title3.bold())
                                }
                            }
                            .padding(.horizontal)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.vertical, 5)
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
                    
                    ZStack {
                        Rectangle()
                            .fill(displayColor)
                        
                        LazyVStack {
                            Rectangle()
                                .fill(.clear)
                                .padding(.top, 5)
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
                                            .background(Color(uiColor: .systemBackground))
                                            .clipShape(.rect(cornerRadius: 10))
                                            .overlay (
                                                RoundedRectangle(cornerRadius: 10)
                                                    .stroke(lineWidth: 1)
                                            )
                                            .tint(.primary)
                                    } // end of navlink
                                    .padding(.top, 10)
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
                                                
                                                NavigationLink {
                                                    EditPostView(global, post: post) { _ in
                                                        viewState = .downloading
                                                    }
                                                } label: {
                                                    Label("Edit post", systemImage: "pencil")
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
                        } // end of lazyvstack
                    } // end of zstack
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
        _picture = State(initialValue: UserDefaults.standard.data(forKey: "userId:\(global.userData.id)") ?? nil)
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
    
    var displayColor: Color {
        if colorScheme == .light {
            Color(red: global.customBackground["light"]?.red ?? 0.9,
                  green: global.customBackground["light"]?.green ?? 0.9,
                  blue: global.customBackground["light"]?.blue ?? 0.9)
        } else {
            Color(red: global.customBackground["dark"]?.red ?? 0.1,
                  green: global.customBackground["dark"]?.green ?? 0.1,
                  blue: global.customBackground["dark"]?.blue ?? 0.1)
        }
    }
    
    var isFollowed: Bool {
        guard let index = global.userData.following.firstIndex(where: { $0.id == user.id }) else { return false }
        
        if user.id == global.userData.following[index].id {
            return true
        } else {
            return false
        }
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
    
    func follow() {
        global.message = ""
        global.timer.upstream.connect().cancel()
        
        Task {
            let response = await followUser(id: user.id, displayName: name, imageURL: profile.profilePicture)
            
            //get data success
            if let data = try? JSONDecoder().decode(ResponseData<Follow>.self, from: response) {
                let profile = global.userData.profile
                global.userData.following.append(data.data)
                user.follower.append(Follow(id: global.userData.id, displayName: profile.name, imageURL: profile.profilePicture, userId: user.id))
            } else {
                print("error handling")
                global.errorHandling(response: response)
                viewState = .failed
            }
        }
    } // end of follow
    
    func unfollow() {
        global.message = ""
        global.timer.upstream.connect().cancel()
        
        Task {
            let response = await unfollowUser(userId: user.id)
            
            //get data success
            global.errorHandling(response: response)
            if global.message.hasPrefix("Unfollow") {
                global.showMessage = false
                global.userData.following.removeAll(where: { $0.id == user.id })
                user.follower.removeAll(where: { $0.id == global.userData.id })
            }
        }
    } // end of removepost
}
