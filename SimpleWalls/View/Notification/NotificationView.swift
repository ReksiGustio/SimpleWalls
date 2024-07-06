//
//  NotificationView.swift
//  SimpleWalls
//
//  Created by Reksi Gustio on 05/07/24.
//

import SwiftUI

struct NotificationView: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var global: Global
    @State private var path = NavigationPath()
    @State private var viewState = ViewState.downloading
    @State private var notifications = [Notification_]()
    @State private var picture: Data?
    
    var body: some View {
        NavigationStack(path: $path) {
            switch viewState {
            case .downloading:
                ProgressView()
                    .tint(.primary)
                    .onAppear {
                        viewState = .downloading
                        downloadNotifications()
                    }
            case .downloaded:
                ScrollView {
                    ZStack {
                        if !notifications.isEmpty {
                            Rectangle()
                                .fill(displayColor)
                        }
                        
                        LazyVStack {
                            Color.clear
                                .frame(width: 1, height: 1)
                                .padding(.bottom, 7)
                            
                            ForEach(notifications) { notification in
                                SingleView(global, notification: notification, path: $path)
                                    .padding(.horizontal)
                                    .padding(.bottom, 7)
                            }
                            
                        } // end of lazyvstack
                    } // end of zstack
                } // end of scrollview
                .navigationTitle("Notifications")
                .navigationDestination(for: Int.self) { userId in
                    ProfileView(global, userId: userId, path: $path)
                }
                .navigationDestination(for: Post.self) { post in
                    DetailPostView(global, postId: post.id, authorId: post.authorId, commentTapped: tapped, path: $path)
                }
                .toolbar {
                    Button {
                        notifications = []
                        viewState = .downloading
                    } label: {
                        Label("refresh", systemImage: "arrow.circlepath")
                    }
                }
            case .failed:
                Button {
                    viewState = .downloading
                    downloadNotifications()
                } label: {
                    Label("Try again", systemImage: "arrow.circlepath")
                }
            } // end of switch
        } // end of navstack
    } // end of body
    
    init(_ global: Global) {
        self.global = global
    }
}

#Preview {
    NotificationView(Global())
}

//function and computed properties here
extension NotificationView {
    
    var tapped: Bool { global.commentTapped }
    
    var displayColor: Color {
        if colorScheme == .light {
            Color(red: global.customBackground["light"]?.red ?? 0.9,
                  green: global.customBackground["light"]?.green ?? 0.9,
                  blue: global.customBackground["light"]?.blue ?? 0.9)
        } else {
            Color(red: global.customBackground["dark"]?.red ?? 0.1,
                  green: global.customBackground["dark"]?.green ?? 0.1,
                  blue: global.customBackground["dark"]?.blue ?? 0.1)
        }
    }
    
    func downloadNotifications() {
        print("downloading notifications")
        
        Task {
            let response = await fetchNotifications(startPoint: notifications.count)
            
            //get data success
            if let data = try? JSONDecoder().decode(ResponseData<[Notification_]>.self, from: response) {
                for notification in data.data {
                    if notifications.contains(where: { $0.id == notification.id }) {
                        continue
                    } else {
                        notifications.append(notification)
                    }
                }
                
                viewState = .downloaded
            } else {
                print("error handling")
                viewState = .failed
            }
        }
    }
}
