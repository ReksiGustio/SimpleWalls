//
//  SearchPostView.swift
//  SimpleWalls
//
//  Created by Reksi Gustio on 01/07/24.
//

import SwiftUI

struct SearchPostView: View {
    @Binding var path: NavigationPath
    @FocusState private var isFocused
    @State private var searchText = ""
    @State private var posts = [Post]()
    @State private var users = [PartialUser]()
    @State private var viewState = ViewState.downloaded
    
    var body: some View {
        VStack {
            
            HStack {
                TextField("Search post", text: $searchText)
                    .focused($isFocused)
                
                Spacer()
                Button { validate() } label: {
                    Image(systemName: "magnifyingglass")
                }
                .buttonStyle(PlainButtonStyle())
            } // end of hstack
            .modifier(CustomTextField())
            
            ScrollView {
                
                switch viewState {
                case .downloading:
                    ProgressView()
                        .tint(.primary)
                case .downloaded:
                    LazyVStack {
                        
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
    }
}

#Preview {
    SearchPostView(path: .constant(NavigationPath()))
}

//function and computed properties here
extension SearchPostView {
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
            let response = await searchRequest(textField: searchText)
            
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
            let response = await searchRequest(textField: searchText)
            
            //get data success
            if let data = try? JSONDecoder().decode(ResponseData<[Post]>.self, from: response) {
                posts = data.data
                
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
