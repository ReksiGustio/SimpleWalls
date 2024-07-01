//
//  WallsView.swift
//  SimpleWalls
//
//  Created by Reksi Gustio on 30/06/24.
//

import SwiftUI

struct WallsView: View {
    @ObservedObject var global: Global
    @State private var path = NavigationPath()
    @State private var viewState = ViewState.downloading
    @State private var posts = [Post]()
    @State private var selectedPost = -1
    @State private var deleteAlert = false
    
    var body: some View {
        NavigationStack(path: $path) {
            switch viewState {
            case .downloading:
                ProgressView()
                    .tint(.primary)
                    .onAppear {
                        viewState = .downloading
                        downloadPosts()
                    }
            case .downloaded:
                ScrollViewReader { proxy in
                    VStack {
                        
                        ScrollView {
                            LazyVStack {
                                
                                HStack {
                                    Button {
                                        path.append(global.userData.id)
                                    } label: {
                                        Text(global.userData.profile.name ?? "")
                                            .lineLimit(1)
                                            .font(.title3.bold())
                                            .frame(maxWidth: .infinity)
                                            .modifier(CustomButton(paddingSize: 7))
                                    }
                                    
                                    Button {
                                        path.append("Search")
                                    } label: {
                                        Image(systemName: "magnifyingglass")
                                    }
                                    .modifier(CustomButton(paddingSize: 10))
                                    
                                    Button {
                                        posts = []
                                        viewState = .downloading
                                    } label: {
                                        Image(systemName: "arrow.circlepath")
                                    }
                                    .modifier(CustomButton(paddingSize: 10))
                                }
                                .id("topView")
                                .padding(.vertical, 5)
                                
                                ForEach(posts) { post in
                                    PostView(global, post: post, author: post.author ?? .example, path: $path)
                                        .contextMenu {
                                            if post.author?.id == global.userData.id {
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
                                        .padding(.bottom, 10)
                                } // end of foreach
                            } // end of lazyvstack
                            
                            //end post marker
                            if posts.count > 19 {
                                Color.secondary
                                    .frame(height: 1)
                                    .onAppear { downloadPosts() }
                            }
                            
                        } // end of scrollview
                        .scrollIndicators(.hidden)
                        
                    } // end of vstack
                    .padding()
                    .onDisappear {
                        viewState = .downloading
                        posts = []
                    }
                    
                    HStack {
                        NavigationLink { 
                            NewPostView(global) { post in
                                posts.insert(post, at: 0)
                            }
                        } label: {
                            Text("Write new post")
                                .frame(maxWidth: .infinity)
                                .modifier(CustomButton(paddingSize: 10))
                        } // end of navlink
                        
                        Button {
                            withAnimation { proxy.scrollTo("topView") }
                        } label: {
                            Image(systemName: "arrow.up")
                                .modifier(CustomButton(paddingSize: 11))
                        }
                    } // end of hstack
                    .padding(.bottom, 5)
                    .padding(.horizontal, 20)
                    .navigationTitle("SimpleWalls")
                    .navigationDestination(for: Int.self) { userId in
                        ProfileView(global, userId: userId, path: $path)
                    }
                    .navigationDestination(for: Int.self) { _ in
                        SearchPostView(path: $path)
                    }
                    .navigationDestination(for: Post.self) { post in
                        DetailPostView(global, postId: post.id, authorId: post.authorId, commentTapped: tapped, path: $path)
                    }
                    .alert("Delete your post?", isPresented: $deleteAlert) {
                        Button("Delete", role: .destructive) { removePost(postId: selectedPost) }
                        Button("Cancel", role: .cancel) { selectedPost = -1 }
                    } message: {
                        Text("Deleted post can't be recovered")
                    }
                    
                } // end of scrollviewReader
            case .failed:
                Button { 
                    viewState = .downloading
                    downloadPosts()
                } label: {
                    Label("Try again", systemImage: "arrow.circlepath")
                }
            } // end if
            
        } // end of navstack
    } // end of body
    
    init(_ global: Global) {
        self.global = global
    }
    
}

#Preview {
    WallsView(Global())
}

//function and computed properties here
extension WallsView {
    
    var tapped: Bool { global.commentTapped }
    
    func downloadPosts() {
        print("downloading posts")
        
        Task {
            let response = await findPosts(posts.count)
            
            //get data success
            if let data = try? JSONDecoder().decode(ResponseData<[Post]>.self, from: response) {
                for post in data.data {
                    if posts.contains(where: { $0.id == post.id }) {
                        continue
                    } else {
                        posts.append(post)
                    }
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    viewState = .downloaded
                }
            } else {
                print("error handling")
                viewState = .failed
            }
        }
    } // end of downloadpost
    
    func removePost(postId: Int) {
        global.message = ""
        global.timer.upstream.connect().cancel()
        
        Task {
            let response = await deletePost(postId: postId)
            
            //get data success
            global.errorHandling(response: response)
            if global.message.hasPrefix("Deleted") {
                selectedPost = -1
                removeUserPost(postId)
            }
        }
    } // end of removepost
    
    func removeUserPost(_ id: Int) {
        if let index = posts.firstIndex(where: { $0.id == id }) {
            posts.remove(at: index)
        }
    } // end of remove post
}
