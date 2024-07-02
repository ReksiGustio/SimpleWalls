//
//  UserView.swift
//  SimpleWalls
//
//  Created by Reksi Gustio on 01/07/24.
//

import SwiftUI

struct UserView: View {
    @ObservedObject var global: Global
    @Binding var path: NavigationPath
    @State private var displayPicture: Image?
    @State private var picture: Data?
    let user: PartialUser
    
    var body: some View {
        Button { path.append(user.id) } label: {
            HStack {
                ProfilePictureView(global: global, data: picture, imageURL: user.profile.profilePicture, frameSize: 44)
                
                Text(user.profile.name ?? "")
                    .font(.title3.weight(.semibold))
                
                Spacer()
            }
            .padding()
            .overlay (
                RoundedRectangle(cornerRadius: 10)
                    .stroke(.primary)
            )
        }
        .contentShape(Rectangle())
        .buttonStyle(PlainButtonStyle())
    } // end of body
}

#Preview {
    UserView(global: Global(), path: .constant(NavigationPath()), user: .example)
}
