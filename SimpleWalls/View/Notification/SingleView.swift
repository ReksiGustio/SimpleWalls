//
//  SingleView.swift
//  SimpleWalls
//
//  Created by Reksi Gustio on 05/07/24.
//

import SwiftUI

struct SingleView: View {
    @ObservedObject var global: Global
    @Binding var path: NavigationPath
    @State private var displayPicture: Image?
    @State private var picture: Data?
    @State private var notification: Notification_
    
    var body: some View {
        Button { 
            if let postId = notification.postId {
                global.commentTapped = false
                Task {
                    let response = await postById(postId)
                    if let data = try? JSONDecoder().decode(ResponseData<Post>.self, from: response) {
                        path.append(data.data)
                    }
                }
            } else {
                path.append(notification.userId)
            }
            Task { 
                let _ = await updateNotification(id: notification.id)
                notification.read = true
            }
        } label: {
            HStack(alignment: .top) {
                ProfilePictureView(global: global, data: picture, imageURL: notification.userImage, frameSize: 44)
                    .padding(.trailing, 10)
                
                VStack(alignment: .leading) {
                    Text(notification.object)
                        .multilineTextAlignment(.leading)
                        .lineLimit(3)
                        .fontWeight(notification.read ? .regular : .semibold)
                    
                    Text(postDate).foregroundStyle(.secondary)
                }
                
                Spacer()
            }
            .padding()
            .background(Color(uiColor: .systemBackground))
            .clipShape(.rect(cornerRadius: 10))
            .overlay (
                RoundedRectangle(cornerRadius: 10)
                    .stroke(notification.read ? .primary : Color.blue)
            )
        }
        .contentShape(Rectangle())
        .buttonStyle(PlainButtonStyle())
    }
    
    init(_ global: Global, notification: Notification_, path: Binding<NavigationPath>) {
        self.global = global
        _notification = State(initialValue: notification)
        _path = path
    }
}

#Preview {
    SingleView(Global(), notification: .example, path: .constant(NavigationPath()))
}

//function and computed properties here
extension SingleView {
    var postDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        
        let date = formatter.date(from: notification.createdAt) ?? .now
        
        let relativeFormatter = RelativeDateTimeFormatter()
        relativeFormatter.unitsStyle = .abbreviated
        
        let relativeDate = relativeFormatter.localizedString(for: date, relativeTo: .now)
        
        return relativeDate
    }
}
