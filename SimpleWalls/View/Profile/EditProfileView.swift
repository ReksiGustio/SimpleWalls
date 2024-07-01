//
//  EditProfileView.swift
//  SimpleWalls
//
//  Created by Reksi Gustio on 25/06/24.
//

import PhotosUI
import SwiftUI

struct EditProfileView: View {
    let global: Global
    let profile: Profile
    @Environment(\.dismiss) var dismiss
    @FocusState private var isFocused
    @State private var displayName: String
    @State private var bio: String
    
    @State private var pickedItem: PhotosPickerItem?
    @State private var picture: Data?
    @State private var pictureURL: String?
    @State private var displayPicture: Image?
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Profile Picture").font(.title3.bold())
            Divider()
            
            VStack {
                PhotosPicker(selection: $pickedItem) {
                    if let displayPicture {
                        displayPicture
                            .resizable()
                            .scaledToFill()
                            .frame(width: 128, height: 128)
                            .clipShape(.circle)
                    } else if let existingImage = global.loadImage(data: userImageData) {
                        existingImage
                            .resizable()
                            .scaledToFill()
                            .frame(width: 128, height: 128)
                            .clipShape(.circle)
                            .onAppear { picture = userImageData }
                    } else {
                        Circle()
                            .fill(.secondary)
                            .frame(width: 128, height: 128)
                    }
                } // end of photopicker
                .onChange(of: pickedItem) { _ in loadImage() }
                .buttonStyle(PlainButtonStyle())
                .padding()
            }
            .frame(maxWidth: .infinity)
            .padding(.bottom, 20)
            
            Text("Display Name").font(.title3.bold())
            Divider()
            
            TextField("Display name", text: $displayName)
                .focused($isFocused)
                .padding(.bottom, 20)
            
            Text("Bio").font(.title3.bold())
            Divider()
            
            TextField("No bio", text: $bio)
                .focused($isFocused)
                .padding(.bottom, 20)
            
            VStack {
                Button("Save changes") { save() }
                    .buttonStyle(BorderedProminentButtonStyle())
            }
            .frame(maxWidth: .infinity)
            .padding()
            
            Spacer()
        } // end of vstack
        .padding()
        .navigationTitle("Edit Profile")
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
    
    init(_ global: Global, profile: Profile) {
        self.global = global
        self.profile = profile
        
        _displayName = State(initialValue: profile.name ?? "")
        _bio = State(initialValue: profile.bio ?? "")
    }
}

#Preview {
    EditProfileView(Global(), profile: .example)
}

//function and computed properties here
extension EditProfileView {
    var findIndex: Int {
        if let index = global.imagesData.firstIndex(where: { $0.userId == global.userData.id }) {
            return index
        }
        
        return -1
    }
    
    var userImageData: Data {
        if let index = global.imagesData.firstIndex(where: { $0.userId == global.userData.id }) {
            return global.imagesData[index].data
        }
        
        return Data()
    }
    
    func save() {
        isFocused = false
        global.loadingState = .loading
        global.timer.upstream.connect().cancel()
        

        Task {
            if picture != nil {
                pictureURL = "http://localhost:3000/download/profile/\(global.userData.userName)-profile_pic.jpg"
                //upload image
                global.imagesData.append(ImageData(userId: global.userData.id, postId: nil, commentId: nil, data: picture ?? Data()))
            }
            let response = await updateStatus(name: displayName, bio: bio, profilePicture: pictureURL)
            global.errorHandling(response: response)
            global.loadingState = .loaded
            dismiss()
        }
        
    } // end of loginUser
    
    func loadImage() {
        Task {
            guard let imageData = try await pickedItem?.loadTransferable(type: Data.self) else { return }
            guard let inputImage = UIImage(data: imageData) else { return }
            
            //load image to view
            
            //store image to binary data
            if let thumbnail = inputImage.preparingThumbnail(of: CGSize(width: 256, height: 256)) {
                picture = thumbnail.jpegData(compressionQuality: 1.0)

                if let compressedUIImage = UIImage(data: picture ?? Data()) {
                    displayPicture = Image(uiImage: compressedUIImage)
                }
            }
        }
    } // end of load image
    
}
