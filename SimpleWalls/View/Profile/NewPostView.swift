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
    @State private var pictureURL: String?
    
    @State private var sharedPost: Post?
    
    @State private var showProgress = false
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
                    
                    if isSharingPost {
                        Text("Attached post").foregroundStyle(.secondary)
                        if let sharedPost {
                            SharedPostView(global, post: sharedPost, author: sharedPost.author ?? .example, path: .constant(NavigationPath()), postId: nil)
                                .disabled(true)
                        }
                    }
                    
                    if let displayPicture {
                        ZStack {
                            Color.secondary
                            
                            Button {
                                global.imageData = picture ?? Data()
                                global.showImage = true
                            } label: {
                                displayPicture
                                    .resizable()
                                    .scaledToFill()
                            }
                        }
                        .frame(maxHeight: 400)
                        .clipped()
                        .contentShape(Rectangle())
                    }
                    
                    HStack {
                        PhotosPicker(selection: $pickedItem) {
                            Text(displayPicture != nil ? "Change Picture" : "Add Picture")
                        } // end of photopicker
                        .onChange(of: pickedItem) { _ in loadImage() }
                        
                        if displayPicture != nil {
                            Button("Remove") { displayPicture = nil }
                        }
                    }
                    .buttonStyle(BorderedProminentButtonStyle())
                    .disabled(isSharingPost)
                    .padding(.vertical)
                    
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
            } // end of scrollview
        } // end of zstack
        .disabled(showProgress)
    } // end of body
    
    init(_ global: Global, sharedPost: Post? = nil, sentPost: @escaping (Post) -> Void) {
        self.global = global
        self.sharedPost = sharedPost
        self.sentPost = sentPost
        
        if let sharedPost {
            _pictureURL = State(initialValue: "\(sharedPost.id)")
        }
    }
    
}

#Preview {
    NewPostView(Global(), sharedPost: .example) { _ in }
}

//function and computed properties here
extension NewPostView {
    
    var isSharingPost: Bool {
        guard let pictureURL else { return false }
        if pictureURL.hasPrefix("http") {
            return false
        } else {
            return true
        }
    }
    
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
        let id = UUID().uuidString
        
        if picture != nil {
            pictureURL = "http://172.20.57.25:3000/download/post/postId-\(id)-post_pic.jpg"
            print("upload image")
            Task {
                await uploadRequest(image: picture ?? Data(), fieldName: "post", id: "\(id)")
            }
        }
        
        Task {
            let response = await uploadPost(title: title, published: published, imageURL: pictureURL)
            global.errorHandling(response: response)
            if global.message.hasPrefix("Posted") {
                sentPost(Post(id: 99999, title: title, imageURL: pictureURL, likes: [], createdAt: "", updatedAt: "", published: isPublic, authorId: global.userData.id, author: PartialUser(id: global.userData.id, userName: global.userData.userName, profile: global.userData.profile)))
                dismiss()
            }
            showProgress = false
            
            //dismiss validation here
        }
    } // end of sendpost
    
    func loadImage() {
        Task {
            guard let imageData = try await pickedItem?.loadTransferable(type: Data.self) else { return }
            guard let inputImage = UIImage(data: imageData) else { return }
            
            //load image to view
            
            //store image to binary data
            if let thumbnail = inputImage.preparingThumbnail(of: CGSize(width: 512, height: 512)) {
                picture = thumbnail.jpegData(compressionQuality: 0.5)
                UserDefaults.standard.setValue(picture, forKey: "userId:\(global.userData.id)")

                if let compressedUIImage = UIImage(data: picture ?? Data()) {
                    displayPicture = Image(uiImage: compressedUIImage)
                }
            }
        }
    } // end of load image
    
}
