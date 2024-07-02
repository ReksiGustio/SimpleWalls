//
//  SearchPostView.swift
//  SimpleWalls
//
//  Created by Reksi Gustio on 01/07/24.
//

import SwiftUI

struct SearchPostView: View {
    @ObservedObject var global: Global
    @Binding var path: NavigationPath
    @FocusState private var isFocused
    @State private var searchText = ""
    @State private var posts = [Post]()
    @State private var users = [PartialUser]()
    @State private var viewState = ViewState.downloaded
    @State private var searchState = SearchState.initial
    
    var body: some View {
        VStack {
            
            HStack {
                TextField("Search post or user", text: $searchText)
                    .focused($isFocused)
                
                Spacer()
                Button { validate() } label: {
                    Image(systemName: "magnifyingglass")
                }
                .buttonStyle(PlainButtonStyle())
            } // end of hstack
            .modifier(CustomTextField())
            
            ScrollView {
                
                if searchState != .empty && searchState != .initial {
                    Picker("", selection: $searchState) {
                        Text("Post").tag(SearchState.post)
                        Text("User").tag(SearchState.user)
                    }
                    .pickerStyle(.segmented)
                    .padding(.bottom, 10)
                }
                
                switch viewState {
                case .downloading:
                    ProgressView()
                        .tint(.primary)
                case .downloaded:
                    LazyVStack {
                        switch searchState {
                        case .user:
                            ForEach(users) { user in
                                UserView(global: global, path: $path, user: user)
                            }
                        case .post:
                            ForEach(posts) { post in
                                PostView(global, post: post, author: post.author ?? .example, path: $path)
                            }
                        case .empty:
                            VStack { 
                                Image(systemName: "xmark.circle")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 72, height: 72)
                                
                                Text("Not Found")
                            }
                            .foregroundStyle(.secondary)
                        case .initial:
                            VStack { }
                        }
                    } // end of lazyvstack
                case .failed:
                    Button { validate() } label: {
                        Label("Try again", systemImage: "arrow.circlepath")
                    }
                }
                
            } // end of scrollview
            .padding()
            
            Spacer()
            
        } // end of vstack
        .navigationTitle("Search Post")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .keyboard) {
                HStack {
                    Spacer()
                    Button("Done") { isFocused = false }
                }
            }
        }
        
    } // end of body
    
    init(_ global: Global, path: Binding<NavigationPath>) {
        self.global = global
        _path = path
    }
    
}

#Preview {
    SearchPostView(Global(), path: .constant(NavigationPath()))
}

//function and computed properties here
extension SearchPostView {
    enum SearchState {
        case user, post, empty, initial
    }
    
    func validate() {
        let text = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if text.isEmpty {
            return
        }
        
        isFocused = false
        viewState = .downloading
        users = []
        posts = []
        searchUsers()
    }
    
    func searchUsers() {
        print("searching users")
        
        Task {
            let response = await searchRequest("users", textField: searchText)
            
            //get data success
            if let data = try? JSONDecoder().decode(ResponseData<[PartialUser]>.self, from: response) {
                users = data.data
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    searchPosts()
                }
            } else {
                print("error handling")
                viewState = .failed
            }
        }
    } // end of downloadpost
    
    func searchPosts() {
        print("searching posts")
        
        Task {
            let response = await searchRequest("posts", textField: searchText)
            
            //get data success
            if let data = try? JSONDecoder().decode(ResponseData<[Post]>.self, from: response) {
                posts = data.data
                
                
                switch (posts.isEmpty, users.isEmpty) {
                case (true, false): searchState = .user
                case (false, _): searchState = .post
                case (true, true): searchState = .empty
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
    
}
