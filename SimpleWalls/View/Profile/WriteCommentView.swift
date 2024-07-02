//
//  WriteCommentView.swift
//  SimpleWalls
//
//  Created by Reksi Gustio on 28/06/24.
//

import PhotosUI
import SwiftUI

struct WriteCommentView: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var global: Global
    @FocusState private var isFocused
    
    @State private var text = ""
    @State private var imageURL: String?
    @State private var pickedItem: PhotosPickerItem?
    @State private var picture: Data?
    @State private var displayPicture: Image?
    @State private var showProgress = false
    
    let postId: Int
    let commentTapped: Bool
    var sent: (Comment) -> Void
    var customColor: Color {
        colorScheme == .dark
            ? Color(red: 0.1, green: 0.1, blue: 0.2)
            : Color(red: 0.9, green: 0.9, blue: 0.9)
    }
    
    var body: some View {
        if let image = displayPicture {
            HStack {
                image
                    .resizable()
                    .scaledToFit()
                    .frame(width: 44, height: 44)
                    .overlay (
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(.primary)
                    )
                
                Text("Attached image")
                    .padding(.horizontal)
                
                Spacer()
                
                Button {
                    picture = nil
                    displayPicture = nil
                } label: {
                    Image(systemName: "xmark.circle")
                        .font(.title)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.vertical, 5)
            .padding(.horizontal)
            .background(customColor)
        }
        
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
                    PhotosPicker(selection: $pickedItem) {
                        Image(systemName: "photo")
                    } // end of photopicker
                    .padding(.trailing, 10)
                    .onChange(of: pickedItem) { _ in loadImage() }
                    
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
        let id = UUID().uuidString
        global.timer.upstream.connect().cancel()
        
        if picture != nil {
            imageURL = "http://172.20.57.25:3000/download/comment/commentId-\(id)-comment_pic.jpg"
            print("upload image")
            Task {
                await uploadRequest(image: picture ?? Data(), fieldName: "comment", id: "\(id)")
            }
        } else {
            imageURL = nil
        }
        
        Task {
            let response = await uploadComment(text: text, imageURL: imageURL, postId: postId, userId: global.userData.id)
            global.errorHandling(response: response)
            if global.message.hasPrefix("You ") {
                print("comment successfully")
                sent(Comment(id:.random(in: 9999...99999), text: text, imageURL: imageURL, likes: [], createdAt: "", updatedAt: "", userId: global.userData.id, postId: postId))
                text = ""
                imageURL = nil
                picture = nil
                displayPicture = nil
            }
            showProgress = false
        }
    } // end of newcomment
    
    func loadImage() {
        Task {
            guard let imageData = try await pickedItem?.loadTransferable(type: Data.self) else { return }
            guard let inputImage = UIImage(data: imageData) else { return }
            
            //load image to view
            
            //store image to binary data
            if let thumbnail = inputImage.preparingThumbnail(of: CGSize(width: 256, height: 256)) {
                picture = thumbnail.jpegData(compressionQuality: 1.0)
                UserDefaults.standard.setValue(picture, forKey: "userId:\(global.userData.id)")

                if let compressedUIImage = UIImage(data: picture ?? Data()) {
                    displayPicture = Image(uiImage: compressedUIImage)
                }
            }
        }
    } // end of load image
}
