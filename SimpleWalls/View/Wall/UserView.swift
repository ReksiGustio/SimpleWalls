//
//  UserView.swift
//  SimpleWalls
//
//  Created by Reksi Gustio on 01/07/24.
//

import SwiftUI

struct UserView: View {
    @Binding var path: NavigationPath
    let user: PartialUser
    
    var body: some View {
        Button { path.append(user.id) } label: {
            HStack {
                Circle()
                    .fill(.gray)
                    .frame(width: 44, height: 44)
                    .padding(.trailing, 10)
                
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
    UserView(path: .constant(NavigationPath()), user: .example)
}
