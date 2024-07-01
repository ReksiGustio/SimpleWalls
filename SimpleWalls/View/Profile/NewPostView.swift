//
//  NewPostView.swift
//  SimpleWalls
//
//  Created by Reksi Gustio on 26/06/24.
//

import PhotosUI
import SwiftUI

struct NewPostView: View {
    @ObservedObject var global: Global
    @Environment(\.dismiss) var dismiss
    @FocusState private var isFocused
    
    @State private var title = ""
    @State private var validationMessage = ""
    @State private var isPublic = true
    
    @State private var pickedItem: PhotosPickerItem?
    @State private var picture: Data?
    @State private var displayPicture: Image?
    
    @State private var showProgress = false
    var sentPost: (Post) -> Void
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading) {
                
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
                
                Button("Add Picture") {  }
                    .buttonStyle(BorderedProminentButtonStyle())
                
                Spacer()
                
            } // end of vstack
            .padding()
            .navigationTitle("Create new post")
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
            
        } // end of zstack
        .disabled(showProgress)
    } // end of body
    
    init(_ global: Global, sentPost: @escaping (Post) -> Void) {
        self.global = global
        self.sentPost = sentPost
    }
    
}

#Preview {
    NewPostView(Global()) { _ in }
}

//function and computed properties here
extension NewPostView {
    
    func validate() {
        let text = title.trimmingCharacters(in: .whitespacesAndNewlines)
        if text.isEmpty && picture == nil {
            validationMessage = "You need at least write a text or add picture to post"
            return
        }
        
        isFocused = false
        showProgress = true
        validationMessage = ""
        sendPost(title: title, published: isPublic, picture: picture)
    }
    
    func sendPost(title: String?, published: Bool, picture: Data?) {
        global.timer.upstream.connect().cancel()
        if picture == nil {
            Task {
                let response = await uploadPost(title: title, published: published, imageURL: nil)
                global.errorHandling(response: response)
                if global.message.hasPrefix("Posted") { 
                    sentPost(Post(id: 99999, title: title, imageURL: nil, likes: [], createdAt: "", updatedAt: "", published: isPublic, authorId: global.userData.id, author: PartialUser(id: global.userData.id, userName: global.userData.userName, profile: global.userData.profile)))
                    dismiss()
                }
                showProgress = false
                
                //dismiss validation here
            }
        }
    } // end of sendpost
    
}
