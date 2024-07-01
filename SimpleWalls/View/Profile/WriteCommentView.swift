//
//  WriteCommentView.swift
//  SimpleWalls
//
//  Created by Reksi Gustio on 28/06/24.
//

import PhotosUI
import SwiftUI

struct WriteCommentView: View {
    @ObservedObject var global: Global
    @FocusState private var isFocused
    
    @State private var text = ""
    @State private var pickedItem: PhotosPickerItem?
    @State private var picture: Data?
    @State private var displayPicture: Image?
    @State private var showProgress = false
    
    let postId: Int
    let commentTapped: Bool
    var sent: (Comment) -> Void
    
    var body: some View {
        HStack(alignment: .bottom) {
            TextField("Write comment", text: $text, axis: .vertical)
                .focused($isFocused)
            
            Spacer()
            
            if showProgress {
                ProgressView()
                    .tint(.primary)
                    .padding(.trailing, 10)
            } else {
                HStack(alignment: .bottom) {
                    Button { } label: {
                        Image(systemName: "photo")
                    }
                    .padding(.trailing, 10)
                    
                    Button { validate() } label: {
                        Image(systemName: "paperplane")
                    }
                    .padding(.trailing, 10)
                } // end of hstack
                .tint(.primary)
            } // end if
            
        } // end of hstack
        .modifier(CustomTextField(radius: 30))
        .disabled(showProgress == true)
        .onAppear {
            if commentTapped { isFocused = true }
        }
        .toolbar {
            ToolbarItem(placement: .keyboard) {
                HStack {
                    Button("Discard") { text = "" }.tint(.red)
                    Spacer()
                    Button("Done") { isFocused = false }
                }
            }
        }
    } // end of body
    
    init(_ global: Global, postId: Int, commentTapped: Bool, sent: @escaping (Comment) -> Void) {
        self.global = global
        self.postId = postId
        self.commentTapped = commentTapped
        self.sent = sent
    }
}

#Preview {
    WriteCommentView(Global(), postId: 1, commentTapped: false) { _ in }
}

//function and computed properties here
extension WriteCommentView {
    func validate() {
        let text = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if text.isEmpty && picture == nil {
            return
        }
        
        isFocused = false
        showProgress = true
        newComment()
    }
    
    func newComment() {
        global.timer.upstream.connect().cancel()
        if picture == nil {
            Task {
                let response = await uploadComment(text: text, imageURL: nil, postId: postId, userId: global.userData.id)
                global.errorHandling(response: response)
                if global.message.hasPrefix("You ") {
                    print("comment successfully")
                    sent(Comment(id:.random(in: 9999...99999), text: text, imageURL: nil, likes: [], createdAt: "", updatedAt: "", userId: global.userData.id, postId: postId))
                    text = ""
                }
                showProgress = false
            }
        }
    }
}
