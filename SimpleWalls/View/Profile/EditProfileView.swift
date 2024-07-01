//
//  EditProfileView.swift
//  SimpleWalls
//
//  Created by Reksi Gustio on 25/06/24.
//

import SwiftUI

struct EditProfileView: View {
    let global: Global
    let profile: Profile
    @Environment(\.dismiss) var dismiss
    @FocusState private var isFocused
    @State private var displayName: String
    @State private var bio: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Profile Picture").font(.title3.bold())
            Divider()
            
            VStack {
                Circle()
                    .fill(.gray)
                    .frame(width: 128, height: 128)
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
    func save() {
        isFocused = false
        global.loadingState = .loading
        global.timer.upstream.connect().cancel()
        Task {
            let response = await updateStatus(name: displayName, bio: bio, profilePicture: nil)
            global.errorHandling(response: response)
            global.loadingState = .loaded
            dismiss()
        }
    } // end of loginUser
}
