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
    @FocusState private var isFocused
    @State private var displayName: String
    @State private var bio: String
    
    @State private var pickedItem: PhotosPickerItem?
    
    @State private var pictureURL: String?
    @State private var displayPicture: Image?
    @State private var picture: Data?
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Profile Picture").font(.title3.bold())
            Divider()
            
            ZStack {
                
                PhotosPicker(selection: $pickedItem) {
                    if let displayPicture {
                        displayPicture
                            .resizable()
                            .scaledToFill()
                            .frame(width: 128, height: 128)
                            .clipShape(.circle)
                    } else {
                        ProfilePictureView(global: global, image: displayPicture, data: picture, imageURL: profile.profilePicture, frameSize: 128)
                    }
                } // end of photopicker
                .onChange(of: pickedItem) { _ in loadImage() }
                .buttonStyle(PlainButtonStyle())
                .padding()
            } // end of vstack
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
        _picture = State(initialValue: UserDefaults.standard.data(forKey: "userId:\(global.userData.id)") ?? nil)
    }
}

#Preview {
    EditProfileView(Global(), profile: .example)
}

//function and computed properties here
extension EditProfileView {
    
    func save() {
        isFocused = false
        global.loadingState = .loading
        global.timer.upstream.connect().cancel()
        

        Task {
            if picture != nil {
                pictureURL = "http://172.20.57.25:3000/download/profile/userId-\(global.userData.id)-profile_pic.jpg"
                print("upload image")
                await uploadRequest(image: picture ?? Data(), fieldName: "profile", id: "\(global.userData.id)")
            } else {
                pictureURL = nil
            }
            print("update status")
            let response = await updateStatus(name: displayName, bio: bio, profilePicture: pictureURL)
            global.errorHandling(response: response)
            global.loadingState = .loaded
        }
        UserDefaults.standard.setValue(picture, forKey: "userId:\(global.userData.id)")
        
    } // end of loginUser
    
    func loadImage() {
        picture = nil
        
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
