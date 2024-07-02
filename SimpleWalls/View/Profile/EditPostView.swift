//
//  EditPostView.swift
//  SimpleWalls
//
//  Created by Reksi Gustio on 02/07/24.
//

import SwiftUI

struct EditPostView: View {
    @ObservedObject var global: Global
    @Environment(\.dismiss) var dismiss
    @FocusState private var isFocused
    @State private var validationMessage = ""
    
    @State private var title: String
    @State private var isPublic: Bool
    @State private var picture: Data?
    @State private var showProgress = false
    
    var post: Post
    var displayPicture: Image?
    var sentPost: (Post) -> Void
    
    var body: some View {
        ZStack {
            ScrollView {
                LazyVStack(alignment: .leading) {
                    
                    Picker(isPublic ? "Public" : "Private", selection: $isPublic) {
                        Text("Public").tag(true)
                        Text("Private").tag(false)
                    }
                    .tint(.primary)
                    .padding(.horizontal, 8)
                    .overlay (
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(lineWidth: 1)
                    )
                    
                    
                    TextField("Write something here", text: $title, axis: .vertical)
                        .focused($isFocused)
                        .padding(.vertical, 20)
                    
                    Text(validationMessage)
                        .foregroundStyle(.red)
                        .padding(.vertical, 20)
                    
                    if let displayPicture {
                        ZStack {
                            Color.secondary
                            
                            displayPicture
                                .resizable()
                                .scaledToFill()
                        }
                        .frame(maxHeight: 400)
                        .clipped()
                        .contentShape(Rectangle())
                    }
                    
                    Spacer()
                    
                } // end of vstack
                .padding()
                .navigationTitle("Edit post")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button { validate() } label: {
                            Label("Send", systemImage: "paperplane.fill")
                        }
                    }
                    
                    ToolbarItem(placement: .keyboard) {
                        HStack {
                            Spacer()
                            Button("Done") { isFocused = false }
                        }
                    }
                }
                
                if showProgress {
                    Color.primary
                        .opacity(0.4)
                        .ignoresSafeArea()
                    
                    ProgressView()
                        .controlSize(.large)
                        .tint(.white)
                }
            } // end of scrollview
        } // end of zstack
        .disabled(showProgress)
    } // end of body
    
    init(_ global: Global, post: Post, sentPost: @escaping (Post) -> Void) {
        self.global = global
        self.post = post
        self.sentPost = sentPost
        
        _title = State(initialValue: post.title ?? "")
        _isPublic = State(initialValue: post.published)
        _picture = State(initialValue: UserDefaults.standard.data(forKey: "postId:\(post.id)") ?? nil)
        
        if let picture {
            if let UIImage = UIImage(data: picture) {
                displayPicture = Image(uiImage: UIImage)
            }
        }

    }
    
    func sendPost(title: String?, published: Bool) {
        global.timer.upstream.connect().cancel()
        
        Task {
            let response = await updatePost(id: post.id, title: title, published: published)
            global.errorHandling(response: response)
            if global.message.hasPrefix("Post") {
                var post = post
                post.title = title
                sentPost(post)
                dismiss()
            }
            showProgress = false
            
            //dismiss validation here
        }
    } // end of sendpost
    
}

#Preview {
    EditPostView(Global(), post: .example) { _ in }
}

//function and computed properties here
extension EditPostView {
    func validate() {
        let text = title.trimmingCharacters(in: .whitespacesAndNewlines)
        if text.isEmpty && picture == nil {
            validationMessage = "You need at least write a text or add picture to post"
            return
        }
        
        isFocused = false
        showProgress = true
        validationMessage = ""
        sendPost(title: title, published: isPublic)
    }
    
}
